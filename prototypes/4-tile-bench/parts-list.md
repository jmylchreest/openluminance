# Parts list — 4-tile bench kit (buy for 8)

Quantities sized for 8 assemblies so there's slack for damage, dead-on-arrival units, and one-step scale-up. Prices are sanity-check estimates (qty 10–100, LCSC/Mouser/AliExpress); confirm on the supplier site before ordering. Total target: **~£135** for the bench kit including a small PSU.

## Semiconductors

| Designator | Part | Qty | Supplier ref | Est. £ each | Total | Notes |
|---|---|---:|---|---:|---:|---|
| U2 | CH32V003F4P6 (TSSOP-20) | 10 | LCSC C5143676 | 0.15 | 1.50 | MCU |
| U3 | MAX485ESA+ (SOIC-8) | 10 | Mouser 700-MAX485ESA | 0.60 | 6.00 | RS-485 transceiver (5 V). SP485EE or MAX3485 (3.3 V) are alternates |
| U1 | MP1584EN (TSOT23-8) | 10 | LCSC C6712 | 0.50 | 5.00 | Or **buy ready-made MP1584 modules** for bench (see below) |
| Q1 | AO3401 P-MOSFET (SOT-23) | 10 | LCSC C15127 | 0.08 | 0.80 | Reverse-polarity protection |
| D1 | SMBJ28CA TVS (SMB) | 10 | LCSC C24327 | 0.12 | 1.20 | 24 V rail clamp, bidir |
| D2 | SS34 Schottky (SMA) | 10 | LCSC C8598 | 0.10 | 1.00 | Buck freewheel |
| — | **SK6812 RGBW 5050** | 250 | LCSC C965556 or AliExpress | 0.15 | 37.50 | 25 per tile × 10 for slack |

**Bench shortcut:** instead of discrete MP1584 circuits, buy **MP1584EN step-down modules** (AliExpress / Amazon, £1–2 each in 5-packs) pre-populated with inductor, caps, and a trim pot. Adjust trim pot to 5.00 V once, solder in. Eliminates most of the buck debugging and gets you to first-light faster. We'll do the discrete implementation on the PCB.

## Passives

| Designator | Value | Pkg | Qty (for 8 tiles) | Est. £ | Notes |
|---|---|---|---:|---:|---|
| F1 | Polyfuse 0.5 A hold / 1 A trip | 1812 SMD | 10 | 0.40 | Littelfuse 1812L050 or similar |
| C1 | 47 µF / 35 V electrolytic | through-hole radial | 10 | 0.50 | Input bulk |
| C_OUT1, C_OUT2 | 22 µF / 10 V X7R | 1206 | 20 | 1.00 | Buck output bulk |
| C_BYP (scattered) | 100 nF / 25 V X7R | 0603 | 50 | 0.50 | Decoupling everywhere |
| C_LED_BULK | 10 µF / 10 V X7R | 1206 | 10 | 0.30 | LED strip bulk, 1 per tile |
| L1 | 22 µH shielded, 3 A sat | SMD or through-hole | 10 | 2.50 | For MP1584 discrete (skip if using modules) |
| R_FB_HI | 10 kΩ 1 % | 0603 | 10 | 0.05 | Feedback divider high side |
| R_FB_LO | 3.16 kΩ 1 % | 0603 | 10 | 0.05 | Feedback divider low side → 5.00 V |
| R_COMP | 22 kΩ | 0603 | 10 | 0.05 | Buck loop comp |
| C_COMP | 2.2 nF | 0603 | 10 | 0.05 | Buck loop comp |
| R_LED_SERIES | 330 Ω | 0603 | 10 | 0.05 | On LED data line |
| R_MCU_PU | 10 kΩ | 0603 | 30 | 0.10 | NRST pullup, DE pulldown, etc. |
| R_TERM | 120 Ω 1 % | 0603 | 5 | 0.05 | Bus termination (2 needed + spares) |
| R_BIAS | 680 Ω | 0603 | 5 | 0.05 | Bus biasing at master (2 needed) |

## Connectors and mechanical

| Item | Qty | Est. £ | Notes |
|---|---:|---:|---|
| 1×8 male pin header (2.54 mm) | 20 | 1.50 | 2 per tile + master + spares |
| 1×8 female socket (2.54 mm) | 20 | 2.00 | Female side used depending on chain orientation |
| 3-pin 2.54 mm header (programming) | 10 | 0.50 | SWIO + 5 V + GND |
| Phoenix / screw terminal 2-pos | 2 | 1.00 | 24 V PSU input at master |
| Perfboard / stripboard 50 × 70 mm | 10 | 5.00 | One per tile |
| Hook-up wire assortment | — | 5.00 | 22 AWG |
| Solid-core jumper wire | — | 3.00 | For protoboard bridging |

## Tools and instruments

| Item | Qty | Est. £ | Notes |
|---|---:|---:|---|
| WCH-LinkE programmer | 1 | 4.00 | Flashes CH32V003 |
| USB-RS485 adapter (FT232RL or CH340 + MAX485) | 1 | 8.00 | For master-side testing and bus sniffing |
| 24 V / 2 A bench PSU | 1 | 30–60 | Mean Well LRS-50-24 is ~£15 if you already have an enclosure/fuse; add 5 V USB for logic separately |
| XIAO ESP32-C3 dev board | 1 | 5.00 | Master MCU |
| USB-to-USB-C cable | 1 | 3.00 | For ESP32-C3 |

**Already-owned assumptions:** logic analyser (e.g. Saleae / cheap 8-ch clone), DMM, soldering iron, oscilloscope with ≥50 MHz BW (helpful for eye diagrams on RS-485).

## Total estimate

| Category | £ |
|---|---:|
| Semiconductors | ~52 |
| Passives | ~6 |
| Connectors and mechanical | ~18 |
| Tools and instruments | ~50–80 |
| **Total (with PSU and programmer)** | **~£125–155** |

If WCH-LinkE and USB-RS485 adapter are already owned, drops to ~£85–115.

## Sourcing notes

- **LCSC** is cheapest for CH32V003, MP1584, most passives — factor in postage (~£15 from CN to UK, 2–3 weeks) or use JLCPCB's parts service.
- **Mouser / Digikey** for authentic MAX485 if you've been burned by counterfeits (MAX485 is heavily cloned).
- **AliExpress** for MP1584 ready-made modules, SK6812 reels, and pogo-pin test accessories.
- **For UK same-day needs** (breakage, replacements): Pimoroni, The Pi Hut, CPC Farnell — roughly 2× LCSC pricing but available tomorrow.