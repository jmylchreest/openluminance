# Sourcing the bench kit

Guide to buying the bench kit. AliExpress is the cheapest path for most items. UK/EU reputable distributors (RS, Farnell/CPC, Mouser, Pimoroni, Digikey, Olimex) are faster and more reliable but 2–4× more expensive — used here mainly for the counterfeit-risk parts.

The links below were verified at commit time. **AliExpress URLs rot fast** — if a specific listing 404s, the search strings in [§ search strings and seller archetypes](#search-strings-and-seller-archetypes) will find equivalents. Paired with [`parts-list.md`](parts-list.md) for quantities.

## Quick-start verified listings

Headline purchases for the bench kit, with both cheapest (AliExpress / LCSC) and UK/EU-reputable sources.

| Part | Cheapest (China) | UK/EU reputable | Notes |
|---|---|---|---|
| **CH32V003F4P6** (MCU, TSSOP-20) | [LCSC C5187096](https://www.lcsc.com/product-detail/C5187096.html) (~$0.12 @ qty 100), or [AliExpress 100pcs](https://www.aliexpress.com/item/1005006178321495.html) | **Not stocked at RS/Farnell/CPC/Mouser UK** — WCH chips are LCSC/AliExpress distribution only | Order from LCSC if you want fewer clone concerns; AliExpress for small qty |
| **WCH-LinkE** programmer | [AliExpress listing](https://www.aliexpress.com/item/1005007777129888.html) (~£4–5); also [LCSC kit with eval board + programmer](https://www.lcsc.com/product-detail/Microcontroller-Units-MCUs-MPUs-SOCs_WCH-Jiangsu-Qin-Heng-CH32V003F4P6-EVT-WCH-LinkE_C5236707.html) | [Olimex WCH-LinkE (EU)](https://www.olimex.com/Products/RISC-V/WCH/WCH-LinkE/) (~€8) | Olimex is authentic and EU-shipped; AliExpress is usually fine for this simple programmer |
| **MAX485ESA+** RS-485 transceiver | [AliExpress MP1584 + MAX485 combo kits](https://www.aliexpress.com/item/32261885063.html) — use search strings below for MAX485-only | [CPC Farnell MAX485CSA+ SC19150](https://cpc.farnell.com/maxim-integrated-analog-devices/max485csa/bus-transceiver-smd-soic8-485/dp/SC19150) (~£1.40/ea), Mouser UK, RS Components | **Buy this one from a reputable UK source.** MAX485 is heavily cloned on AliExpress and clones fail at 1 Mbps. Few £ savings not worth the debugging time. |
| **MP1584EN buck module** | [AliExpress 1pc listing](https://www.aliexpress.com/item/32261885063.html), [AliExpress module listing](https://www.aliexpress.com/item/32828603866.html) (buy in 10-packs) | [Opencircuit MP1584EN module (EU)](https://opencircuit.shop/product/mp1584en-mini-buck-converter-4.5v-28v-module), Pimoroni carries similar | AliExpress 10-pack is fine — these modules are hard to fake meaningfully |
| **SK6812 RGBW 5050 natural white, 100 pcs** | [AliExpress 100/1000pcs RGBW listing](https://www.aliexpress.com/item/Germany-warehouse-100pcs-1000pcs-SK6812-IC-Bulit-in-5050-RGB-RGBW-RGBW-CCT-SMD-Addressable-LED/32580793956.html), [BTF-LIGHTING on AliExpress](https://www.aliexpress.us/item/2251832628463811.html) | [BTF-LIGHTING SK6812 100pcs RGBW Natural White on Amazon](https://www.amazon.com/BTF-LIGHTING-Natural-5050SMD-WS2812B-Addressable/dp/B0DNJJNBHJ) | BTF-LIGHTING is the well-regarded brand; buy direct from them on AliExpress or via Amazon for faster UK delivery |
| **XIAO ESP32-C3** (master) | ~£3 clones on AliExpress (search `XIAO ESP32C3`) | [Pimoroni UK](https://shop.pimoroni.com/en-us/products/seeed-studio-xiao-esp32c3) (~£6–7), [Mouser Europe 113991054](https://eu.mouser.com/ProductDetail/Seeed-Studio/113991054?qs=3Rah4i+hyCHVBerMrpzCkw%3D%3D), [Digikey 113991054](https://www.digikey.com/en/products/detail/seeed-technology-co-ltd/113991054/16652880) ($4.99) | Pimoroni ships UK next day; genuine Seeed board |

## Key finding: CH32V003 is effectively China-only distribution

Confirmed at commit time: **RS Components UK, Farnell UK, CPC UK, and Mouser UK do not stock the CH32V003 in any variant.** WCH (the manufacturer) distributes via LCSC, AliExpress, and a small number of regional distributors. Practical implication:

- Order CH32V003 chips from **LCSC** (lcsc.com) — shipping is ~£15 from Shenzhen to UK via DHL / FedEx (7–10 days), or ~£5 via standard post (2–3 weeks). Minimum order thresholds are low.
- **Do not wait for RS/Farnell to stock it** — they don't, and probably won't in the short term.
- For the first prototype, 10 units cost ~£1.50 on LCSC + shipping. Bundle with other parts to amortise shipping.

## Search strings and seller archetypes

Once the verified links above rot, use these search patterns to find equivalents.

### Shipping tiers (matters for timing)

- **AliExpress Standard Shipping** — tracked, typically 15–25 days to UK. Best default for non-urgent bulk buys.
- **AliExpress Choice** / **Cainiao Premium** — often 10–15 days, sometimes free over a threshold.
- **EU Shipping** / **Local warehouse** — 3–7 days, more expensive, stock limited to popular items.
- **Standard free** (no tracking) — do not use for anything over £5.

Order everything in one or two baskets with the same shipping tier so parts arrive together.

## Reputable seller archetypes

AliExpress sellers come and go, but these *types* of sellers reliably sell the real thing:

- **"WCH Official Store"** — authentic CH32V003 and WCH-LinkE programmers. Search `WCH official` on AliExpress.
- **"LCSC" on AliExpress is NOT the same as lcsc.com** — beware. Use lcsc.com directly for LCSC pricing; the AliExpress lookalikes are unrelated.
- **"Chip CBM"**, **"Utsource"**, **"IC Brand"** — typically authentic branded silicon (MAX485, MP1584) but check reviews for counterfeits.
- **"BTF-LIGHTING"**, **"AKwil"**, **"Chinly"** — established SK6812 / WS2812 suppliers with consistent quality.
- **"Makerbase"**, **"HiLetgo"**, **"DIYmore"** — reliable for dev boards and modules.

**Always check:** seller age > 1 year, seller rating > 96 %, listing has > 100 orders, at least a few text reviews (not just photo reviews).

## Counterfeit-risk parts

These commonly get cloned on AliExpress. Either buy from Mouser/Digikey/LCSC instead, or be prepared to reject a batch:

| Part | Counterfeit risk | How to mitigate |
|---|---|---|
| MAX485 | **High** — clones use NE5090 or unmarked silicon, work at 100 kbps but fail at 1 Mbps | Buy SP485EEN or MAX485ESA from LCSC/Mouser, or accept ~25 % reject rate from AliExpress |
| FT232RL | **Very high** — old FTDI driver versions refused to work with clones | Buy CH340-based adapters instead (not commonly cloned) |
| SK6812 RGBW | **Medium** — often mixed with WS2812B or de-rated LEDs | Stick to BTF-Lighting / Chinly branded reels |
| CH32V003 | **Low** — too cheap to be worth cloning; but verify the IC marking reads "CH32V003" | Buy from WCH official or high-reputation sellers |
| MP1584EN | Low (module), medium (bare IC) | Buy pre-built modules for bench — clones are rare and usually still work |

Rule of thumb: **anything priced < 50 % of the Mouser price and < 80 % of LCSC price is suspect.**

## The shopping list

Grouped for bundling into single orders. Prices are typical AliExpress (qty-10 where applicable, inclusive of standard shipping) as of late 2025 / early 2026 — confirm before buying.

### Order 1 — MCUs, transceivers, protection ICs

Search on AliExpress, sort by orders, filter to 4-star+ sellers.

| Part | Search string | Qty | Expected total £ | Notes |
|---|---|---:|---:|---|
| CH32V003F4P6 | `CH32V003F4P6 TSSOP-20` | 10 | 1.50–3.00 | Sold in lots of 5 or 10. Often cheaper in 10-lots. |
| WCH-LinkE programmer | `WCH-LinkE` or `CH32V WCH-Link` | 1 | 3–5 | Needed to flash CH32V003. One is enough. |
| MAX485 SOIC-8 | `MAX485 SOIC-8` or `MAX485ESA` | 10 | 3.00–6.00 | If cheap (< £0.30/ea), expect some clones. |
| SP485EEN (alternative) | `SP485EE SOIC-8` | 10 | 5.00–8.00 | Lower clone rate than MAX485. |
| AO3401 P-MOSFET | `AO3401 SOT-23` | 50-pack | 1.00–2.00 | Buy in 50-packs, use elsewhere. |
| SMBJ28CA TVS | `SMBJ28CA` | 20-pack | 1.00–2.00 | Bidirectional variant (`CA` suffix). |
| SS34 Schottky | `SS34 SMA` | 50-pack | 1.00–2.00 | Standard buck freewheel. |
| **Order 1 subtotal** | | | **~£12–28** | |

### Order 2 — MP1584 modules (bench-speed shortcut)

For the bench prototype, **do not** populate MP1584 IC + inductor + caps discretely — it just adds debugging time. Buy ready-made modules and screw-set them to 5.00 V.

| Part | Search string | Qty | Expected total £ | Notes |
|---|---|---:|---:|---|
| MP1584EN buck module (adjustable, 3 A) | `MP1584EN 3A buck module adjustable` | 10 | 6–10 | Pre-assembled, pin headers, trim pot. |
| **Order 2 subtotal** | | | **~£6–10** | |

When the PCB lands, the discrete MP1584 components belong in order 1 instead. For bench, modules win.

### Order 3 — LEDs

| Part | Search string | Qty | Expected total £ | Notes |
|---|---|---:|---:|---|
| SK6812 RGBW individual chips (5050 package) | `SK6812 RGBW 5050 LED 100pcs` | 200–300 | 20–30 | Buy enough for 10 tiles (250) plus spares. |
| **— alternative —** SK6812 strip at 60 LED/m | `SK6812 RGBW 60LED natural white 5m` | 5 m | 25–35 | If you want to desolder from strip (fiddly) — *not recommended*. |
| **Order 3 subtotal** | | | **~£20–30** | |

Ask seller for **natural white (4000K)** variant unless you specifically want warm or cool. Confirm it says "SK6812 RGBW" — some sellers substitute WS2812B RGB at the last minute.

### Order 4 — Passives

Buy passives in **assortment kits** — it's cheaper than individual values and you'll need the spares.

| Part | Search string | Qty | Expected total £ | Notes |
|---|---|---:|---:|---|
| 0603 resistor assortment (e.g. 170 values × 25 each) | `0603 SMD resistor assortment kit` | 1 kit | 8–15 | Covers everything below 1 W. |
| 0603 ceramic cap assortment (inc. 100 nF, 22 µF, 10 µF) | `0603 SMD capacitor sample book` | 1 kit | 8–15 | 10k+ caps, useful for years. |
| Electrolytic 47 µF/35 V | `47uF 35V electrolytic radial` | 20-pack | 1.50 | For C1 tile input bulk. |
| Polyfuse 0.5 A / 1 A 1812 SMD | `polyfuse 1812 0.5A SMD` | 20-pack | 2.00 | |
| 22 µH shielded inductor, 3 A sat | `22uH 3A shielded inductor SMD` | 20-pack | 4.00 | Only needed if going discrete on the buck (skip if using modules). |
| 120 Ω precision resistors 1 % | Part of 0603 kit | — | — | Check the kit includes 120 Ω and 680 Ω; if not, buy separately. |
| **Order 4 subtotal** | | | **~£20–35** | |

### Order 5 — Connectors and mechanical

| Part | Search string | Qty | Expected total £ | Notes |
|---|---|---:|---:|---|
| 2.54 mm 1×8 male pin header (straight) | `2.54mm 1x8 pin header straight 20pcs` | 30 | 2.00 | Cheap; cut from 40-pin strips if needed. |
| 2.54 mm 1×8 female socket | `2.54mm 1x8 female pin socket 20pcs` | 30 | 3.00 | |
| Dupont jumper wires M-M, M-F, F-F (40 of each) | `Dupont jumper wire 40pcs` | 1 set | 3–5 | Essential for bench prototyping. |
| Perfboard 50×70 mm | `prototype PCB 50x70 double sided 10pcs` | 10 | 4–6 | One per tile + spares. |
| Screw terminals 2-pos 5.08 mm | `screw terminal 5.08mm 2 pin` | 10 | 2.00 | For 24 V input on master. |
| Neodymium magnets 5 × 2 mm | `neodymium magnet 5x2mm 50pcs` | 50 | 3–5 | Tile edge mating assist. |
| **Order 5 subtotal** | | | **~£17–23** | |

### Order 6 — Test gear and master

| Part | Search string | Qty | Expected total £ | Notes |
|---|---|---:|---:|---|
| 24 V / 2 A desktop PSU (barrel plug) | `24V 2A power supply 5.5x2.1mm` | 1 | 8–12 | Adequate for 4-tile bench; bigger LRS-350 needed for 32-tile system. |
| XIAO ESP32-C3 dev board | `XIAO ESP32-C3` or `Seeed XIAO ESP32-C3 clone` | 1 | 4–7 | Genuine Seeed or clone; clones are usually fine. |
| USB-RS485 adapter (CH340 + SP485) | `USB to RS485 CH340 SP3485` | 1 | 3–6 | For bus sniffing from a laptop. CH340-based preferred over FT232 clones. |
| Small logic analyser (8 ch, 24 MHz) if not owned | `Saleae 8 channel logic analyzer clone USB` | 1 | 5–10 | Pairs with sigrok/PulseView free software. |
| **Order 6 subtotal** | | | **~£20–35** | |

## Grand total

| Order | £ |
|---|---:|
| 1 — ICs | ~12–28 |
| 2 — MP1584 modules | ~6–10 |
| 3 — LEDs | ~20–30 |
| 4 — Passives | ~20–35 |
| 5 — Connectors / mech | ~17–23 |
| 6 — Test gear and master | ~20–35 |
| **Total AliExpress** | **~£95–160** |

Typical landed cost: **~£120** for everything needed to build and bring up 4 tiles on the bench, with spares for 8.

If you already own a bench PSU, WCH-LinkE, logic analyser, and USB-RS485 adapter, the actual consumable parts are **~£60–90**.

## What NOT to buy on AliExpress

- **Authentic branded RS-485 transceivers** if you need 1 Mbps reliability with zero clone roulette — get from Mouser/Digikey/LCSC proper.
- **FTDI chips** — the clone saga is still not fully over; use CH340 alternatives.
- **PCBs for the final product** — JLCPCB (not on AliExpress) is cheaper and better.
- **Precision 1 % resistors** if you need the 1 % — assortment kits are nominally 1 % but often 5 %. For the buck feedback divider, measure with a DMM before placing.

## Before placing the order

- [ ] Verify the seller accepts PayPal (easier dispute resolution if items don't arrive).
- [ ] Read the last 20 reviews — look for "item not as described" or "sent wrong chip".
- [ ] Check the listing photos carefully — many sellers show a photo of the genuine chip but ship unmarked clones.
- [ ] Check shipping tier — "Choice" is a trap if the threshold isn't met.
- [ ] Combine orders from the same seller to save on shipping.
- [ ] Take screenshots of listings (in case the seller relists with different terms mid-dispute).

## When parts arrive

- [ ] **Verify IC markings with a loupe** — "MAX485" clones often have slightly wrong font or spacing.
- [ ] Measure a buck module at a known load before soldering — 5 V trim pot can be mis-adjusted from factory.
- [ ] Test **one SK6812** from the reel with a known-good controller (Arduino + FastLED) before committing 25 to a tile.
- [ ] Check the CH32V003 is flashable — connect WCH-LinkE and read UID. Non-programmable units (rare but possible) save debugging time later.