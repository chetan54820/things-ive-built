//==================================================
// CRYSTAL FOOT — v2, now standalone (no more fused shaft)
//
// FIX: the old combined foot+transition+shaft was one rigid piece.
// The transition cone (up to 24mm wide, tapering to 8mm) had to
// physically pass through the shell's 9mm shaft passage for the top
// lugs (then on the foot) to ever reach the collar -- impossible for
// a solid cone that wide. That's why the lug never hit the notch.
//
// Fix: foot and shaft are now separate parts (see crystal_shaft_v1.
// scad). The bare shaft -- always thin, no wide taper -- slides
// through the shell easily and locks via its own lugs. THIS foot
// then press-fits onto the shaft's exposed bottom end afterward,
// via the socket at the top.
//
// Mechanism (bottom lug, disc lock) unchanged from before:
//   1. Foot inserts straight down through the ring's hole.
//   2. Rotates 90° (single asymmetric lug).
//   3. Lug seats under the disc's retaining lip.
//   4. At the 90° end-stop, the pad connector aligns with the disc's
//      fixed pin connector -- mechanical lock and electrical contact
//      complete at the same motion.
//
// ONE lug, not two symmetric ones — deliberate. A symmetric pair
// would let the foot lock at either of two rotations 180° apart,
// and since the pad row isn't symmetric, the 180°-flipped case would
// scramble GND/5V/DATA. One lug = one valid orientation.
//==================================================

$fn = 64;

/* [Foot] */
foot_diameter   = 24;   // stays 24mm -- MATCH engineering_disc_v4.
                         // The 25mm connector presses into the disc
                         // rather than needing the foot to clear its
                         // ears, so the foot never had to grow.
foot_length     = 4;

/* [Bayonet lug — disc lock, unchanged] */
lug_width_deg   = 20;
lug_thickness   = 2.2;     // was 1.6mm. The disc's collar bore was
                            // widened to 26mm for connector room and
                            // lock wiggle; without thickening the lug
                            // to match, engagement would have dropped
                            // from 1.2mm to 0.6mm. MATCH disc's
                            // bayonet_lug_thickness.
lug_height      = 1.5;
lug_z           = 2.5;

/* [Pad connector pocket — all measured, unchanged] */
pad_length    = 17;
pad_height    = 4.5;
pad_width     = 6.2;
pad_clearance = 0.1;
pad_corner_r  = 1.5;

/* [Peg relief] REMOVED. The disc's alignment pegs are gone (ears now
   seat flush in their own recess on the disc), so there is nothing
   left to clear. The arc-slot version added previously is therefore
   obsolete -- it existed only to let the foot rotate past those
   pegs. */

module rounded_rect_prism(l, w, h, r)
{
    hull()
    {
        for (x = [-l/2 + r, l/2 - r])
            for (y = [-w/2 + r, w/2 - r])
                translate([x, y, 0])
                    cylinder(h = h, r = r);
    }
}

/* [Wire channel through the foot, unchanged] */
wire_channel_dia = 5;
chamfer_height = 1.5;
chamfer_extra  = 2;

module wire_channel_lower()
{
    // straight bore + funnel chamfer down into the pocket, same as
    // before, but now it needs to reach UP to meet the socket instead
    // of a theoretical "future shaft"
    main_h = foot_length - pad_height + 1 - chamfer_height;
    union()
    {
        cylinder(h = main_h, d = wire_channel_dia);
        translate([0, 0, main_h])
            cylinder(h = chamfer_height,
                      d1 = wire_channel_dia,
                      d2 = wire_channel_dia + chamfer_extra);
    }
}

module foot_shaft()
{
    cylinder(h = foot_length, d = foot_diameter);
}

module bayonet_lug()
{
    rotate([0, 0, -lug_width_deg/2])
        rotate_extrude(angle = lug_width_deg)
            translate([foot_diameter/2 - 0.5, lug_z])
                square([lug_thickness + 0.5, lug_height]);
}

module pad_pocket()
{
    translate([0, 0, foot_length - pad_height])
        rounded_rect_prism(pad_length + pad_clearance*2,
                            pad_width + pad_clearance*2,
                            pad_height + 1,
                            pad_corner_r);
}

/* [Press-fit socket — WIDENED. The old 6mm socket/peg had a 5mm wire
   channel bored through its own center, leaving only ~0.4mm of wall
   -- too thin to print reliably, and left no room for the wire
   bundle (already threaded through this channel) to coexist with a
   peg trying to occupy the same space. That's why there wasn't
   enough room to actually mount the shaft.
   MATCH crystal_shaft_v1.scad's peg_diameter=7.5, peg_length=7.
*/
socket_dia    = 7.5;   // was 6
socket_depth  = 7.5;

module press_fit_socket()
{
    translate([0, 0, -0.5])
        cylinder(h = socket_depth, d = socket_dia);
}

module foot()
{
    difference()
    {
        union()
        {
            foot_shaft();
            bayonet_lug();
        }
        pad_pocket();
        wire_channel_lower();
        press_fit_socket();
    }
}

foot();
