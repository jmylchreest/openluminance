# firmware/tile

Per-tile firmware for the CH32V003.

Not yet implemented. Target responsibilities:

- Read 64-bit UID at boot
- Listen on the bus for addressed packets (SOF / ADDR / CMD / LEN / PAYLOAD / CRC8)
- Respond to discovery broadcasts
- Drive the local LED strip
- Report neighbour-pin state on request (v2)

Toolchain target: [ch32v003fun](https://github.com/cnlohr/ch32v003fun) or PlatformIO with the CH32V platform. Decide once the bus design is frozen.
