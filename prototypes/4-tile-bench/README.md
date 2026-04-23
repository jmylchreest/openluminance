# 4-tile bench prototype

First physical prototype. Goal is to prove the v1 electrical and protocol design end-to-end on a breadboard / perfboard before committing to a PCB.

## Scope

- 4 tiles assembled, bench parts for 8 in stock (slack for failures and iteration).
- Real 24 V PSU, real RS-485 wiring between tiles.
- Linear chain topology (master → tile 1 → tile 2 → tile 3 → tile 4).
- Discovery, addressing, pixel push, full-frame latch verified.

## Contents

- [`schematic.md`](schematic.md) — electrical diagrams, netlist, component-level detail.
- [`parts-list.md`](parts-list.md) — exact part numbers with supplier references.
- [`bringup-checklist.md`](bringup-checklist.md) — step-by-step verification plan.

## Success criteria

The prototype is successful when all of these pass:

1. **Power:** 4 tiles chained, measured 24 V rail sag at tile 4 is < 0.3 V at worst-case brightness. 5 V local buck output stays within ±2 % under full LED load.
2. **Bus integrity:** RS-485 eye diagram at tile 4 is clean at 1 Mbps. Sustained zero-error packet stream for 10 minutes at 60 fps-equivalent load.
3. **Discovery:** All 4 UIDs enumerated and addressed within 1 s from cold boot. Reproducible across 10 cold starts.
4. **Frame push:** Full 4-tile frame (25 RGBW pixels each) delivered and latched in < 20 ms. No visible tearing between tiles during animation.
5. **Fault tolerance:** Shorting the 5 V output on one tile (simulated LED short) blows only that tile's polyfuse; the other three continue operating.
6. **Thermal:** Tiles at full white for 30 minutes stay below 60 °C surface temperature with passive convection.

Failures on any of these invalidate the design assumption and must be resolved before PCB order.

## What this prototype does NOT test

- Mechanical edge connector (bench uses flying leads; connector choice is tested separately).
- Final PCB routing and ground-pour EMI.
- Scaling beyond 4 tiles (covered later with a 16-tile run on PCB).
- Free-form mesh v2.