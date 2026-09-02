#!/usr/bin/env python3
"""Verify that OpenSCAD can resolve and compile BOSL2."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


FAILURE_PATTERNS = (
    "can't find include file",
    "error:",
    "ignoring unknown module",
    "current top level object is empty",
    "parser error",
    "compilation failed",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compile a small BOSL2 model and verify the exported STL."
    )
    parser.add_argument(
        "--library-root",
        type=Path,
        help="directory containing BOSL2/ (not the BOSL2 directory itself)",
    )
    parser.add_argument(
        "--openscad",
        default="openscad",
        help="OpenSCAD executable (default: openscad)",
    )
    return parser.parse_args()


def fail(message: str, log: str = "") -> int:
    print(f"BOSL2 preflight FAILED: {message}", file=sys.stderr)
    if log.strip():
        print("\nOpenSCAD output:", file=sys.stderr)
        print(log.rstrip(), file=sys.stderr)
    print(
        "\nInstall project-local BOSL2 with:\n"
        "  git clone --depth 1 https://github.com/BelfrySCAD/BOSL2.git BOSL2\n"
        "Then rerun this script from that directory, or pass --library-root PATH.\n"
        "The library root must contain BOSL2/std.scad. Inspect shared locations with:\n"
        "  openscad --info",
        file=sys.stderr,
    )
    return 1


def main() -> int:
    args = parse_args()
    executable = shutil.which(args.openscad)
    if executable is None:
        return fail(f"OpenSCAD executable not found: {args.openscad}")

    root: Path | None = None
    if args.library_root is not None:
        root = args.library_root.expanduser().resolve()
        if (root / "std.scad").is_file() and not (root / "BOSL2" / "std.scad").is_file():
            return fail(
                f"--library-root points directly at BOSL2: {root}. "
                f"Pass its parent instead: {root.parent}"
            )
        if not (root / "BOSL2" / "std.scad").is_file():
            return fail(f"{root} does not contain BOSL2/std.scad")
    elif (Path.cwd() / "BOSL2" / "std.scad").is_file():
        root = Path.cwd().resolve()

    env = os.environ.copy()
    if root is not None:
        existing = env.get("OPENSCADPATH")
        env["OPENSCADPATH"] = str(root) + (os.pathsep + existing if existing else "")

    version = subprocess.run(
        [executable, "--version"], capture_output=True, text=True, check=False
    )
    version_text = (version.stdout + version.stderr).strip()

    with tempfile.TemporaryDirectory(prefix="bosl2-preflight-") as temp_dir:
        temp = Path(temp_dir)
        source = temp / "smoke.scad"
        output = temp / "smoke.stl"
        source.write_text(
            "include <BOSL2/std.scad>\n"
            "cuboid([10, 10, 10], rounding=1, edges=\"Z\");\n",
            encoding="utf-8",
        )
        try:
            result = subprocess.run(
                [executable, "-o", str(output), str(source)],
                capture_output=True,
                text=True,
                env=env,
                timeout=120,
                check=False,
            )
        except subprocess.TimeoutExpired as error:
            return fail("OpenSCAD smoke test timed out after 120 seconds", str(error))

        log = result.stdout + result.stderr
        matched = [pattern for pattern in FAILURE_PATTERNS if pattern in log.lower()]
        if result.returncode != 0:
            return fail(f"OpenSCAD exited with status {result.returncode}", log)
        if matched:
            return fail(f"OpenSCAD reported: {', '.join(matched)}", log)
        if not output.is_file() or output.stat().st_size == 0:
            return fail("OpenSCAD did not produce a non-empty STL", log)

        facets = re.search(r"Facets:\s+(\d+)", log)
        print("BOSL2 preflight PASSED")
        print(f"OpenSCAD: {version_text or executable}")
        print(f"Library root: {root if root is not None else 'OpenSCAD configured paths'}")
        print(f"STL bytes: {output.stat().st_size}")
        if facets:
            print(f"Facets: {facets.group(1)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
