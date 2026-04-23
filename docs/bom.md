# Bill of Materials

Draft. Prices are rough estimates and **need real supplier quotes** before any of these numbers drive a decision. All prices GBP.

## Per tile

| Component | Qty | Est. unit | Est. total | Notes |
|---|---:|---:|---:|---|
| SK6812 RGBW LED | 25 | £0.17 | £4.25 | Confirm with volume quote |
| CH32V003 MCU (QFN-20) | 1 | £0.15 | £0.15 | Volume price from LCSC |
| Edge connector (pogo pins or 1×14 header) | 4 edges | TBD | £2.00–5.60 | **Unresolved — see open questions** |
| Neodymium magnets | 4 | £0.10 | £0.40 | Alignment only, not primary attach |
| Small PCB | 1 | £0.20 | £0.20 | Est. from JLCPCB at volume |
| Passives (decoupling, pullups, fuses) | ~10 | — | £0.20 | |
| Polyfuse | 1 | £0.05 | £0.05 | Short isolation |
| PETG / PLA filament | — | — | £0.30 | Enclosure |
| Diffuser sheet | 1 | — | £0.10 | |
| **Per-tile subtotal** | | | **~£5.65–9.25** | **Wider range than the original £2.62 estimate** |

## Per system (32-tile target)

| Line item | Qty | Est. cost | Notes |
|---|---:|---:|---|
| Tiles | 32 | £180–296 | Per-tile range × 32 |
| ESP32 master | 1 | £8 | |
| 5 V PSU (sized for ~50 A or brightness-capped) | 1 | £25–60 | **Depends on brightness policy** |
| Power distribution (backbone/backplane) | 1 | £10–30 | **Unresolved** |
| Enclosure / frame | 1 | £20–50 | |
| **System subtotal** | | **~£243–444** | |

## Notes on the original estimate

The original proposal quoted ~£100 per 32-tile system. That used optimistic pogo-pin pricing and assumed 2× 5V pogo pins can carry the whole rail (they cannot — see architecture doc). This BOM will be revised once supplier quotes and the 2-tile bench test land.
