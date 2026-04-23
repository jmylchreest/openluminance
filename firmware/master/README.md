# firmware/master

Master controller firmware (ESP32).

Not yet implemented. Target responsibilities:

- Discover tiles on the bus, assign addresses, collect UIDs
- Hold the topology map (manual in v1, neighbour-derived in v2)
- Accept frame data from upstream (custom API, WLED integration, or DDP/E1.31 bridge)
- Slice frames into per-tile pixel payloads and push them over the bus
- Serve a web UI for manual tile placement and system control

Framework TBD. Likely ESP-IDF or Arduino-ESP32 depending on whether we fork WLED or build fresh.
