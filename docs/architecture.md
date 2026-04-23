# Architecture — v1

This is the committed v1 direction. The original 8-bit-parallel sketch is retained in the appendix for context. v2 (free-form 2D mesh) is deferred — see [`open-questions.md`](open-questions.md).

## Summary

- **Topology:** linear / serpentine chain (tiles connect on two opposing edges).
- **Signal bus:** RS-485 multidrop, half-duplex, 1 Mbps (headroom to 10 Mbps).
- **Power backbone:** 24 V DC, chained through connectors, regulated locally on each tile.
- **Per-tile MCU:** CH32V003F4P6 (TSSOP-20).
- **LEDs:** 25 × SK6812 RGBW per tile, 5 V, driven from the local buck output.
- **Discovery:** UID-based enumeration using a 1-Wire-style binary-tree search, adapted for RS-485.
- **Master:** ESP32-C3 with an RS-485 transceiver; web UI holds the tile map.

## System block diagram

```
  24V PSU
     │
     ▼
┌────────────┐    ┌───────┐    ┌───────┐          ┌───────┐
│  MASTER    │────│ Tile  │────│ Tile  │── ... ──│ Tile  │
│ ESP32-C3   │    │   1   │    │   2   │          │   N   │
│ + MAX485   │    └───────┘    └───────┘          └───────┘
│ + 120Ω     │                                     + 120Ω
│   term     │                                    (end term)
└────────────┘
     │
     ▼
    Wi-Fi / Web UI
```

Master and the last tile are the two RS-485 bus endpoints; both carry 120 Ω termination. Middle tiles leave termination unpopulated. Power and signal share the same edge connectors.

## Why this stack (vs. the original parallel-bus sketch)

| Concern | Parallel bus (original) | RS-485 + 24 V (this) |
|---|---|---|
| Pins per edge | 14 | **8 (palindromic, redundant)** |
| Signal integrity over chained connectors | Poor (skew, reflections) | **Excellent (differential, proven at DMX scale)** |
| Power distribution | 5 V chained → unusable past ~4 tiles | **24 V chained, local buck — scales to 32+ tiles** |
| Protocol maturity | Novel / hand-rolled | **RS-485 is 40+ years proven, DMX is literally this** |
| Auto-addressing | Unproven on parallel bus | **1-Wire binary search adapted — well-understood** |
| Bill of materials | Underestimated pogo pin cost | Realistic, slightly higher per tile but viable |
| EMI | Significant (48 MHz parallel across gaps) | Low (differential, slow edges) |

## Edge connector — 8-pin palindromic

Pinout reads identically forwards and backwards. This means any two edges mate correctly in either relative orientation — a tile can be flipped end-for-end in-plane and still connect. Every signal is carried by two pins in parallel, so contact resistance halves and single-pin failures don't break the link.

| Pin | Name | Purpose |
|---:|---|---|
| 1 | GND | Return |
| 2 | V+ | 24 V backbone |
| 3 | BUS_A | RS-485 differential A |
| 4 | BUS_B | RS-485 differential B |
| 5 | BUS_B | RS-485 differential B (paralleled — same net as pin 4) |
| 6 | BUS_A | RS-485 differential A (paralleled — same net as pin 3) |
| 7 | V+ | 24 V backbone (paralleled — same net as pin 2) |
| 8 | GND | Return (paralleled — same net as pin 1) |

Pass-through on the tile: `V+` and `GND` wire straight across from one edge connector to the other — no series element — so downstream tiles get full rail. The local circuit taps via a polyfuse into the buck converter. Both edges share the same `BUS_A` and `BUS_B` nets (RS-485 multidrop).

### Rotational invariance — v1 vs v2

- **v1:** populate this 8-pin connector on the two chain edges only. Gives 180° in-plane flip tolerance for chain mating. Leave the other two edges unpopulated.
- **v2:** populate the same 8-pin connector on all four edges, all wired to the same V+/GND/BUS nets. Now any tile can mate any other tile on any edge in any orientation, BUT the bus becomes a mesh — need per-edge analogue switches (e.g. TS5A3166) selected by the MCU so only two edges are electrically active on the bus at any time. **Mechanical connector is identical between v1 and v2**, so v2 upgrade is a firmware-plus-populate change, no PCB redesign.

Face-flip (LEDs pointing at the wall) is prevented mechanically — magnet polarity + asymmetric alignment dowels on the back face only.

## Per-tile electrical overview

