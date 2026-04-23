// openluminance — tile mechanical assembly, draft v0.3
//
// TWO-PIECE print: FRAME (main body, closed back, open front) + DIFFUSER
// (100 × 100 × 1.5 mm panel with a continuous inner rim that press-fits
// into the frame opening). The back cap of earlier drafts is merged into
// the frame as an integrated rear wall with ventilation slots.
//
// The diffuser covers the entire front face edge-to-edge, so when two
// tiles sit side-by-side the glow runs continuously across the seam —
// no visible frame lip interrupting the line.
//
// Overall assembled height: 15 mm (frame 13.5 mm + diffuser 1.5 mm).
//
// EDGE CONNECTOR — matches the 8-pin palindromic spec in
// docs/architecture.md. Reading pins 1..8 at increasing Y along the +X
// edge:
//
//     pin 1 (low Y)  → GND
//     pin 2          → V+   (24 V backbone)
//     pin 3          → BUS_A
//     pin 4          → BUS_B
//     pin 5          → BUS_B  (paralleled with pin 4)
//     pin 6          → BUS_A  (paralleled with pin 3)
//     pin 7          → V+     (paralleled with pin 2)
//     pin 8 (high Y) → GND    (paralleled with pin 1)
//
// 24 V POWER RAIL — not a separate bus bar. It's distributed by the PCB:
// V+ pins on every populated edge tie to a single V+ net; GND pins all
// tie to a single GND net. Power enters on any edge, exits on any
// (unoccupied) neighbouring edge. The buck converter on the PCB taps
// this net locally. With all 4 edges populated, power can flow in any
// direction through the tile array — no dedicated power-injection edge
// required.
//
// BUS_A and BUS_B behave similarly for the RS-485 signal, with one
// wrinkle: a full 4-edge tie would make the bus a mesh with reflections.
// The v1 PCB populates BUS_A/BUS_B on only two edges (one chain). v2
// PCBs will use per-edge analogue switches (e.g. TS5A3166) to make the
// bus routable under firmware control. The frame geometry is the same
// for both.
//
// EDGE MAGNETS — tiles attach edge-to-edge. Two magnets per populated
// edge, offset from the edge midpoint. Polarity follows a CCW-handed
// rule so any edge pair mates correctly in any rotation:
//
//     +X edge    N outward at LOW Y,   S outward at HIGH Y
//     +Y edge    N outward at HIGH X,  S outward at LOW X
//     -X edge    N outward at HIGH Y,  S outward at LOW Y
//     -Y edge    N outward at LOW X,   S outward at HIGH X
//
// COORDINATE SYSTEM — the SCAD model uses "use orientation":
//     z = 0           → closed back outer face (build plate when printing)
//     z = BACK_THICK  → back inner face (interior begins)
//     z = FRAME_H     → top of the frame walls (where the diffuser sits)
//     z = TILE_HEIGHT → diffuser front face (assembled tile outer front)
//
// PRINT ORIENTATION — frame prints back-face DOWN on the build plate, no
// overhangs except the back-face vent slots (bridges cleanly). Diffuser
// prints flat, rim up or down either way.
//
// Set RENDER at the top to export a specific part.

/* ============================ parameters ============================ */

RENDER           = "assembly";   // "frame" | "diffuser" | "light_guide" | "assembly"

// ----- overall -----
TILE_SIZE        = 100;
TILE_HEIGHT      = 15;

// ----- split: frame height + diffuser thickness = TILE_HEIGHT -----
DIFFUSER_THICK   = 1.5;
FRAME_H          = TILE_HEIGHT - DIFFUSER_THICK;   // 13.5

// ----- frame walls and back -----
WALL_THICK       = 2;
BACK_THICK       = 2;     // integrated rear wall (was the "back cap")

// ----- interior PCB bay -----
PCB_THICK        = 1.6;
PCB_BACK_SPACE   = 4;     // between inner back face and PCB bottom face
                          // (budget for SMD components on the PCB back)
