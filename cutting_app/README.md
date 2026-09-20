# Cutting Machine Control

! RARELY UPDATED, PROBABLY HAS SOME OLD INFO

A minimal front end for operating your cutting machine:

- **Left sidebar** — list of ready-to-cut G-code files from a folder.
- **Top bar** — pick the serial port, Connect/Disconnect, Home Machine,
  Send Selected File, and a big red STOP.
- **Right panel** — a simple table of cutting parameters. Fill in numbers,
  press "Generate New G-code", and a fresh file appears in the sidebar.
- **Status box** — plain-language log of what's happening.

## 1. Install (one time)

Requires Python 3.11+ (for built-in TOML support; use `pip install tomli`
as well if on an older Python).

```
pip install -r requirements.txt
```

## 2. Set up your files

- Put your ready-to-go `.gcode` / `.nc` / `.tap` files in the
  `gcode_files` folder (or point `gcode_folder` in `config.toml` at
  wherever you already keep them).

## 3. The generator

`circleGen6_2.py` (your real generator) lives right in this folder.
`generator_adapter.py` calls it by temporarily overriding whichever
ALL_CAPS variables (`CIRCLE_DIAMETER`, `PLANE_WIDTH`, `PATTERN`, ...)
the operator changed in the table, then calling its `generate_gcode()`
exactly as it already works — no changes to circleGen6_2.py itself.

**To update to a newer version of your script:** drop the new file
into this folder and change the `import circleGen6_2 as generator`
line near the top of `generator_adapter.py` to match its filename.

## 4. Configure

Everything else — the folder path, serial baud rate, homing/stop
commands, and which parameters show up in the table — lives in
`config.toml`. Edit it in any text editor; no coding required.
Restart the app after changing it.

To add a new parameter to the table, just add a block like this:

```toml
[[variables.fields]]
name = "kerf_mm"
label = "Kerf Compensation (mm)"
default = 0.2
type = "float"
```

## 5. Run

```
python main.py
```

## Operator interface notes

- The whole operator-facing UI is in Polish; code and this README stay
  in English so they're easy for you to keep maintaining.
- **File browser:** the sidebar mirrors an OctoPrint-style file list —
  double-click a folder to enter it, use "⬅ Wstecz" to go back. It can
  never leave the `gcode_files` folder.
- **Newly generated files** always land in `gcode_files/tmp/`, and the
  app jumps there automatically after generating so the operator sees
  the new file right away.
- **Terminal/log panel** is hidden by default (an operator never needs
  to see raw G-code or serial replies). Press `Ctrl+Shift+T` to show or
  hide it — useful for you while debugging.
- **STOP button** sends GRBL's realtime soft-reset byte directly (not
  a G-code line — GRBL has no such command). It halts motion instantly
  and clears the queue. The machine will likely need re-homing after.
- **Remembering values:** whatever the operator last typed into the
  parameter table is saved to `last_values.json` when the app closes,
  and takes priority over `config.toml`'s defaults on the next launch.
  Delete that file if you ever want the table to reset to the
  `config.toml` defaults.
- **G-code sending** waits for GRBL's `ok`/`error` reply after every
  line before sending the next one, so it can't outrun the controller.
  If the machine reports an error, sending stops immediately instead
  of continuing to send more lines.
- **Pause/Resume** (button to the left of STOP): Pause sends GRBL's
  realtime feed-hold (decelerates the axes to a stop), stops sending
  further lines, and turns the wire heater off (`M101 R0 P0`) -
  remembering exactly which line it stopped on. Resume reheats the
  wire (`M101 R<cutting_temp> P<temp_set_time>` from `config.toml`)
  and waits for that to finish before releasing the hold and
  continuing the G-code from where it left off.
- **Alarm indicator** (far top-right corner, next to STOP): shows
  green "GRBL: OK" normally, or red "⚠ ALARM" if GRBL reports an alarm
  state (checked automatically every couple seconds while connected
  and idle). Click it to send GRBL's unlock command (`$X`).

## Files

| File                  | Purpose                                                     |
|-----------------------|---------------------------------------------------------------|
| `main.py`             | The window and all UI logic                                   |
| `serial_worker.py`    | Talks to the machine over serial (pyserial), threaded          |
| `generator_adapter.py`| Bridge that overrides circleGen6_2's variables and calls it    |
| `circleGen6_2.py`     | Your real generator, unchanged                                 |
| `config.toml`         | All settings — folder, serial, homing/stop, parameter table    |
| `gcode_files/`        | Where ready-made and newly generated files live                |

Every variable name in circleGen6_2.py (CIRCLE_DIAMETER, PLANE_WIDTH,
RAIL_LENGTH, CUTTING_TEMP, and so on) can be exposed in the app's
table just by adding it to `config.toml` — see the reference list of
all available names in that file's comments.

## Notes on the machine protocol

`serial_worker.py` streams G-code line by line and waits for an
`ok` (or `error`) reply after each line — the standard behavior for
Grbl/Marlin-style controllers. If your controller talks differently,
that's the one place to adjust (`_wait_for_response`).
