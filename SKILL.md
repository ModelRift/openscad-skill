---
name: modelrift-openscad
description: Design, render, inspect, debug, and export parametric CAD models in OpenSCAD for 3D-printable parts. Use OpenSCAD CLI to create preview PNGs, compare STL revisions, select cameras, export STL and multi-object 3MF files, generate projections and cross-sections, diagnose fit and geometry issues, expose Customizer parameters, and adapt bundled reference parts for printable threads and hinges. Apply to OpenSCAD part design and iteration, including threaded connectors, moving assemblies, and print-in-place hinges.
---

# ModelRift OpenSCAD Skill

Generate 3D renders, 2D outlines, and cross-section slices with the OpenSCAD command-line interface (CLI). Import exported meshes when alignment, clearance, or wall-thickness debugging must reflect the compiled output.

## Require a Development Snapshot

Use an OpenSCAD `2026.x` development snapshot or newer, not the legacy `2021.01` stable build. This workflow relies on the Manifold backend, lazy union, and newer CLI behavior.

Before modeling, run:

```bash
openscad --version
openscad --help 2>&1 | rg -- '--backend|lazy-union'
```

Require `openscad --version` to report a `2026.x` development snapshot or newer, and require the help output to expose the `Manifold` backend and `lazy-union`. If OpenSCAD is missing, reports `2025.x` or older, or lacks either feature, stop and direct the user to install a current [development snapshot](https://openscad.org/downloads.html#snapshots). Keep the official [GitHub Releases page](https://github.com/openscad/openscad/releases) as the stable-release history; do not mistake an older stable release for the required snapshot. On macOS, the official download page lists `brew install openscad@snapshot`.

After installation, rerun both checks and ensure the shell resolves the new executable. OpenSCAD has no `-e` option for evaluating source text; write a `.scad` file or pass source on stdin with `-` as the input filename.

Reject a build if the OpenSCAD log contains `ERROR:`, `WARNING:`, an assertion failure, an unknown module, a missing include, or an empty top-level object. Do not trust the process exit code alone. Confirm that every requested export exists and is non-empty.

## Bundled Reference Parts

Use these dependency-free examples as known-good starting points:

- For mating internal and external threads, inspect [the threaded connector source](assets/reference-parts/threaded-connector.scad) and [its compact preview](assets/reference-parts/threaded-connector.png).
- For a print-in-place knuckle hinge, inspect [the hinge source](assets/reference-parts/print-in-place-hinge.scad) and [its compact preview](assets/reference-parts/print-in-place-hinge.png).

Compile the selected example unchanged before adapting it. Copy only the relevant modules into the user's versioned source; do not rewrite unrelated geometry merely to use an example. Keep fit clearance, printer tolerance, layer height, nozzle width, material, and print orientation explicit.

For threaded parts, export a short male/female fit coupon before a large part. For hinges, render the print position and at least 45°, 90°, and closed states around the actual hinge axis. Export the two moving parts separately and use `intersection()` at every state; any unintended solid intersection fails QA. A manifold export proves mesh validity, not fit or motion.

## Uniform File Naming Conventions

All OpenSCAD iterations and exports must reside in the `./output` folder and adhere to a strict, uniform naming convention. Each modification—including design changes, tweaks, corrections, and bug fixes—must increment the version number. Do not overwrite previous source files or exports:

*   **OpenSCAD Source Files**: `output/out.vXX.scad` (for example, `output/out.v01.scad`, `output/out.v02.scad`, `output/out.v03.scad`)
*   **STL Export Mesh Files**: `output/out.vXX.stl` (e.g., `output/out.v02.stl`)
*   **PNG Preview Images**: `output/preview.vXX.[camera-settings].png`
    *   Example Isometric Ortho preview: `output/preview.v02.iso-ortho.png`
    *   Example Top Ortho preview: `output/preview.v02.top-ortho.png`
    *   Example Side Ortho preview: `output/preview.v02.side-ortho.png`
*   **STL Diff Images**: `output/diff.vXX-vYY.[camera-settings].png` (for example, `output/diff.v02-v03.iso-ortho.png`)

*   **Immutable Versions & Editing Rules**:
    *   **Internal Agentic QA Loop**: You are permitted to edit and overwrite the current active version's files (e.g., `out.v02.scad` and its renders) *during* your own inner loop of development and QA testing, before you complete your turn and present the design.
    *   **External Human Interaction**: Once a design version has been presented to the user (the turn is ended), that version is locked and immutable. If the user asks for any "fixes", "updates", "changes", or "tweaks", you must increment the version number and write the modifications to a brand-new file version (e.g., `out.v03.scad`). Never edit a version that has already been shared.

---

## Development & Quality Assurance Loop

Before completing a turn and presenting a new design version to the user, you must perform a visual Quality Assurance (QA) self-check:
1. Render the preview images for the current version (e.g. `preview.vXX.*.png`).
2. Use the environment's image-viewing capability to inspect every generated preview at full useful detail.
3. If there are any visual issues, rendering artifacts, trenches, flat spots, or corner glitches, edit the code, re-render, and check again.
4. When a previous STL exists, render an STL diff against it and inspect every intended addition and removal.
5. Repeat this edit-and-render loop until you are completely satisfied with the visual look and geometry manifold metrics of the model.
6. Only present the version and its files to the user once it passes this visual QA check.

---

## 1. CLI Rendering & Preview Settings

To generate standard previews, use the `openscad` command-line utility. Always configure image size, auto-centering, and auto-zoom to fit:

*   **Size**: `--imgsize=800,600` (or similar 4:3 aspect ratio)
*   **Frame**: `--autocenter --viewall` (crucial to center and fit the model in the viewport)

### Recommended View Modes
| View Type | CLI Arguments | Description |
| :--- | :--- | :--- |
| **Isometric (Ortho)** | `--camera=0,0,0,55,0,25,0 --projection=ortho` | **Recommended Default.** Standard technical 3D perspective without distortion. |
| **Isometric (Persp)** | `--camera=0,0,0,55,0,25,0 --projection=perspective` | A realistic 3D perspective mimicking human eye view. |
| **Top-Down (Ortho)** | `--camera=0,0,0,0,0,0,0 --projection=ortho` | Plan view, best for checking footprints, lips, and horizontal shapes. |
| **Front (Ortho)** | `--camera=0,0,0,90,0,0,0 --projection=ortho` | Front elevation, best for inspecting widths and heights. |
| **Right (Ortho)** | `--camera=0,0,0,90,0,90,0 --projection=ortho` | Right elevation, best for inspecting depths and heights. |

### Color Schemes (`--colorscheme`)
OpenSCAD supports multiple rendering color schemes. Use the appropriate one based on context:
*   `Cornfield` (Default): High contrast, standard green/yellow/orange colors.
*   `Metallic`: Shiny greys, excellent for visualizing metal brackets or technical prints.
*   `Sunset`: Red, orange, pink tones.
*   `Solarized`: Sleek blue/grey dark mode look.
*   `Monotone`: Pure greyscale, ideal for black-and-white print documentation.

### Render Type (Always use Manifold full render)
*   **Full Render Mode (`--render --backend=Manifold`)**: Use the development snapshot's Manifold backend for rendered preview images and mesh exports. Never use the default preview mode (OpenGL "ThrownTogether" rendering) as it frequently causes z-fighting, transparency, and missing surface rendering artifacts.

---

## 2. 3D-to-2D Projection & Debug Slicing

OpenSCAD's `projection()` operator projects 3D models onto the 2D `Z=0` plane. This is powerful for checking profiles and internal clearances.

### Direct Silhouette Projection (2D Outlines)
Projects the entire 3D model footprint onto the XY plane. Useful for exporting DXF/SVG for laser or CNC cutting:
```openscad
use <output/out.vXX.scad>;
projection(cut = false) bed_shelf();
```

### Direct Cross-Section Slicing
Slices the model at a specific Z height. To slice at height `z_slice`, translate the model down by `z_slice` so the desired cut plane aligns with `Z=0`, then call `projection(cut = true)`:
```openscad
use <output/out.vXX.scad>;
projection(cut = true) translate([0, 0, -z_slice]) bed_shelf();
```

### Debug Slicing via STL Import
When working with complex assemblies or verifying exports, export the model to an STL first, then use a helper script to import it back inside a projection slice. This ensures you check the actual compiled output mesh rather than individual parameter logic:

1.  **Export the STL**:
    ```bash
    openscad -o output/out.vXX.stl output/out.vXX.scad
    ```
2.  **Render the Cut Preview via CLI Stdin**:
    ```bash
    echo 'projection(cut = true) translate([0, 0, -z_slice]) import("output/out.vXX.stl");' | \
    openscad -o output/preview.vXX.cut-z_slice.png --autocenter --viewall --imgsize=800,600 -
    ```

### STL Revision Diff

Use the bundled `scripts/stl_diff.py` tool to render two STL files in their shared coordinate system. Red shows material added in the newer model, blue shows material removed from the older model, and translucent gray shows unchanged volume:

```bash
python3 /path/to/modelrift-openscad/scripts/stl_diff.py \
  output/out.v02.stl output/out.v03.stl \
  -o output/diff.v02-v03.iso-ortho.png \
  --view iso
```

Inspect the PNG with the environment's image-viewing capability. Generate additional `top`, `front`, or `right` views when the isometric render hides a critical change. Treat unexpected red or blue regions as regressions to investigate. The tool performs exact CSG differences, so both meshes must use the same units and coordinate frame; it intentionally does not auto-align them.

---

## 3. Compiling Previews into a Grid with FFmpeg

To visualize multiple iterations or camera angles in a single overview image, compile individual previews into a grid using FFmpeg's `xstack` filter:

1.  Generate the individual labeled previews (e.g., using Python Pillow to write text labels at the top of each image).
2.  Use the `xstack` filter to compile them. For example, to tile a 4x4 grid of sixteen `800x600` images:
    ```bash
    ffmpeg \
      -i img00.png -i img01.png -i img02.png -i img03.png \
      -i img04.png -i img05.png -i img06.png -i img07.png \
      -i img08.png -i img09.png -i img10.png -i img11.png \
      -i img12.png -i img13.png -i img14.png -i img15.png \
      -filter_complex "xstack=inputs=16:layout=0_0|800_0|1600_0|2400_0|0_600|800_600|1600_600|2400_600|0_1200|800_1200|1600_1200|2400_1200|0_1800|800_1800|1600_1800|2400_1800" \
      -y output/preview_grid.png
    ```

---

## 4. OpenSCAD Customizer Integration

To make designs interactive and configurable, write parameters at the top of the file using OpenSCAD Customizer comment syntax. Expose all design variables that make sense to customize:

### Customizer Rules
*   **Placement**: Parameters must be declared at the top of the file, before any modules or functions.
*   **Assignment**: Use simple literal values (e.g., `x = 10;`). Do not use math, variables, or functions in parameter assignments.
*   **Formatting**: Underscores in variable names automatically display as spaces in the UI.

### Customizer Syntax Patterns
*   **Sliders (Numeric Ranges)**: Use `// [min:max]` or `// [min:step:max]`
    ```openscad
    thickness = 2.4; // [1.0:0.1:5.0]
    height = 50; // [10:100]
    ```
*   **Dropdowns / Combo Boxes**: Use `// [val1, val2]` or `// [val1:Label1, val2:Label2]`
    ```openscad
    style = "round"; // [round, square, flat]
    preset_size = 10; // [10:Small, 20:Medium, 30:Large]
    ```
*   **Checkboxes**: Assign boolean values (`true` / `false`)
    ```openscad
    include_cap = true;
    ```
*   **Grouping & Tabs**: Use `/* [Group Name] */` to group parameters, and `/* [Hidden] */` to hide internal non-customizer variables from the Customizer UI.
    ```openscad
    /* [Bottle Dimensions] */
    height = 150; // [100:250]

    /* [Hidden] */
    $fn = 64;
    ```

---

## 5. Multi-Object 3MF Export (Lazy Union)

When exporting assemblies for multi-color or multi-part 3D printing in slicers (like Bambu Studio, PrusaSlicer, or OrcaSlicer), export to `.3mf` with **Lazy Union** enabled:

1. **Avoid Module Wrapping**: Instantiating a module in OpenSCAD implicitly unions all its child geometries into a single mesh. To keep objects separate in the exported file, instantiate them directly at the **top level** of the `.scad` script (e.g., inside top-level `if-else` blocks).
2. **Group Sub-Assemblies**: Wrap parts that must remain merged (e.g., a body and its hinge knuckles) in a `union()` block at the top level.
3. **Command-Line Export**:
   ```bash
   openscad -o output/out.vXX.3mf --enable lazy-union output/out.vXX.scad
   ```
4. **Best Practices**:
   - Use `.stl` files for single-object rendering, slicing, and 2D projection clearance tests.
   - Use `.3mf` files (with `--enable lazy-union`) for exporting multi-part assemblies to slicers.
