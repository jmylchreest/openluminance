# Open Questions and Risks

Live list of things we don't yet know or haven't decided. Resolve and remove items as they close out. See also the closed/settled list at the bottom.

## Must resolve before PCB order

- [ ] **Edge connector physical form.** 1×8 pin header + socket (cheap, proven, one mating direction) vs spring pogo strips (lower profile, more mating cycles, needs tighter alignment) vs Amphenol/Molex mezzanine (rigid, expensive). Target: decide from 4-tile bench test data.
- [ ] **Mechanical alignment feature.** FDM printing tolerance on PETG is ±0.3 mm. Need dowel+pocket, keyed edges, or machined inserts.
- [ ] **Bus termination strategy.** Fixed at endpoints (simple, but endpoints must be known) vs switchable per-tile (complex, but any tile can be the endpoint). v1: fixed, master + designated "terminator" tile at far end.
- [ ] **Bus biasing.** RS-485 idle-state biasing (680 Ω to V+ on A, 680 Ω to GND on B). Populated on master only, or on first tile?

## Must resolve before firmware v1

- [ ] **Discovery timing.** Implement the 1-Wire-style binary-tree UID search on RS-485 and measure. Expected ~2 s for 32 tiles at 1 Mbps.
- [ ] **Frame synchronisation mechanism.** Proposed: master sends per-tile `SET_PIXELS`, then a broadcast `LATCH` command. Verify timing jitter across tiles under worst-case load.
- [ ] **Firmware update path.** Field-updatable tiles? Over the bus, or only via WCH-LinkE programmer? Bus-based firmware update is non-trivial with only 16 KB flash (bootloader budget).

## Must resolve before calling it done

- [ ] **Thermal.** 25 SK6812 at full white ≈ 7.5 W per tile. Diffuser standoff, vent pattern, and/or a global brightness cap in firmware.
- [ ] **EMI.** Differential RS-485 + 24 V linear power drop is low-risk, but buck switching noise needs measurement if CE/FCC is ever a goal.
- [ ] **License.** MIT / CERN-OHL-S / CC-BY-SA or something else.
- [ ] **v2 scope.** Commit to v2 (4-edge mesh, palindromic all round) only after v1 ships and we know real-world UX demand.

## Settled / resolved

- **Bus choice** → RS-485 multidrop, half-duplex, 1 Mbps. See [`architecture.md`](architecture.md). Parallel bus discarded.
- **Power distribution** → 24 V backbone, chained through connectors; per-tile buck converter to 5 V. See power math in architecture doc.
- **Edge connector pin count and layout** → 8 pins, palindromic: `GND, V+, A, B, B, A, V+, GND`. Identical pinout reserved on all 4 edges; v1 populates 2. Same connector supports v2 mesh without PCB respin.
- **Per-tile short isolation** → polyfuse on the local 24 V branch tap, leaving pass-through rail unaffected.
- **CH32V003 GPIO budget** → comfortable for v1 (UART TX/RX + DE, 1× LED output, 4× spare for v2 neighbour pins).
- **Topology for v1** → linear / serpentine chain. Map held at master, user arranges tiles in web UI. Free-form 2D mesh is v2.
- **Addressing** → UID-based auto-enumeration via 1-Wire-style binary search, adapted for RS-485. No hardcoded addresses.

## Claims from the original proposal that needed verification

- "Auto-addressing is a well-established pattern" — was unverified on a parallel bus. **Resolved** by switching to RS-485 with a 1-Wire-adapted search algorithm, which *is* well-established.
- ">60 fps for 100 tiles" — bandwidth math now in architecture doc: ~27 ms/frame for 32 tiles at 1 Mbps RS-485, comfortably >30 fps. 100 tiles at 1 Mbps is borderline; bump to 2–5 Mbps if needed. Verify on bench.
- "£2.62 per tile" — replaced with honest ~£8/tile figure driven by real parts and proper power regulation.
- "Keeps WLED ecosystem intact" — still partially true; a bridge that does 2D→tile slicing is needed. Not a blocker for v1 since we can ship a custom master UI first.
