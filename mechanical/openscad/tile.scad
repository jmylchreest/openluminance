// openluminance — tile mechanical assembly, draft v0.2
//
// Three-part assembly: FRAME (main print), DIFFUSER (interchangeable panel),
// BACK_CAP (removable cover with PCB access).
//
// EDGE CONNECTOR — matches the 8-pin palindromic spec in
// docs/architecture.md. Mechanical-electrical alignment from the PCB's
// perspective, reading pins 1..8 at increasing Y along the +X edge:
//
//     pin 1  (lowest Y)  →  GND
//     pin 2              →  V+  (24 V backbone)
//     pin 3              →  BUS_A  (RS-485 A)
//     pin 4              →  BUS_B  (RS-485 B)
//     pin 5              →  BUS_B  (paralleled with pin 4)
//     pin 6              →  BUS_A  (paralleled with pin 3)
//     pin 7              →  V+     (paralleled with pin 2)
//     pin 8  (highest Y) →  GND    (paralleled with pin 1)
//
// This arrangement reads identically forwards and backwards, so a tile
// flipped 180° in-plane still mates correctly pin-for-pin. Every signal
// is carried on two pins in parallel — contact resistance halves and a
// single dirty pin does not break the link.
//
// Pin positions are set by CONN_PINS and CONN_PITCH below; the SCAD
// model is agnostic to which pin is which net — it just places the holes.
// The PCB layout in hardware/tile/ assigns nets to pin positions per the
// table above.
//
// Overall dimensions: 100 × 100 × 15 mm. Design for FDM print on a 0.4 mm
// nozzle. PETG or translucent PLA for the diffuser, PETG / PLA / ABS for
// the frame and back cap.
//
// Assembled orientation (viewer looking at the tile on a wall):
//
//       ┌─────────────────────────────────┐   ← diffuser face (you see this)
//       │                                 │
//       │     (FRAME lip, 4 mm wide)      │
//       │  ┌───────────────────────────┐  │
//       │  │                           │  │
//       │  │   88 × 88 mm open area    │  │
//       │  │     LEDs shine through    │  │
//       │  │      the diffuser         │  │
//       │  │                           │  │
//       │  └───────────────────────────┘  │
//       │                                 │
//       └─────────────────────────────────┘
//            ↑                           ↑
//            edge connector (pogo)       edge connector (pogo)
//
// Stack-up (front → back):
//   FRAME lip                          z = 0 (top, in render)
//   DIFFUSER (1.5 mm panel)            z = 1.5–3.0 mm
//   air gap + LED height               z = 3.0–5.5 mm
//   PCB (1.6 mm)                       z = 5.5–7.1 mm
//   BACK_CAP inner face                z = 13.0 mm
//   BACK_CAP outer face                z = 15.0 mm
//
// Print orientation:
//   FRAME   → lip face down on build plate. No overhangs. PCB supports print
//              as vertical columns.
//   DIFFUSER→ flat, either face down. 1.5 mm is 4 × 0.3 mm layers or similar.
//   BACK_CAP→ outer face down. Simple rectangular print.
//
// Render part selection:  set RENDER = "frame" | "diffuser" | "back_cap" |
// "assembly" at the top of this file before exporting.

/* ============================ parameters ============================ */

RENDER           = "assembly";   // "frame" | "diffuser" | "back_cap" | "assembly"

// ----- overall -----
TILE_SIZE        = 100;
TILE_HEIGHT      = 15;

// ----- frame -----
WALL_THICK       = 2;
LIP_WIDTH        = 4;       // perimeter lip that retains diffuser, inward from walls
LIP_THICK        = 1.5;     // thickness of the retaining lip
DIFFUSER_BAY_D   = 2;       // depth of the bay that accepts the diffuser (past the lip)
PCB_BAY_D        = 4;       // bay depth from diffuser bottom to PCB top
PCB_THICK        = 1.6;
BACK_CAP_THICK   = 2;       // back cap thickness

// ----- diffuser -----
DIFFUSER_CLEAR   = 0.3;      // total clearance per axis for diffuser fit (halved on each side)
DIFFUSER_THICK   = 1.5;

// ----- back cap -----
BACK_CAP_CLEAR   = 0.25;     // clearance for snap fit
BACK_CAP_SNAP_H  = 1.0;      // height of snap tab
BACK_CAP_SNAP_W  = 8;        // width of snap tab

