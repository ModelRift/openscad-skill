/*
 * Dependency-free printable thread reference.
 * Use as a fit coupon before integrating the modules into a larger part.
 */

/* [Thread] */
nominal_diameter = 14; // [8:0.5:30]
pitch = 2.5; // [1.2:0.1:5]
thread_length = 12; // [6:1:30]
thread_depth = 0.75; // [0.4:0.05:1.5]
fit_clearance = 0.30; // [0.15:0.05:0.6]

/* [Display] */
part = "demo"; // [demo, male, female, assembled]

/* [Hidden] */
$fn = 40;
thread_quality = 12;
epsilon = 0.02;

module helical_ridge(major_d, thread_pitch, length, depth, clearance = 0) {
    minor_r = major_d / 2 - depth;
    turns = length / thread_pitch;
    slices = max(24, ceil(turns * thread_quality));
    crest_half = thread_pitch * 0.14;

    intersection() {
        cylinder(d = major_d + 2 * clearance, h = length);
        linear_extrude(
            height = length,
            twist = -360 * turns,
            slices = slices,
            convexity = 12
        )
        offset(delta = clearance)
            polygon([
                [minor_r, -thread_pitch * 0.36],
                [major_d / 2, -crest_half],
                [major_d / 2,  crest_half],
                [minor_r,  thread_pitch * 0.36]
            ]);
    }
}

module male_thread(major_d = nominal_diameter,
                   thread_pitch = pitch,
                   length = thread_length,
                   depth = thread_depth,
                   clearance = 0) {
    union() {
        cylinder(d = major_d - 2 * depth + 2 * clearance, h = length);
        helical_ridge(major_d, thread_pitch, length, depth, clearance);
    }
}

module female_thread_body(major_d = nominal_diameter,
                          thread_pitch = pitch,
                          length = thread_length,
                          depth = thread_depth,
                          clearance = fit_clearance,
                          wall = 3) {
    difference() {
        cylinder(d = major_d + 2 * wall, h = length);
        male_thread(
            major_d = major_d,
            thread_pitch = thread_pitch,
            length = length,
            depth = depth,
            clearance = clearance
        );
        translate([0, 0, -epsilon])
            cylinder(
                d1 = major_d + 2 * clearance + 1.2,
                d2 = major_d - 2 * depth + 2 * clearance,
                h = min(1.2, length / 4) + epsilon
            );
    }
}

module male_coupon() {
    union() {
        cylinder(d = nominal_diameter + 8, h = 3);
        translate([0, 0, 3]) male_thread();
    }
}

module female_coupon() {
    female_thread_body();
}

if (part == "male") {
    male_coupon();
} else if (part == "female") {
    female_coupon();
} else if (part == "assembled") {
    male_coupon();
    translate([0, 0, 3]) female_coupon();
} else if (part == "demo") {
    color("gold") translate([-13, 0, 0]) male_coupon();
    color("lightblue") translate([13, 0, 0]) female_coupon();
}
