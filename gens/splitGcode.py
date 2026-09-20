from pathlib import Path
import sys


def split_gcode(input_file):
    input_path = Path(input_file)

    if not input_path.exists():
        print(f"Error: file not found: {input_path}")
        return

    # Read entire file while preserving line endings
    with open(input_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    output_dir = input_path.parent / f"{input_path.stem}_split"
    output_dir.mkdir(exist_ok=True)

    part = []
    part_number = 1

    for line in lines:
        part.append(line)

        # CUT_GCODE marks the END of a part
        if "; CUT_GCODE" in line:
            output_file = output_dir / f"{input_path.stem}_{part_number:03d}.gcode"

            with open(output_file, "w", encoding="utf-8") as f:
                f.writelines(part)

            print(f"Created: {output_file}")
            
            part = []
            part_number += 1

    # Write remaining content after the last CUT_GCODE
    if part:
        output_file = output_dir / f"{input_path.stem}_{part_number:03d}.gcode"

        with open(output_file, "w", encoding="utf-8") as f:
            f.writelines(part)

        print(f"Created: {output_file}")

    print(f"\nDone. Created {part_number - 1 if not part else part_number} files.")
    

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage:")
        print(f"    python {Path(sys.argv[0]).name} your_file.gcode")
        sys.exit(1)

    split_gcode(sys.argv[1])