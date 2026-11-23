#!/usr/bin/env python3
"""
Prepend 150 ms of silence to every .m4a in the current directory
and shift every .json cue sheet by the same amount.
Original files are left untouched. New files get a -primed suffix.
"""
import json
import subprocess
import sys
from pathlib import Path

SILENCE_SEC = 0.15
SILENCE_MS = int(SILENCE_SEC * 1000)

def main():
    folder = Path.cwd()
    m4as = sorted(folder.glob("*.m4a"))
    if not m4as:
        print("No .m4a files found in", folder)
        sys.exit(1)

    print(f"Found {len(m4as)} M4A files. Prepending {SILENCE_MS} ms silence...")

    for src in m4as:
        dst = src.with_name(src.stem + "-primed.m4a")
        if dst.exists():
            print(f"  skip {dst.name} (already exists)")
            continue
        cmd = [
            "ffmpeg", "-y", "-loglevel", "error",
            "-f", "lavfi", "-t", str(SILENCE_SEC), "-i", "anullsrc=r=44100:cl=mono",
            "-i", str(src),
            "-filter_complex", "[0:a][1:a]concat=n=2:v=0:a=1[out]",
            "-map", "[out]",
            "-c:a", "aac", "-b:a", "128k",
            str(dst)
        ]
        subprocess.run(cmd, check=True)
        print(f"  created {dst.name}")

    for js in sorted(folder.glob("*.json")):
        if js.stem.endswith("-primed"):
            continue
        data = json.loads(js.read_text())
        if "offsets" not in data:
            continue
        dst = js.with_name(js.stem + "-primed.json")
        new_offsets = [round(o + SILENCE_SEC, 4) for o in data["offsets"]]
        new_data = dict(data)
        new_data["offsets"] = new_offsets
        dst.write_text(json.dumps(new_data, indent=2) + "\n")
        print(f"  created {dst.name} (offsets shifted by {SILENCE_SEC}s)")

    print("\nDone. Primed files are next to the originals.")

if __name__ == "__main__":
    main()