PCB_BOTTOM_Z     = BACK_THICK + PCB_BACK_SPACE;        // 6.0
PCB_TOP_Z        = PCB_BOTTOM_Z + PCB_THICK;           // 7.6
PCB_CENTER_Z     = (PCB_BOTTOM_Z + PCB_TOP_Z) / 2;     // 6.8

// LED height above PCB top (SK6812 5050 ~1.4 mm body)
LED_HEIGHT       = 1.5;
LED_TOP_Z        = PCB_TOP_Z + LED_HEIGHT;             // 9.1
DIFFUSER_GAP     = FRAME_H - LED_TOP_Z;                // 4.4 — plenty

// ----- corner bosses (PCB screws and optional back magnets) -----
// Bosses stop at the PCB bottom face so the PCB sits flat on top of them.
// Avoids the need for 10 × 10 mm corner cutouts in the PCB, preserving
// the corner LED positions of the 5 × 5 grid.
CORNER_BOSS_XY   = 10;                                 // reduced from 14
CORNER_BOSS_Z_LO = BACK_THICK;                         // 2
CORNER_BOSS_Z_HI = PCB_BOTTOM_Z;                       // 6 (was 9.6)

// ----- PCB retention -----
PCB_SCREW_OD     = 2.2;      // M2 self-tapping clearance
PCB_HOLE_INSET   = 4;        // screw hole from tile corner

// ----- edge connector -----
CONN_TYPE        = "pogo";   // "pogo" | "header"
CONN_PINS        = 8;
CONN_PITCH       = 2.54;
// Populate ALL FOUR edges by default. The frame supplies the geometry;
// the PCB decides which edges' signal pins are tied together (see
// header comment on 24 V power rail). Set to [0, 2] to model a v1
// PCB that only routes a linear chain.
CONN_EDGES       = [0, 1, 2, 3];   // 0=+X, 1=+Y, 2=-X, 3=-Y

// SHORT double-ended pogo pin — just enough to protrude and make contact
// when tiles sit essentially wall-to-wall. Common "short spring contact"
// or "short pogo pin" format on LCSC / AliExpress — search for e.g.
// "1.0mm pogo pin 5mm" or "P50-B short spring contact".
//
//   free length        5.0 mm (tip-to-tip, uncompressed)
//   compressed        ~4.0 mm
//   wall exposure      0.5 mm at each tile's outer face (at rest)
//   compressed gap     2 × 0.5 = 1 mm compression when mated (0.5 per side)
//   wall-to-wall gap  ~0 mm — tiles sit flush, springs loaded
POGO_PIN_OD      = 1.0;
POGO_PIN_HOLE    = 1.1;
POGO_FLANGE_OD   = 1.5;
POGO_FLANGE_H    = 0.6;
POGO_FREE_LEN    = 5.0;
POGO_COMPRESSED  = 4.0;
POGO_WALL_EXPOSE = 0.5;

// 1×8 pin header fallback
HEADER_BODY_W    = CONN_PINS * CONN_PITCH + 0.8;
HEADER_BODY_H    = 2.5;
HEADER_SLOT_H    = HEADER_BODY_H + 1.0;

// connector z-center: coincides with PCB centre height
CONN_Z_CENTER    = PCB_CENTER_Z;                       // 6.8

// ----- magnets (neodymium 5 × 2 mm discs) -----
MAG_OD           = 5;
MAG_H            = 2;
MAG_CLEAR_RAD    = 0.15;
MAG_CLEAR_AX     = 0.2;

EDGE_MAGNETS     = true;
BACK_MAGNETS     = false;   // only needed for metal-backplate wall mount
EDGE_MAG_OFFSET  = 20;      // from edge midpoint along the edge
EDGE_MAG_BOSS_D  = 3;       // inward extension from inner wall face
EDGE_MAG_BOSS_W  = 9;       // width along edge (> MAG_OD)
EDGE_MAG_BOSS_H  = 8;       // Z-extent of boss
// centre the magnets at the vertical midpoint of the frame interior
EDGE_MAG_Z_CENT  = (BACK_THICK + FRAME_H) / 2;         // 7.75
EDGE_MAG_BOSS_ZL = EDGE_MAG_Z_CENT - EDGE_MAG_BOSS_H/2;
EDGE_MAG_BOSS_ZH = EDGE_MAG_Z_CENT + EDGE_MAG_BOSS_H/2;

