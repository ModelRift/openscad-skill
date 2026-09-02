/*
 * Dependency-free print-in-place hinge reference.
 * The fixed part owns a continuous faceted pin; the moving sleeves print
 * around it with radial clearance.
 */

/* [Hinge] */
hinge_length = 48; // [24:1:100]
leaf_depth = 22; // [12:1:50]
leaf_thickness = 2.0; // [1.2:0.2:4]
barrel_diameter = 6.4; // [4:0.2:10]
pin_diameter = 3.2; // [2:0.2:6]
radial_clearance = 0.30; // [0.15:0.05:0.6]
segment_gap = 0.40; // [0.2:0.05:0.8]
segments = 5; // [5, 7, 9]

/* [Display] */
view_mode = "demo"; // [demo, print, half_open, closed, fixed, moving]

/* [Hidden] */
$fn = 48;
epsilon = 0.02;
barrel_r = barrel_diameter / 2;
axis_z = barrel_r;
segment_length = (hinge_length - (segments - 1) * segment_gap) / segments;

function segment_start(index) =
    -hinge_length / 2 + index * (segment_length + segment_gap);

module x_cylinder(length, radius, facets = $fn) {
    rotate([0, 90, 0]) cylinder(h = length, r = radius, $fn = facets);
}

module fixed_leaf() {
    union() {
        translate([-hinge_length / 2, -barrel_r - leaf_depth, 0])
            cube([hinge_length, leaf_depth, leaf_thickness]);

        // Continuous octagonal pin: printable bridges span only moving segments.
        translate([-hinge_length / 2, 0, axis_z])
            x_cylinder(hinge_length, pin_diameter / 2, 8);

        for (index = [0 : segments - 1]) {
            if (index % 2 == 0) {
                x0 = segment_start(index);
                hull() {
                    translate([x0, 0, axis_z])
                        x_cylinder(segment_length, barrel_r);
                    translate([x0, -barrel_r - 1, 0])
                        cube([segment_length, 1, leaf_thickness]);
                }
            }
        }
    }
}

module moving_leaf_flat() {
    union() {
        translate([-hinge_length / 2, barrel_r, 0])
            cube([hinge_length, leaf_depth, leaf_thickness]);

        for (index = [0 : segments - 1]) {
            if (index % 2 == 1) {
                x0 = segment_start(index);
                difference() {
                    hull() {
                        translate([x0, 0, axis_z])
                            x_cylinder(segment_length, barrel_r);
                        translate([x0, barrel_r, 0])
                            cube([segment_length, 1, leaf_thickness]);
                    }
                    translate([x0 - epsilon, 0, axis_z])
                        x_cylinder(
                            segment_length + 2 * epsilon,
                            pin_diameter / 2 + radial_clearance,
                            32
                        );
                }
            }
        }
    }
}

module moving_leaf(angle = 0) {
    translate([0, 0, axis_z])
        rotate([angle, 0, 0])
            translate([0, 0, -axis_z])
                moving_leaf_flat();
}

module hinge_assembly(angle = 0) {
    color("gold") fixed_leaf();
    color("lightblue") moving_leaf(angle);
}

if (view_mode == "print") {
    hinge_assembly(0);
} else if (view_mode == "half_open") {
    hinge_assembly(90);
} else if (view_mode == "closed") {
    hinge_assembly(180);
} else if (view_mode == "fixed") {
    fixed_leaf();
} else if (view_mode == "moving") {
    moving_leaf_flat();
} else if (view_mode == "demo") {
    translate([-30, 0, 0]) hinge_assembly(0);
    translate([30, 0, 0]) hinge_assembly(90);
}
