# Acceptance testing

## Recorded testing status

The author reports successful manual testing in Autodesk AutoCAD: the command
creates native 3D CIRCLE entities without manually changing the UCS. The
application version/build and coverage of the individual cases below were
not supplied. This report does not mark the full acceptance matrix as passed.
Automated AutoCAD runtime tests were not executed in the development
environment. Mathematical/static validation is recorded in VALIDATION.md.
BricsCAD runtime compatibility remains unverified; repeat this procedure in
the intended BricsCAD version and record its results separately.

## Test procedure

Use a disposable drawing in full Windows AutoCAD. Load `3C.lsp` and
`3C-tests.lsp` through APPLOAD, run `3CTEST`; all nine cases must PASS.
This runner checks geometry only and creates no entities.

## Coordinates (WCS)

| Case | P1 | P2 | P3 | Expected center; radius |
|---|---|---|---|---|
| A | 10,0,0 | 0,10,0 | -10,0,0 | 0,0,0; 10 |
| B | 10,0,0 | 0,0,10 | -10,0,0 | 0,0,0; 10 |
| C | 5,7,6 | -3,5,8 | -3,-1,2 | 1,3,4; 6 |
| D | 6580004,670004,37 | 6579996,670002,39 | 6579996,669996,33 | 6580000,670000,35; 6 |

C and D share unit normal (1/3, -2/3, 2/3) for this point order.
A has normal (0,0,1); B has normal (0,-1,0). Reversing order reverses
the normal without changing the geometric circle.

Run 3C interactively in World UCS for A–D. After each run inspect:

```lisp
(setq e (entlast) d (entget e))
(cdr (assoc 0 d))                 ; "CIRCLE"
(trans (cdr (assoc 10 d)) e 0)     ; expected WCS center
(cdr (assoc 40 d))                ; radius
(cdr (assoc 210 d))               ; expected unit normal
```

The runtime checks must accept all three point distances and plane residuals
within the formula in README. Additionally compare center/radius against the
table: 1e-8 drawing units for A–C, 1e-6 for D; normal error <= 1e-10.
Exactly one entity must be added. Save, close, reopen and inspect it again.

## E — Non-world UCS

Create persistent snap targets at C's WCS points in the disposable drawing.
Build a translated, tilted UCS with `_UCS` → `_3point`, origin `100,200,300`,
positive X point `101,201,300`, positive Y-side point `99,201,301` (starting
from World). Select the same three targets using 3D object snaps; ensure
OSNAPZ is 0 for this test. Run 3C and inspect WCS data as above. The circle
must match C. Repeat with UCS rotations and a translated-only UCS. For typed
input, convert each WCS point with `(trans point 0 1)` beforehand, then type
its full UCS coordinates at the prompts. Do not type WCS values as UCS values.

## F — Cancellation and degenerate cases

- Escape at each prompt, and Enter at each prompt: no new entities, clear
  cancellation message, no stack trace.
- Duplicate: (0,0,0), (0,0,0), (1,0,0): reject.
- Collinear: (0,0,0), (1,1,1), (2,2,2): reject.
- Near collinear: (0,0,0), (1,0,0), (2,1e-10,0): reject.
- Small but valid: (1e-9,0,0), (0,1e-9,0), (-1e-9,0,0): radius 1e-9.
- Below resolution: the last case in `3C-tests.lsp`: reject.
- Repeat with point order permutations and different drawing units.

For creation failure in a disposable session, temporarily replace `entmake`
through a debugger/test harness to return nil, then restore/reload the normal
environment. For readback failure temporarily instrument `3c:entity-ok` to
return nil. Acceptance: failure message and no retained new entity. Do not
ship instrumented code. These failure injection tests are manual and pending.

## Drawing behavior

Before/after compare UCSORG, UCSXDIR, UCSYDIR, VIEWDIR, VIEWCTR, VIEWSIZE,
OSMODE, OSNAPZ, INSUNITS, LUNITS, ELEVATION, CLAYER, CECOLOR, CELTYPE,
CELWEIGHT, THICKNESS and CMDECHO. No setting should change. Normal input
history/LASTPOINT effects are permitted. Check model space and paper space,
current-layer placement and defaults under nondefault drawing properties.
Test MOVE, COPY, ROTATE, ERASE, LIST, CENTER snapping, UNDO and Enter/Space
repeat. No helper entities may appear. Test successful and cancelled commands.

Record application name, release/build, test date, cases executed, results and
any failures for each AutoCAD or BricsCAD run. The author-reported AutoCAD
manual success is recorded above; individual cases without execution evidence
remain unverified. No automated host-runtime results are claimed here.