BACK_MAG_INSET   = 8;       // from tile corner, diagonal (BACK_MAGNETS = true)

// ----- back ventilation slots -----
BACK_VENT_W      = 3;
BACK_VENT_L      = 30;
BACK_VENT_ROWS   = 3;

// ----- diffuser rim (press-fit into frame interior opening) -----
// Diffuser is a 100 × 100 × DIFFUSER_THICK panel. On its back face, a
// continuous downward rim matches the frame's interior opening, creating
// a press-fit jar-lid closure. Light interference fit (negative
// clearance) gives a firm hold; bump to RIM_CLEAR = 0.05 if your printer
// over-extrudes.
RIM_CLEAR        = 0.20;     // per-side clearance (smaller = tighter)
RIM_DEPTH        = 3.0;      // how far the rim descends into the frame
RIM_T            = 1.2;      // rim wall thickness
DIFF_PULL_W      = 12;       // finger-pry slot on one edge
DIFF_PULL_D      = 1.2;

// ----- light guide (optional 3rd part — distinct-pixel look) -----
// 5 × 5 grid of pixel chambers that sits on top of the PCB, between the
// LEDs and the diffuser. Each chamber is LED_PITCH × LED_PITCH. Walls
// reflect stray light back into the intended cell, giving sharp pixel
// boundaries. Without this part, light blends smoothly across the
// diffuser.
LED_COLS         = 5;
LED_ROWS         = 5;
LED_PITCH        = 20;       // mm between LED centres
GUIDE_WALL_T     = 1.2;      // grid wall thickness
GUIDE_WALL_H     = 5.0;      // wall height (PCB top → near diffuser)
GUIDE_CLEAR      = 0.4;      // total per-side clearance vs interior

/* ============================ rendering ============================ */

$fn              = 48;

if      (RENDER == "frame")       frame();
else if (RENDER == "diffuser")    diffuser();
else if (RENDER == "light_guide") light_guide();
else if (RENDER == "assembly")    assembly_exploded();
else echo("RENDER must be \"frame\" | \"diffuser\" | \"light_guide\" | \"assembly\"");


/* ============================= assembly ============================= */

module assembly_exploded() {
    color("lightgrey") frame();

    // pogo pins installed in the frame (visualisation only)
    if (CONN_TYPE == "pogo") color("gold", 0.9) ghost_pogo_pins();

    // edge magnets colour-coded by polarity
    if (EDGE_MAGNETS) ghost_edge_magnets();

    // light guide (optional) floated up a bit
    color("white", 0.8)
        translate([0, 0, TILE_HEIGHT + 3])
            light_guide();

    // diffuser floated up further
    color("white", 0.45)
        translate([0, 0, TILE_HEIGHT + 12])
            diffuser();

    // ghost PCB for context
    %translate([(TILE_SIZE - 94) / 2, (TILE_SIZE - 94) / 2, PCB_BOTTOM_Z])
        cube([94, 94, PCB_THICK]);

    echo("=== palindromic pinout on populated edges ===");
    echo("pin 1 = GND,  2 = V+, 3 = BUS_A, 4 = BUS_B, 5 = BUS_B, 6 = BUS_A, 7 = V+, 8 = GND");
    echo("=== edge magnet polarity (outward face), CCW rule ===");
    echo("+X: N low-Y, S high-Y      -X: S low-Y, N high-Y");
}


/* =============================== frame =============================== */

module frame() {
    difference() {
        union() {
            frame_shell();
            frame_corner_bosses();
            if (CONN_TYPE == "pogo") frame_pogo_retainers();
            if (EDGE_MAGNETS)         frame_edge_magnet_bosses();
        }
        // subtractions
        frame_back_vents();
        frame_connector_cuts();
        if (BACK_MAGNETS) frame_back_magnet_pockets();
        if (EDGE_MAGNETS) frame_edge_magnet_pockets();
        frame_pcb_screw_holes();
    }
}

