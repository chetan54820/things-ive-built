//==================================================
// ENGINEERING DISC (first pass)
//
// Sits on the puck's 3 ledge segments (kyber_puck_v2.scad,
// engineering_ledge() -- inner_r=50, so this disc's outer edge
// needs to match that to rest flush).
//
// Job: mount the FIXED pin+ear connector dead-center, on-axis,
// at a fixed rotation, pins facing UP toward the descending foot.
// Wire tail exits downward toward the MCU below.
//
// NOT modeled here: the NeoPixel ring itself (still don't have its
// real dimensions -- flagged earlier in the project and never
// resolved). It sits somewhere in the open space above this disc;
// most ring-style NeoPixel PCBs have an open center anyway, so it
// shouldn't need a hole through THIS part, just clearance above it.
//==================================================

$fn = 64;

/* [Disc] — ADAPTED for the original 70mm prototype puck
   (Reya_Puckmvp.scad). Was 99.3mm for the 110mm puck. */
disc_diameter  = 63;   // matches prototype's ledge inner_r*2 (32*2),
                          // same ~0.7% clearance margin as before
disc_thickness = 3;      // matches prototype's plate_thickness, unchanged

/* [Bayonet lock — THIS is where the real lock lives now, not the
   ring above. The ring only guides; this is what actually secures
   the crystal AND guarantees pogo contact, since both happen from
   the same rotation with no tolerance gap between them. */
foot_diameter          = 24;   // MATCH crystal_foot_v6.scad. Stays
                                // 24mm -- the 25mm connector slot
                                // overhangs the collar bore by only
                                // 0.3mm at each end, leaving 2.4mm of
                                // the 2.7mm collar wall intact there.
bayonet_lug_width_deg  = 20;   // MATCH foot's lug_width_deg
bayonet_clearance_deg  = 8;    // was 3° -- confirmed too tight for
                                // reliable PETG printing, widened
                                // significantly
bayonet_lug_thickness  = 2.2;  // MATCH foot's lug_thickness. Was 1.6
                                // -- thickened because widening the
                                // bore to +2 ate the lug's engagement
                                // (1.20mm -> 0.60mm). At 2.2 it's back
                                // to the original 1.20mm of catch.
bayonet_entry_angle    = -90;  // MATCH ring's guide slot angle
bayonet_locked_angle   = 12.5;    // matches the connector's own fixed
                                // angle (see conn mount section) —
                                // lock completes exactly when pins
                                // reach the pads, same motion
bayonet_collar_height  = 9;    // rises UP from the disc surface,
                                // around the descending foot
bayonet_lip_thickness  = 1.5;  // material ABOVE the groove — this
                                // is what actually retains the lug
bayonet_groove_height  = 4;    // was 3.4mm (only 0.4mm margin over
                                // the 3mm lug) -- widened to 1mm
                                // margin for reliable PETG fit

module bayonet_collar()
{
    difference()
    {
        cylinder(h = bayonet_collar_height,
                  d = foot_diameter + bayonet_lug_thickness*2 + 3);
        // clearance bore for the foot shaft itself to pass through
        translate([0,0,-1])
            // BORE WIDENED: +0.8 -> +2 (26mm). Gives the 25mm
            // connector real room instead of a 0.3mm bite out of the
            // collar wall, and gives the foot deliberate wiggle room
            // to find the lock -- the pogo magnets self-align, so
            // slop here costs nothing electrically.
            cylinder(h = bayonet_collar_height + 2, d = foot_diameter + 1.5);
    }
}

module bayonet_entry_slot()
{
    // full-height cut, lug drops through here past the groove level
    arc = bayonet_lug_width_deg + bayonet_clearance_deg;
    rotate([0,0, bayonet_entry_angle - arc/2])
        rotate_extrude(angle = arc)
            translate([foot_diameter/2 - 0.5, -1])
                square([bayonet_lug_thickness + 1, bayonet_collar_height + 2]);
}

module bayonet_lock_groove()
{
    // horizontal channel the lug rotates into. Lip material sits
    // ABOVE this (between the groove and the collar's open top),
    // which is what stops the foot pulling back out once locked.
    arc_start = min(bayonet_entry_angle, bayonet_locked_angle);
    arc_span  = abs(bayonet_locked_angle - bayonet_entry_angle);
    rotate([0,0, arc_start])
        rotate_extrude(angle = arc_span)
            translate([foot_diameter/2 - 0.5,
                       bayonet_collar_height - bayonet_lip_thickness - bayonet_groove_height])
                square([bayonet_lug_thickness + 1, bayonet_groove_height]);
}
/* [Connector mount - pin+ear side, FIXED]
   Measured: 24.8mm ear-to-ear, 5.9mm height, 15.6mm body-only length.
   conn_body_width CORRECTED to 6.2mm -- the 5.5mm value here was
   stale, already superseded by an earlier test print that found
   5.5mm too tight. This file never got that correction applied,
   which is almost certainly why the connector doesn't fit. */
conn_body_length  = 24.8;    // MEASURED, FULL length including ears --
                            // the ears press in with the body now,
                            // they are not resting on anything
conn_body_width   = 5.1;   // CORRECTED, was stale 5.5mm
conn_corner_r     = 1.5;   // ASSUMED — same rounded-rect connector
                            // family as the pad side. Not measured
                            // exactly, flag if visibly off.
slot_clearance    = 0;   // PRESS FIT. 0.6mm was sized as drop-in
                            // clearance back when the ears carried
                            // the load; now friction holds the
                            // connector, so this needs to be tight.
                            // Open up with a needle file if too snug.

// hull of 4 corner cylinders — matches the rounded-rect connector
// body shape instead of a plain cube
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
//ear_hole_spacing  = 21.7;  // MEASURED (caliper, ear-to-ear across
                            // the mounting holes)

