# openluminance

Modular, magnetically-attached LED tiles with per-tile MCUs on a shared bus. Firmware, hardware, mechanical models, and docs live together in this repo.

**Status:** pre-hardware — architecture draft. No prototype built yet. Everything here is subject to change after the first bench test.

---

## Concept

A master controller talks directly to every tile on a shared bus. Each tile carries its own MCU, a small cluster of RGB(W) LEDs, and edge connectors so it can be snapped against neighbouring tiles in any arrangement. The master assembles a topology map from what the tiles report, then pushes pixels.

Key decisions on the table (not yet settled):

- **Per-tile MCU:** CH32V003 (32-bit RISC-V, ~£0.15, 64-bit UID baked in).
- **Bus:** 8-bit parallel + CLK + EN via edge connectors. *See [`docs/architecture.md`](docs/architecture.md) — SPI / RS-485 are live alternatives under review.*
- **Topology:** tile-to-tile edge connection via pogo pins or 1×14 headers, magnet-aligned. Mechanical alignment is unresolved.
- **Master:** ESP32 running either custom firmware or a WLED fork with a parallel-bus usermod.

## Repo layout

```
firmware/
  tile/            CH32V003 firmware (per tile)
  master/          ESP32 master firmware
hardware/
  tile/            KiCad project for the tile PCB
  master/          KiCad project for the master/bus-driver board
mechanical/
  openscad/        Parametric tile enclosure, diffuser, alignment features
  stl/             Exported STLs for printing
docs/
  architecture.md  Bus, addressing, topology detection
  bom.md           Per-tile and per-system BOM
  open-questions.md Unresolved design questions and risks
  references.md    Prior art and reference projects
thirdparty/        Git submodules for external libraries (OpenSCAD, etc.)
```

## Open questions

Tracked in [`docs/open-questions.md`](docs/open-questions.md). Non-exhaustive:

- Auto-addressing on a clocked parallel bus — aspirational, not proven. Reference project hardcodes addresses.
- Power distribution — pogo pins at 48 A system-wide won't work; need a dedicated power backbone.
- Daisy-chained bus signal integrity — skew/reflections across N hops, not a true shared bus.
- Pogo-pin alignment tolerance on FDM-printed PETG tiles.
- Honest BOM — pogo pin price assumptions in the original sketch were low.

## Prior art

- [rmingon/led-wall](https://github.com/rmingon/led-wall) — CH32V003F*P6 + 8-bit parallel bus via 1×14 edge headers. Closest reference; hardcodes tile addresses.
- [Modular LED Wall with CH32V006 RISC-V Slave Tiles (Hackaday.io)](https://hackaday.io/project/203942-modular-led-wall-with-ch32v006-risc-v-slave-tiles)
- [CH32V003 64-bit UID read](https://pallavaggarwal.in/2023/09/25/ch32v003-programming-read-unique-id/)

## License

TBD — expected MIT for firmware/software, CERN-OHL-S for hardware, CC-BY-SA for mechanical models. Will be finalised before first release.