// ----- edge connector -----
CONN_TYPE        = "pogo";   // "pogo" | "header"
CONN_PINS        = 8;
CONN_PITCH       = 2.54;
CONN_EDGES       = [0, 2];   // 0=+X, 1=+Y, 2=-X, 3=-Y. v1: [0,2]. v2: [0,1,2,3].

// pogo pin (double-ended spring, 1.0 mm pin OD, 1.5 mm flange OD, 8 mm free length)
POGO_PIN_OD      = 1.0;
POGO_PIN_HOLE    = 1.1;      // PCB-side & frame through-hole
POGO_FLANGE_OD   = 1.5;
POGO_FLANGE_H    = 0.6;
POGO_FREE_LEN    = 8.0;      // uncompressed total length
POGO_COMPRESSED  = 5.5;      // typical compressed length
POGO_WALL_EXPOSE = 2.5;      // how much pin protrudes past the outer wall when un-mated

// 1×8 pin header fallback (CONN_TYPE = "header")
HEADER_BODY_W    = CONN_PINS * CONN_PITCH + 0.8;   // ~21.1 mm
HEADER_BODY_H    = 2.5;
HEADER_SLOT_H    = HEADER_BODY_H + 1.0;

// ----- magnets (neodymium disc) -----
MAG_OD           = 5;
MAG_H            = 2;
MAG_CLEAR_RAD    = 0.15;
MAG_CLEAR_AX     = 0.2;
MAG_POCKET_WALL  = 1.0;      // min material between magnet and outer face
MAG_INSET        = 8;        // centre of magnet from tile corner (diagonal inset)

// ----- corner bosses carry magnets + PCB screws -----
CORNER_BOSS_XY   = 14;
PCB_SCREW_OD     = 2.2;      // M2 screw clearance
PCB_SCREW_HEAD   = 4.0;      // counterbore OD (not used in main print, reference only)

// ----- PCB retention -----
PCB_HOLE_INSET   = 4;        // distance of mounting holes from tile corner (matches PCB design)

// ----- diffuser retention clips on frame interior -----
DIFF_CLIP_W      = 10;
DIFF_CLIP_H      = 0.8;      // clip protrusion into the diffuser bay
DIFF_CLIP_COUNT_PER_SIDE = 2;

// ----- back cap magnet access (none; magnets sit in frame corner bosses) -----

// ----- rendering aesthetics -----
$fn              = 48;

// ----- derived -----
LIP_INNER_SIZE   = TILE_SIZE - 2 * (WALL_THICK + LIP_WIDTH);   // 88 for defaults
DIFF_SIZE        = TILE_SIZE - 2 * WALL_THICK - DIFFUSER_CLEAR; // sits inside walls
BACK_CAP_OUTER   = TILE_SIZE - 2 * BACK_CAP_CLEAR;              // slides inside walls from behind
BACK_CAP_FRAME_OPENING = TILE_SIZE - 2 * WALL_THICK;            // size of the back opening in the frame

/* ============================== entry ============================== */

if (RENDER == "frame")        frame();
else if (RENDER == "diffuser") diffuser();
else if (RENDER == "back_cap") back_cap();
else if (RENDER == "assembly") assembly_exploded();
else echo("unknown RENDER value");


/* ============================== modules ============================== */

// -------- assembly view (exploded for review; not for printing) --------
module assembly_exploded() {
    // frame at z = 0
    color("lightgrey") frame();

    // pogo pins installed in their frame holes (if CONN_TYPE == "pogo")
    if (CONN_TYPE == "pogo")
        color("gold", 0.9) ghost_pogo_pins();

    // diffuser floated up
    color("white", 0.4)
        translate([0, 0, TILE_HEIGHT + 6])
            translate([TILE_SIZE/2, TILE_SIZE/2, 0])
                translate([-DIFF_SIZE/2, -DIFF_SIZE/2, 0])
                    diffuser();

    // back cap floated up further
    color("darkgrey", 0.9)
        translate([0, 0, TILE_HEIGHT + 16])
            back_cap();

    // ghost PCB for context
    %translate([(TILE_SIZE - 94) / 2, (TILE_SIZE - 94) / 2,
                LIP_THICK + DIFFUSER_THICK + PCB_BAY_D - PCB_THICK])
        cube([94, 94, PCB_THICK]);

