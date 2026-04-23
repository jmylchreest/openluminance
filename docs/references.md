# References and Prior Art

## Closest reference project

- **[rmingon/led-wall](https://github.com/rmingon/led-wall)** — CH32V003F*P6 per tile, 8-bit parallel bus via 1×14 edge headers, SOF-based packet format with address byte and CRC8. Tile addresses are **hardcoded in `main.c`** — no auto-addressing in the reference. This is the closest existing implementation of the architecture sketched here.

## Related

- **[Modular LED Wall with CH32V006 RISC-V Slave Tiles](https://hackaday.io/project/203942-modular-led-wall-with-ch32v006-risc-v-slave-tiles)** — Similar approach on the larger CH32V006.
- **[CH32V003 Programming: How To Read 64-Bit Unique ID](https://pallavaggarwal.in/2023/09/25/ch32v003-programming-read-unique-id/)** — Reference for using the UID as tile identity.
- **[I2C automatic address assignment (Electronics Stack Exchange)](https://electronics.stackexchange.com/questions/85646/i2c-automatic-address-assignment)** — Auto-addressing pattern. Works cleanly on I2C because of open-drain arbitration; the parallel bus here would need a different mechanism.

## Upstream ecosystems we may borrow from

- **[WLED](https://github.com/Aircoookie/WLED)** — Established effects library and web UI. Could be used directly on the master, or forked, or used via DDP/E1.31 to a bus-driver bridge.
- **[E1.31 / sACN](https://www.esta.org/tsp/documents/published_docs.php)** and **[DDP](http://www.3waylabs.com/ddp/)** — Pixel delivery protocols over IP.

## OpenSCAD libraries available in `thirdparty/`

See [`thirdparty/README.md`](../thirdparty/README.md) for what's vendored as submodules and why each one is useful for this project.
