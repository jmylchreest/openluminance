# Electrical Schematic — 4-tile bench

Text schematic for the bench prototype. A proper KiCad schematic will land in `hardware/tile/` before PCB order; this document captures the design the KiCad sheets should implement and is the source of truth for the bench build.

## 1. System-level

```
   ┌─────────────┐
   │  24 V PSU   │   Mean Well LRS-50-24 or equivalent
   │   (2 A +)   │
   └──┬──────┬───┘
      │ 24V  │ GND
      ▼      ▼
   ┌──────────────┐
   │   MASTER     │
   │              │
   │  ESP32-C3    │       ┌───────┐   ┌───────┐   ┌───────┐   ┌───────┐
   │  + MAX485    │──A────│       │───│       │───│       │───│       │
   │  + 120Ω term │──B────│ Tile  │───│ Tile  │───│ Tile  │───│ Tile  │
   │  + biasing   │──V+───│  #1   │───│  #2   │───│  #3   │───│  #4   │
   │  680Ω x2     │──GND──│       │───│       │───│       │───│       │
   │              │       └───────┘   └───────┘   └───────┘   └───┬───┘
   └──────┬───────┘                                                │
          │                                                  120Ω termination
          ▼                                                  between A and B
        Wi-Fi                                                  on last tile
```

Master carries the `+` end of the RS-485 bus, fixed biasing (680 Ω A→V+, 680 Ω B→GND), and one 120 Ω termination. The fourth tile carries the other 120 Ω. Middle tiles leave termination and biasing unpopulated.

## 2. Per-tile block diagram

```
        LEFT EDGE                                           RIGHT EDGE
        CONNECTOR J1                                        CONNECTOR J2
        ┌────────┐                                          ┌────────┐
 GND ───│ 1      │◄────────── pass-through rail ───────────►│  1   8 │─── GND
  V+ ───│ 2  PIN │                                          │  PIN 7 │─── V+
 A   ───│ 3  MAP │◄────────── shared bus net A ────────────►│  MAP 6 │─── A
 B   ───│ 4      │◄────────── shared bus net B ────────────►│      5 │─── B
 B   ───│ 5      │                                          │      4 │─── B
 A   ───│ 6      │                                          │      3 │─── A
  V+ ───│ 7      │                                          │      2 │─── V+
 GND ───│ 8      │                                          │      1 │─── GND
        └────────┘                                          └────────┘
            │                                                    │
            │                                                    │
            │  (V+ and GND pass straight across — no series element)
            │
            ├───────────────────────────────────────── local 24V tap
            │
            ▼
      ┌─────────────┐
      │ POLYFUSE    │ 0.5 A hold, 1 A trip
      │ (F1)        │
      └─────┬───────┘
            ▼
      ┌─────────────┐
      │ P-MOSFET    │ Reverse-polarity block
      │ (Q1)        │
      └─────┬───────┘
            ▼
      ┌─────────────┐
      │ TVS (D1)    │ SMBJ28CA bidirectional, 28 V clamp
      └─────┬───────┘
            ▼
      ┌─────────────┐
      │ 47 µF/35V   │ Bulk input cap (C1)
      │ + 100 nF    │ HF bypass (C2)
      └─────┬───────┘
            ▼
      ┌─────────────┐   L1: 22 µH shielded
      │ MP1584EN    │   D2: SS34 Schottky
      │ buck (U1)   │   R_FB: 10k / 3.16k → 5.0 V out
      │ 24V → 5V    │   C_OUT: 2× 22 µF X7R
      └─────┬───────┘
            │ 5 V local
            ├─────────────────┬───────────────────┐
            ▼                 ▼                   ▼
       ┌────────┐        ┌─────────┐      ┌──────────────┐
       │ CH32V- │        │ MAX485  │      │ 25 × SK6812  │
       │  003   │──TX───►│ DI      │      │  RGBW chain  │
       │  (U2)  │◄─RX────│ RO      │      │              │
       │        │──DE───►│ DE/RE'  │      │ DATA_IN ◄────┼── from U2 PA1
       │        │        │ A   B   │      │              │
       └────────┘        └──┬───┬──┘      └──────────────┘
                            │   │
                      SHARED BUS NET A/B
                      (tied to both J1 and J2
                       pins via identical PCB nets)
```

## 3. Power subsystem detail

