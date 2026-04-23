# Tile PCB layout plan

How the LED array, MCU, buck, transceiver, and supporting components fit inside the 100 × 100 × 15 mm enclosure. Companion to [`../../mechanical/openscad/tile.scad`](../../mechanical/openscad/tile.scad) and [`../../docs/architecture.md`](../../docs/architecture.md). Drives the KiCad board outline before the first schematic spin.

## Topology: no custom PCB — drop-in modules + pre-made dev board

**Nothing is custom-fabricated.** Nine individual pre-made SK6812 LED modules drop into 9 cradles printed into the frame interior at the 3 × 3 grid positions. A pre-made MCU dev board (XIAO ESP32-C3, CH32V003 breakout, or equivalent) slides into a retention-rib pocket in the −X, −Y corner of the frame. Short point-to-point wires connect the dev board to each LED module (data chain + power) and to each edge-connector group. No custom PCB; no central board; no corner screw bosses.

```
   ┌──────────────────────────────┐ ← diffuser (100 × 100, edge-to-edge)
   │                              │
   │                              │
   │  (LED) (LED) (LED)           │ ← 9 × SK6812 modules in 3 × 3 cradles
   │                              │     on 30 mm pitch, printed into frame
   │  (LED) (LED) (LED)           │
   │                              │
   │  (LED) (LED) (LED)           │
   │                              │
   ├──────────────────────────────┤
   │ [dev brd]                    │ ← MCU dev board in its corner pocket,
   │                              │     retained by printed rib clips.
   │                              │     Wires fan out to LED cradles and
   │                              │     to the edge connector groups.
   ├──────────────────────────────┤ ← frame back inner face
   │     vvv     vvv     vvv      │ ← vent slots
   └──────────────────────────────┘ ← frame back outer face
```

### Why no PCB

- **Lower iteration cost.** No board spin, no JLCPCB wait time. Pick a different MCU next week — swap the dev board.
- **No SMT assembly.** All parts come pre-assembled. Per-tile build is soldering wires to header pins.
- **Simpler v1 bench.** Any CH32V003 dev board + MP1584 buck module + MAX485 breakout wired together works; or a XIAO ESP32-C3 on its own if you're willing to take the WiFi-per-tile path.
- **Repairability.** Dead LED? Pop the diffuser, pull the module, plug in a new one. Dead MCU? Slide the dev board out of its pocket and replace.

### Trade-off

Per-tile assembly is **slower and more expensive** than a custom PCB would be (~£18 + ~30 min of wiring vs ~£5 + 10 min of click-and-solder). This is the right choice for exploratory v1 bench hardware, not for a production run — at volume, collapse back into a custom PCB.

## Space budget — what's actually available

### Z stack (15 mm total, 11.5 mm interior)

```
  z = 15.0 ────────── diffuser front face ──────────
  z = 13.5 ────────── frame walls top / diffuser back
                 ↑
                 │ 4.4 mm diffusion gap (air)
                 ↓
  z =  9.1 ────────── LED top (SK6812 body 1.5 mm above PCB)
  z =  7.6 ────────── PCB top face ──── [ 9 × SK6812 in 3×3 grid ]
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

| Feature | Footprint | Qty | Area | Notes |
|---|---|---:|---:|---|
| LED module cradles | 17.4 × 17.4 mm | 9 | 2725 mm² | 15 × 15 mm module bay with 1.2 mm lip, z = 2 → 6 |
| MCU board pocket (floor + ribs) | 26 × 20 mm | 1 | 520 mm² | Corner at (3, 3) with rib clips on ±Y sides |
| Edge magnet bosses | 9 × 3 mm | 8 | 216 mm² | 2 per edge × 4 edges |
| Pogo pin retainers | 22 × 2 mm | 4 | 176 mm² | 1 strip per edge, centred |
| **Total feature area** | | | **~3640 mm²** | out of 9 216 mm² interior |

There's no longer a PCB footprint to negotiate — all these features are just printed plastic that the modules/board drop into. Remaining interior volume is for wire routing.

## Layout — plan view

No board outline to draw — the features are printed directly into the frame. Plan view (not to scale):

```
           -Y edge
           ▼
  ┌──────────────────────────────┐ ← 100 mm tile outer edge
  │                              │
  │ [MCU]                        │
  │ pocket    ┌─┐  ┌─┐  ┌─┐      │   3 × 3 LED cradles (17.4 mm each)
  │ (26×20)   └─┘  └─┘  └─┘      │   centred at tile-local
  │           ┌─┐  ┌─┐  ┌─┐      │   (20, 20), (50, 20), (80, 20),
  │           └─┘  └─┘  └─┘      │   (20, 50), (50, 50), (80, 50),
  │           ┌─┐  ┌─┐  ┌─┐      │   (20, 80), (50, 80), (80, 80)
  │           └─┘  └─┘  └─┘      │
  │                              │
  └──────────────────────────────┘