// ---- shell: box with closed back + walls, open at z = FRAME_H -----
module frame_shell() {
    difference() {
        cube([TILE_SIZE, TILE_SIZE, FRAME_H]);
        // hollow out the interior above the back thickness
        translate([WALL_THICK, WALL_THICK, BACK_THICK])
            cube([TILE_SIZE - 2 * WALL_THICK,
                  TILE_SIZE - 2 * WALL_THICK,
                  FRAME_H]);  // over-cut through the top (open front)
    }
}

// ---- back face ventilation slots --------------------------------------
module frame_back_vents() {
    for (i = [0 : BACK_VENT_ROWS - 1]) {
        y = (i + 1) * TILE_SIZE / (BACK_VENT_ROWS + 1);
        translate([(TILE_SIZE - BACK_VENT_L) / 2,
                   y - BACK_VENT_W / 2,
                   -0.1])
            cube([BACK_VENT_L, BACK_VENT_W, BACK_THICK + 0.2]);
    }
}

// ---- corner bosses for PCB screws (and optional back magnets) --------
module frame_corner_bosses() {
    h = CORNER_BOSS_Z_HI - CORNER_BOSS_Z_LO;
    for (xsign = [0, 1], ysign = [0, 1]) {
        x = xsign ? TILE_SIZE - CORNER_BOSS_XY : 0;
        y = ysign ? TILE_SIZE - CORNER_BOSS_XY : 0;
        translate([x, y, CORNER_BOSS_Z_LO])
            cube([CORNER_BOSS_XY, CORNER_BOSS_XY, h]);
    }
}

module frame_pcb_screw_holes() {
    // M2 self-tapping clearance through the corner boss, from below the
    // PCB up to the top of the boss.
    for (xsign = [0, 1], ysign = [0, 1]) {
        x = xsign ? TILE_SIZE - PCB_HOLE_INSET : PCB_HOLE_INSET;
        y = ysign ? TILE_SIZE - PCB_HOLE_INSET : PCB_HOLE_INSET;
        translate([x, y, CORNER_BOSS_Z_LO - 0.1])
            cylinder(h = CORNER_BOSS_Z_HI - CORNER_BOSS_Z_LO + 0.3,
                     d = PCB_SCREW_OD);
    }
}

module frame_back_magnet_pockets() {
    pocket_d = MAG_OD + 2 * MAG_CLEAR_RAD;
    pocket_h = MAG_H + MAG_CLEAR_AX;
    for (xsign = [0, 1], ysign = [0, 1]) {
        x = xsign ? TILE_SIZE - BACK_MAG_INSET : BACK_MAG_INSET;
        y = ysign ? TILE_SIZE - BACK_MAG_INSET : BACK_MAG_INSET;
        translate([x, y, -0.1])
            cylinder(h = pocket_h + 0.1, d = pocket_d);
    }
}

// ---- edge magnet bosses (inside of each populated edge) --------------
module frame_edge_magnet_bosses() {
    zh = EDGE_MAG_BOSS_ZH - EDGE_MAG_BOSS_ZL;
    for (e = CONN_EDGES) {
        for (s = [-1, 1]) {
            u = TILE_SIZE / 2 + s * EDGE_MAG_OFFSET;
            if (e == 0)
                translate([TILE_SIZE - WALL_THICK - EDGE_MAG_BOSS_D,
                           u - EDGE_MAG_BOSS_W / 2,
                           EDGE_MAG_BOSS_ZL])
                    cube([EDGE_MAG_BOSS_D, EDGE_MAG_BOSS_W, zh]);
            else if (e == 2)
                translate([WALL_THICK,
                           u - EDGE_MAG_BOSS_W / 2,
                           EDGE_MAG_BOSS_ZL])
                    cube([EDGE_MAG_BOSS_D, EDGE_MAG_BOSS_W, zh]);
            else if (e == 1)
                translate([u - EDGE_MAG_BOSS_W / 2,
                           TILE_SIZE - WALL_THICK - EDGE_MAG_BOSS_D,
                           EDGE_MAG_BOSS_ZL])
                    cube([EDGE_MAG_BOSS_W, EDGE_MAG_BOSS_D, zh]);
            else if (e == 3)
                translate([u - EDGE_MAG_BOSS_W / 2, WALL_THICK,
                           EDGE_MAG_BOSS_ZL])
                    cube([EDGE_MAG_BOSS_W, EDGE_MAG_BOSS_D, zh]);
        }
    }
}

