# Tile PCB layout plan

How the LED, MCU, buck, transceiver, and supporting components fit inside the 100 × 100 × 15 mm enclosure. Companion to [`../../mechanical/openscad/tile.scad`](../../mechanical/openscad/tile.scad) and [`../../docs/architecture.md`](../../docs/architecture.md). Drives the KiCad board outline before the first schematic spin.

## Space budget — what's actually available

### Z stack (15 mm total, 11.5 mm interior)

```
  z = 15.0 ────────── diffuser front face ──────────
  z = 13.5 ────────── frame walls top / diffuser back
                 ↑
                 │ 4.4 mm diffusion gap (air)
                 ↓
  z =  9.1 ────────── LED top (SK6812 body 1.5 mm above PCB)
  z =  7.6 ────────── PCB top face ──── [ 25 × SK6812, pogo-pin pads ]
  z =  6.0 ────────── PCB bottom face ── [ MCU, buck, transceiver, passives ]
                 ↑
                 │ 4.0 mm back-side component space
                 ↓
  z =  2.0 ────────── back inner face
  z =  0.0 ────────── back outer face (ventilation slots)
```

**Tight constraint: the 4 mm back-side space.** Any component taller than 4 mm doesn't fit. This rules out standard radial electrolytic caps (~11 mm tall) and some through-hole inductors. See [BOM constraints](#component-height-constraints) below.

### Plan view — 100 × 100 mm interior features

Features that cut into the 96 × 96 mm usable interior footprint:

| Feature | Footprint | Qty | Area lost | Notes |
|---|---|---:|---:|---|
| Corner bosses | 10 × 10 mm | 4 | 400 mm² | Screw bosses, stop at z = 6 (under PCB) |
| Edge magnet bosses | 9 × 3 mm | 8 | 216 mm² | 2 per edge × 4 edges |
| Pogo pin retainers | 22 × 2 mm | 4 | 176 mm² | 1 strip per edge, centred |
| **Total intrusion** | | | **792 mm²** | out of 9 216 mm² interior |

The PCB must work around these features or notch around them.

## PCB outline

Recommended outline: **94 × 94 mm with edge notches** for the magnet and pogo-pin bosses. Corner bosses stop at the PCB bottom face (z = 6) so the PCB sits flat on top of them — **no corner cutouts required** (all 25 LED positions preserved).

Plan view (not to scale):

```
            -Y edge
            ▼
  ┌──────────────────────────────┐ ← 100 mm tile outer edge
  │┌───┐    ┌─┐    ┌──┐    ┌─┐   ┌───┐│
  ││░░░│    │ │    │░░│    │ │   │░░░││
  │└───┘    └─┘    └──┘    └─┘   └───┘│   ← ░ = PCB-absent zones
  │                                    │     (notch or cutout at edges;
  │     ┌──────────────────────┐       │      corner bosses under PCB)
  │     │                      │       │
 -X│    │   PCB 94 × 94 mm     │      +X
 ──│    │                      │ ──────│
 edge   │   (pogo strip cuts   │       edge
  │     │    a 22 × 2 mm notch │       │
  │     │    at each edge; each│       │
  │     │    magnet boss cuts  │       │
  │     │    a 10 × 3 mm notch)│       │
  │     └──────────────────────┘       │
  │┌───┐    ┌─┐    ┌──┐    ┌─┐   ┌───┐│
  ││░░░│    │ │    │░░│    │ │   │░░░││
  │└───┘    └─┘    └──┘    └─┘   └───┘│
  └──────────────────────────────┘
            ▲
            +Y edge
```

Notch dimensions (all cut inward from the PCB edge):

- **Pogo-pin strip notch** (1 per edge, centred): 22 mm wide × 2 mm deep.
- **Magnet-boss notch** (2 per edge, offset ±20 mm from edge midpoint): 10 mm wide × 3 mm deep.

With those notches the PCB keeps ≈ 94 × 94 mm minus ~1060 mm² of notches = **≈ 7780 mm² usable**. Plenty for a 25-LED array + supporting circuitry.