```

### LED cradle dimensions

Each cradle is a 17.4 × 17.4 mm printed plinth with a 1.2 mm lip around the top. The 15 × 15 × 1.6 mm LED module drops into the centre recess (friction fit, no glue). A 3 mm wire-exit slot on the −Y face of each cradle lets the pigtail escape to the harness.

Typical SK6812 single-LED module footprints (confirm before buying):

| Source | Outer size | Notes |
|---|---|---|
| BTF-Lighting individual SK6812 PCB | ~15 × 15 mm | Solder pads on all 4 sides |
| Adafruit NeoPixel single (1558) | ~8 × 10 mm | Smaller; would need adapter plate or smaller cradle |
| Custom bare SK6812 5050 on a 15 × 15 breakout | 15 × 15 mm | ~£0.15 at JLCPCB with 500 MOQ — still no *per-tile* custom board, just a reusable sub-module |

If your modules are smaller than 15 × 15, reduce `LED_MOD_XY` in `tile.scad`; the cradle auto-sizes.

### MCU board pocket

Floor at the frame back inner face, in the −X, −Y corner. Two parallel printed ribs (1.2 mm × 3 mm tall) retain the board by clamping its long sides. Works for any board up to 24 × 18 mm or so — covers the common dev boards:

| Board | Size | Notes |
|---|---|---|
| Seeed XIAO ESP32-C3 | 21 × 17.5 mm | USB-C, WiFi + BT. Overkill but plug-and-play |
| Seeed XIAO RP2040 / RP2350 | 21 × 17.5 mm | No WiFi, great for RS-485 node |
| CH32V003F4P6 bare breakout (hand-made or LCSC) | ~20 × 15 mm | Matches the committed architecture |
| RP2040-Zero | 23 × 18 mm | Cheap (~£3), USB-C, loads of GPIO |

## LED grid placement

**Nine** SK6812 RGBW modules at 30 mm pitch, centred in the tile: positions (20, 20), (50, 20), (80, 20), (20, 50), (50, 50), (80, 50), (20, 80), (50, 80), (80, 80). Each module sits in its own printed cradle; the centre cradle also acts as a thermal conduit from the centre LED down into the frame back.

Data chain: WS2812-style serpentine — row 0 left→right, row 1 right→left, row 2 left→right. DIN of LED (20, 20) from MCU (e.g. ESP32-C3 GPIO0); DOUT of LED (80, 80) terminated at a header pin on the MCU board for debug.

### Why 9, not 25

Each tile is **one colour cell in the system**, not a pixel-addressable display. Nine SK6812 RGBW at 60 mA = ~540 mA @ 5 V = 2.7 W peak per tile, ~45 lumens of diffused ambient output. The diffuser blends them into a single uniform glow (or 9 distinct pixels if the optional light guide is fitted). Going to 25 triples the power, cost, and thermal load for no benefit if the tile isn't trying to draw an image.

## Controller stack per tile

Three pre-made modules wired together, sitting in the MCU pocket + routed to the edge connectors via a harness:

1. **MCU dev board** — carries the CH32V003 (or ESP32-C3, etc.) and exposes its GPIOs on 2.54 mm headers. Sits in the corner pocket.
2. **Buck converter module** — MP1584EN 24 → 5 V, ~17 × 11 × 4 mm. Pre-trimmed to 5 V output. Mounts anywhere with double-sided tape; its output supplies the dev board and LED string.
3. **RS-485 transceiver breakout** — MAX485 on a tiny carrier with header pins. ~15 × 15 mm. Wired between the MCU's USART and the BUS_A/BUS_B edge pins.

Total controller footprint: ~55 × 20 mm when laid end-to-end, plus some wiring space. Fits comfortably in the bottom half of the tile interior (between the LED cradles and the back wall), held by double-sided tape. The MCU pocket holds only the MCU board; buck and transceiver float in the interior.

### Height budget

Interior depth from back inner face (z = 2) to lowest LED cradle surface (z = 2) is 0 — the cradles *start* at the back inner face. So the buck/transceiver modules sit in the gaps between cradles, not underneath them. Max module height = cradle top − back face = 4 mm. MP1584 modules are ~4 mm including header pin stubs (trim stubs flush if necessary). RS-485 breakouts are typically 3 mm. Both fit.

Alternative: mount buck + transceiver to the inside of the back cap or the underside of the diffuser... no, neither of those is accessible. They live in the interior floor between cradles.

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

## Build constraints (for the assembly person)

- **MCU board** fits a pocket 26 × 20 mm at tile-local (3, 3) – (29, 23), retained by 1.2 mm ribs on ±Y long sides. Boards up to 24 × 18 mm work.
- **9 LED modules** drop into cradles on 30 mm pitch centred at tile-local (20, 20) through (80, 80). Each cradle bay is 15 × 15 mm with a 1.2 mm lip — pre-made 15 × 15 mm SK6812 breakouts are the target fit. Smaller modules (e.g. 8 × 10 mm) need either a smaller `LED_MOD_XY` in the SCAD or a printed adapter plate.
- **Pogo pin tips** are at z = 6.8 on every populated edge. Wire the module's edge-pad pigtails to each pin's inner tip — 32 pins per tile is a lot of hand-soldering; an edge-breakout mini-PCB (pre-made or custom) makes this tractable. Kept out of the SCAD for v1; pure flying-lead assembly works for the bench prototype.
- **Max interior component height** (for buck, transceiver, wire bundles) between the back wall and the underside of the LED cradles = 4 mm. MP1584 modules fit with trimmed header pins; RS-485 breakouts fit easily.
- **Thermal:** 9 LEDs × 60 mA @ 5 V = 2.7 W peak per tile. Passive convection via back-face vents handles this; no heat sinks or thermal grease needed.

## Open questions for the PCB design stage

- **Pogo pin mounting:** pins mounted to the frame (currently modelled) or soldered to PCB edge castellations? Choice affects PCB edge-pad vs. edge-castellation design.
- **Power injection:** do we need a dedicated tile variant with a screw-terminal 24 V input for the head of a long chain? Or inject via a custom master-adjacent tile?
- **Firmware update path:** expose SWIO via a 3-pin test pad on the back of the PCB, accessible through the back-face vent area with a pogo jig. Needs space reservation.