module frame_edge_magnet_pockets() {
    pocket_d = MAG_OD + 2 * MAG_CLEAR_RAD;
    pocket_h = MAG_H + MAG_CLEAR_AX;
    for (e = CONN_EDGES) {
        for (s = [-1, 1]) {
            u = TILE_SIZE / 2 + s * EDGE_MAG_OFFSET;
            if (e == 0)
                translate([TILE_SIZE - pocket_h, u, EDGE_MAG_Z_CENT])
                    rotate([0, 90, 0])
                        cylinder(h = pocket_h + 0.2, d = pocket_d);
            else if (e == 2)
                translate([-0.1, u, EDGE_MAG_Z_CENT])
                    rotate([0, 90, 0])
                        cylinder(h = pocket_h + 0.2, d = pocket_d);
            else if (e == 1)
                translate([u, TILE_SIZE - pocket_h, EDGE_MAG_Z_CENT])
                    rotate([-90, 0, 0])
                        cylinder(h = pocket_h + 0.2, d = pocket_d);
            else if (e == 3)
                translate([u, -0.1, EDGE_MAG_Z_CENT])
                    rotate([-90, 0, 0])
                        cylinder(h = pocket_h + 0.2, d = pocket_d);
        }
    }
}

// ---- edge connector features ------------------------------------------

module frame_connector_cuts() {
    for (e = CONN_EDGES) {
        if (CONN_TYPE == "pogo") pogo_pin_cuts_on_edge(e);
        else                     header_slot_on_edge(e);
    }
}

module frame_pogo_retainers() {
    strip_len = (CONN_PINS - 1) * CONN_PITCH + POGO_FLANGE_OD + 0.5;
    retainer_th = 2.0;
    z_lo = CONN_Z_CENTER - POGO_FLANGE_OD / 2 - 0.5;
    z_hi = CONN_Z_CENTER + POGO_FLANGE_OD / 2 + 0.5;
    zh = z_hi - z_lo;
    for (e = CONN_EDGES) {
        if (e == 0)
            translate([TILE_SIZE - WALL_THICK - retainer_th,
                       TILE_SIZE / 2 - strip_len / 2, z_lo])
                cube([retainer_th, strip_len, zh]);
        else if (e == 2)
            translate([WALL_THICK,
                       TILE_SIZE / 2 - strip_len / 2, z_lo])
                cube([retainer_th, strip_len, zh]);
        else if (e == 1)
            translate([TILE_SIZE / 2 - strip_len / 2,
                       TILE_SIZE - WALL_THICK - retainer_th, z_lo])
                cube([strip_len, retainer_th, zh]);
        else if (e == 3)
            translate([TILE_SIZE / 2 - strip_len / 2, WALL_THICK, z_lo])
                cube([strip_len, retainer_th, zh]);
    }
}

module pogo_pin_cuts_on_edge(edge) {
    pin_y0 = TILE_SIZE / 2 - (CONN_PINS - 1) * CONN_PITCH / 2;
    for (i = [0 : CONN_PINS - 1]) {
        u = pin_y0 + i * CONN_PITCH;
        if (edge == 0)
            _pogo_one_cut([TILE_SIZE + 0.1, u, CONN_Z_CENTER], [90, 90, 0]);
        else if (edge == 2)
            _pogo_one_cut([-0.1, u, CONN_Z_CENTER], [-90, 90, 0]);
        else if (edge == 1)
            _pogo_one_cut([u, TILE_SIZE + 0.1, CONN_Z_CENTER], [90, 0, 0]);
        else if (edge == 3)
            _pogo_one_cut([u, -0.1, CONN_Z_CENTER], [-90, 0, 0]);
    }
}

