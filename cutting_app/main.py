"""
Cutting Machine Control - main.py

A deliberately simple front end for:
  - browsing folders under gcode_files/ (like OctoPrint's file list) and
    sending a chosen G-code file to the cutting machine over serial
  - homing / stopping the machine
  - filling in a small table of cutting parameters and generating a
    fresh G-code file into gcode_files/tmp (via generator_adapter.py
    -> circleGen6_2.py)

The operator-facing UI text is in Polish. Code, comments, and
config.toml's structural comments stay in English so the app is easy
for you (the developer) to keep maintaining.

A hidden terminal/log panel can be toggled with Ctrl+Shift+T - it's
off by default so the operator never has to look at raw G-code lines
or serial chatter.

Run with:  python main.py
Configure paths / serial / parameters in config.toml.
"""

import sys
import os
import json
import shutil
import datetime

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:
    import tomli as tomllib  # pip install tomli   (for Python < 3.11)

from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout,
    QListWidget, QListWidgetItem, QPushButton, QLabel, QTableWidget,
    QTableWidgetItem, QComboBox, QTextEdit, QMessageBox, QHeaderView,
    QAbstractItemView, QLineEdit,
)
from PySide6.QtCore import Qt, QTimer
from PySide6.QtGui import QShortcut, QKeySequence
import serial.tools.list_ports

from serial_worker import SerialWorker
import generator_adapter

APP_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(APP_DIR, "config.toml")

# Where the operator's last-entered parameter values are remembered
# between runs. This file is created/overwritten automatically by the
# app - you normally never need to edit it by hand. Its values take
# priority over the "default" values in config.toml, so an operator's
# last session picks up where they left off.
LAST_VALUES_PATH = os.path.join(APP_DIR, "last_values.json")

GCODE_EXTENSIONS = (".gcode", ".nc", ".tap")
FOLDER_PREFIX = "\U0001F4C1 "  # 📁
FILE_PREFIX = "\U0001F4C4 "    # 📄

# Item kinds stored in Qt.UserRole for the sidebar's file browser
ROLE_KIND = Qt.UserRole
ROLE_PATH = Qt.UserRole + 1


def load_config():
    with open(CONFIG_PATH, "rb") as f:
        return tomllib.load(f)


