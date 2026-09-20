"""
serial_worker.py

Everything related to talking to the cutting machine over serial
(pyserial) lives here, kept separate from the UI code in main.py.

This assumes a GRBL-style controller (matches the "$H" homing command
already used elsewhere in this app). A few GRBL realtime commands are
used - these are single raw bytes GRBL always reacts to immediately,
regardless of whatever G-code line is currently being processed, which
is exactly why they're safe to send at any moment:

    0x18 ('\\x18', Ctrl-X)  -> soft reset. Used by the STOP button:
                               halts everything immediately and clears
                               the pending queue. Closest thing GRBL
                               has to an e-stop.
    '!'                     -> feed hold. Decelerates the axes to a
                               controlled stop. Used by Pause.
    '~'                     -> cycle start / resume. Releases a feed
                               hold. Used by Resume.
    '?'                     -> status report request. GRBL replies
                               with a line like "<Idle|...>" or
                               "<Alarm|...>". Used to show the
                               alarm indicator.

Ordinary G-code lines go through the normal line-by-line protocol:
send a line, wait for GRBL's "ok"/"error:<n>"/"ALARM:<n>" reply before
sending the next one. If the machine ever reports an error/alarm mid
-stream, we stop sending immediately instead of continuing to spam
more lines at it.

Sending happens on background QThreads so the app window never
freezes while G-code is streaming or a pause/resume heat command is
in flight.
"""

import time
import threading
import serial
from PySide6.QtCore import QObject, QThread, Signal

GRBL_SOFT_RESET_BYTE = b"\x18"   # Ctrl-X: soft reset (STOP button)
GRBL_FEED_HOLD_BYTE = b"!"       # feed hold (Pause button)
GRBL_CYCLE_START_BYTE = b"~"     # resume after a feed hold (Resume button)
GRBL_STATUS_QUERY_BYTE = b"?"    # request a status report (alarm indicator)

# How long to wait for a single line's "ok"/"error" reply before giving
# up. Homing ($H) and the reheat command can legitimately take a long
# time since GRBL/the firmware only replies once done, so this is
# generous.
LINE_TIMEOUT_SECONDS = 60

# How long to wait for a reply to a '?' status query. This should come
# back almost instantly, so a short timeout keeps the UI responsive
# while polling.
STATUS_QUERY_TIMEOUT_SECONDS = 0.3


class _StreamThread(QThread):
    """Sends a list of G-code lines, one at a time, waiting for GRBL's
    ok/error reply after each before sending the next."""

    line_sent = Signal(str)
    progress = Signal(int)  # absolute index (into the ORIGINAL full line list) just completed
    finished_job = Signal()
    error = Signal(str)

    def __init__(self, ser: serial.Serial, lock: threading.Lock, lines, start_index=0):
        super().__init__()
        self.ser = ser
        self.lock = lock
        self.lines = lines
        self.start_index = start_index
        self._abort = False

    def run(self):
        try:
            for offset, raw_line in enumerate(self.lines):
                if self._abort:
                    self.line_sent.emit("Zatrzymano przed zakończeniem.")
                    return

                line = raw_line.strip()
                if not line or line.startswith(";") or line.startswith("("):
                    continue  # skip blank lines and comments

                with self.lock:
                    self.ser.write((line + "\n").encode())
                self.line_sent.emit(f"> {line}")

                response = self._wait_for_ok_or_error()

                if self._abort:
                    self.line_sent.emit("Zatrzymano przed zakończeniem.")
                    return

                if response is None:
                    self.error.emit(
                        f"Maszyna nie odpowiedziała na linię w ciągu {LINE_TIMEOUT_SECONDS}s: {line}"
                    )
                    return

                self.line_sent.emit(f"< {response}")

                if response.lower().startswith(("error", "alarm")):
                    self.error.emit(f"Maszyna zgłosiła błąd dla linii „{line}”: {response}")
                    return

                self.progress.emit(self.start_index + offset + 1)

            self.finished_job.emit()
        except Exception as e:
            self.error.emit(f"Błąd komunikacji szeregowej: {e}")

    def _wait_for_ok_or_error(self):
        """
        Block until GRBL sends back a complete reply line containing
        "ok" or "error"/"alarm", or until LINE_TIMEOUT_SECONDS elapses.
        Uses readline() (newline-terminated), which is what GRBL's
        line-based protocol actually is.
        """
        deadline = time.time() + LINE_TIMEOUT_SECONDS
        while time.time() < deadline:
            if self._abort:
                return None
            raw = self.ser.readline()  # blocks up to self.ser.timeout (set in connect())
            if not raw:
                continue  # readline timed out with no data yet; keep waiting
            text = raw.decode(errors="ignore").strip()
            if not text:
                continue
            low = text.lower()
            if low.startswith("ok") or low.startswith("error") or low.startswith("alarm"):
                return text
            # Anything else (startup banner, status reports, etc.) - show it
            # but keep waiting for the actual ok/error for this line.
            self.line_sent.emit(f"< {text}")
        return None

    def abort(self):
        self._abort = True


