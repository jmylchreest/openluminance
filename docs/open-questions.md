# Open Questions and Risks

Live list of things we don't yet know or haven't decided. Resolve, link to a decision, and remove items as they close out.

## Must resolve before PCB order

- [ ] **Bus choice.** Parallel vs SPI vs RS-485. Build a 2-tile bench test and measure signal integrity at target frame rate.
- [ ] **Power distribution.** Pogo pins cannot carry 48 A. Need a plan: injection points, backplane rail, or brightness cap.
- [ ] **Edge connector.** Pogo pins vs 1×14 headers vs castellated edges + spring contacts. Alignment tolerance drives this.
- [ ] **Mechanical alignment.** Magnets alone won't hold sub-mm tolerance. Dowel + pocket? Keyed edges? Precision-printed pockets?
- [ ] **CH32V003 pinout.** 18 GPIO budget check: 8 data + CLK + EN + LED_OUT + 4 neighbour + SWDIO/SWCLK. Confirm no conflicts on programming pins.
- [ ] **Per-tile fuse / short isolation.** A single shorted tile should not kill the whole rail.

## Must resolve before firmware v1

- [ ] **Addressing scheme.** Hardcoded in firmware (ships fast) vs UID auto-assignment (nicer UX, unproven on parallel bus).
- [ ] **Topology detection.** Manual map (Option C) for v1. Keep hardware compatible with neighbour pins (Option A) for v2.
- [ ] **Bus bandwidth math.** Worst-case full-frame refresh for target tile count at target fps. Does the chosen bus clear it with margin?
- [ ] **Frame synchronisation.** How are all tiles made to update in the same frame for cross-tile effects?

## Must resolve before calling it done

- [ ] **Thermal.** 25 SK6812 at full white ≈ 7.5 W per tile. Diffuser standoff, vent pattern, duty-cycle cap?
- [ ] **EMI.** Any chance of CE/FCC in the future? Parallel bus + pogo pin gaps is a radiator.
- [ ] **Firmware update path.** Field-updatable tiles? Over the bus, or only via WCH-LinkE?
- [ ] **License.** MIT / CERN-OHL-S / CC-BY-SA or something else.

## Claims from the original proposal that need verification

- "Auto-addressing is a well-established pattern" — **unverified on parallel bus.** Well-established on I2C. Treat as a design task.
- ">60 fps for 100 tiles" — **unverified.** Needs bus-bandwidth math and bench data.
- "£2.62 per tile" — **optimistic.** Pogo pin price assumed ~£0.023 each; realistic is £0.05–0.10. Rework BOM with real quotes.
- "Keeps WLED ecosystem intact" — **partially true.** Linear pixel mapping works; tile-addressed payloads require a bridge that does 2D→tile slicing.
