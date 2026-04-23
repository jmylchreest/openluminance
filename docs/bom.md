# Bill of Materials

Prices in GBP, estimated from LCSC / Mouser volume pricing (qty 100+) unless marked otherwise. Final BOM will be revised once real quotes and the 4-tile bench test land. For specific part numbers and hand-solder bench kit, see [`../prototypes/4-tile-bench/parts-list.md`](../prototypes/4-tile-bench/parts-list.md).

## Per tile (v1 — RS-485 + 24 V backbone)

| Component | Qty | Est. unit | Est. total | Notes |
|---|---:|---:|---:|---|
| SK6812 RGBW LED | 25 | £0.17 | £4.25 | Confirm with volume quote |
| CH32V003F4P6 MCU (TSSOP-20) | 1 | £0.12 | £0.12 | LCSC C5143676 |
| MAX485 / SP485EEN RS-485 transceiver | 1 | £0.35 | £0.35 | SOIC-8, 5 V |
| MP1584EN buck (24→5 V, 2 A) | 1 | £0.45 | £0.45 | TSOT-23-8 + L + Cs |
| Buck inductor + output caps + Schottky | — | — | £0.18 | 22 µH shielded, 2× 22 µF |
| P-MOSFET (reverse-polarity) | 1 | £0.10 | £0.10 | AO3401 or similar |
| TVS diode (SMBJ28CA, bidir) | 1 | £0.10 | £0.10 | 24 V rail clamp |
| Polyfuse (0.5 A hold) | 1 | £0.05 | £0.05 | Local branch protect |
| Bulk cap on 24 V tap | 1 | £0.08 | £0.08 | 47 µF, 35 V electrolytic |
| Edge connectors (2 × 8-pin header + socket, palindromic) | 1 set | £1.00 | £1.00 | Same pinout on all 4 edges reserved for v2; v1 populates 2 |
| PCB (100 × 100 mm, 4-layer) | 1 | £0.40 | £0.40 | JLCPCB volume |
| Passives (decoupling, pullups, term resistors) | ~15 | — | £0.15 | |
| Neodymium magnets 5 × 2 mm | 4 | £0.10 | £0.40 | Mating assist |
| PETG enclosure + alignment dowels | — | — | £0.30 | 3D printed |
| Diffuser sheet | 1 | — | £0.10 | |
| **Per-tile subtotal** | | | **~£8.03** | |

## Per system (32-tile target)

| Line item | Qty | Est. cost | Notes |
|---|---:|---:|---|
| Tiles | 32 | £257 | 32 × £8.03 |
| ESP32-C3 master module | 1 | £5 | XIAO ESP32-C3 or equivalent |
| Master-side MAX485 + biasing + termination | 1 | £2 | |
| 24 V PSU | 1 | £30 | Mean Well LRS-350-24 (≈15 A) |
| Power distribution cable + connectors | 1 | £15 | 2 × 14 AWG + DC barrel/terminal |
| Array frame + back panel | 1 | £25 | Aluminium extrusion or plywood |
| Miscellaneous (fasteners, cable ties, strain relief) | — | £10 | |
| **System subtotal** | | **~£344** | |

## Cost comparison vs. the original sketch

| Version | Claimed | Reality |
|---|---:|---:|
| Original parallel-bus proposal | £107 | Understated; pogo pin pricing unrealistic, power distribution unaccounted for |
| v1 RS-485 + 24 V (this) | — | **~£337 all-in** for a working 32-tile system |

The system cost roughly triples compared to the original guess, because the original omitted power distribution, PSU, frame, and realistic connector pricing. £337 is still a reasonable price for a 32-tile custom LED wall.

## What still needs real quotes before PCB order

- SK6812 RGBW from a verified supplier (price varies 2× between reels)
- Edge connector choice (see [`open-questions.md`](open-questions.md))
- PCB quote once design is finalised
- Enclosure cost once mechanical design is drawn
