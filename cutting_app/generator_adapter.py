"""
generator_adapter.py

Bridge between the app and circleGen6_2.py (your real hot-wire circle
cutting G-code generator). This is the only file that needs to change
if you swap in a newer/different version of your generator script.

HOW THIS WORKS
--------------
circleGen6_2.py is written as a script: all of its settings are plain
ALL_CAPS module-level variables (CIRCLE_DIAMETER, PLANE_WIDTH, PATTERN,
...) and its generate_gcode() function reads those variables directly
instead of taking arguments.

So, for every job, this adapter:
  1. Reloads circleGen6_2 fresh, so nothing left over from a previous
     job leaks into the next one - every generate starts from
     circleGen_config.toml's external defaults.
  2. Overwrites whichever of its variables the operator changed in the
     app's parameter table (config.toml decides which ones show up).
  3. Calls its generate_gcode() and saves the resulting G-code to disk.
  4. Hands back the stats dict circleGen6_2.py already computes (circle
     count, window count, etc.) so the app can show it in the log.

TO ADD A NEW ADJUSTABLE VARIABLE TO THE APP:
You do NOT need to touch this file. Just add it to config.toml's
[[variables.fields]] list, using the EXACT variable name from
circleGen6_2.py (e.g. "SEVER_DISTANCE", "ARC_STOP_ANGLE", "RAIL_LENGTH",
"PATTERN", ...). This file picks it up automatically. See the comment
block at the top of config.toml for the full list of variable names
available in circleGen6_2.py.

TO UPDATE TO A NEWER circleGen SCRIPT:
Drop the new file into this folder and change the import line below
(and the filename check in generate_gcode) to match its filename.
"""

import importlib
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
import circleGen7_2 as generator

def generate_gcode(values: dict, output_path: str) -> dict:
    """
    Generate a G-code file using circleGen6_2.py.

    values: dict mapping circleGen6_2 variable name -> new value
            (comes straight from the app's parameter table)
    output_path: full path to the .gcode file to write

    Returns the `stats` dict circleGen6_2.generate_gcode() produces,
    so the app can log a human-readable summary.
    """
    importlib.reload(generator)  # always start from circleGen_config.toml defaults

    for name, value in values.items():
        if not hasattr(generator, name):
            raise ValueError(
                f"'{name}' is not a variable in circleGen6_2.py. Check the "
                f"spelling in the app configuration against the ALL_CAPS variable "
                f"names supported by circleGen6_2.py."
            )
        setattr(generator, name, value)

    gcode, stats = generator.generate_gcode()

    with open(output_path, "w") as f:
        f.write(gcode)

    return stats