    // net labels above each edge connector (echo only; does not render)
    echo("=== palindromic pinout on populated edges ===");
    echo("pin 1 (low Y)  = GND");
    echo("pin 2          = V+ (24 V)");
    echo("pin 3          = BUS_A");
    echo("pin 4          = BUS_B");
    echo("pin 5          = BUS_B (paralleled with 4)");
    echo("pin 6          = BUS_A (paralleled with 3)");
    echo("pin 7          = V+    (paralleled with 2)");
    echo("pin 8 (high Y) = GND   (paralleled with 1)");
}

// ----- ghost pogo pins: render the pins in their installed positions ---
// Not for printing; only for visual verification of the electrical-mechanical
// alignment. One simple shape per pin: a cylinder matching POGO_PIN_OD, with
// a flange disc at the midpoint, centred on the connector pin position.
module ghost_pogo_pins() {
    z_center = LIP_THICK + DIFFUSER_THICK + PCB_BAY_D - PCB_THICK / 2;
    pin_y0 = TILE_SIZE / 2 - (CONN_PINS - 1) * CONN_PITCH / 2;
    pin_len = POGO_FREE_LEN;

    for (e = CONN_EDGES) {
        for (i = [0 : CONN_PINS - 1]) {
            u = pin_y0 + i * CONN_PITCH;
            if (e == 0)       // +X edge
                translate([TILE_SIZE - pin_len/2 + POGO_WALL_EXPOSE,
                           u, z_center])
                    rotate([0, 90, 0]) _ghost_pin();
            else if (e == 2)  // -X edge
                translate([-POGO_WALL_EXPOSE - pin_len/2, u, z_center])
                    rotate([0, 90, 0]) _ghost_pin();
            else if (e == 1)  // +Y edge
                translate([u, TILE_SIZE - pin_len/2 + POGO_WALL_EXPOSE,
                           z_center])
                    rotate([-90, 0, 0]) _ghost_pin();
            else if (e == 3)  // -Y edge
                translate([u, -POGO_WALL_EXPOSE - pin_len/2, z_center])
                    rotate([-90, 0, 0]) _ghost_pin();
        }
    }
}

module _ghost_pin() {
    // a cylinder for the pin body, centred on origin, axis along Z
    translate([0, 0, -POGO_FREE_LEN/2])
        cylinder(h = POGO_FREE_LEN, d = POGO_PIN_OD);
    // flange at the middle
    translate([0, 0, -POGO_FLANGE_H/2])
        cylinder(h = POGO_FLANGE_H, d = POGO_FLANGE_OD);
}


// ============================== frame ==============================
// Main mechanical print. Contains:
//   - Top lip (perimeter)
//   - 4 walls
//   - 4 interior corner bosses (magnets + PCB screw bosses)
//   - Edge connector features (pogo or header) on CONN_EDGES
//   - Diffuser retention clips on interior
//   - Back cap snap recesses

module frame() {
    difference() {
        union() {
            // outer shell — box with open back and lipped front
            frame_shell();
            frame_corner_bosses();
            frame_diffuser_clips();
            if (CONN_TYPE == "pogo") frame_pogo_retainers();
        }
        // subtractions
        frame_back_opening();     // the main hollow interior accessible from behind
        frame_connector_cuts();   // pogo pin holes or header slot
        frame_magnet_pockets();
        frame_back_cap_ledge();   // step that the back cap sits into
        frame_pcb_screw_holes();
    }
}

module frame_shell() {
    // Outer box
    difference() {
        cube([TILE_SIZE, TILE_SIZE, TILE_HEIGHT]);

        // hollow out everything above the lip
        translate([WALL_THICK, WALL_THICK, LIP_THICK])
            cube([TILE_SIZE - 2*WALL_THICK,
                  TILE_SIZE - 2*WALL_THICK,
                  TILE_HEIGHT]);  // overcut (back is open)

        // hollow out the lip itself to leave the diffuser opening
        translate([WALL_THICK + LIP_WIDTH, WALL_THICK + LIP_WIDTH, -0.1])
            cube([LIP_INNER_SIZE, LIP_INNER_SIZE, LIP_THICK + 0.2]);
    }
}

module frame_back_opening() {
    // no-op for now; frame_shell already leaves the back open.
    // Kept as a named module so the intent is explicit.
}

module frame_corner_bosses() {
    // Chunky inside corners holding magnet and PCB screw.
    bh = TILE_HEIGHT - LIP_THICK;
    for (xsign = [0, 1], ysign = [0, 1]) {
        x = xsign ? TILE_SIZE - CORNER_BOSS_XY : 0;
        y = ysign ? TILE_SIZE - CORNER_BOSS_XY : 0;
        translate([x, y, LIP_THICK])
            cube([CORNER_BOSS_XY, CORNER_BOSS_XY, bh]);
    }
}

