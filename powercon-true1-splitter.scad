$fn = 80;

meh            =  0.01;
wall           =  3.35;
corner_radius  =  3.0;
diameter       = 28.7;
radius         = diameter / 2;
connectordepth = 30;
conndepth2     = 22.5;  // shallow part of in+out connector
freespace      = 18;    // cavity for wires and faston connectors
shift          = -3 + -0.5;
screw          =  2.6;  // PETG: 2.5, ABS: 2.6
screwdepth     = 14;
screwdist_y    = 24.4;
screwdist_x    = 50.0;

mountscrew     =  4.5;
mountscrewhead =  9.5;
mountscrewwall =  2.4;
mountscrewstop = 30;
mountscrewdist =  0;
mountscrewsize = mountscrewhead + 2 * mountscrewwall;
mountscrewoverlap = 5;

length         = connectordepth + freespace + wall;  // actually, the depth now...
inwidth        = 2 * diameter + shift + 2 * wall;
outwidth       = diameter + 2 * wall;
width          = outwidth + inwidth + 2 * mountscrewsize - 2 * mountscrewoverlap;
height         = diameter + 2 * wall;

echo(width, height);  // Neutrik NAC3PX is 61 x 35.4

module screwhole() {
    rotate([-90, 0, 0]) cylinder(h = screwdepth, d = screw);
}

module screwholes_through() {
    r = mountscrewsize / 2;
    y = length - r;
    x = width - (mountscrewsize / 2);
    translate([r,  r, 0]) cylinder(h = height, d = mountscrew);
    translate([x,  r, 0]) cylinder(h = height, d = mountscrew);
    translate([r,  y, 0]) cylinder(h = height, d = mountscrew);
    translate([x,  y, 0]) cylinder(h = height, d = mountscrew);

    translate([r,  r, 0]) cylinder(h = height - mountscrewstop, d = mountscrewhead);
    translate([x,  r, 0]) cylinder(h = height - mountscrewstop, d = mountscrewhead);
    translate([r,  y, 0]) cylinder(h = height - mountscrewstop, d = mountscrewhead);
    translate([x,  y, 0]) cylinder(h = height - mountscrewstop, d = mountscrewhead);

}

module bridgehack(depth) {
    // The flame retardant ABS doesn't bridge well.
    // This angled overhang is a workaround; it gets hidden behind the connector.
    radius = 5.5;
    translate([-11, 0, 0]) rotate([0, 0, 36]) cylinder(h = depth + meh, r = radius, $fn=5);
}


module powercon_true1_outlet() {
    translate([radius, 0, radius]) rotate([-90, 0, 0]) {
        cylinder(h = connectordepth + meh, r = radius);
	bridgehack(connectordepth);
    }

    xy = (diameter - screwdist_y) / 2;
    translate([xy,               0, xy + screwdist_y]) screwhole();
    translate([xy + screwdist_y, 0, xy              ]) screwhole();
}

module powercon_true1_combi() {
    translate([radius, 0, radius]) rotate([-90, 0, 0]) {
            x = diameter + shift;
            translate([x, 0, 0]) {
                cylinder(h = connectordepth + meh, r = radius);
                bridgehack(connectordepth);
            }
            hull() {
                translate([0, 0, 0]) cylinder(h = conndepth2, r = radius);
                translate([x, 0, 0]) cylinder(h = conndepth2, r = radius);
            }
            bridgehack(conndepth2);
    }

    x = (2 * diameter + shift - screwdist_x) / 2;
    y = (diameter - screwdist_y) / 2;
    translate([x,               0, y              ]) screwhole();
    translate([x + screwdist_x, 0, y              ]) screwhole();
    translate([x,               0, y + screwdist_y]) screwhole();
    translate([x + screwdist_x, 0, y + screwdist_y]) screwhole();
}

module outer() {
	difference() {
	    translate([corner_radius, 0, corner_radius]) {
			minkowski() {
				sphere(corner_radius);
				cube([width - corner_radius*2, length - corner_radius, height - corner_radius]);
			}
		}
	    translate([0, -corner_radius - meh, 0]) {
			cube([width, corner_radius + meh*2, height]);
		}
	    translate([0, -corner_radius, height - meh]) {
			cube([width, length + corner_radius, corner_radius + meh*2]);
		}
	}
}

module inner() {
    translate([0,        0, 0]) powercon_true1_outlet();
    translate([outwidth, 0, 0]) powercon_true1_combi();

    translate([radius, 0, radius]) rotate([-90, 0, 0]) {
        // cavity for wires
        translate([0, 0, connectordepth]) {
            hull () {
                x = outwidth + shift + diameter;
                translate([0, 0, 0]) cylinder(h = freespace, r = radius);
                translate([x, 0, 0]) cylinder(h = freespace, r = radius);
            }
            bridgehack(freespace);
        }
    }
}

translate([0, 0, width]) rotate([0, 90, 0]) {
    difference() {
        outer();
        translate([wall + mountscrewsize - mountscrewoverlap, -meh, wall]) inner();
        screwholes_through();
    }
}

