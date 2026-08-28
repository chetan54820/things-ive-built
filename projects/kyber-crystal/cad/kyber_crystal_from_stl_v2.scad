//==================================================
// KYBER CRYSTAL — from imported STL (kyber_crystal.stl)
//
// Original mesh: 12.5x12.5mm footprint, 46mm tall, centered around
// (-55.3, -40.2) in its own file, base at z=10. Recentered here to
// (0,0) with base at z=0, then scaled to hit the 75mm target height.
//
// IMPORTANT: place kyber_crystal.stl in the SAME FOLDER as this
// file before rendering -- import() needs it at render time.
//
// Hollowing technique: this is an ARBITRARY imported mesh, not one
// of our own point-array shapes, so the precise inset() trick used
// elsewhere in this project doesn't apply. Using the standard (but
// approximate) scaled-inner-copy technique instead -- wall thickness
// will vary by location (thicker at the wide "belt", thinner near
// the tip) rather than being uniform. Biased toward a safer/thicker
// wall rather than risking a too-thin one.
//==================================================

$fn = 32;

/* [Import + scale] */
raw_offset    = [55.3, 40.2, -10];  // undoes the original mesh's
                                     // off-center position, puts
                                     // its base at z=0
target_height = 100;
raw_height    = 46;
scale_factor  = target_height / raw_height;   // ~1.630

/* [Hollowing] */
inner_scale = 0.8;   // approximate wall thickness control -- lower
                       // number = thicker walls. 0.85 chosen to keep
                       // the narrowest point (~6.4mm outer radius
                       // near the base, before scaling) from getting
                       // dangerously thin.

module crystal_outer_raw()
{
    scale([scale_factor, scale_factor, scale_factor])
        translate(raw_offset)
            import("kyber_crystal.stl");
}

module crystal_inner_raw()
{
    scale([scale_factor*inner_scale, scale_factor*inner_scale, scale_factor*inner_scale])
        translate(raw_offset)
            import("kyber_crystal.stl");
}

/* [Lock housing — REBUILT for the new split shaft/foot design.
   The old 30mm housing + 24.6mm foot_bore are now obsolete: the
   foot no longer passes through the shell at all (it press-fits
   onto the shaft's exposed bottom end, outside/below the shell).
   Only the thin 8mm shaft enters, so this can be much smaller --
   which also directly helps the "cactus" look, since there's much
   less bulk at the base fighting the crystal's own taper. */
shaft_diameter      = 12;    // MATCH crystal_shaft_v1.scad
housing_od          = 24;   // was 30 -- only needs to clear the
                             // shaft + its lugs + reasonable wall now
housing_height      = .1;
shaft_hole_dia      = 15;    // shaft clearance for the new 7mm
                               // shaft (was 9mm, sized for the old
                               // 8mm shaft + lug clearance -- no
                               // longer needs lug clearance at all)

blend_ring_r = 9;      // widened further -- generous, not trying to
                        // precisely match the mesh's actual shape
blend_ring_z = 15;      // was 7, now pushed much deeper. The real
                         // problem wasn't overlap DISTANCE, it was
                         // that a circular ring approximation and
                         // the mesh's actual irregular cross-section
                         // don't perfectly match -- more distance
                         // alone doesn't fix a shape mismatch. This
                         // pushes deep enough that genuine volumetric
                         // overlap should hold regardless of exactly
                         // how the mesh's real shape diverges from a
                         // circle. Trade-off: housing extends further
                         // up, more visually present -- prioritizing
                         // not shipping a leaking print over the
                         // "cactus" concern for now.

module lock_housing()
{
    union()
    {
        translate([0,0,-housing_height])
            cylinder(h = housing_height + blend_ring_z, r = housing_od/2);
        hull()
        {
            translate([0,0,blend_ring_z - 0.01])
                cylinder(h=0.01, r=housing_od/2);
            translate([0,0,blend_ring_z])
                cylinder(h=0.01, r=blend_ring_r);
        }
    }
}

module shaft_passage()
{
    // single plain passage, full height, no more split -- the wide
    // foot never enters this part anymore
    translate([0,0,-housing_height-1])
        cylinder(h = housing_height + blend_ring_z + 2, d = shaft_hole_dia);
}

// REMOVED: bayonet lock cuts (collar/groove). Confirmed unreliable
// in PETG at this tolerance -- lugs never seated cleanly. Plain
// press-fit through shaft_passage() (below) is fine on its own.
// shaft_diameter updated to match crystal_shaft_v3.scad's new 7mm
// (was 8mm), with shaft_hole_dia clearance following accordingly.
//shaft_diameter = 7;   // MATCH crystal_shaft_v3.scad

//------------------------------
// Final assembly
//------------------------------
module hollow_crystal_from_stl()
{
    difference()
    {
        union()
        {
            crystal_outer_raw();
            lock_housing();
        }
        crystal_inner_raw();
        shaft_passage();
    }
}

//------------------------------
// BUILT-IN SUPPORT WEDGE — not a removable slicer support, a
// permanent part of the print. Positioned at the branch, detected
// via an angular gap in the mesh (z=19-26mm, direction ~143deg in
// XY) -- approximate, not exact coordinates like our hand-built
// crystal, since this is an arbitrary imported mesh without proper
// mesh-analysis tools available. Sized generously (not a delicate
// thin strut) specifically because the positioning is approximate --
// better to have a visible, definitely-connected wedge than a
// precisely-placed thin one that might miss the actual overhang.
//
// WORTH DOING: check this visually once rendered, and consider also
// trying a tilted print orientation in the slicer (free, no geometry
// change) as a complementary/alternative fix.
//------------------------------
wedge_angle    = 143;
wedge_r_inner  = 3;    // near the trunk's own core
wedge_r_outer  = 13;   // reaches out toward the branch
wedge_z_low    = 17;
wedge_z_high   = 27;
wedge_thickness = 3;   // generous, not delicate

module support_wedge()
{
    rotate([0,0,wedge_angle])
        hull()
        {
            translate([wedge_r_inner,0,wedge_z_low])
                sphere(r=wedge_thickness/2);
            translate([wedge_r_inner,0,wedge_z_high])
                sphere(r=wedge_thickness/2);
            translate([wedge_r_outer,0,wedge_z_low])
                sphere(r=wedge_thickness/2);
            translate([wedge_r_outer,0,wedge_z_high])
                sphere(r=wedge_thickness/2);
        }
}

//------------------------------
// Final assembly
//------------------------------
module hollow_crystal_from_stl_supported()
{
    hollow_crystal_from_stl();
}

hollow_crystal_from_stl_supported();
