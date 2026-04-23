# thirdparty/

External libraries vendored as git submodules. Clone with `git submodule update --init --recursive`.

| Submodule | Upstream | Why we use it |
|---|---|---|
| `BOSL2/` | [BelfrySCAD/BOSL2](https://github.com/BelfrySCAD/BOSL2) | General-purpose OpenSCAD library — rounded primitives, joinery, threads, attachable parts. Primary modelling toolkit. |
| `NopSCADlib/` | [nophead/NopSCADlib](https://github.com/nophead/NopSCADlib) | Has ready-made models for LEDs, PCBs, headers, **pogo pins**, fasteners, and other electromechanical parts. Saves drawing every component from scratch. |
| `Round-Anything/` | [Irev-Dev/Round-Anything](https://github.com/Irev-Dev/Round-Anything) | Filleted/chamfered 2D profiles for tile enclosures. |
| `threadlib/` | [adrianschlatter/threadlib](https://github.com/adrianschlatter/threadlib) | Standards-based threads if we want threaded fasteners or inserts in the enclosure. |

## Adding more libraries

If something else from `../openscad-models/libraries/` (e.g. LEGO.scad, gridfinity, Technic) turns out useful, add it with:

```
git submodule add <upstream-url> thirdparty/<name>
```

and append a row to the table above.

## Licenses

Each submodule ships its own license. Do not assume anything in `thirdparty/` is under the openluminance license — check upstream before redistributing.