def load_last_values():
    """Operator-entered values saved when the app last closed, if any."""
    try:
        with open(LAST_VALUES_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.config = load_config()
        self.setWindowTitle("Sterowanie maszyną tnącą")
        self.resize(1050, 620)

        self.serial_worker = None
        self._is_paused = False

        gcode_folder_cfg = self.config["paths"]["gcode_folder"]
        if os.path.isabs(gcode_folder_cfg):
            self.gcode_folder = os.path.normpath(gcode_folder_cfg)
        else:
            self.gcode_folder = os.path.normpath(os.path.join(APP_DIR, gcode_folder_cfg))
        os.makedirs(self.gcode_folder, exist_ok=True)

        # Freshly generated files always land here. Cleared out on every
        # startup so it never fills up with old one-off jobs.
        self.tmp_folder = os.path.join(self.gcode_folder, "tmp")
        os.makedirs(self.tmp_folder, exist_ok=True)
        self._clear_tmp_folder()

        self.current_dir = self.gcode_folder

        self._build_ui()
        self._refresh_file_list()

        # Periodically ask the machine if it's in an alarm state (only
        # actually queries when connected and idle - see _poll_alarm_status).
        self.alarm_poll_timer = QTimer(self)
        self.alarm_poll_timer.setInterval(2000)
        self.alarm_poll_timer.timeout.connect(self._poll_alarm_status)
        self.alarm_poll_timer.start()

    # ------------------------------------------------------------------
    # UI construction
    # ------------------------------------------------------------------
    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        main_layout = QVBoxLayout(central)

        main_layout.addLayout(self._build_top_bar())

        body_layout = QHBoxLayout()
        body_layout.addLayout(self._build_sidebar(), 1)
        body_layout.addLayout(self._build_parameter_panel(), 2)
        main_layout.addLayout(body_layout)

        # Hidden terminal / log panel - toggled with Ctrl+Shift+T.
        self.log_label = QLabel("Terminal (Ctrl+Shift+T, aby ukryć):")
        self.log_box = QTextEdit()
        self.log_box.setReadOnly(True)
        self.log_box.setFixedHeight(130)
        main_layout.addWidget(self.log_label)
        main_layout.addWidget(self.log_box)
        self.log_label.setVisible(False)
        self.log_box.setVisible(False)

        terminal_shortcut = QShortcut(QKeySequence("Ctrl+Shift+T"), self)
        terminal_shortcut.activated.connect(self._toggle_terminal)

    def _toggle_terminal(self):
        visible = not self.log_box.isVisible()
        self.log_label.setVisible(visible)
        self.log_box.setVisible(visible)

    def _build_top_bar(self):
        top_bar = QHBoxLayout()

        top_bar.addWidget(QLabel("Port:"))
        self.port_combo = QComboBox()
        self.port_combo.setMinimumWidth(120)
        top_bar.addWidget(self.port_combo)
        self._refresh_ports()

        refresh_ports_btn = QPushButton("Odśwież porty")
        refresh_ports_btn.clicked.connect(self._refresh_ports)
        top_bar.addWidget(refresh_ports_btn)

        self.connect_btn = QPushButton("Połącz")
        self.connect_btn.clicked.connect(self._toggle_connect)
        top_bar.addWidget(self.connect_btn)

        top_bar.addSpacing(20)

        home_btn = QPushButton("Zerowanie maszyny")
        home_btn.clicked.connect(self._home_machine)
        top_bar.addWidget(home_btn)

        self.send_btn = QPushButton("Wyślij wybrany plik")
        self.send_btn.clicked.connect(self._send_selected)
        top_bar.addWidget(self.send_btn)

        top_bar.addStretch()

        self.pause_btn = QPushButton("Pauza")
        self.pause_btn.setStyleSheet("padding: 4px 14px;")
        self.pause_btn.clicked.connect(self._toggle_pause)
        top_bar.addWidget(self.pause_btn)

        stop_btn = QPushButton("STOP")
        stop_btn.setStyleSheet(
            "background-color: #cc3333; color: white; font-weight: bold; padding: 4px 18px;"
        )
        stop_btn.clicked.connect(self._emergency_stop)
        top_bar.addWidget(stop_btn)

        self.alarm_btn = QPushButton()
        self.alarm_btn.setStyleSheet("padding: 4px 14px;")
        self.alarm_btn.clicked.connect(self._on_alarm_clicked)
        self._set_alarm_indicator(None)
        top_bar.addWidget(self.alarm_btn)

        return top_bar

    def _build_sidebar(self):
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Gotowe pliki G-code:"))

        nav_bar = QHBoxLayout()
        self.back_btn = QPushButton("\u2b05 Wstecz")
        self.back_btn.clicked.connect(self._navigate_up)
        nav_bar.addWidget(self.back_btn)
        layout.addLayout(nav_bar)

        self.breadcrumb_label = QLabel()
        self.breadcrumb_label.setWordWrap(True)
        self.breadcrumb_label.setStyleSheet("color: #555;")
        layout.addWidget(self.breadcrumb_label)

        self.file_list = QListWidget()
        self.file_list.setSelectionMode(QAbstractItemView.SingleSelection)
        self.file_list.itemDoubleClicked.connect(self._on_item_double_clicked)
        layout.addWidget(self.file_list)

        refresh_files_btn = QPushButton("Odśwież listę")
        refresh_files_btn.clicked.connect(self._refresh_file_list)
        layout.addWidget(refresh_files_btn)
        return layout

    def _build_parameter_panel(self):
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Parametry cięcia:"))

        self.var_table = QTableWidget()
        self.var_table.setColumnCount(2)
        self.var_table.setHorizontalHeaderLabels(["Parametr", "Wartość"])
        self.var_table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
        self.var_table.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch)
        self._populate_variable_table()
        layout.addWidget(self.var_table)

        self.filename_input = QLineEdit()
        self.filename_input.setPlaceholderText("Nazwa nowego pliku (opcjonalnie)")
        layout.addWidget(self.filename_input)

        generate_btn = QPushButton("Generuj nowy G-code")
        generate_btn.setStyleSheet("font-weight: bold; padding: 8px;")
        generate_btn.clicked.connect(self._generate_gcode)
        layout.addWidget(generate_btn)

        return layout

    # ------------------------------------------------------------------
    # Logging helper
    # ------------------------------------------------------------------
    def _log(self, message):
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        self.log_box.append(f"[{timestamp}] {message}")

    # ------------------------------------------------------------------
    # Serial ports
    # ------------------------------------------------------------------
    def _refresh_ports(self):
        self.port_combo.clear()
        ports = serial.tools.list_ports.comports()
        for p in ports:
            self.port_combo.addItem(p.device)
        if not ports:
            self.port_combo.addItem("Brak dostępnych portów")

    # ------------------------------------------------------------------
    # Sidebar file browser (OctoPrint-style: browse folders under
    # gcode_files/, never leave that root)
    # ------------------------------------------------------------------
    def _relative_display(self, path):
        path = os.path.normpath(path)
        if path == self.gcode_folder:
            return "gcode_files"
        rel = os.path.relpath(path, self.gcode_folder)
        return "gcode_files/" + rel.replace(os.sep, "/")

    def _navigate_to(self, path):
        path = os.path.normpath(path)
        # Safety: never allow navigating outside gcode_files.
        try:
            if os.path.commonpath([path, self.gcode_folder]) != self.gcode_folder:
                path = self.gcode_folder
        except ValueError:
            path = self.gcode_folder
        self.current_dir = path
        self._refresh_file_list()

    def _navigate_up(self):
        if self.current_dir == self.gcode_folder:
            return
        self._navigate_to(os.path.dirname(self.current_dir))

    def _on_item_double_clicked(self, item):
        if item.data(ROLE_KIND) == "dir":
            self._navigate_to(item.data(ROLE_PATH))

    def _refresh_file_list(self):
        self.file_list.clear()

        self.breadcrumb_label.setText("Folder: " + self._relative_display(self.current_dir))
        self.back_btn.setEnabled(self.current_dir != self.gcode_folder)

        try:
            entries = list(os.scandir(self.current_dir))
        except FileNotFoundError:
            self._navigate_to(self.gcode_folder)
            return

        dirs = sorted((e for e in entries if e.is_dir()), key=lambda e: e.name.lower())
        files = sorted(
            (e for e in entries if e.is_file() and e.name.lower().endswith(GCODE_EXTENSIONS)),
            key=lambda e: e.name.lower(),
        )

        for d in dirs:
            item = QListWidgetItem(FOLDER_PREFIX + d.name)
            item.setData(ROLE_KIND, "dir")
            item.setData(ROLE_PATH, d.path)
            self.file_list.addItem(item)

        for f in files:
            item = QListWidgetItem(FILE_PREFIX + f.name)
            item.setData(ROLE_KIND, "file")
            item.setData(ROLE_PATH, f.path)
            self.file_list.addItem(item)

        self._log(f"Znaleziono {len(files)} plik(ów) G-code w: {self._relative_display(self.current_dir)}")

    # ------------------------------------------------------------------
    # Startup cleanup
    # ------------------------------------------------------------------
    def _clear_tmp_folder(self):
        for entry in os.scandir(self.tmp_folder):
            try:
                if entry.is_dir():
                    shutil.rmtree(entry.path)
                else:
                    os.remove(entry.path)
            except OSError:
                pass  # best-effort; never block startup on a stray locked file

    # ------------------------------------------------------------------
    # Parameter table -> generator
    # ------------------------------------------------------------------
    def _format_value_for_display(self, value, field_type):
        if field_type == "bool":
            return "True" if value else "False"
        if field_type == "list" and isinstance(value, list):
            return ", ".join(str(v) for v in value)
        return str(value)

    def _populate_variable_table(self):
        self.field_defs = self.config.get("variables", {}).get("fields", [])
        last_values = load_last_values()
        self.var_table.setRowCount(len(self.field_defs))
        for row, field in enumerate(self.field_defs):
            label_item = QTableWidgetItem(field["label"])
            label_item.setFlags(Qt.ItemIsEnabled)  # read-only label
            self.var_table.setItem(row, 0, label_item)

            name = field["name"]
            field_type = field.get("type", "text")
            if name in last_values:
                display = self._format_value_for_display(last_values[name], field_type)
            else:
                display = self._format_value_for_display(field.get("default", ""), field_type)
            value_item = QTableWidgetItem(display)
            self.var_table.setItem(row, 1, value_item)

    def _collect_variable_values(self):
        values = {}
        for row, field in enumerate(self.field_defs):
            text = self.var_table.item(row, 1).text().strip()
            field_type = field.get("type", "text")
            try:
                if field_type == "int":
                    values[field["name"]] = int(text)
                elif field_type == "float":
                    values[field["name"]] = float(text)
                elif field_type == "bool":
                    if text.lower() not in ("true", "false"):
                        raise ValueError()
                    values[field["name"]] = text.lower() == "true"
                elif field_type == "list":
                    # Comma-separated numbers, e.g. "70, 50" -> [70, 50]
                    parts = [p.strip() for p in text.split(",") if p.strip()]
                    if not parts:
                        raise ValueError()
                    parsed = []
                    for p in parts:
                        try:
                            parsed.append(int(p))
                        except ValueError:
                            parsed.append(float(p))
                    values[field["name"]] = parsed
                else:
                    values[field["name"]] = text
            except ValueError:
                raise ValueError(f"Pole „{field['label']}” ma nieprawidłową wartość: „{text}”")
        return values

    def _generate_gcode(self):
        try:
            values = self._collect_variable_values()
        except ValueError as e:
            QMessageBox.warning(self, "Nieprawidłowa wartość", str(e))
            return

        name = self.filename_input.text().strip()
        if not name:
            name = "cut_" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        if not any(name.lower().endswith(ext) for ext in GCODE_EXTENSIONS):
            name += ".gcode"
        output_path = os.path.join(self.tmp_folder, name)

        try:
            stats = generator_adapter.generate_gcode(values, output_path)
        except Exception as e:
            QMessageBox.critical(self, "Błąd generatora", f"Nie udało się wygenerować G-code:\n{e}")
            return

        circles = stats.get("total_circles")
        windows = stats.get("total_windows")
        if circles is not None and windows is not None:
            self._log(f"Wygenerowano nowy plik: {name} ({circles} kół(a), {windows} okno/a)")
        else:
            self._log(f"Wygenerowano nowy plik: {name}")

        self.filename_input.clear()
        self._navigate_to(self.tmp_folder)  # jump to tmp/ so the operator sees the new file

    # ------------------------------------------------------------------
    # Machine control
    # ------------------------------------------------------------------
    def _toggle_connect(self):
        if self.serial_worker and self.serial_worker.is_connected():
            self.serial_worker.disconnect()
            self.serial_worker = None
            self.connect_btn.setText("Połącz")
            self._reset_pause_ui()
            self._set_alarm_indicator(None)
            self._log("Rozłączono z maszyną.")
            return

        port = self.port_combo.currentText()
        if not port or port == "Brak dostępnych portów":
            QMessageBox.warning(
                self, "Brak portu",
                "Nie wybrano portu szeregowego. Podłącz maszynę i naciśnij „Odśwież porty”.",
            )
            return

        baud = self.config["serial"].get("baud_rate", 115200)
        worker = SerialWorker(port, baud)
        worker.line_sent.connect(self._log)
        worker.error.connect(lambda msg: QMessageBox.critical(self, "Błąd maszyny", msg))
        worker.finished_job.connect(self._on_job_finished)
        worker.paused.connect(self._on_paused)
        worker.resumed.connect(self._on_resumed)
        worker.alarm_cleared.connect(self._on_alarm_cleared)
        worker.status_received.connect(self._on_status_received)

        try:
            worker.connect()
        except Exception as e:
            QMessageBox.critical(self, "Błąd połączenia", f"Nie można otworzyć portu {port}:\n{e}")
            return

        self.serial_worker = worker
        self.connect_btn.setText("Rozłącz")
        self._set_alarm_indicator(False)
        self._log(f"Połączono z portem {port}.")

    def _require_connection(self) -> bool:
        if not self.serial_worker or not self.serial_worker.is_connected():
            QMessageBox.warning(self, "Brak połączenia", "Najpierw połącz się z maszyną.")
            return False
        return True

    def _home_machine(self):
        if not self._require_connection():
            return
        if self.serial_worker.is_busy():
            QMessageBox.warning(self, "Zadanie w toku", "Poczekaj, aż bieżące zadanie się zakończy.")
            return
        homing_cmd = self.config["machine"].get("homing_command", "$H")
        self.serial_worker.send_lines([homing_cmd])
        self._log("Wysłano polecenie zerowania.")

    def _send_selected(self):
        if not self._require_connection():
            return
        if self.serial_worker.is_busy():
            QMessageBox.warning(self, "Zadanie w toku", "Zadanie już trwa.")
            return
        item = self.file_list.currentItem()
        if not item:
            QMessageBox.warning(self, "Nie wybrano pliku", "Wybierz plik G-code z listy.")
            return
        if item.data(ROLE_KIND) != "file":
            QMessageBox.warning(
                self, "To jest folder",
                "Kliknij dwukrotnie na folder, aby go otworzyć, albo wybierz plik G-code.",
            )
            return

        path = item.data(ROLE_PATH)
        file_name = os.path.basename(path)
        try:
            with open(path, "r") as f:
                lines = f.readlines()
        except Exception as e:
            QMessageBox.critical(self, "Błąd pliku", f"Nie można odczytać pliku:\n{e}")
            return

        confirm = QMessageBox.question(
            self, "Potwierdź", f"Wysłać „{file_name}” do maszyny i rozpocząć cięcie?",
            QMessageBox.Yes | QMessageBox.No,
        )
        if confirm != QMessageBox.Yes:
            return

        self._log(f"Wysyłanie pliku {file_name}...")
        self._reset_pause_ui()
        self.serial_worker.send_lines(lines)

    def _on_job_finished(self):
        self._log("Zadanie zakończone.")
        self._reset_pause_ui()

    def _emergency_stop(self):
        if not self.serial_worker or not self.serial_worker.is_connected():
            return
        self.serial_worker.emergency_stop()
        self._reset_pause_ui()
        self._log("Wysłano STOP AWARYJNY (reset GRBL). Może być konieczne ponowne zerowanie maszyny.")

    # ------------------------------------------------------------------
    # Pause / Resume
    # ------------------------------------------------------------------
    def _reset_pause_ui(self):
        self._is_paused = False
        self.pause_btn.setText("Pauza")
        self.pause_btn.setEnabled(True)

    def _toggle_pause(self):
        if self._is_paused:
            self._request_resume()
        else:
            self._request_pause()

    def _request_pause(self):
        if not self._require_connection():
            return
        if not self.serial_worker.is_busy():
            QMessageBox.information(self, "Brak zadania", "Nic teraz nie jest wysyłane do maszyny.")
            return
        self.pause_btn.setEnabled(False)
        self._log("Wstrzymywanie: hamowanie osi i wyłączanie grzania drutu...")
        self.serial_worker.pause("M101 R0 P0")

    def _on_paused(self):
        self._is_paused = True
        self.pause_btn.setText("Wznów")
        self.pause_btn.setEnabled(True)
        self._log("Wstrzymano. Drut wychłodzony, oś zatrzymana.")

    def _request_resume(self):
        if not self._require_connection():
            return
        cutting_temp = self.config["machine"].get("cutting_temp", 10)
        temp_set_time = self.config["machine"].get("temp_set_time", 4)
        self.pause_btn.setEnabled(False)
        self._log(f"Wznawianie: podgrzewanie drutu do {cutting_temp} przez {temp_set_time}s...")
        self.serial_worker.resume(f"M101 R{cutting_temp} P{temp_set_time}")

    def _on_resumed(self):
        self._is_paused = False
        self.pause_btn.setText("Pauza")
        self.pause_btn.setEnabled(True)
        self._log("Wznowiono cięcie.")

    # ------------------------------------------------------------------
    # Alarm indicator (top-right corner)
    # ------------------------------------------------------------------
    def _set_alarm_indicator(self, is_alarm):
        """is_alarm: True = alarm active, False = ok, None = unknown/disconnected."""
        if is_alarm is None:
            self.alarm_btn.setText("GRBL: –")
            self.alarm_btn.setStyleSheet("background-color: #999; color: white; padding: 4px 14px;")
        elif is_alarm:
            self.alarm_btn.setText("⚠ ALARM – kliknij, aby odblokować")
            self.alarm_btn.setStyleSheet(
                "background-color: #cc3333; color: white; font-weight: bold; padding: 4px 14px;"
            )
        else:
            self.alarm_btn.setText("GRBL: OK")
            self.alarm_btn.setStyleSheet("background-color: #3a9d4f; color: white; padding: 4px 14px;")

    def _poll_alarm_status(self):
        if not self.serial_worker or not self.serial_worker.is_connected():
            return
        self.serial_worker.query_status()

    def _on_status_received(self, text):
        self._set_alarm_indicator("alarm" in text.lower())

    def _on_alarm_clicked(self):
        if not self.serial_worker or not self.serial_worker.is_connected():
            QMessageBox.warning(self, "Brak połączenia", "Najpierw połącz się z maszyną.")
            return
        self.serial_worker.clear_alarm()
        self._log("Wysłano polecenie odblokowania alarmu ($X).")

    def _on_alarm_cleared(self):
        self._log("Alarm odblokowany.")
        self._set_alarm_indicator(False)

    def _save_last_values(self):
        """Best-effort save of the operator's current table values, so
        next launch starts from where they left off."""
        try:
            values = self._collect_variable_values()
        except ValueError:
            return  # don't overwrite a good saved file with invalid data
        try:
            with open(LAST_VALUES_PATH, "w", encoding="utf-8") as f:
                json.dump(values, f, indent=2, ensure_ascii=False)
        except OSError:
            pass

    def closeEvent(self, event):
        self._save_last_values()
        if self.serial_worker and self.serial_worker.is_connected():
            self.serial_worker.disconnect()
        event.accept()


def main():
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
