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
LINE_TIMEOUT_SECONDS = 600

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
        self._util_thread = None  # short-lived thread for single utility lines (heat off/reheat/unlock/terminal)
        self._util_purpose = None  # what the current/last utility thread was for: "pause"/"resume"/"unlock"/"terminal"

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
    # Single-line utility commands (heat off, reheat, unlock, terminal
    # input) - reuse the same line-protocol machinery as the main
    # stream, just for one line. Completion is reported through
    # _on_util_finished/_on_util_error below (purpose: "pause_heater",
    # "resume", "unlock", or "terminal") rather than passed-in
    # callbacks: those two are real bound methods of this QObject, so
    # Qt can tell they belong to the GUI thread and queues the call
    # properly when the utility thread (running in the background)
    # emits finished_job/error. A plain function or lambda passed
    # straight into connect() has no such thread affinity - Qt then
    # has no safe way to hand it off, and PySide just invokes it
    # directly on the background thread instead. That's exactly the
    # kind of bug that lets the underlying serial command genuinely
    # succeed while the signal meant to update the UI never reliably
    # reaches it - so every codepath below is routed through these two
    # slots instead of a closure.
    # ------------------------------------------------------------------
    def _send_single(self, line, purpose):
        self._util_purpose = purpose
        thread = _StreamThread(self.ser, self._lock, [line])
        thread.line_sent.connect(self.line_sent)
        thread.finished_job.connect(self._on_util_finished)
        thread.error.connect(self._on_util_error)
        self._util_thread = thread
        thread.start()

    def _on_util_finished(self):
        purpose, self._util_purpose = self._util_purpose, None
        if purpose == "pause_heater":
            # Just a confirmation for the log - the UI already flipped
            # to "paused" the moment the feed hold went out, in pause()
            # below, since that's the part that's actually instant and
            # guaranteed. This is a separate custom M-code your real
            # controller firmware understands; a bare test board running
            # stock GRBL won't recognize it, so don't gate the button on it.
            self.line_sent.emit("< Grzanie drutu wyłączone (potwierdzone).")
        elif purpose == "resume":
            try:
                with self._lock:
                    self.ser.write(GRBL_CYCLE_START_BYTE)
                    self.ser.flush()
            except Exception as e:
                self.error.emit(f"Nie udało się wznowić (cycle start): {e}")
                self.paused.emit()  # reheat's own "ok" arrived, but we still couldn't release the hold - stay in Wznów state
                return
            self.resumed.emit()
            self._start_stream_from(self._resume_index)
        elif purpose == "unlock":
            self.alarm_cleared.emit()
        # purpose == "terminal" (or unset): nothing further to do - the
        # line/ok reply was already shown via line_sent forwarding.

    def _on_util_error(self, msg):
        purpose, self._util_purpose = self._util_purpose, None
        self.error.emit(msg)
        if purpose == "resume":
            # Reheat failed or timed out (e.g. the controller doesn't
            # support this M-code at all) - the feed hold must stay in
            # place, so we're still paused. Re-emit paused so the button
            # goes back to an enabled "Wznów" instead of being stuck
            # disabled forever with no way to retry.
            self.paused.emit()
        # "pause_heater"/"unlock"/"terminal": error already reported
        # above; the pause/resume button's state was already settled
        # elsewhere and doesn't depend on this particular command.

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
            if not self._thread.wait(2000):
                # It didn't actually release the port in time - starting a
                # new thread now would mean two threads reading the same
                # serial port at once, which can make the new one wait
                # forever for a reply the old one already consumed.
                self.error.emit(
                    "Nie udało się zatrzymać wysyłania w czasie - wstrzymanie przerwane. "
                    "Spróbuj ponownie albo użyj STOP."
                )
                self.paused.emit()  # release the UI (feed hold was already sent, so re-enable Wznów)
                return

        # The feed hold above is a realtime GRBL command - it's already
        # in effect by the time we get here, so the machine genuinely
        # IS paused right now. Reflect that in the UI immediately rather
        # than waiting on the heater-off command below: that one depends
        # on your controller firmware supporting a custom M-code, can
        # legitimately take a moment, and on hardware that doesn't
        # support it (like a stock-GRBL test board) might never reply
        # at all - none of which should leave the operator stuck staring
        # at a disabled button.
        self.paused.emit()

        self._send_single(heat_off_line, purpose="pause_heater")

    def resume(self, reheat_line: str):
        """
        Reheat the wire (blocks until the firmware reports it's back up
        to temperature), release the feed hold, then continue sending
        G-code from wherever we paused.

        Unlike pause(), this one deliberately keeps the button disabled
        until the reheat is confirmed - resuming cutting motion before
        the wire is actually back up to temperature isn't safe to do
        unconditionally. If it fails or times out, _on_util_error above
        re-emits paused() so the button still recovers to a usable state.
        """
        if not self.is_connected():
            self.error.emit("Brak połączenia z maszyną.")
            return

        self._send_single(reheat_line, purpose="resume")

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

        self._send_single("$X", purpose="unlock")

    # ------------------------------------------------------------------
    # Manual terminal input (Ctrl+Shift+T panel)
    # ------------------------------------------------------------------
    def send_raw(self, text: str):
        """
        Send whatever the operator typed into the debug terminal.

        GRBL's four realtime single-character commands ('!', '~', '?',
        and soft-reset) are recognized and written straight to the
        port as raw bytes, exactly like the Pause/Resume/STOP buttons
        do - these are safe to send at any moment, even mid-job, so
        they skip the busy check entirely.

        Anything else is treated as an ordinary line (a G-code command,
        a '$' setting, etc.) and goes through the same one-line-at-a-
        time wait-for-ok/error protocol as every other line, via the
        existing single-line utility machinery. Since that shares the
        port with any in-progress job, it's only sent when the port
        isn't already busy.
        """
        text = text.strip()
        if not text:
            return
        if not self.is_connected():
            self.error.emit("Brak połączenia z maszyną.")
            return

        realtime_bytes = {
            "!": GRBL_FEED_HOLD_BYTE,
            "~": GRBL_CYCLE_START_BYTE,
            "?": GRBL_STATUS_QUERY_BYTE,
            "ctrl-x": GRBL_SOFT_RESET_BYTE,
            "0x18": GRBL_SOFT_RESET_BYTE,
        }
        key = text.lower()
        if key in realtime_bytes:
            try:
                with self._lock:
                    self.ser.write(realtime_bytes[key])
                    self.ser.flush()
                self.line_sent.emit(f"> {text}  (bajt czasu rzeczywistego)")
            except Exception as e:
                self.error.emit(f"Nie udało się wysłać polecenia: {e}")
            return

        if self.is_busy():
            self.error.emit(
                "Port jest zajęty bieżącym zadaniem - poczekaj albo użyj poleceń "
                "czasu rzeczywistego (!, ~, ?)."
            )
            return

        self._send_single(text, purpose="terminal")