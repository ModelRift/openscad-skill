---
name: bosl2
description: Use BOSL2, the Belfry OpenSCAD Library v2, for attachment-aware parametric modeling and specialized printable parts. Apply when the user explicitly requests BOSL2, provides BOSL2 code, or asks for threads, threaded rods or nuts, screws, pipe or bottle threads, knuckle hinges, living hinges, print-in-place hinges, or snap-lock hinged parts.
---

# BOSL2 Modeling

Use this optional companion with the parent OpenSCAD preview-and-debug skill. BOSL2 is large and evolves quickly; confirm every module signature against the installed library version instead of relying on memory.

## Resolve the Library and Documentation

1. Locate the project or system `BOSL2/` directory and record its Git commit or version from `BOSL2/version.scad`. Prefer the dependency already used by the project.
2. Include `BOSL2/std.scad` plus only the specialized library files required by the model.
3. Read [the library map](references/library-map.md) to choose source files and search terms.
4. Search the installed `.scad` source comments for the exact symbol, arguments, constraints, and examples. If an official wiki checkout is available, open only the corresponding generated Markdown page.
5. Inspect only the example images referenced by the relevant section. Do not load, copy, or summarize the full BOSL2 wiki: it contains hundreds of pages and a very large image set.
6. If local source and online documentation disagree, treat the installed source as authoritative for compilation and record the version mismatch.

Use only the official BOSL2 sources when retrieving missing documentation:

- Library: <https://github.com/BelfrySCAD/BOSL2>
- Generated documentation: <https://github.com/BelfrySCAD/BOSL2/wiki>

## Threads: Treat as a Primary BOSL2 Workflow

For any printable internal or external thread request, inspect `threading.scad` first. Also inspect `screws.scad` for standard fastener specifications and `bottlecaps.scad` for closure standards.

```openscad
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
```

- Start with `threaded_rod()` and `threaded_nut()` for ISO/UTS-style threads.
- Select the specialized APIs for trapezoidal/ACME, NPT/BSPP, buttress, square, ball-screw, or generic profiles only after reading their current source documentation.
- Use the documented internal-thread or mask mode when subtracting a threaded hole; do not approximate a mating internal thread by subtracting the unchanged external solid.
- Expose diameter, pitch, length, handedness, starts, lead-in/end treatment, and fit allowance when they are meaningful to the user.
- Account for printer, material, layer height, nozzle, and orientation. Render a small male/female fit coupon before committing to a large print, and keep `$slop` or explicit clearances visible and documented.
- Inspect the relevant thread-end and mating examples; thread geometry can look plausible while lead-ins or clearances make assembly fail.

## Hinges: Treat as a Primary BOSL2 Workflow

For knuckle, living, print-in-place, folding, or snap-lock hinge requests, inspect `hinges.scad` first and include it explicitly:

```openscad
include <BOSL2/std.scad>
include <BOSL2/hinges.scad>
```

- Start with `knuckle_hinge()` for pinned and print-in-place knuckle hinges.
- Use `living_hinge_mask()` for a foldable thin section and inspect the material/orientation assumptions before modeling it.
- Inspect `apply_folding_hinges_and_snaps()`, `snap_lock()`, and `snap_socket()` for folding assemblies with closures.
- Verify segment parity, pin diameter, gap, knuckle clearance, support arms, rotation envelope, layer orientation, and assembly access.
- Prefer teardrop or otherwise printable horizontal holes when the current API and print orientation support them.
- Render both mating states and a sectional or exploded view. For print-in-place hinges, create a clearance coupon and verify that slicer line width will preserve the intended gaps.

## Modeling and QA Rules

- Preserve BOSL2 attachment semantics. Use documented anchors, `position()`, `attach()`, `orient()`, and diff/tag patterns instead of converting them to fragile coordinate arithmetic without reason.
- Do not mix BOSL1 APIs into BOSL2 code.
- Build the smallest compilable example before integrating a complex module into the full part.
- Compile with the project's BOSL2 version, export an STL, and follow the parent skill's multi-view visual QA loop.
- When revising an existing part, use the parent's `scripts/stl_diff.py` tool to confirm that changes are localized and intentional.