module frame_magnet_pockets() {
    // One magnet per corner, recessed from the BACK face.
    // Depth: MAG_H + MAG_CLEAR_AX, leaves MAG_POCKET_WALL to the lip side.
    pocket_d = MAG_OD + 2 * MAG_CLEAR_RAD;
    pocket_h = MAG_H + MAG_CLEAR_AX;
    z_from_back_face = TILE_HEIGHT - pocket_h;
    if (z_from_back_face < LIP_THICK + MAG_POCKET_WALL)
        echo("WARNING: magnet pocket too deep, collides with lip");

    for (xsign = [0, 1], ysign = [0, 1]) {
        // position on the diagonal from the tile corner toward centre
        x = xsign ? TILE_SIZE - MAG_INSET : MAG_INSET;
        y = ysign ? TILE_SIZE - MAG_INSET : MAG_INSET;
        translate([x, y, z_from_back_face])
            cylinder(h = pocket_h + 0.1, d = pocket_d);
    }
}

module frame_pcb_screw_holes() {
    // M2 screw clearance through the corner bosses.
    // Screwed through PCB into boss from the LED side (before diffuser
    // is installed). Threads into the plastic (self-tapping) — no insert.
    // Hole is through the boss from PCB height up to the magnet pocket.
    z_pcb_top = LIP_THICK + DIFFUSER_THICK + PCB_BAY_D;   // PCB top face
    z_bottom = z_pcb_top - PCB_THICK - 0.5;                // below PCB bottom
    // bore is a simple through-hole in the boss
    for (xsign = [0, 1], ysign = [0, 1]) {
        x = xsign ? TILE_SIZE - PCB_HOLE_INSET : PCB_HOLE_INSET;
        y = ysign ? TILE_SIZE - PCB_HOLE_INSET : PCB_HOLE_INSET;
        translate([x, y, z_bottom])
            cylinder(h = TILE_HEIGHT, d = PCB_SCREW_OD);
    }
}

module frame_diffuser_clips() {
    // Four small bumps protruding into the diffuser bay on each long wall.
    // They compress slightly when the diffuser is pushed past them and
    // snap back to retain it. Placed on the interior face of each wall,
    // at the depth of the diffuser bay (just above the lip).
    z = LIP_THICK + DIFFUSER_THICK * 0.5;
    for (side = [0 : 3]) {
        for (i = [0 : DIFF_CLIP_COUNT_PER_SIDE - 1]) {
            u = (i + 1) * (TILE_SIZE / (DIFF_CLIP_COUNT_PER_SIDE + 1));
            clip_size = [DIFF_CLIP_W, DIFF_CLIP_H * 2, DIFFUSER_THICK * 0.8];
            if (side == 0)      // +X wall, clip pointing -X (inward)
                translate([TILE_SIZE - WALL_THICK - DIFF_CLIP_H, u - DIFF_CLIP_W/2, z])
                    cube(clip_size);
            else if (side == 2) // -X wall, clip pointing +X
                translate([WALL_THICK - DIFF_CLIP_H, u - DIFF_CLIP_W/2, z])
                    cube(clip_size);
            else if (side == 1) // +Y wall
                translate([u - DIFF_CLIP_W/2, TILE_SIZE - WALL_THICK - DIFF_CLIP_H, z])
                    cube([clip_size[1], clip_size[0], clip_size[2]]);
            else                // -Y wall
                translate([u - DIFF_CLIP_W/2, WALL_THICK - DIFF_CLIP_H, z])
                    cube([clip_size[1], clip_size[0], clip_size[2]]);
        }
    }
}

module frame_back_cap_ledge() {
    // A 1 mm step cut on the interior of each wall near the back, for the
    // back cap to rest on. Cap sits flush with the outer back face.
    step_depth = 0.6;
    z_cut_lo = TILE_HEIGHT - BACK_CAP_THICK;
    // cut a continuous ring along the inner wall
    difference() {
        translate([WALL_THICK - step_depth, WALL_THICK - step_depth, z_cut_lo])
            cube([TILE_SIZE - 2*(WALL_THICK - step_depth),
                  TILE_SIZE - 2*(WALL_THICK - step_depth),
                  BACK_CAP_THICK + 0.1]);
        translate([WALL_THICK, WALL_THICK, z_cut_lo - 0.1])
            cube([TILE_SIZE - 2*WALL_THICK,
                  TILE_SIZE - 2*WALL_THICK,
                  BACK_CAP_THICK + 0.3]);
    }
}

