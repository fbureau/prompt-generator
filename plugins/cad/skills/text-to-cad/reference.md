# OpenSCAD reference — idioms and gotchas

Loaded on demand. Copy the pattern that fits, keep everything parametric.

## Rounded box (offset — 2D then extrude, cleanest)

```scad
module rounded_box(w, d, h, r) {
    linear_extrude(h)
        offset(r=r) offset(r=-r)
            square([w, d], center=false);
}
```

`offset(r) offset(-r)` rounds outer corners of any 2D profile before extruding. For rounded corners *and* edges use `minkowski` with a sphere, but it is slow — prefer `offset` for prisms.

## Shell / hollow with uniform wall

```scad
module shell(w, d, h, wall, open_top=true) {
    difference() {
        cube([w, d, h]);
        translate([wall, wall, wall])
            cube([w - 2*wall, d - 2*wall, h - (open_top ? 0 : wall) + eps]);
    }
}
```

## Fillet on an inner edge (quarter-round subtraction)

```scad
module fillet(r, len) {
    // subtract this along an edge to round it
    translate([0,0,-eps]) difference() {
        cube([r+eps, r+eps, len+2*eps]);
        translate([r, r, -eps]) cylinder(r=r, h=len+4*eps);
    }
}
```

OpenSCAD has no general fillet operator. For arbitrary fillets/chamfers on organic shapes, switch to CadQuery (`.edges().fillet(r)`).

## Bolt / screw clearance holes

```scad
// through-hole for a bolt, with clearance
clearance = 0.3;
module bolt_hole(d_nominal, len) {
    translate([0,0,-eps])
        cylinder(d=d_nominal + clearance, h=len + 2*eps);
}
// common metric clearance diameters (close fit): M3->3.2  M4->4.3  M5->5.3  M6->6.4
```

Counterbore for a socket-head cap screw: subtract a wider, shallower cylinder on top of the shaft hole.

## Heat-set insert / press fit

Model the hole slightly *under* nominal and let the insert/press create interference: `d = insert_d - 0.1`. Add a lead-in chamfer at the mouth.

## Polar array (screws around a bolt circle, teeth, spokes)

```scad
module polar(n, r) {
    for (i = [0:n-1])
        rotate([0,0, i*360/n]) translate([r,0,0]) children();
}
// usage: polar(6, 20) cylinder(d=3, h=10);
```

## Spur gear (involute) — use a library

Do not hand-roll involute math. Use the BOSL2 or MCAD `gears` library:

```scad
use <BOSL2/gears.scad>
spur_gear(mod=2, teeth=20, thickness=6, shaft_diam=5);
```

If the user can't add a library, a trochoidal approximation with `polar()` teeth on a base circle is acceptable for low-precision prints — say so.

## Text and embossing

```scad
linear_extrude(1) text("A1", size=6, halign="center", valign="center", font="Liberation Sans:style=Bold");
```

Emboss = union a thin extrude on a face; deboss = difference it out. Give raised/recessed text ≥0.4 mm depth so it survives slicing.

## Threads

Real threads: use BOSL2 `threaded_rod()` / `threaded_nut()`. For a quick printable thread without a library, a `linear_extrude(twist=...)` of a triangular profile approximates it. Note pitch and that printed threads usually need ~0.2 mm clearance to mate.

## Common gotchas

- **Coplanar face flicker / non-manifold**: when subtracting, always overshoot the surface by `eps` (0.01–0.1 mm). Two solids sharing an exact face confuse slicers.
- **`$fn` performance**: high `$fn` on many cylinders is slow. Set a global draft `$fn` and bump it only for final render, or use `$fa`/`$fs`.
- **Minkowski is expensive**: only for small convex hulls; avoid on big models.
- **`hull()` for smooth transitions** between two profiles (e.g. a rounded lozenge from two cylinders) — cheaper than minkowski.
- **Units**: OpenSCAD is unitless; treat 1 unit = 1 mm and slicers agree. Never mix.
- **Preview vs render**: F5 preview can hide non-manifold errors that F6 (full render / CGAL) catches. Trust F6 / `openscad -o out.stl`.
- **Negative or zero dimensions** from a bad parameter produce empty or inverted geometry silently. Guard critical params with `assert(wall > 0);`.

## Handy metric reference (mm)

| Screw | Clearance (close) | Tap/press hole | Head dia (socket) |
|------|------|------|------|
| M2   | 2.4  | 1.6  | 3.8 |
| M3   | 3.2  | 2.5  | 5.5 |
| M4   | 4.3  | 3.3  | 7.0 |
| M5   | 5.3  | 4.2  | 8.5 |
| M6   | 6.4  | 5.0  | 10.0 |

Typical FDM fit gaps: sliding fit 0.3–0.4, snug/press fit 0.1–0.15, living hinge wall 0.4–0.6.