## LED grid placement

Twenty-five SK6812 RGBW 5050 packages at 20 mm pitch, centred in the tile:

- LED centres: tile-local (10, 30, 50, 70, 90) in both X and Y.
- In PCB-local coordinates (PCB origin at tile (3, 3)): (7, 27, 47, 67, 87).
- All 25 positions fall safely within the PCB after notches (notches are shallow and away from the LED grid — closest LED at (7, 7) is > 4 mm clear of the nearest corner boss).

Data chain: standard WS2812-style serpentine (row 0 left→right, row 1 right→left, etc.). Data input at LED (7, 7) from the MCU; data output from LED (87, 87) is terminated on a test pad (or left floating).

## Back-side component placement

All control electronics go on the **bottom face of the PCB** (opposite the LEDs), in the 4 mm space between the PCB and the back wall.

Recommended zoning:

```
   Bottom face of PCB (view looking through the back):

  ┌──────────────────────────────────────────────────┐
  │ [buck module or discrete buck circuit]            │
  │  MP1584 + L + Cs, ~17 × 11 mm or ~20 × 15 mm     │
  │                                                  │
  │           ┌─────────┐                            │
  │ [MCU]     │  power  │       [MAX485 transceiver]│
  │ CH32V003  │  tap    │       SOIC-8, ~4 × 5 mm   │
  │ ~5 × 6 mm │  region │                            │
  │                                                  │
  │ [TVS][polyfuse][rev-pol MOSFET][bulk cap]        │
  │                                                  │
  │ [0603 passives scattered throughout]             │
  └──────────────────────────────────────────────────┘
```

Total component area: roughly 400 mm² of dense SMT. Plenty of PCB room. Thermal spreading is via copper pours.

## Component height constraints

The 4 mm back-side space is the limiting dimension. Substitutions vs. the original BOM where needed:

| Component | Standard variant | Height | Fits in 4 mm? | Action |
|---|---|---:|:---:|---|
| CH32V003 TSSOP-20 | | 1.2 mm | ✅ | |
| MAX485 SOIC-8 | | 1.75 mm | ✅ | |
| MP1584EN TSOT-23-8 (discrete circuit) | | 1.0 mm + L 2.5 mm + caps | ✅ | Discrete is safer than module |
| MP1584EN module (pre-built) | | ~4 mm | ⚠ marginal | Use only for bench; go discrete on PCB |
| **47 µF/35 V electrolytic (radial)** | | ~11 mm | ❌ | **Substitute:** 47 µF/35 V tantalum 1411 (4 × 4.5 × 3.8 mm) or 2× 22 µF/35 V ceramic 1210 |
| 22 µH shielded inductor | | 2–3 mm | ✅ | SMD shielded types |
| SS34 Schottky SMA | | 1 mm | ✅ | |
| SMBJ28CA TVS SMB | | 2.4 mm | ✅ | |
| Polyfuse 1812 | | 0.9 mm | ✅ | |
| AO3401 P-MOSFET SOT-23 | | 1.1 mm | ✅ | |
| 0603 passives | | 0.8 mm | ✅ | |

**Headline substitution**: the input bulk cap (47 µF/35 V) must be a tantalum or a ceramic bank; a radial electrolytic will not fit.

## LEDs are not strips

Individual SMD SK6812 5050 parts placed directly on the tile PCB, not a flexible strip. Three reasons:

1. **Pitch mismatch.** 60 LED/m strip has 16.7 mm pitch; our grid needs 20 mm. Re-cutting and re-wiring a strip to 25 segments is fragile and time-consuming.
2. **Fewer parts, fewer joints.** The PCB is already being made for the MCU and supporting circuitry. Placing 25 more LEDs on the same board is near-free at JLCPCB (~1 ¢ per placement).
3. **Thickness.** Strip form factor adds ~1 mm for the strip PCB plus adhesive plus any sleeving. The SMD LEDs sit flat on our board with no extra stack-up.