module _pogo_one_cut(pos, rot) {
    translate(pos) rotate(rot) {
        // through-hole
        cylinder(h = WALL_THICK + 5, d = POGO_PIN_HOLE);
        // flange counterbore cut from the INSIDE face
        translate([0, 0, WALL_THICK])
            cylinder(h = POGO_FLANGE_H + 0.3, d = POGO_FLANGE_OD + 0.3);
    }
}

module header_slot_on_edge(edge) {
    slot_w = HEADER_BODY_W;
    slot_h = HEADER_SLOT_H;
    slot_z = CONN_Z_CENTER - slot_h / 2;
    if (edge == 0)
        translate([TILE_SIZE - WALL_THICK - 0.2,
                   (TILE_SIZE - slot_w) / 2, slot_z])
            cube([WALL_THICK + 0.4, slot_w, slot_h]);
    else if (edge == 2)
        translate([-0.2, (TILE_SIZE - slot_w) / 2, slot_z])
            cube([WALL_THICK + 0.4, slot_w, slot_h]);
    else if (edge == 1)
        translate([(TILE_SIZE - slot_w) / 2,
                   TILE_SIZE - WALL_THICK - 0.2, slot_z])
            cube([slot_w, WALL_THICK + 0.4, slot_h]);
    else if (edge == 3)
        translate([(TILE_SIZE - slot_w) / 2, -0.2, slot_z])
            cube([slot_w, WALL_THICK + 0.4, slot_h]);
}


/* ============================== diffuser ============================== */

// 100 × 100 × DIFFUSER_THICK panel. On the back face, a continuous
// rectangular rim descends into the frame interior for a press-fit.
// Rim outer dimensions = frame interior − 2 × RIM_CLEAR.
// Print orientation: rim up or rim down, either works.
module diffuser() {
    // outer rim footprint in plan (on X,Y)
    rim_outer = TILE_SIZE - 2 * WALL_THICK - 2 * RIM_CLEAR;   // ≈ 95.6
    rim_inner = rim_outer - 2 * RIM_T;                        // ≈ 93.2
    rim_origin = (TILE_SIZE - rim_outer) / 2;

    difference() {
        union() {
            // visible top plate — full tile footprint
            translate([0, 0, DIFFUSER_THICK])
                cube([TILE_SIZE, TILE_SIZE, 0.001])    // reference, removed below
                ;
            cube([TILE_SIZE, TILE_SIZE, DIFFUSER_THICK]);

            // continuous rim descending from the back face into the frame
            translate([rim_origin, rim_origin, -RIM_DEPTH])
                difference() {
                    cube([rim_outer, rim_outer, RIM_DEPTH]);
                    translate([RIM_T, RIM_T, -0.1])
                        cube([rim_outer - 2 * RIM_T,
                              rim_outer - 2 * RIM_T,
                              RIM_DEPTH + 0.2]);
                }
        }
        // finger-pry slot on one edge so the diffuser can be popped off
        translate([(TILE_SIZE - DIFF_PULL_W) / 2, -0.1, 0])
            cube([DIFF_PULL_W, DIFF_PULL_D + 0.1, DIFFUSER_THICK * 0.6]);
    }
}


/* ============================ light guide ============================ */

// Optional 5 × 5 pixel grid insert. Sits between PCB top (z = 7.6) and the
// underside of the diffuser, reaching up to z = 7.6 + GUIDE_WALL_H.
// Outer footprint matches the frame interior opening minus GUIDE_CLEAR.
// Pure passive optic — just a wall grid. No retention features; held in
// place by the PCB below and the diffuser rim above.
//
// Print orientation: walls build up from a flat base — print flat, walls
// print as thin tall columns. Use 2–3 perimeters for wall reliability.
// White PETG or PLA recommended (reflects stray light).
module light_guide() {
    outer = TILE_SIZE - 2 * WALL_THICK - 2 * GUIDE_CLEAR;   // ≈ 95.2
    origin = (TILE_SIZE - outer) / 2;