class SerialWorker(QObject):
    """Thin wrapper the UI talks to. Owns the serial port and the
    background streaming/utility threads."""

    line_sent = Signal(str)
    finished_job = Signal()
    error = Signal(str)
    paused = Signal()
    resumed = Signal()
    alarm_cleared = Signal()
    status_received = Signal(str)  # raw GRBL status report line

    def __init__(self, port: str, baud_rate: int):
        super().__init__()
        self.port = port
        self.baud_rate = baud_rate
        self.ser = None
        self._lock = threading.Lock()

        self._thread = None       # the main G-code stream thread
        self._util_thread = None  # short-lived thread for single utility lines (heat off/reheat/unlock)

        self._all_lines = []
        self._resume_index = 0

    # ------------------------------------------------------------------
    # Connection
    # ------------------------------------------------------------------
    def connect(self):
        # timeout=1 makes readline() return after 1s if nothing arrives,
        # so background threads can keep checking for abort/deadlines
        # instead of blocking forever.
        self.ser = serial.Serial(self.port, self.baud_rate, timeout=1)
        time.sleep(2)  # many controllers reset when the serial port opens

    def is_connected(self) -> bool:
        return self.ser is not None and self.ser.is_open

    def is_busy(self) -> bool:
        """True while a G-code stream or a pause/resume/unlock command
        is actively using the port. Status polling should be skipped
        while this is true."""
        def running(t):
            return bool(t and t.isRunning())
        return running(self._thread) or running(self._util_thread)

    def disconnect(self):
        for t in (self._thread, self._util_thread):
            if t and t.isRunning():
                t.abort()
                t.wait(2000)
        if self.ser:
            self.ser.close()
        self.ser = None

    # ------------------------------------------------------------------
    # Normal G-code streaming
    # ------------------------------------------------------------------
    def send_lines(self, lines):
        """Stream a list of G-code lines to the machine on a background thread."""
        if not self.is_connected():
            self.error.emit("Brak połączenia z maszyną.")
            return
        self._all_lines = list(lines)
        self._resume_index = 0
        self._start_stream_from(0)

    def _start_stream_from(self, start_index):
        remaining = self._all_lines[start_index:]
        self._thread = _StreamThread(self.ser, self._lock, remaining, start_index=start_index)
        self._thread.line_sent.connect(self.line_sent)
        self._thread.progress.connect(self._on_progress)
        self._thread.finished_job.connect(self.finished_job)
        self._thread.error.connect(self.error)
        self._thread.start()

    def _on_progress(self, absolute_index):
        self._resume_index = absolute_index

    # ------------------------------------------------------------------
    # Single-line utility commands (heat off, reheat, unlock) - reuse
    # the same line-protocol machinery as the main stream, just for one
    # line, with its own completion callbacks instead of the shared
    # finished_job/error signals (so callers can chain what happens
    # next without it being confused for the main job finishing).
    # ------------------------------------------------------------------
    def _send_single(self, line, on_ok, on_error):
        thread = _StreamThread(self.ser, self._lock, [line])
        thread.line_sent.connect(self.line_sent)
        thread.finished_job.connect(on_ok)
        thread.error.connect(on_error)
        self._util_thread = thread
        thread.start()

    # ------------------------------------------------------------------
    # Pause / Resume
    # ------------------------------------------------------------------
    def pause(self, heat_off_line: str):
        """
        Decelerate the axes (GRBL feed hold), stop sending further
        G-code lines (remembering where we left off), then turn the
        wire heater off.
        """
        if not self.is_connected():
            self.error.emit("Brak połączenia z maszyną.")
            return

        try:
            with self._lock:
                self.ser.write(GRBL_FEED_HOLD_BYTE)
                self.ser.flush()
        except Exception as e:
            self.error.emit(f"Nie udało się wysłać wstrzymania (feed hold): {e}")
            return

        if self._thread and self._thread.isRunning():
            self._thread.abort()
            self._thread.wait(2000)

        def on_ok():
            self.paused.emit()

        def on_error(msg):
            self.error.emit(msg)
            self.paused.emit()  # motion is already held even if the heater command failed

        self._send_single(heat_off_line, on_ok, on_error)

    def resume(self, reheat_line: str):
        """
        Reheat the wire (blocks until the firmware reports it's back up
        to temperature), release the feed hold, then continue sending
        G-code from wherever we paused.
        """
        if not self.is_connected():
            self.error.emit("Brak połączenia z maszyną.")
            return

        def on_ok():
            try:
                with self._lock:
                    self.ser.write(GRBL_CYCLE_START_BYTE)
                    self.ser.flush()
            except Exception as e:
                self.error.emit(f"Nie udało się wznowić (cycle start): {e}")
                return
            self.resumed.emit()
            self._start_stream_from(self._resume_index)

        def on_error(msg):
            self.error.emit(msg)

        self._send_single(reheat_line, on_ok, on_error)

    # ------------------------------------------------------------------
    # Emergency stop
    # ------------------------------------------------------------------
    def emergency_stop(self):
        """
        Immediately halt the machine: stop any in-progress line stream
        and send GRBL's realtime soft-reset byte directly (not a
        G-code line, so it isn't queued behind anything).
        """
        for t in (self._thread, self._util_thread):
            if t and t.isRunning():
                t.abort()
                t.wait(1500)  # let it release the port before we write
        if self.is_connected():
            try:
                with self._lock:
                    self.ser.write(GRBL_SOFT_RESET_BYTE)
                    self.ser.flush()
            except Exception as e:
                self.error.emit(f"Nie udało się wysłać polecenia STOP: {e}")

    # ------------------------------------------------------------------
    # Alarm status (indicator in the top-right corner)
    # ------------------------------------------------------------------
    def query_status(self):
        """
        Ask GRBL for a status report ('<Idle|...>', '<Alarm|...>', ...)
        and emit it via status_received. Only call this when is_busy()
        is False, or you risk reading a byte meant for an in-progress
        line/heater command instead.
        """
        if not self.is_connected() or self.is_busy():
            return
        old_timeout = self.ser.timeout
        try:
            self.ser.timeout = STATUS_QUERY_TIMEOUT_SECONDS
            with self._lock:
                self.ser.write(GRBL_STATUS_QUERY_BYTE)
                self.ser.flush()
                raw = self.ser.readline()
            if raw:
                text = raw.decode(errors="ignore").strip()
                if text:
                    self.status_received.emit(text)
        except Exception:
            pass  # best-effort background poll; don't interrupt the operator for this
        finally:
            try:
                self.ser.timeout = old_timeout
            except Exception:
                pass

    def clear_alarm(self):
        """Send GRBL's alarm-unlock command ($X)."""
        if not self.is_connected():
            self.error.emit("Brak połączenia z maszyną.")
            return

        def on_ok():
            self.alarm_cleared.emit()

        def on_error(msg):
            self.error.emit(msg)

        self._send_single("$X", on_ok, on_error)