If you ever want to adapt the design to strips, the control electronics would need to split onto a separate small MCU board at one end of the strip run.

## Optional light guide

A third printable part — a 5 × 5 pixel-grid lattice — can be printed separately and dropped into the tile between the PCB and the diffuser. With it, each LED has its own 20 × 20 mm chamber with reflective walls, producing sharp distinct pixels. Without it, light blends smoothly across the diffuser.

Specs (see [`../../mechanical/openscad/tile.scad`](../../mechanical/openscad/tile.scad) — `RENDER = "light_guide"`):

- 5 × 5 grid of 20 × 20 mm cells
- Wall thickness 1.2 mm, wall height 5 mm
- Outer footprint ≈ 95 × 95 mm (sits inside the frame opening with 0.4 mm per-side clearance)
- Material: white PETG or PLA (reflective)
- No retention features — held in place by the PCB below and the diffuser rim above
- Swappable without disassembling the frame: pop the diffuser, drop the guide in, re-seat the diffuser

Print orientation: flat. Walls print as tall thin columns; use 2–3 perimeters for wall strength.

## Routing summary

High-level PCB wiring plan for the v1 (linear-chain) variant:

| Net | Where | Notes |
|---|---|---|
| `V+` (24 V) | From +X and −X edge connectors (pin 2 and pin 7) → common net → local buck input | Tie +Y and −Y V+ pads to the same net for v2 compatibility |
| `GND` | From all four edge connectors (pins 1 and 8) → common ground plane | Thick copper pour on inner layers |
| `5V` (local) | Buck output → MCU, MAX485, and the 25-LED array | Local to this tile; does not leave |
| `BUS_A` / `BUS_B` | +X edge (pins 3, 6 and 4, 5) ↔ MAX485 A/B ↔ −X edge | +Y and −Y bus pads left unconnected in v1 |
| `LED_DATA` | MCU PA1 → 330 Ω series R → DIN of first LED → DOUT→DIN chain through all 25 → final DOUT to test pad | Serpentine route |
| `UART_TX` / `UART_RX` / `DE` | MCU USART1 + one GPIO → MAX485 control pins | Keep short |

## Constraints summary (for the PCB designer)

- **Board outline:** 94 × 94 mm with 4 × pogo-pin notches (22 × 2 mm) and 8 × magnet-boss notches (10 × 3 mm). No corner cutouts needed.
- **Corner screw holes:** 4 × M2 through-hole at tile-local (5, 5), (95, 5), (5, 95), (95, 95) → PCB-local (2, 2), (92, 2), (2, 92), (92, 92). Hole OD 2.2 mm.
- **LED grid:** 25 × SK6812 5050, front side, 20 mm pitch, centred at PCB-local (7, 27, 47, 67, 87).
- **Edge pads:** 8 contact pads per populated edge at 2.54 mm pitch, aligned with pogo pin positions. Gold-plated for low contact resistance. On the PCB **top face** (LED side) or as edge castellations — depends on pogo pin orientation choice, still under review.
- **Max component height back-side:** 4 mm. Use low-profile SMD throughout; tantalum or ceramic bulk caps only.
- **Ground:** heavy inner-layer pour. At least 2 oz copper on inner layers.
- **Thermal:** LED array dissipates up to ~7.5 W at full white. Use large back-side copper pours connected to LED GND pads; leverage the back-face vent slots in the enclosure for convection.

## Open questions for the PCB design stage

- **Pogo pin mounting:** pins mounted to the frame (currently modelled) or soldered to PCB edge castellations? Choice affects PCB edge-pad vs. edge-castellation design.
- **Power injection:** do we need a dedicated tile variant with a screw-terminal 24 V input for the head of a long chain? Or inject via a custom master-adjacent tile?
- **Firmware update path:** expose SWIO via a 3-pin test pad on the back of the PCB, accessible through the back-face vent area with a pogo jig. Needs space reservation.