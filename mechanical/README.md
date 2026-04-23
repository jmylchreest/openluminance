# mechanical/

Parametric tile enclosures, diffusers, and alignment features.

- [`openscad/`](openscad/README.md) — source `.scad` files with a preview render. Standalone; submodules in [`thirdparty/`](../thirdparty/README.md) available when needed.
- `stl/` — canonical exported STLs checked in for the current release. Iterative exports are gitignored.

Current state: **draft v0 tile model in [`openscad/tile.scad`](openscad/tile.scad)** — 100 × 100 × 15 mm single-piece enclosure. See [`openscad/README.md`](openscad/README.md) for design notes, parameters, and TODOs.

Target print material is PETG or translucent PLA. Print orientation: diffuser face down on the build plate.
