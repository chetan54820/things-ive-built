//==================================================
// CRYSTAL SHAFT — separate piece, no longer fused to the foot
//
// Splitting from the foot solved the original insertion-jam problem
// (the old fused transition cone couldn't pass through the shell's
// narrow passage). The top-lug bayonet lock that came with that
// split has since been REMOVED too -- confirmed unreliable in PETG
// at this tolerance. Plain press-fit through the shell's passage,
// same as the foot-to-shaft joint below.
//==================================================

$fn = 32;

/* [Shaft] */
shaft_diameter = 9;   // was 8mm -- reduced to the structural floor
                       // (5mm wire channel + 1mm wall each side).
                       // Wrapped OD (LED protruding 1.5mm) ~10.6mm,
                       // down from ~11.6mm.
shaft_length   = 65;   // placeholder, same as before

/* [Press-fit peg — plugs into the foot]
   WIDENED from 6mm to 7.5mm. The old 6mm peg had a 5mm wire channel
   bored through its own center, leaving only ~0.4mm of wall -- too
   thin to print reliably, and left no room for the wire bundle to
   coexist with the peg in that space. MATCH crystal_foot_v3.scad's
   socket_dia=7.5 exactly.
*/
peg_diameter = 14.7;   // was 6
peg_length   = 7;
//peg_clearance = 0.15;

/* [Wire channel — runs the full length, into the peg too] */
wire_channel_dia = 7;

module shaft_body()
{
    cylinder(h = shaft_length, d = shaft_diameter);
}

module press_fit_peg()
{
    translate([0,0,-peg_length])
        cylinder(h = peg_length, d = peg_diameter );
}

module wire_channel()
{
    translate([0,0,-peg_length-1])
        cylinder(h = shaft_length + peg_length + 2, d = wire_channel_dia);
}

// REMOVED: top_lugs bayonet twist-lock -- confirmed unreliable in
// PETG at this scale/tolerance. Press-fit through the shell's plain
// passage is fine on its own.

module shaft()
{
    difference()
    {
        union()
        {
            shaft_body();
            press_fit_peg();
        }
        wire_channel();
    }
}

shaft();