    // horizontal (along Y) interior walls at x = LED_PITCH, 2·LED_PITCH, ...
    translate([origin, origin, 0]) {
        // 5 × 5 lattice inside a bounding rectangle
        // outer perimeter (optional — lets the guide self-align to the
        // diffuser rim by matching its footprint)
        difference() {
            cube([outer, outer, GUIDE_WALL_H]);
            translate([GUIDE_WALL_T, GUIDE_WALL_T, -0.1])
                cube([outer - 2 * GUIDE_WALL_T,
                      outer - 2 * GUIDE_WALL_T,
                      GUIDE_WALL_H + 0.2]);
        }
        // interior walls along Y (vertical lines between X-columns)
        for (c = [1 : LED_COLS - 1]) {
            x = c * outer / LED_COLS - GUIDE_WALL_T / 2;
            translate([x, 0, 0])
                cube([GUIDE_WALL_T, outer, GUIDE_WALL_H]);
        }
        // interior walls along X (horizontal lines between Y-rows)
        for (r = [1 : LED_ROWS - 1]) {
            y = r * outer / LED_ROWS - GUIDE_WALL_T / 2;
            translate([0, y, 0])
                cube([outer, GUIDE_WALL_T, GUIDE_WALL_H]);
        }
    }
}


/* =========================== ghost geometry =========================== */
// Not for printing — renders pogo pins and magnets in the assembled
// positions for visual verification.

module ghost_pogo_pins() {
    pin_y0 = TILE_SIZE / 2 - (CONN_PINS - 1) * CONN_PITCH / 2;
    pin_len = POGO_FREE_LEN;
    for (e = CONN_EDGES) {
        for (i = [0 : CONN_PINS - 1]) {
            u = pin_y0 + i * CONN_PITCH;
            if (e == 0)
                translate([TILE_SIZE - pin_len/2 + POGO_WALL_EXPOSE,
                           u, CONN_Z_CENTER])
                    rotate([0, 90, 0]) _ghost_pin();
            else if (e == 2)
                translate([-POGO_WALL_EXPOSE - pin_len/2, u, CONN_Z_CENTER])
                    rotate([0, 90, 0]) _ghost_pin();
            else if (e == 1)
                translate([u, TILE_SIZE - pin_len/2 + POGO_WALL_EXPOSE,
                           CONN_Z_CENTER])
                    rotate([-90, 0, 0]) _ghost_pin();
            else if (e == 3)
                translate([u, -POGO_WALL_EXPOSE - pin_len/2, CONN_Z_CENTER])
                    rotate([-90, 0, 0]) _ghost_pin();
        }
    }
}

module _ghost_pin() {
    translate([0, 0, -POGO_FREE_LEN / 2])
        cylinder(h = POGO_FREE_LEN, d = POGO_PIN_OD);
    translate([0, 0, -POGO_FLANGE_H / 2])
        cylinder(h = POGO_FLANGE_H, d = POGO_FLANGE_OD);
}

module ghost_edge_magnets() {
    for (e = CONN_EDGES) {
        for (s = [-1, 1]) {
            u = TILE_SIZE / 2 + s * EDGE_MAG_OFFSET;
            is_N = (e == 0 && s == -1) ||    // +X low Y
                   (e == 1 && s ==  1) ||    // +Y high X
                   (e == 2 && s ==  1) ||    // -X high Y
                   (e == 3 && s == -1);      // -Y low X
            col = is_N ? "red" : "blue";
            if (e == 0)
                color(col) translate([TILE_SIZE - 1, u, EDGE_MAG_Z_CENT])
                    rotate([0, 90, 0]) cylinder(h = MAG_H, d = MAG_OD);
            else if (e == 2)
                color(col) translate([1 - MAG_H, u, EDGE_MAG_Z_CENT])
                    rotate([0, 90, 0]) cylinder(h = MAG_H, d = MAG_OD);
            else if (e == 1)
                color(col) translate([u, TILE_SIZE - 1, EDGE_MAG_Z_CENT])
                    rotate([-90, 0, 0]) cylinder(h = MAG_H, d = MAG_OD);
            else if (e == 3)
                color(col) translate([u, 1 - MAG_H, EDGE_MAG_Z_CENT])
                    rotate([-90, 0, 0]) cylinder(h = MAG_H, d = MAG_OD);
        }
    }
}
