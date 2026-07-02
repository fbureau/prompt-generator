---
name: text-to-cad
description: Turn a plain-language description of a physical object or part into a clean, fully parametric CAD model — OpenSCAD by default, CadQuery (Python) on request — ready to render to STL for 3D printing or CNC. Use whenever the user describes something to model or asks to generate or edit CAD, an OpenSCAD/.scad file, a 3D model, or an STL (e.g. "model a phone stand", "parametric box with a snap-fit lid", "an M3 standoff 10mm tall", "OpenSCAD for a 20-tooth spur gear", "make that wall 2mm thicker").
---

# Text to CAD

You turn a description of a physical object into a manufacturable, parametric CAD model. Default target is **OpenSCAD** (`.scad`): it is text-based, diffable, and renders to STL from the command line. Switch to **CadQuery** (Python) only if the user asks for Python/CadQuery or needs features OpenSCAD handles poorly (lofts, fillets/chamfers on complex edges, assemblies).

The model is the deliverable. Write it so the user can change a dimension at the top and re-render without touching the geometry.

## Process

1. **Read the request for real dimensions.** Pull out every number and constraint the user gave (a 10 mm bolt, fits a 18650 cell, 3 mm wall). Treat everything in millimeters unless told otherwise — that is the CAD/3D-printing default.
2. **Fill gaps with sensible defaults, don't interrogate.** If a non-critical dimension is missing, choose a reasonable value, expose it as a parameter, and state your assumption in one line after the code. Ask a clarifying question only when a *load-bearing* dimension is genuinely unknowable and would make the part useless if guessed wrong (e.g. "what diameter cable does the clip hold?"). At most one or two questions, asked once.
3. **Design parametrically.** Every dimension that a user might reasonably change is a named variable at the top of the file, grouped and commented. Geometry below references only those variables — no magic numbers buried in the body.
4. **Write the model** following the house style below.
5. **Render-check and hand off.** State how to render it to STL and note any assumptions or tolerances the user should tune for their printer/material.

## OpenSCAD house style

- **Parameters first.** A commented block of named variables at the top: outer dimensions, wall thickness, clearances, `$fn`. Add units in the comment (`wall = 2;   // mm`).
- **Modules for parts.** Wrap each distinct feature or reusable part in a `module`. Compose the final object from module calls, not one giant CSG expression.
- **Manifold, printable geometry.** Keep everything a closed solid. When subtracting, make the cutting tool overlap the surface it breaks (extend holes ~0.1 mm past each face, a common `eps = 0.01;` fudge) so there are no zero-thickness coplanar faces that break slicers.
- **Real-world tolerances.** For parts that fit together, add an explicit `clearance` variable (typical FDM: 0.2–0.4 mm on a sliding fit, ~0.1 mm on a press fit) rather than modeling nominal-to-nominal.
- **Smoothness on purpose.** Set `$fn` via a parameter (e.g. `$fn = 64;` for visible curves; lower for drafts). Do not leave curved surfaces at the default facet count.
- **Center or ground deliberately.** Put the part flat on the XY plane (z ≥ 0) so it is ready to slice, unless the user wants it centered.
- **Comment the intent, not the syntax.** Explain *why* a feature exists or what it mates with, not what `translate` does.

Minimal shape of a good answer:

```scad
// ---- Parameters (mm) ----
width      = 60;
depth      = 40;
height     = 25;
wall       = 2;
clearance  = 0.3;   // fit gap for the lid
$fn        = 64;

eps = 0.01;         // overlap to keep subtractions manifold

module box() {
    difference() {
        cube([width, depth, height]);
        translate([wall, wall, wall])
            cube([width - 2*wall, depth - 2*wall, height]);  // open top
    }
}

box();
```

## CadQuery mode (on request)

Same discipline: parameters as named variables up top, one `Workplane` chain per feature, `.val()`/`show_object()` at the end, and an explicit `cq.exporters.export(result, "part.stl")`. Reach for CadQuery when the user needs real fillets/chamfers, lofts, or a multi-solid assembly, and say in one line why you switched.

## Rendering to STL

OpenSCAD renders headless from the CLI:

```sh
openscad -o part.stl part.scad          # mesh for slicing
openscad -o preview.png part.scad       # quick visual check
```

If `openscad` is on PATH you can run the bundled helper: `scripts/render.sh part.scad` (writes `part.stl`, plus a PNG if you pass `--png`). If OpenSCAD isn't installed, point the user to https://openscad.org/downloads.html and still deliver the `.scad` file — it is the source of truth.

When the user asks for the finished mesh (not just the code), write the `.scad` file to disk and render it, then report the output path. For a quick "give me the code" ask, just return the code block.

## Editing an existing model

When the user asks to change a model already in the conversation or on disk, edit the relevant parameter or module in place and keep the rest byte-for-byte. Do not regenerate the whole file or renumber unrelated variables. If the change is just a dimension, it should be a one-line edit to the parameter block — that is the payoff of parametric design.

## Self-check before delivering

- Every user-supplied number appears as a named parameter with the right value and unit.
- No unintended zero-thickness or coplanar faces (subtractions overlap by `eps`).
- Mating features carry an explicit clearance; nothing is modeled nominal-to-nominal.
- Curved surfaces have a deliberate `$fn`.
- The part sits flat on Z=0 (or centered, if that's what was asked) and is a single closed solid.

See `reference.md` for OpenSCAD idioms: shells, rounded boxes (minkowski/offset), fillets, threads, gears, text, polar arrays, and common gotchas.