```
Edge V+ (24 V) ──┬────────────────────────────────────── pass-through to other edge V+
                 │
                 ├── F1 ──┬── Q1_s     Q1 = AO3401 P-MOSFET
                 │        │            gate to GND via R_G (10k), diode-clamped
                 │        │            source faces load (blocks reverse polarity
                 │        │            and drops only ~Rds_on × I ≈ 50 mV)
                 │        │
                 │        └── drain ──┬── TVS (D1, SMBJ28CA) to GND
                 │                    │
                 │                    ├── C1 (47 µF/35 V) to GND
                 │                    │
                 │                    └── VIN of MP1584
                 │
Edge GND ────────┴────────────────────────────────────── pass-through to other edge GND


MP1584EN (U1) pinout (TSOT-23-8):
   1 BOOT  ── 10 nF to SW
   2 VIN   ── from Q1 drain
   3 EN    ── tied to VIN (always on)
   4 COMP  ── loop compensation RC (22 kΩ + 2.2 nF to GND)
   5 FB    ── 3.16 kΩ to GND, 10 kΩ to VOUT  (Vfb = 0.8 V, ratio → 5.0 V)
   6 GND
   7 SW    ── to L1 (22 µH) → VOUT node; D2 (SS34) from SW to GND
   8 VIN   ── tied to pin 2

VOUT node:
   ── 2 × 22 µF X7R (C_OUT1, C_OUT2) to GND
   ── 100 nF (C_OUT3) to GND at point of load
   ── 5 V rail to MCU, transceiver, LED cluster
```

### Power math check

| Load | I @ 5 V | Local 5 V current |
|---|---:|---:|
| CH32V003 active | ~5 mA | |
| MAX485 active | ~1 mA | |
| 25 × SK6812 RGBW at full white | ~1500 mA | |
| **Peak local load** | | **~1.51 A** |

MP1584EN is rated 3 A output — comfortable margin. Efficiency at 1.5 A load, 24 V input: ~85 % from the datasheet curves. Input current: `1.51 × 5 / 24 / 0.85 ≈ 0.37 A per tile at 24 V`.

For 8 tiles chained, worst case through tile 1's connectors: **~3 A at 24 V**, well within 2×-pin-parallel header capacity (~6 A for 0.1" headers).

## 4. RS-485 subsystem detail

```
MAX485 (U3) pinout (SOIC-8):
   1  RO   ── to CH32V003 USART1_RX (PD6)
   2  RE'  ── tied to pin 3 (half-duplex: DE and RE' always match)
   3  DE   ── from CH32V003 GPIO (PD4); HIGH = driving, LOW = receiving
   4  DI   ── from CH32V003 USART1_TX (PD5)
   5  GND
   6  A    ── to edge connector pins 3 and 6 (both edges)
   7  B    ── to edge connector pins 4 and 5 (both edges)
   8  VCC  ── 5 V

Protection and biasing (populated only on first/last tiles):
   TVS diode between A-B (SM712 or PESD1CAN, £0.15)
   120 Ω termination: resistor between A and B, placed on endpoint tiles only
   680 Ω fail-safe bias: A→V+ and B→GND, placed on master only
```

### Bus throughput budget at 1 Mbps

- 1 bit = 1 µs. UART framing: 10 bits/byte (start + 8 + stop) = 10 µs/byte.
- Per-tile packet: `SOF(1) + ADDR(1) + CMD(1) + LEN(1) + 75B payload + CRC(1) = 80 bytes = 800 µs`.
- 32 tiles × 800 µs = 25.6 ms per full frame + broadcast LATCH (~50 µs).
- **Supports ~38 fps for 32 tiles at 1 Mbps.** Bump to 2.5 Mbps (CH32V003 USART can do this) for ~96 fps.

## 5. MCU subsystem detail

CH32V003F4P6 pin assignments for v1 (TSSOP-20):

| Pin | Name | Function | Net |
|---:|---|---|---|
| 1 | PD4 | GPIO output | `RS485_DE` (driver enable, also tied to /RE) |
| 2 | PD5 | USART1_TX | `TX` → MAX485 DI |
| 3 | PD6 | USART1_RX | `RX` ← MAX485 RO |
| 4 | PD7/NRST | Reset | pulled up, test point |
| 5 | PA1 | GPIO output (TIM1 CH2 optional) | `LED_DATA` → SK6812 chain |
| 6 | PA2 | GPIO | Reserved (v2 NBR_N) |
| 7 | GND | Ground | GND |
| 8 | PC0 | GPIO | Reserved (v2 NBR_E) |
| 9 | PC1 | GPIO | Reserved (v2 NBR_S) |
| 10 | PC2 | GPIO | Reserved (v2 NBR_W) |
| 11 | PC3 | GPIO | (spare) |
| 12 | PC4 | GPIO | (spare) |
| 13 | PC5 | GPIO | (spare) |
| 14 | PC6 | GPIO | (spare) |
| 15 | PC7 | GPIO | (spare) |
| 16 | PD0 | GPIO / OSCI | (spare) |
| 17 | PD1 | SWIO | **PROGRAMMING — WCH-LinkE** (do not load) |
| 18 | PD2 | GPIO | (spare) |
| 19 | PD3 | GPIO | (spare) |
| 20 | VDD | 5 V | 5 V rail (with 100 nF + 10 µF decoupling) |

