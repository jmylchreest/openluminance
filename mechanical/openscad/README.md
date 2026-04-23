# mechanical/openscad

Parametric OpenSCAD models for the tile enclosure and associated parts.

## Files

| File | Description |
|---|---|
| [`tile.scad`](tile.scad) | Tile enclosure, draft v0. 100 × 100 × 15 mm, single-piece FDM print. |
| [`tile-preview.png`](tile-preview.png) | Rendered preview of `tile.scad` with default parameters. |

## Building

Requires OpenSCAD 2021.01 or newer.

```bash
# Render an STL for printing
openscad -o tile.stl tile.scad

# Render a preview PNG
openscad -o tile-preview.png --imgsize=1200,900 \
    --camera=50,50,7,60,0,30,400 \
    --colorscheme=Tomorrow tile.scad
```

## `tile.scad` — design notes

### Assembly structure — two printed parts (plus optional light guide)

| Part | What it is | Interchangeable? |
|---|---|---|
| **Frame** | Main body — closed back + vents, walls, edge-magnet bosses, pogo pin holes, **9 LED module cradles in a 3 × 3 grid**, **MCU dev-board retention pocket** in one corner. 100 × 100 × 13.5 mm. | No |
| **Diffuser** | 100 × 100 × 1.5 mm panel covering the entire front edge-to-edge, continuous rim press-fit into the frame opening. | **Yes** — swap for different diffusion patterns |

There is **no custom PCB** in the v1 tile. All electronics are pre-made drop-ins: 9 × SK6812 LED modules (15 × 15 mm each) slot into the cradles, and a pre-made MCU dev board (XIAO ESP32-C3, CH32V003 breakout, etc.) slides into the retention pocket. Buck + RS-485 breakout boards float in the gaps between cradles. Wiring is point-to-point with flying leads.

Render a specific part by setting `RENDER`:

```openscad
RENDER = "frame";      // or "diffuser", "assembly"
```

`assembly` shows both parts exploded along the Z axis with ghost pogo pins and colour-coded magnets — for design review, not printing.

### Print orientation

- **Frame:** closed back face down on the build plate. Walls build upward; the open front is the top of the print. Back-face vent slots print cleanly as bridged voids (first layer + in-fill around slot openings). No overhangs elsewhere.
- **Diffuser:** flat, rim side up or down either works. The rim is thin (1.2 mm) but short (3 mm) so it prints reliably in any orientation.

### How the diffuser stays on

The diffuser has a continuous rectangular rim descending from its back face that matches the frame's interior opening minus a per-side `RIM_CLEAR` (0.20 mm default). When pressed in, the rim's outer surfaces slide against the frame wall interiors along all four sides — a friction press-fit. No discrete clips to fatigue, no snap bumps, no high-stress contact points.

Assembly / service: press diffuser on from the front; to remove, insert a fingernail or plastic spudger into the `DIFF_PULL_W` (12 mm) notch cut into one edge of the diffuser and lift. The diffuser comes off clean, PCB is now accessible from the front.

| Parameter | Default | Effect |
|---|---:|---|
| `DIFFUSER_THICK` | 1.5 | Visible panel thickness |
| `RIM_DEPTH` | 3.0 | How far the rim descends into the frame |
| `RIM_T` | 1.2 | Rim wall thickness |
| `RIM_CLEAR` | 0.20 | Per-side clearance between rim outer and frame inner. **Tune this** if your printer over- or under-extrudes. Smaller = tighter; 0.05 is a very firm fit, 0.30 is loose. |
| `DIFF_PULL_W` | 12 | Finger-pry notch width |
| `DIFF_PULL_D` | 1.2 | Finger-pry notch depth |

### Coordinate system

- `z = 0` — closed back outer face (build plate when printing)
- `z = BACK_THICK` — back inner face (interior begins here)
- `z = FRAME_H` (= 13.5 mm) — top of frame walls (where diffuser rim meets the frame)
- `z = TILE_HEIGHT` (= 15 mm) — diffuser front face

Interior layout:

```
  z = 15.0  ┌─────────────── diffuser front face
  z = 13.5  ├─── diffuser back = frame wall top ───┐
                ▲                                 │
  z =  9.1  ─── ▼ LED top (SK6812 on PCB front)   │  diffuser rim
  z =  7.6  ─── PCB top face                      │  descends 3 mm
  z =  6.0  ─── PCB bottom face                   │  into frame
                ▲
  z =  2.0  ─── back inner face            ───────┘
  z =  0.0  ───────────────── back outer face (build plate)
```

### The 8-pin edge connector — all four edges populated by default

The frame cuts pogo pin holes on all four edges (`CONN_EDGES = [0, 1, 2, 3]`) so the mechanical tile is ready for v2 free-form mesh topology with no re-print. Matches the palindromic spec in [`docs/architecture.md`](../../docs/architecture.md).

```
  Reading along +X edge, low Y → high Y:
    pin 1 GND, 2 V+, 3 A, 4 B, 5 B, 6 A, 7 V+, 8 GND
```

Connector z-centre coincides with the PCB mid-plane at `CONN_Z_CENTER = 6.8`. Set `CONN_TYPE = "header"` for the bench prototype (1×8 header slot instead of individual pin holes).

### Pogo pins — short spring contacts, not deep breakouts

Tiles sit essentially wall-to-wall when mated. The pogo pins are intentionally short so the tiles don't need a gap between them — only enough length to make contact and compress ~0.5 mm per side under magnetic clamping force:

| Parameter | Default | Notes |
|---|---:|---|
| `POGO_FREE_LEN` | 5.0 mm | Uncompressed tip-to-tip |
| `POGO_COMPRESSED` | 4.0 mm | ~20 % compression when mated |
| `POGO_WALL_EXPOSE` | 0.5 mm | Tip protrusion past outer wall face at rest |
| `POGO_PIN_OD` / `POGO_FLANGE_OD` | 1.0 / 1.5 mm | Standard short-pogo format |

Sourcing: search AliExpress / LCSC for "short pogo pin 5mm 1.0mm OD" or "P50-B short spring contact". These are the same family used in pogo-pin testing jigs and magnetic breakouts.

### 24 V power rail — distributed by the PCB, not by the frame

Power is **not** a separate physical bus bar inside the frame. `V+` and `GND` pins on every populated edge tie to common `V+` / `GND` nets on the PCB — so power enters through any edge connector and exits on any other. The per-tile buck converter taps the local net.

With all four edges populated:

- **Power flows in any direction** through the tile array. No dedicated power-injection edge.
- **Chain topology on the bus** is still possible (and preferred for v1) — the PCB simply leaves `BUS_A` / `BUS_B` unrouted on 2 of the 4 edges. Frame geometry is the same.
- **v2 mesh bus** will use per-edge analogue switches (TS5A3166 or similar) under MCU control so any 2 edges can be active on the bus at a time.

### Magnets — edge-to-edge attachment

Tiles attach to adjacent tiles on the side walls. Two 5 × 2 mm neodymium discs per populated edge, offset from the edge midpoint.

| Parameter | Default | Notes |
|---|---:|---|
| `EDGE_MAGNETS` | `true` | Cut edge magnet pockets on `CONN_EDGES` |
| `EDGE_MAG_OFFSET` | 20 | mm, from edge midpoint |
| `EDGE_MAG_BOSS_D` | 3 | mm, boss extension inward from wall |
| `EDGE_MAG_Z_CENT` | 7.75 | Automatically = `(BACK_THICK + FRAME_H) / 2` |
| `MAG_CLEAR_AX` | 0.2 | Axial clearance = recess from outer face |

Pockets open outward; installed magnets recess ~0.2 mm from the tile's outer face. When two tiles mate edge-to-edge the magnet faces are separated by only ~0.4 mm of air (print clearance both sides).

**Polarity (CCW-handed rule):**

```
  +X edge   N outward at LOW Y,   S outward at HIGH Y
  +Y edge   N outward at HIGH X,  S outward at LOW X
  -X edge   N outward at HIGH Y,  S outward at LOW Y
  -Y edge   N outward at LOW X,   S outward at HIGH X
```