// -------- edge connector features --------

module frame_connector_cuts() {
    for (e = CONN_EDGES) {
        if (CONN_TYPE == "pogo") pogo_pin_cuts_on_edge(e);
        else                     header_slot_on_edge(e);
    }
}

module frame_pogo_retainers() {
    // Thickened zone on the interior of each populated edge that holds the
    // pogo pin flanges. Length = pin strip length, thickness so flange seats
    // against the outer wall.
    strip_len = (CONN_PINS - 1) * CONN_PITCH + POGO_FLANGE_OD + 0.5;
    retainer_th = 2.0;                             // added material inward
    z_center = LIP_THICK + DIFFUSER_THICK + PCB_BAY_D - PCB_THICK / 2;
    z_lo = z_center - POGO_FLANGE_OD / 2 - 0.5;
    z_hi = z_center + POGO_FLANGE_OD / 2 + 0.5;
    zh = z_hi - z_lo;

    for (e = CONN_EDGES) {
        if (e == 0)
            translate([TILE_SIZE - WALL_THICK - retainer_th,
                       TILE_SIZE/2 - strip_len/2, z_lo])
                cube([retainer_th, strip_len, zh]);
        else if (e == 2)
            translate([WALL_THICK, TILE_SIZE/2 - strip_len/2, z_lo])
                cube([retainer_th, strip_len, zh]);
        else if (e == 1)
            translate([TILE_SIZE/2 - strip_len/2,
                       TILE_SIZE - WALL_THICK - retainer_th, z_lo])
                cube([strip_len, retainer_th, zh]);
        else if (e == 3)
            translate([TILE_SIZE/2 - strip_len/2, WALL_THICK, z_lo])
                cube([strip_len, retainer_th, zh]);
    }
}

module pogo_pin_cuts_on_edge(edge) {
    // Through holes for POGO_PIN_OD, with a flange counterbore from the
    // INSIDE face so the pin flange is captured against the outer wall.
    z_center = LIP_THICK + DIFFUSER_THICK + PCB_BAY_D - PCB_THICK / 2;
    pin_y0 = TILE_SIZE / 2 - (CONN_PINS - 1) * CONN_PITCH / 2;

    for (i = [0 : CONN_PINS - 1]) {
        u = pin_y0 + i * CONN_PITCH;
        if (edge == 0)            // +X
            _pogo_one_cut([TILE_SIZE + 0.1, u, z_center], [90, 90, 0]);
        else if (edge == 2)       // -X
            _pogo_one_cut([-0.1, u, z_center], [-90, 90, 0]);
        else if (edge == 1)       // +Y
            _pogo_one_cut([u, TILE_SIZE + 0.1, z_center], [90, 0, 0]);
        else if (edge == 3)       // -Y
            _pogo_one_cut([u, -0.1, z_center], [-90, 0, 0]);
    }
}

module _pogo_one_cut(pos, rot) {
    // Reusable single-pin cut: through-hole + flange counterbore.
    // Orient so cylinder axis points along rot (Y rotation of 90 = along +X).
    translate(pos) rotate(rot) {
        // through-hole (pin body + clearance) — the hole goes from outer face
        // all the way through the retainer block
        cylinder(h = WALL_THICK + 5, d = POGO_PIN_HOLE, center = false);
        // flange counterbore from the inside face (starts WALL_THICK in)
        translate([0, 0, WALL_THICK])
            cylinder(h = POGO_FLANGE_H + 0.3, d = POGO_FLANGE_OD + 0.3);
    }
}

module header_slot_on_edge(edge) {
    // Fallback: single rectangular slot sized for a 1×8 pin header body.
    z_center = LIP_THICK + DIFFUSER_THICK + PCB_BAY_D - PCB_THICK / 2;
    slot_w = HEADER_BODY_W;
    slot_h = HEADER_SLOT_H;
    slot_z = z_center - slot_h / 2;

