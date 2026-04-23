# Architecture

This document captures the current working design. It is **a draft**, not a committed specification. Claims marked "unverified" need bench data before they become load-bearing.

## High-level

```
┌──────────────────────────────────────────┐
│         MASTER UNIT                      │
│  ESP32 (or RPi Zero 2W)                  │
│  - Custom firmware or WLED fork          │
│  - Holds full grid map                   │
└────────────────┬─────────────────────────┘
                 │ Shared bus (see below)
                 │
    ┌────────────┼────────────┬────────────┐
    ▼            ▼            ▼            ▼
 [Tile 01]   [Tile 02]   [Tile 03]   [Tile 04]
 CH32V003    CH32V003    CH32V003    CH32V003
 + LEDs      + LEDs      + LEDs      + LEDs
```

Every tile is addressed individually. No row leaders, no per-row WiFi.

## MCU: CH32V003

- 32-bit RISC-V @ 48 MHz, 16 KB flash, 2 KB RAM
- 18 GPIO on QFN-20; fewer on smaller packages
- **64-bit unique ID** in silicon — basis for tile identity
- ~£0.15 at volume, WCH-LinkE programmer is a one-off ~£4

## The bus — under review

The original proposal (inherited from [rmingon/led-wall](https://github.com/rmingon/led-wall)) uses an **8-bit parallel bus**:

```
DATA0..DATA7   8 data lines
CLK            Rising edge latches a byte
EN             Per-tile chip select
GND × 2        Ground
5V × 2         Power
```

14 pins per edge. Packet format:

```
0xA5  0x5A  ADDR  CMD  LEN  PAYLOAD[LEN]  CRC8
```

`ADDR 0xFF` = broadcast. `ADDR 0x00–0xFE` = unicast.

**Why this is under review:**

- Parallel buses across daisy-chained connectors suffer skew, reflections, and EMI above a few MHz. Reference project signal-integrity data does not exist publicly.
- Pin count (14 per edge × 4 edges) is a mechanical cost driver.
- The CH32V003 has SPI and UART peripherals that could drive the same LED payload with far fewer pins across a backplane or star topology.

**Alternatives to evaluate on the bench:**

| Option | Pins/edge | Pros | Cons |
|---|---|---|---|
| 8-bit parallel (current) | 14 | Reference implementation exists | EMI, skew, pin count |
| SPI (MOSI, MISO, SCK, CS) + power | ~8 | Standard peripheral, fewer pins | Bus loading across many tiles |
| RS-485 multidrop + power | ~6 | Robust over long runs, differential | Needs transceiver per tile (+cost) |
| WS2812B passthrough + per-tile sidechannel | 4–6 | Reuses existing ecosystem | Loses per-tile addressing benefit |

Decision deferred until a 2-tile proof is built.

## Addressing

Two paths, simplest first:

**Phase 1 — manual/factory-assigned addresses.** Matches the reference project. Each tile flashed with its address at build time. Ships working; loses the plug-and-play promise.

**Phase 2 — UID-based auto-assignment.** On boot, master broadcasts "report your UID"; tiles respond in UID-keyed time slots to avoid collisions; master assigns sequential addresses. This is a **novel design for a clocked parallel bus** — arbitration is not native the way it is on I2C. Treat as a research task, not a done deal.

## Position detection

**Option A — neighbour pins (target for v2).** Each edge has a dedicated neighbour-detect pin wired through the connector. When two tiles mate, each side sees the other's pin go high, and also exchanges UIDs over the bus on request. Master builds a topology graph from reports.

- Needs 4 GPIO on the tile MCU (available).
- Needs pinout **mirror symmetry** on opposing edges so a tile's NORTH pin lands on the next tile's SOUTH pin through the connector.

**Option B — daisy-chain address pass-through.** First tile is address 1, passes `next=2` to its physical neighbour, etc. Works only for fixed topologies.

**Option C — manual map in web UI (target for v1).** User arranges tiles on a grid in the UI. Tiles identified by UID. Persisted.

Ship C first. Design hardware so A can land later.

## Power distribution

**The original proposal of "2× 5V pogo pins per edge feeds the whole bus" does not scale.**

- 25 SK6812 per tile at full white ≈ 1.5 A. 32 tiles ≈ 48 A.
- Pogo pins are ~1–2 A each. Daisy-chained 5V across many tile edges drops voltage noticeably.

Options under review:

- Dedicated power injection points every N tiles via fatter contacts or screw terminals.
- A separate power backplane (rigid or flex) that tiles clip into, distinct from the signal bus.
- Lower per-tile LED current budget (software-capped brightness).

Not resolved.

## Master firmware approaches

| Approach | Effort | Result |
|---|---|---|
| Custom firmware on ESP32 | Medium | Full control, clean architecture |
| WLED fork + parallel-bus usermod | Medium | Keeps WLED effects library |
| WLED → DDP/E1.31 → bus-driver ESP32 | Low–medium | Keeps WLED ecosystem; bridge handles 2D→tile mapping |

Cross-tile effects require synchronous frame delivery; the bridge approach needs to hold a frame buffer and push whole frames, not stream pixels.

## Known risks

See [`open-questions.md`](open-questions.md) for the live list.