// Orientation: connector's long axis along X, at the disc's fixed
// rotation reference (angle=0). This MUST match wherever the foot's
// bayonet lug ends up pointing at its 90° locked position — that
// geometry doesn't exist yet (ring's L-slot, still to be built),
// so treat this angle=0 as the reference the ring geometry has to
// be built around, not the other way around.

/* [NeoPixel ring registration recess] — ADAPTED. Your original 85mm
   ring physically cannot fit inside a 70mm puck at all (confirmed:
   ring alone is 15mm wider than the whole puck). This targets a
   real, purchasable 12-pixel WS2812B ring instead: 50mm OD / 35mm ID
   -- also matches the original "50mm NeoPixel" spec from early on. */
ring_recess_od    = 53;   // was 50 (exact ring OD, zero clearance --
                           // confirmed it sat on top instead of
                           // dropping in). +3mm so it can actually
                           // seat.
ring_recess_id    = 33;   // was 35 (exact ring ID) -- pulled in 2mm
                           // so the ring drops INTO the recess rather
                           // than sitting on top of it. The 27mm-foot
                           // collar clash that forced 34mm is gone now
                           // the foot is back to 24mm: 1.4mm clear.
ring_recess_depth = 3;    // unchanged -- fixed hardware (LED+PCB
                           // stack), not tied to puck size

// hub_boss is now full-width (matches disc_diameter, no taper needed
// since there's no step to taper away). Only needs enough depth for
// the ring_recess's floor thickness -- NOT a radial step anymore.
hub_extra_depth   = 2;    // was 6.8mm when tapered -- floor thickness
                           // (ring_recess_depth 3mm - disc_thickness
                           // 3mm + 2mm target floor) is all that's
                           // actually required now. Frees the rest
                           // of the vertical budget for the MCU.

module ring_recess()
{
    translate([0, 0, disc_thickness - ring_recess_depth])
        difference()
        {
            cylinder(h = ring_recess_depth + 1, d = ring_recess_od);
            translate([0,0,-0.5])
                cylinder(h = ring_recess_depth + 2, d = ring_recess_id);
        }
}

/* [NeoPixel ring wire channel] */
// The ring's own wire leads (separate from the pin connector's tail,
// which already exits through connector_slot) need a path from the
// recess down to the MCU below. Placed at 90° from the connector's
// X-axis reference so it's clear of the connector footprint.
// ASSUMED position/size — move ring_wire_angle to wherever your
// actual ring's solder pads/leads exit, and check the diameter
// against your actual wire gauge (2-3 conductors typically).
ring_wire_dia   = 5.0;   // was 3.5 -- same margin fix as the foot's
                          // wire channel, in case the ring uses
                          // similar-gauge wire
ring_wire_angle = 90;
ring_wire_r     = (ring_recess_od + ring_recess_id) / 4;  // mid-annulus

module ring_wire_channel()
{
    rotate([0, 0, ring_wire_angle])
        translate([ring_wire_r, 0, -(hub_extra_depth + 1)])
            cylinder(h = disc_thickness + hub_extra_depth + 2, d = ring_wire_dia);
}

module hub_boss()
{
    // REDESIGNED: puck is already printed at 24mm, can't grow it, so
    // the fix has to live entirely in the disc. The previous tapered
    // hub (narrow at bottom, widening to disc_r) needed 6.8mm of
    // depth just to keep the taper angle safe at 45deg -- that alone
    // ate most of the available vertical budget, leaving only 4mm
    // for the MCU.
    //
    // Insight: a taper is only needed because the hub was NARROWER
    // than the disc above it. Made it the SAME width as the disc
    // instead -- zero step, zero overhang, at ANY depth. Now it only
    // needs to be as deep as the ring_recess's floor actually
    // requires (2mm), not as deep as matching a radial step. Frees
    // up 4.8mm of vertical budget directly for MCU clearance
    // (4.0mm -> 8.8mm) without touching the puck at all.
    translate([0, 0, -hub_extra_depth])
        cylinder(h = hub_extra_depth, d = disc_diameter);
}

module hub_boss_OLD_UNUSED()
{
    hub_r = ring_recess_od / 2;
    disc_r = disc_diameter / 2;
    translate([0, 0, -hub_extra_depth])
        cylinder(h = hub_extra_depth, r1 = hub_r, r2 = disc_r);
}

module disc_base()
{
    cylinder(h = disc_thickness, d = disc_diameter);
}

/* [Connector slot — full 25mm, body AND ears press in together]
   NOT a two-level pocket with the ears resting on a ledge: the
   ear-to-body height step is finer than this printer can hold, so
   relying on it would never seat consistently. Instead the whole
   connector -- body plus ears -- press fits into one straight
   through-cut. Nothing depends on that height step, and nothing sits
   proud in the rotating foot's path. */
module connector_slot()
{
    slot_l = conn_body_length + slot_clearance*2;
    slot_w = conn_body_width  + slot_clearance*2;
    translate([0, 0, -(hub_extra_depth + 1)])
        rounded_rect_prism(slot_l, slot_w,
                            disc_thickness + hub_extra_depth + 2,
                            conn_corner_r);
}

// REMOVED: alignment_pegs -- the whole connector now press fits into
// the slot, so nothing needs pegging and nothing stands proud. The
// foot's matching relief slots are removed too.

module engineering_disc()
{
    difference()
    {
        union()
        {
            disc_base();
            hub_boss();
            bayonet_collar();
        }
        connector_slot();
        ring_recess();
        ring_wire_channel();
        bayonet_entry_slot();
        bayonet_lock_groove();
    }
}

engineering_disc();