In `RENDER = "assembly"`, ghost magnets are colour-coded **red = N outward**, **blue = S outward**. Use this as the install reference.

### Optional back-face magnets

`BACK_MAGNETS = true` cuts four additional magnet pockets into the corner bosses, recessed from the back face. Use only if the array will stick to a ferromagnetic backplate behind the wall. Default is `false`.

### The 8-pin edge connector — matches the architecture doc

`tile.scad` models the exact palindromic 8-pin layout committed in [`docs/architecture.md`](../../docs/architecture.md). Default is `CONN_TYPE = "pogo"`, which places 8 through-holes with flange counterbores on each populated edge for double-ended pogo pins. Setting `CONN_TYPE = "header"` swaps to a single rectangular slot for a 1×8 pin header, used on the bench prototype.

Pin signal assignment (set by the PCB, not the frame — the frame is just geometry):

```
  Reading along +X edge, low Y → high Y:
    pin 1  GND
    pin 2  V+ (24 V backbone)
    pin 3  BUS_A (RS-485 A)
    pin 4  BUS_B (RS-485 B)
    pin 5  BUS_B    ← paralleled with pin 4
    pin 6  BUS_A    ← paralleled with pin 3
    pin 7  V+       ← paralleled with pin 2
    pin 8  GND      ← paralleled with pin 1
```

Palindromic. A tile flipped 180° in-plane still mates net-for-net. Every signal is carried by two pins in parallel — contact resistance halves and a single bent or oxidised pin doesn't break the link.

`CONN_EDGES` picks which edges are populated. v1 uses `[0, 2]` (= +X and −X, a linear chain). v2 sets `[0, 1, 2, 3]` and mates any edge to any edge in any orientation.

### Pogo pin spec (matches the frame cut)

Default parameters target a **double-ended spring-loaded pin, 1.0 mm OD body, 1.5 mm OD flange, 8 mm free / 5.5 mm compressed** — the common "PA1.0-8.0" format on AliExpress / LCSC. If you use a different pogo pin, update:

- `POGO_PIN_OD` — tip OD
- `POGO_PIN_HOLE` — through-hole diameter
- `POGO_FLANGE_OD` / `POGO_FLANGE_H` — flange capture counterbore
- `POGO_FREE_LEN` / `POGO_COMPRESSED` — pin length (affects tile-to-tile gap)

Render `RENDER = "assembly"` to see ghost pogo pins in their installed positions. Use this to visually verify they clear the PCB and the diffuser bay.

### Magnets — edge-to-edge attachment

Tiles attach to adjacent tiles **edge-to-edge** (not back-to-back). Edge magnets sit in the side walls of each populated edge at two positions symmetric about the edge midpoint, so that when two tiles meet along their seam the magnet faces press against each other through a thin sliver of plastic.

**Edge magnet geometry** (default 5 × 2 mm N42 neodymium discs):