Programming header (3-pin JST-SH or test pads): 5 V, GND, SWIO (PD1). Flashed by WCH-LinkE before install; over-the-bus OTA is a v2 firmware task.

## 6. LED chain

SK6812 RGBW data line is fed from `PA1` (CH32V003) via a 330 Ω series resistor (reduces reflections on the first LED's data input). 25 LEDs in a 5×5 grid, wired in classic snake order (row 0 left-to-right, row 1 right-to-left, etc.).

Decoupling: 100 nF per LED is overkill but good practice — budget allows. Minimum: one 10 µF bulk cap + 100 nF every 5 LEDs.

Absolute max current with all LEDs full white: 25 × 60 mA = 1.5 A. Buck is sized for 2 A → 25 % margin. If the user-facing brightness cap is set to 80 %, continuous worst case drops to 1.2 A.

## 7. Master module

```
ESP32-C3 (e.g. XIAO ESP32-C3 dev board):
   3V3  ─── from onboard USB/LDO
   GND  ─── shared with 24 V PSU GND!!  ← critical
   GPIO0 ── UART0 TX ─► MAX485 DI
   GPIO1 ── UART0 RX ─◄ MAX485 RO
   GPIO2 ── GPIO ────► MAX485 DE (tied to /RE)

MAX485 (master side, SOIC-8):
   VCC   ─── 5 V (can derive from USB or step-up from 3.3 V; 3.3 V-tolerant variants exist — check datasheet)
   A     ─── to bus A, via 120 Ω termination to B
                            and 680 Ω bias to V+
   B     ─── to bus B, via 680 Ω bias to GND

Master 24 V → tile chain V+: wired directly (PSU feeds the chain, master logic
powered from USB — separate rail for clean operation during firmware work).
```

**Critical:** master GND and 24 V PSU GND must be **the same net**. If not, the RS-485 common-mode reference is undefined and you'll get intermittent bit errors.

## 8. Consolidated netlist (per tile)

For reference when laying out the PCB.

```
NET V24        J1.2, J1.7, J2.2, J2.7, F1.1, (no decoupling — pass-through)
NET V24_LOCAL  F1.2, Q1.source
NET V24_FUSED  Q1.drain, D1.+, C1.+, U1.2 (VIN), U1.8 (VIN)
NET SW         U1.7, L1.a, D2.cathode
NET V5         L1.b, D2.anode_NO (Schottky anode = GND side), C_OUT1+, C_OUT2+, U1.5 via feedback divider, U2.20 (VDD), U3.8 (VCC), LED[0].VCC..LED[24].VCC
NET GND        J1.1, J1.8, J2.1, J2.8, D1.-, C1.-, U1.6, D2.anode (SS34 cathode = SW, anode = GND), C_OUT*.-, R_FB_lo, U2.7 (GND), U3.5 (GND), LED[*].GND
NET BUS_A      J1.3, J1.6, J2.3, J2.6, U3.6 (A)
NET BUS_B      J1.4, J1.5, J2.4, J2.5, U3.7 (B)
NET UART_TX    U2.2 (PD5), U3.4 (DI)
NET UART_RX    U2.3 (PD6), U3.1 (RO)
NET RS485_DE   U2.1 (PD4), U3.2 (RE'), U3.3 (DE)
NET LED_DATA   U2.5 (PA1), R_SERIES, LED[0].DIN
```

(`LED[i]` is the i-th SK6812 in the chain; DOUT of each connects to DIN of the next.)

## Open electrical questions

- **Ground pour under buck switch node** — keep SW node area minimised; pour under VOUT only. Will be addressed in PCB layout.
- **ESD on edge connector pins** — TVS on bus already specced; V+ and GND pins see transients too. Consider TVS arrays on all four pins of the connector in the PCB version.
- **Brown-out on master when chain is live-connected** — inrush from C1 (47 µF × 32 tiles = 1.5 mF) at 24 V is severe. Add NTC inrush limiter at the PSU or soft-start resistor on the first tile's polyfuse branch.