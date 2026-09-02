# BOSL2 Library Map

Use this routing table before opening documentation. Search the installed source first, then the matching official wiki page. Read only the selected files and the example images they reference.

| Need | Source / wiki page | Search symbols or topics |
| --- | --- | --- |
| Attach and orient parts | `attachments.scad` and attachment tutorials | `attach`, `position`, `orient`, `anchor`, `diff`, tags |
| Basic rounded solids | `shapes3d.scad` | `cuboid`, `cyl`, `tube`, `prismoid`, rounding |
| 2D shapes | `shapes2d.scad` | `rect`, `circle`, `trapezoid`, anchors |
| ISO/UTS and generic threads | `threading.scad` | `threaded_rod`, `threaded_nut`, `generic_threaded_rod`, `internal`, `blunt_start`, `lead_in` |
| ACME/trapezoidal threads | `threading.scad` | `trapezoidal_threaded_rod`, `acme_threaded_rod` |
| Pipe threads | `threading.scad` | `npt_threaded_rod`, `bspp_threaded_rod` |
| Standard screws and holes | `screws.scad`, `screw_drive.scad` | `screw`, `screw_hole`, specifications, tolerance |
| Bottle closures | `bottlecaps.scad` | cap and neck standards, thread clearances |
| Knuckle and living hinges | `hinges.scad` | `knuckle_hinge`, `living_hinge_mask`, `gap`, `in_place`, `teardrop` |
| Folding hinges and snaps | `hinges.scad` | `apply_folding_hinges_and_snaps`, `snap_lock`, `snap_socket` |
| Gears | `gears.scad` | spur, helical, bevel, rack, backlash |
| Joinery | `joiners.scad` | dovetails, clips, joiners, masks |
| Paths, sweeps, and skins | `paths.scad`, `skin.scad` | `path_sweep`, `skin`, texture |
| Rounding arbitrary profiles | `rounding.scad` | `offset_sweep`, `round_corners`, roundovers |
| Direct mesh construction | `vnf.scad` | VNF, vertices, faces, validation |

Useful targeted searches from a directory containing `BOSL2/` and optionally `BOSL2.wiki/`:

```bash
rg -n "Module: threaded_rod|module threaded_rod|function threaded_rod" BOSL2/threading.scad BOSL2.wiki/threading.scad.md
rg -n "Module: knuckle_hinge|module knuckle_hinge|function knuckle_hinge" BOSL2/hinges.scad BOSL2.wiki/hinges.scad.md
rg -n "images/(threading|hinges)/" BOSL2.wiki/threading.scad.md BOSL2.wiki/hinges.scad.md
```

Official entry points:

- <https://github.com/BelfrySCAD/BOSL2>
- <https://github.com/BelfrySCAD/BOSL2/wiki/Topics>
- <https://github.com/BelfrySCAD/BOSL2/wiki/Tutorials>
- <https://github.com/BelfrySCAD/BOSL2/wiki/threading.scad>
- <https://github.com/BelfrySCAD/BOSL2/wiki/hinges.scad>
