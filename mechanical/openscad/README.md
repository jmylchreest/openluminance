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

### Assembly structure — three printed parts

| Part | What it is | Interchangeable? |
|---|---|---|
| **Frame** | Main body — walls, corner bosses, magnet pockets, edge-connector features. One print per tile. | No |
| **Diffuser** | Separate flat panel, 94 × 94 × 1.5 mm, drops into the frame from behind and is retained by the front lip + four interior clips. | **Yes** — swap for frosted, dotted, pixelated, or coloured variants without touching the frame. |
| **Back cap** | Removable rear cover, snaps into a ledge around the frame's rear interior. Ventilated. | Yes — swap for different vent patterns or a solid cap. |

Render a specific part by setting `RENDER` at the top of the SCAD file:

```openscad
RENDER = "frame";      // or "diffuser", "back_cap", "assembly"
```

`assembly` shows all three parts exploded along the Z axis along with ghost pogo pins — useful for design review; not for printing.

### Print orientation

- **Frame:** lip face down on the build plate. The open back is the top of the print. No overhangs.
- **Diffuser:** flat, either face down. 1.5 mm thick.
- **Back cap:** outer face down, vents print as slot cuts (no bridging).

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

### Magnets

`MAG_OD = 5`, `MAG_H = 2`, `MAG_CLEAR_RAD = 0.15`, `MAG_CLEAR_AX = 0.2`. Pockets drilled from the back face into the four corner bosses, centred 8 mm in from each tile corner on the diagonal. At least 1 mm of material remains between the magnet pocket and the outer face (`MAG_POCKET_WALL`). Magnet polarity should be set at assembly time so only the "front" face of the tile attracts a metal backplate — prevents face-flipping.

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