| Parameter | Default | Notes |
|---|---:|---|
| `EDGE_MAGNETS` | `true` | Cut edge magnet pockets on `CONN_EDGES` |
| `EDGE_MAG_OFFSET` | 20 | mm, magnet centre from edge midpoint (one above, one below) |
| `EDGE_MAG_BOSS_D` | 3 | mm, how far the interior reinforcement boss sticks in from the wall |
| `EDGE_MAG_BOSS_W` | 9 | mm, Y-extent of each boss (> MAG_OD for margin) |
| `EDGE_MAG_BOSS_H` | 8 | mm, Z-extent (only in the back half of the tile, so PCB doesn't need cutouts) |
| `MAG_OD` | 5 | Magnet OD |
| `MAG_H` | 2 | Magnet thickness |
| `MAG_CLEAR_RAD` | 0.15 | Radial print clearance per side |
| `MAG_CLEAR_AX` | 0.2 | Axial clearance — also the recess from the outer face |

Pockets open **outward** so magnet faces are separated by only ~0.4 mm of print-clearance air when two tiles meet (MAG_CLEAR_AX × 2). Holding force is close to the "magnets touching" maximum. Plenty of boss material behind the pocket floor for structural strength.

**Polarity — use the CCW-handed pattern:**

```
Traversing edges counter-clockwise around the tile:
   +X edge    N outward at LOW Y,   S outward at HIGH Y
   +Y edge    N outward at HIGH X,  S outward at LOW X
   -X edge    N outward at HIGH Y,  S outward at LOW Y
   -Y edge    N outward at LOW X,   S outward at HIGH X
```

With this rule, any edge pair mating in any orientation pairs N↔S automatically. A 180° in-plane rotation of one tile swaps the magnet positions but also swaps the polarities on each edge, so mating still works.

In the `RENDER = "assembly"` view, ghost magnets are colour-coded: **red = N outward**, **blue = S outward**. Use this as an install reference.

### Optional back-face magnets

`BACK_MAGNETS = true` turns on the original back-face magnet pockets — one per corner boss, recessed from the back face. Use these **only** if you want the assembled tile to stick to a ferromagnetic backplate behind the wall (e.g. a steel sheet). They are **not required** for normal operation; edge magnets hold adjacent tiles together, and the array mounts to the wall via screws through the corner bosses or via a separate mounting rail. Default is `false`.

### Diffuser retention

Four clips on the frame interior (two per long wall) protrude 0.8 mm into the diffuser bay. The diffuser snaps past them during install and is held against the lip above. A 12 mm finger-pull slot on one edge of the diffuser lets it be popped out with a fingernail or spudger when swapping variants.

### Frequently-tweaked parameters

| Parameter | Default | Effect |
|---|---:|---|
| `TILE_SIZE` | 100 | Square footprint |
| `TILE_HEIGHT` | 15 | Overall Z |
| `WALL_THICK` | 2 | Side walls |
| `LIP_WIDTH` | 4 | Perimeter lip that retains the diffuser (inward from walls) |
| `LIP_THICK` | 1.5 | Front lip thickness (visible perimeter frame) |
| `DIFFUSER_THICK` | 1.5 | Diffuser panel thickness |
| `PCB_BAY_D` | 4 | Gap between diffuser back and PCB top — LED height budget |
| `BACK_CAP_THICK` | 2 | Rear cover thickness |
| `CORNER_BOSS_XY` | 14 | Size of corner post (carries magnet + PCB screw) |
| `MAG_INSET` | 8 | Magnet pocket centre from tile corner |
| `CONN_TYPE` | `"pogo"` | `"pogo"` or `"header"` |
| `CONN_EDGES` | `[0, 2]` | Which edges are populated |

### Known issues / TODO

- **Palindromic PCB layout not yet drawn.** The SCAD file reserves the geometry; the KiCad layout in `hardware/tile/` will assign nets per the table above.
- **Pogo pin retention assumes insertion from the inside face** before the PCB is installed. If a different pin type is used (e.g. single-ended sleeve-mounted to the PCB), the frame cuts need `_pogo_one_cut` updated.
- **Inter-tile alignment dowels** are not yet modelled. Currently the mating is positioned by the pogo pin tips + corner magnets. For >4 tiles chained, a pair of 1 mm alignment posts on each edge will reduce accumulated misalignment. Reserved for v0.3.
- **Ventilation** is on the back cap only. Side-wall vents may be needed once thermals are measured on the bench.
- **No cable passthrough** for a dedicated 24 V power injection tile. A tile variant with a screw-terminal cutout is a v1 job.
- **No orientation indicator on the diffuser.** If the diffuser is directional (e.g. pixelated), add an alignment notch that matches one on the frame.

## Library availability

The [`thirdparty/`](../../thirdparty/README.md) submodules (BOSL2, NopSCADlib, Round-Anything, threadlib) are available if needed. `tile.scad` is intentionally dependency-free in v0.x for easy review. Later versions will use BOSL2 for rounded fillets and NopSCADlib's pogo pin / PCB primitives.