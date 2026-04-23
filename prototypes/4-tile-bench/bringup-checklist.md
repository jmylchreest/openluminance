# Bring-up checklist

Sequential verification plan. Each step assumes the previous ones passed. Stop and diagnose at the first failure — don't power on the next stage with a broken previous stage.

## Stage 0 — before powering anything

- [ ] All parts inventoried and counted against [`parts-list.md`](parts-list.md).
- [ ] 24 V PSU set-point confirmed on DMM **before** connecting any tile.
- [ ] 24 V PSU GND and master GND wired together; verified with DMM continuity.
- [ ] Reverse-polarity MOSFET (Q1) orientation verified on at least one tile before first power.
- [ ] Inrush: first tile's C1 (47 µF) is not yet connected — wire the chain tile-by-tile as you validate each stage.

## Stage 1 — single tile, no LEDs, no bus

- [ ] Connect tile #1 to 24 V PSU via its edge connector.
- [ ] Confirm Q1 does not heat (indicates correct polarity; reverse-polarity would dissipate rail power).
- [ ] Measure 5 V rail at MP1584 output: **4.95–5.05 V**. Trim pot if using module.
- [ ] Measure buck ripple: target **< 50 mV pk-pk** on 20 MHz scope.
- [ ] Disconnect PSU and measure current-limited short between 5 V and GND to verify polyfuse trips within a few seconds (re-settable).

## Stage 2 — MCU alive

- [ ] Flash CH32V003 with a minimal blink firmware (toggle PA1 at 1 Hz, no LEDs attached yet).
- [ ] Verify SWIO programming at 3 V PD1 level (WCH-LinkE handles this).
- [ ] Scope PA1 — clean 1 Hz square wave at 5 V logic.
- [ ] Run the "read UID" firmware; log 64-bit UID over SWD console. Save the UID for the four tiles so we know which chip is which during bench tests.

## Stage 3 — LEDs alive, local frame

- [ ] Attach the 25-LED SK6812 chain to tile #1.
- [ ] Flash "rainbow" firmware that cycles the chain with no bus.
- [ ] Measure 5 V rail at full white: **must not dip below 4.8 V**. If it does, buck is undersized or input rail is sagging.
- [ ] Thermal check: surface temperature of buck chip and LEDs after 10 minutes of full white. Target < 70 °C on the buck, < 60 °C on the LED PCB.
- [ ] Repeat stages 1–3 for tiles #2, #3, #4 independently before chaining.

## Stage 4 — RS-485 point-to-point (master ↔ tile #1)

- [ ] Wire only tile #1 to the master. Populate 120 Ω termination and 680 Ω biasing on master; populate 120 Ω on tile #1 (its the "far end" for this sub-test).
- [ ] Master firmware: send a `PING` packet every 100 ms at 1 Mbps. Tile #1 echoes back.
- [ ] Scope A and B on the tile side. Differential swing should be **≥ 1.5 V pk-pk**; common mode steady near V+/2.
- [ ] Run ping loop for 10 minutes. Count errors. Target: **zero**.

## Stage 5 — discovery on single tile

- [ ] Master runs binary-tree UID search; verify it returns the UID saved in stage 2.
- [ ] Master assigns address 1 to tile #1. Tile #1 responds only to address 1 and 0xFF thereafter.
- [ ] Power-cycle tile. Re-enumerate. Verify same UID, same address assignment (deterministic if master uses UID-ordered assignment).

## Stage 6 — chain of 2

- [ ] Remove tile #1's termination (it's no longer the endpoint).
- [ ] Wire tile #2 into the chain; populate 120 Ω on tile #2.
- [ ] Verify both tiles enumerate. UIDs match those saved in stage 2.
- [ ] Measure 24 V rail at tile #2's input: target **≥ 23.5 V** under full LED load on both tiles.
- [ ] Verify no regression in ping error rate after 10-minute soak.

## Stage 7 — chain of 4 (the goal)

- [ ] Wire tiles #3 and #4. Termination moves to tile #4.
- [ ] All four tiles enumerate within 1 second from cold boot. Repeat 10 times.
- [ ] Frame push: master writes 25 pixels to each tile, broadcasts `LATCH`, measures round-trip time. Target **≤ 20 ms per frame**.
- [ ] Sustained 30 fps animation for 30 minutes. Log errors. Target: **zero dropped frames**.
- [ ] Measure 24 V at tile #4: target **≥ 23.0 V** under full-white worst case.
- [ ] Thermal soak all four tiles at full white for 30 minutes; all surfaces < 60 °C.

## Stage 8 — fault injection

- [ ] With all four running, short the 5 V rail on tile #2 (deliberately, with a test lead).
- [ ] Verify only tile #2's polyfuse trips; tiles #1, #3, #4 continue operating.
- [ ] Allow polyfuse to cool (~30 s), verify tile #2 recovers after reset.
- [ ] Disconnect tile #3 mid-operation (pull the edge connector). Verify:
  - [ ] Tiles #1 and #2 continue operating.
  - [ ] Master detects tile #3 and #4 are missing on next poll.
  - [ ] Reconnect; re-enumerate finds them again.

## Stage 9 — stretch goals (nice to have before PCB)

- [ ] Push bit rate to 2.5 Mbps; verify still clean on 4-tile chain.
- [ ] Measure idle current per tile (just the MCU + transceiver, LEDs off): target < 30 mA @ 24 V.
- [ ] EMI sniff with a near-field probe on the LED data line and RS-485 A/B. Note any worrying peaks >100 MHz for future PCB shielding.

## Exit criteria

All stages 0–8 passing and repeatable across two cold-start cycles means the design is validated and we can move to PCB layout. Anything failing is a gate — fix before continuing.