    if (edge == 0)
        translate([TILE_SIZE - WALL_THICK - 0.2, (TILE_SIZE - slot_w)/2, slot_z])
            cube([WALL_THICK + 0.4, slot_w, slot_h]);
    else if (edge == 2)
        translate([-0.2, (TILE_SIZE - slot_w)/2, slot_z])
            cube([WALL_THICK + 0.4, slot_w, slot_h]);
    else if (edge == 1)
        translate([(TILE_SIZE - slot_w)/2, TILE_SIZE - WALL_THICK - 0.2, slot_z])
            cube([slot_w, WALL_THICK + 0.4, slot_h]);
    else if (edge == 3)
        translate([(TILE_SIZE - slot_w)/2, -0.2, slot_z])
            cube([slot_w, WALL_THICK + 0.4, slot_h]);
}


// ============================== diffuser ==============================
// Interchangeable diffuser panel. Drops into the frame's back opening from
// behind and rests against the lip. Retained by the frame's diffuser clips.
//
// Make this in a range of patterns — frosted flat, dotted, honeycomb,
// pixelated squares matching the 5×5 LED grid — by subclassing this module.

module diffuser() {
    difference() {
        // panel
        cube([DIFF_SIZE, DIFF_SIZE, DIFFUSER_THICK]);

        // small finger-pull slot on one edge so the diffuser can be popped
        // out from behind with a fingernail / plastic spudger.
        pull_w = 12;
        translate([DIFF_SIZE/2 - pull_w/2, -0.1, DIFFUSER_THICK * 0.4])
            cube([pull_w, 1.2, DIFFUSER_THICK]);
    }
}

// Variant: 5×5 pixel-mask diffuser — small circular windows over each LED
// position, fully transparent; surrounding area opaque (print in opaque
// colour and the LEDs peek through the holes).
// Commented out by default; enable by wrapping diffuser() call in assembly.
//
// module diffuser_pixelated() {
//     led_pitch = TILE_SIZE / 5;
//     diff_origin = (TILE_SIZE - DIFF_SIZE) / 2;
//     difference() {
//         cube([DIFF_SIZE, DIFF_SIZE, DIFFUSER_THICK]);
//         for (r = [0:4], c = [0:4])
//             translate([led_pitch/2 + c*led_pitch - diff_origin,
//                        led_pitch/2 + r*led_pitch - diff_origin,
//                        -0.1])
//                 cylinder(h = DIFFUSER_THICK + 0.2, d = 7);
//     }
// }


// ============================== back cap ==============================
// Removable rear cover. Provides PCB access and holds the assembly closed.
// Snaps into the back cap ledge cut into the frame's rear interior.

module back_cap() {
    difference() {
        union() {
            // main plate
            translate([BACK_CAP_CLEAR, BACK_CAP_CLEAR, 0])
                cube([BACK_CAP_OUTER, BACK_CAP_OUTER, BACK_CAP_THICK]);
            // snap tabs — one in the centre of each side, protruding past
            // the plate to catch on the frame ledge
            back_cap_snaps();
        }
        // ventilation slots — 4 per side, removing ~10 % of the back face
        back_cap_vents();
        // central label / cable-exit cutout (reserved; not cut by default)
    }
}

module back_cap_snaps() {
    tab_h = BACK_CAP_SNAP_H;
    tab_w = BACK_CAP_SNAP_W;
    tab_d = 1.0;
    for (side = [0 : 3]) {
        if (side == 0)
            translate([BACK_CAP_CLEAR + BACK_CAP_OUTER,
                       TILE_SIZE/2 - tab_w/2, 0])
                cube([tab_d, tab_w, tab_h]);
        else if (side == 2)
            translate([BACK_CAP_CLEAR - tab_d,
                       TILE_SIZE/2 - tab_w/2, 0])
                cube([tab_d, tab_w, tab_h]);
        else if (side == 1)
            translate([TILE_SIZE/2 - tab_w/2,
                       BACK_CAP_CLEAR + BACK_CAP_OUTER, 0])
                cube([tab_w, tab_d, tab_h]);
        else
            translate([TILE_SIZE/2 - tab_w/2,
                       BACK_CAP_CLEAR - tab_d, 0])
                cube([tab_w, tab_d, tab_h]);
    }
}

module back_cap_vents() {
    vent_w = 3;
    vent_l = 30;
    rows = 3;
    for (i = [0 : rows - 1]) {
        y = BACK_CAP_CLEAR + (i + 1) * BACK_CAP_OUTER / (rows + 1);
        translate([BACK_CAP_CLEAR + (BACK_CAP_OUTER - vent_l) / 2,
                   y - vent_w / 2,
                   -0.1])
            cube([vent_l, vent_w, BACK_CAP_THICK + 0.2]);
    }
}
