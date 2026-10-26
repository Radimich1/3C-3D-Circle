# Development validation — 2026-10-26

## Manual testing reported by the author

Dzmitry Tsiapkin reports that the command was manually tested in Autodesk
AutoCAD and successfully creates native 3D CIRCLE entities without manually
changing the UCS. No specific release/build, execution log or case-by-case
coverage was supplied. This report is distinct from the development checks
below and does not establish that every acceptance test passed.

## Mathematical and static checks executed during development

- Parsed both AutoLISP files with a small local JavaScript S-expression parser;
  balanced forms and strings passed.
- Evaluated the actual `3c:solve` and `3c:verify` function bodies using a
  limited local evaluator of the standard arithmetic/list/control operations
  they use. This is not Autodesk's AutoLISP interpreter.
- All nine fixed cases from `3C-tests.lsp` passed: horizontal, vertical,
  tilted, survey coordinates, duplicate, collinear, near collinear, tiny valid
  geometry, and geometry below the coordinate precision threshold.
- 500 generated circles with independently known centers/radii passed center
  and radius comparisons. Their radii span 1e-6 through 1e6, with centers at
  (6580000, 670000, 35) and varying plane orientations.
- Reviewed the cross-product circumcenter formula, longest-edge scaling,
  tolerance units, point-order normal, WCS/UCS conversion and WCS/OCS
  readback against the official references linked in README.
- Reviewed cancellation, creation failure, verification rollback, current-layer
  assignment and absence of system-variable writes or temporary geometry.

## Automated host testing and compatibility limitations

Automated AutoCAD runtime tests were not executed in the development
environment. The limited evaluator does not verify Autodesk APIs, AutoLISP
runtime semantics generally, or application behavior. The author's manual
report confirms successful circle creation but does not establish full coverage
of persistence, failure rollback, command repeat, drawing properties, editing
operations or every UCS/test configuration. Record those results individually
using TESTING.md before relying on them.

BricsCAD support is intended on the basis of standard AutoLISP use; no BricsCAD
runtime results or verified versions are documented. Verify compatibility in
the target version before engineering use. No official Autodesk or Bricsys
certification or support for every version is claimed.

## Public-release preparation

Copyright comments and documentation were updated for the public release.
The production source from its first function definition onward and the full
3C-tests.lsp file were verified unchanged against the pre-edit copies. The
geometry algorithm, tolerances, coordinate transformations, DXF creation,
input workflow and error handling were not changed. No new host-runtime tests
were executed as part of these documentation-only changes.
