# openluminance

Modular, magnetically-attached LED tiles with per-tile MCUs on a shared bus. Firmware, hardware, mechanical models, and docs live together in this repo.

**Status:** v1 design committed; 4-tile bench prototype is the next step. See [`prototypes/4-tile-bench/`](prototypes/4-tile-bench/).

---

## Concept

A master controller talks to every tile on an RS-485 bus. Each tile carries its own MCU, a small cluster of RGBW LEDs, a local buck converter, and an 8-pin palindromic edge connector so it can be rotated and still mate. The master enumerates tiles via a 1-Wire-style UID search, then pushes per-tile pixel data and broadcasts a synchronous latch.

Committed v1 decisions:

- **Per-tile MCU:** CH32V003F4P6 (32-bit RISC-V, TSSOP-20, ~£0.12, 64-bit UID baked in).
- **Bus:** RS-485 half-duplex at 1 Mbps (headroom to 10 Mbps). Linear / serpentine chain.
- **Power:** 24 V backbone chained through edge connectors, per-tile buck to 5 V. Self-correcting under voltage sag.
- **Edge connector:** 8-pin palindromic (`GND V+ A B B A V+ GND`) — any orientation mates, every signal has a redundant pin.
- **Master:** ESP32-C3 + MAX485, exposes a web UI and serves frames to the chain.

Full rationale and math in [`docs/architecture.md`](docs/architecture.md). Bench-prototype electrical schematic in [`prototypes/4-tile-bench/schematic.md`](prototypes/4-tile-bench/schematic.md).

## Repo layout

```
firmware/
  tile/            CH32V003 firmware (per tile)
  master/          ESP32-C3 master firmware
hardware/
  tile/            KiCad project for the tile PCB
  master/          KiCad project for the master board
mechanical/
  openscad/        Parametric tile enclosure, diffuser, alignment features
  stl/             Exported STLs for printing
prototypes/
  4-tile-bench/    First physical prototype — schematic, parts list, bring-up plan
docs/
  architecture.md  Bus, power, addressing, edge connector
  bom.md           Per-tile and per-system BOM
  open-questions.md Open risks and unsettled decisions
  references.md    Prior art and reference projects
thirdparty/        Git submodules for external libraries (OpenSCAD, etc.)
```

## Open questions (live)

Tracked in [`docs/open-questions.md`](docs/open-questions.md). Headline items still open:

- Edge connector physical form (pin header vs pogo strip vs mezzanine).
- Mechanical alignment tolerance on FDM PETG parts.
- Firmware update path over the bus.
- Inrush current when hot-plugging a chain of 32+ tiles at 24 V.

## Prior art

- [rmingon/led-wall](https://github.com/rmingon/led-wall) — CH32V003F*P6 + 8-bit parallel bus via 1×14 edge headers. Closest reference; hardcodes tile addresses.
- [Modular LED Wall with CH32V006 RISC-V Slave Tiles (Hackaday.io)](https://hackaday.io/project/203942-modular-led-wall-with-ch32v006-risc-v-slave-tiles)
- [CH32V003 64-bit UID read](https://pallavaggarwal.in/2023/09/25/ch32v003-programming-read-unique-id/)

## License

TBD — expected MIT for firmware/software, CERN-OHL-S for hardware, CC-BY-SA for mechanical models. Will be finalised before first release.
