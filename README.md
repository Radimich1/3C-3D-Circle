# 3C - 3D Circle

Author: Dzmitry Tsiapkin

A lightweight AutoLISP utility for creating a native 3D CIRCLE through three
arbitrary spatial points without manually changing the UCS. The points must
be non-collinear and numerically well-conditioned. No projection, helper
geometry, COM or external dependency is required.

## Install and use

1. Save `3C.lsp` in a dedicated local folder you control.
2. In AutoCAD Options → Files → Trusted Locations, add that folder if required
   by your security policy. Keep secure loading enabled; do not trust broad
   download folders. A trusted location and a support search path are separate.
3. Run `APPLOAD`, browse to `3C.lsp`, and load it.
4. Optionally use APPLOAD → Startup Suite → Contents → Add to load it for
   subsequent drawings. Startup loading remains subject to trusted locations.
5. Enter `3C`, then select or type three points at the English prompts.
   Example in World UCS: `10,0,0`, `0,0,10`, `-10,0,0` produces radius 10.
6. Enter or Space repeats the command through AutoCAD's normal command history.

Successful completion prints `3C: 3D circle created successfully.` Enter at a
required point cancels cleanly; Escape also cancels. The circle is created in
the current space on the current layer with native entity default properties.
Use normal layer property controls for presentation. No center POINT is added.

## Geometry and safeguards

`getpoint` supplies current-UCS points. Each is transformed with `trans` from
UCS to WCS. Subtract P1, normalize both edge vectors by the longest triangle
edge s, and call the resulting vectors a and b. With N = a × b:

    h = (|a|² (b × N) + |b|² (N × a)) / (2 |N|²)
    center = P1 + s h
    radius = |center - P1|; normal = N / |N|

The center is transformed WCS → OCS using the normal for DXF 10; radius goes
in 40 and the WCS unit normal in 210. `entmake` creates an owned drawing
entity; its data is read back and the OCS center transformed back to WCS.
Radius, center, orientation, equal distances and plane residuals are verified.
A failed verification deletes the new entity. No partial construction is kept.

Let epsilon = 2.220446049250313e-16 and M be the largest absolute input
coordinate. Edges or triangle altitude at or below 64 epsilon M are rejected.
Also reject |a × b| <= 1e-8 (twice area / longest edge squared). This rejects
ill-conditioned skinny triangles, including configurations with one very short
edge. The threshold is dimensionless, not a fixed drawing-unit area.
The linear verification tolerance is 128 epsilon times the maximum absolute
input/center coordinate, plus 1e-9 times max(longest edge, radius).
No internal decimal rounding is used. Small well-shaped triangles near the
origin can succeed; small features at enormous coordinates can be rejected
because their coordinate precision is insufficient. Arbitrary extreme IEEE
floating-point magnitudes are outside the intended engineering range.

## Environment and limitations

Manually tested in Autodesk AutoCAD by the author. The implementation uses
standard AutoLISP functionality and is intended to support BricsCAD. BricsCAD
runtime compatibility should be verified in the target version before
engineering use; no BricsCAD runtime test results are documented here.

The primary target is full desktop AutoCAD for Windows with AutoLISP. The
author's manual test report does not specify a release/build or a complete
acceptance-test matrix. Compatibility with individual AutoCAD and BricsCAD
versions remains to be verified. AutoCAD LT, Mac and other CAD environments
are unverified. There is no official certification by Autodesk or Bricsys,
and support for every version is not claimed. No Visual LISP/ActiveX
dependencies are used. Run TESTING.md in the target application/version.
Runtime verification is a numerical consistency check, not a substitute for
validating survey input accuracy.

The command does not set system variables, view, UCS, units or object snaps.
Interactive input still has AutoCAD's normal input effects (such as LASTPOINT
and command history). Existing OSNAPZ and other input settings affect which
points AutoCAD returns; use OSNAPZ=0 yourself when true snapped Z is required.
Two-coordinate entries use AutoCAD's current elevation conventions. Supply all
three coordinates for reproducible tests. The selected points, not an inferred
survey surface, determine the circle. Point order determines the normal sign.

## Troubleshooting

- Unknown command: check APPLOAD completion and the trusted folder.
- Collinearity message: check duplicates and triangle shape; insufficient
  coordinate precision or failed geometric validation also uses this message.
- Creation/verification failure: inspect the current drawing/layer and test in
  a new drawing; no success is reported unless entity verification passes.
- Unexpected elevation: inspect object snap settings and entered UCS values.
- Circle looks like a line: view its plane obliquely or use a suitable 3D view.

## Validation and references

The command has been manually tested in Autodesk AutoCAD and successfully
creates native 3D CIRCLE entities. This manual testing was reported by the
author. Automated AutoCAD runtime tests were not executed in the development
environment. Mathematical and static validation is recorded separately in
VALIDATION.md. See TESTING.md and `3C-tests.lsp` for the acceptance procedure;
the author's report does not establish that every listed test was executed.

Official Autodesk references:
- [getpoint coordinate convention](https://help.autodesk.com/cloudhelp/2025/JPN/AutoCAD-AutoLISP-Reference/files/GUID-445F32F0-8A9D-4E1D-976F-DE87CC5267D0.htm)
- [trans and extrusion-vector OCS](https://help.autodesk.com/cloudhelp/2016/ENU/AutoCAD-AutoLISP/files/GUID-1A316343-0B68-4DBE-8F49-B4D601CB8FCC.htm)
- [CIRCLE DXF](https://help.autodesk.com/cloudhelp/2020/ENU/AutoCAD-DXF/files/GUID-8663262B-222C-414D-B133-4A8506A27C18.htm)
- [entmake](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-AutoLISP-Reference/files/GUID-D47983BA-1E5D-417D-85B8-6F3DE5F506BA.htm)

## Technical Publication

The mathematical methodology and implementation of 3C and 3A are documented in:

**Dzmitry Tsiapkin (2026)**  
*Native Spatial Circle and Ordered Arc Construction from Three Points in AutoLISP without UCS Modification.*

[Read the technical paper on Zenodo](https://doi.org/10.5281/zenodo.23701052)

## Copyright and availability

Copyright (c) 2026 Dzmitry Tsiapkin. All rights reserved.

The source code is publicly available for inspection. No explicit license for
copying, modification, redistribution, or commercial reuse is granted with
this release.