```
                            ┌──────────────────────────────────┐
  LEFT EDGE                  │              TILE               │        RIGHT EDGE
  CONNECTOR                  │                                 │        CONNECTOR
                             │                                 │
  V+ ──────┬──────────────── pass-through rail ─────────────────┬──── V+
  GND ─────┼──────────────── pass-through rail ─────────────────┼──── GND
           │                 │                                 │      │
           │  ┌──────────────┴─────┐                           │      │
           │  │ Polyfuse (0.5A)    │                           │      │
           │  │ → P-MOSFET (rev)   │                           │      │
           │  │ → TVS diode        │                           │      │
           │  │ → Buck (24→5V, 2A) │                           │      │
           │  └────────┬───────────┘                           │      │
           │           │ 5V                                    │      │
           │           ├────────────────┬──────────┐           │      │
           │           │                │          │           │      │
           │           ▼                ▼          ▼           │      │
           │     ┌──────────┐    ┌──────────┐  ┌─────────┐     │      │
           │     │ CH32V003 │    │  MAX485  │  │ 25× SK- │     │      │
           │     │  MCU     │────│ RS-485   │  │  6812   │     │      │
           │     │          │    │  TRX     │  │ RGBW    │     │      │
           │     └────┬─────┘    └────┬─────┘  └─────────┘     │      │
           │          │               │                        │      │
           │          │          ┌────┴────┐                   │      │
  BUS_A ───┼──────────┼──────────┤ A     B ├───────────────────┼── BUS_A
  BUS_B ───┼──────────┼──────────┤         ├───────────────────┼── BUS_B
           │          │          └─────────┘                   │      │
           │          │                                        │      │
           │          └── UART TX/RX + DE/nRE                  │      │
           │                                                   │      │
           └───────────────────────────────────────────────────┘
```

## Addressing protocol (v1)

Half-duplex RS-485. Master polls; tiles respond only when addressed or during a discovery slot.

**Discovery (binary-tree UID search)** — adapted from Dallas 1-Wire:

1. Master broadcasts `SEARCH_ROM(prefix, length)`.
2. All tiles whose 64-bit UID starts with `prefix` respond on the next bit position: `0`, `1`, or both (collision).
3. Collision → master descends one branch (say `0`), recurses.
4. When a leaf is reached, master has a unique UID → assigns it a bus address (1..254).

For N tiles this is O(N × 64) bus transactions — about 2 seconds for 32 tiles at 1 Mbps. Runs once at startup, never again unless the map is rebuilt.

**Normal operation:**

```
  Packet: 0xA5  ADDR  CMD  LEN  PAYLOAD[LEN]  CRC8
          SOF   1B    1B   1B   0..240B       1B
```

- `ADDR 0x00` = master
- `ADDR 0xFF` = broadcast
- `ADDR 0x01..0xFE` = unicast
- Commands: `PING`, `SET_PIXELS`, `LATCH`, `GET_STATUS`, `REBOOT`, `SET_ADDR` (during discovery only)

Frame flow: master sends `SET_PIXELS` to each tile in turn (75 bytes RGB × 25 pixels + overhead ≈ 80 bytes per tile → 0.8 ms per tile at 1 Mbps). Then a single `LATCH` broadcast tells everyone to update simultaneously. 32 tiles = 25.6 ms + 1 latch = ~27 ms, comfortably inside a 60 fps budget.

## Power math (why 24 V)

Per tile worst case: 9 LEDs × 60 mA @ full white = 540 mA @ 5 V = 2.7 W. 32-tile array = 86 W. (The original 25-LED design pushed 7.5 W/tile / 240 W system; the tile is a lighting element, not a pixel-addressable display, so 9 LEDs is plenty and the numbers shrink.)

At **5 V** chained: tile 1 carries 17 A. Pogo/header contacts can't carry that across many tiles without significant IR drop — LEDs go dim and off-colour down-chain.

At **24 V** chained with per-tile buck (η ≈ 85 %): tile 1 carries ~4.3 A across the whole 32-tile chain, drop per hop ≈ 0.1 V. Buck compensates by drawing slightly more current as input sags. **Self-correcting**.

System PSU: 24 V, **≥5 A** for 32 tiles (with margin). Mean Well LRS-100-24 or equivalent (~£15).

## Components per tile (high level)

| Function | Part | Est. £ (vol) |
|---|---|---:|
| MCU | CH32V003F4P6 (TSSOP-20) | 0.12 |
| RS-485 transceiver | MAX485 / SP485EEN / MAX3485 | 0.35 |
| Buck converter (24→5 V) | MP1584EN + L + Cs (discrete) | 0.60 |
| LEDs | 9 × SK6812 RGBW (3 × 3 grid, 30 mm pitch) | 1.53 |
| Protection | Polyfuse + TVS + rev-pol FET | 0.25 |
| Edge connectors | 2× pin header or pogo strip | 0.80 |
| PCB + passives | | 0.40 |
| Enclosure + diffuser + magnets | | 0.80 |
| **Total** | | **~£5.31** |

Detailed part numbers in [`../prototypes/4-tile-bench/parts-list.md`](../prototypes/4-tile-bench/parts-list.md).

## Appendix — discarded: 8-bit parallel bus

The original proposal used DATA0–7, CLK, EN on a 14-pin edge connector with tile addresses hardcoded in `main.c`. Discarded because: (a) signal integrity across chained connectors at 48 MHz is unpredictable, (b) pin count drives connector cost and mechanical failure rate, (c) no native arbitration means auto-addressing requires inventing a scheme, (d) EMI risk for any future compliance work. The reference project ([rmingon/led-wall](https://github.com/rmingon/led-wall)) is a working existence proof of that architecture at small scale but does not auto-address. RS-485 gives us equivalent or better bandwidth with 6 pins, proven protocol stacks, and off-the-shelf transceivers.
