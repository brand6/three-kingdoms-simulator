---
phase: 02-旬内行动—关系闭环
plan: "01"
subsystem: runtime
tags: [godot, gdscript, runtime-state, relationships, action-loop]
requires:
  - phase: 01-190
    provides: MainHUD/GameRoot/DataRepository bootstrap and typed runtime state base.
provides:
  - Typed Phase 2 action, resolution, relation, and xun summary DTOs.
  - Session-owned relation history and xun action buffers.
  - Bootstrap relation seeds plus city/faction character lookup helpers.
affects: [02-02, 02-03, 02-04, phase-2-ui, action-resolver]
tech-stack:
  added: []
  patterns: [typed RefCounted DTOs, session-owned mutable runtime state, repository-seeded prototype relations]
key-files:
  created:
    - three-kingdoms-simulator/scripts/runtime/Phase2ActionSpec.gd
    - three-kingdoms-simulator/scripts/runtime/ActionResolution.gd
    - three-kingdoms-simulator/scripts/runtime/RuntimeRelationState.gd
    - three-kingdoms-simulator/scripts/runtime/XunSummaryData.gd
  modified:
    - three-kingdoms-simulator/scripts/runtime/GameSession.gd
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd
key-decisions:
  - "Phase 2 shared contracts are explicit typed RefCounted DTOs instead of dictionary conventions."
  - "Directional relation seeds live in GameSession bootstrap runtime state, not static definition JSON."
patterns-established:
  - "Runtime DTO pattern: new Phase 2 contracts expose static create(...) helpers for stable downstream construction."
  - "Relation storage pattern: directional keys map to RuntimeRelationState objects inside GameSession."
requirements-completed: [ACTN-04, RELA-01, CHAR-03]
duration: 3min
completed: 2026-04-06
---

# Phase 2 Plan 01: Contracts + Session Storage Summary

**Typed Phase 2 DTOs, directional runtime relationship seeds, and session-owned xun action buffers now define the action-loop backend contract.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-06T00:27:24Z
- **Completed:** 2026-04-06T00:30:11Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Added four typed runtime contracts for action specs, action outcomes, relationship values, and xun summaries.
- Extended `GameSession` to own mutable relation state, per-xun action history, and latest summary buffers.
- Extended `DataRepository` bootstrap/query helpers to seed the eight prototype directional relationships and expose city/faction character lookups.

## Task Commits

1. **Task 0: Write the shared Phase 2 contracts first** - `bef43af` (feat)
2. **Task 1: Extend session storage and repository bootstrap for Phase 2 runtime data** - `f5e3cb2` (feat)

## Files Created/Modified
- `three-kingdoms-simulator/scripts/runtime/Phase2ActionSpec.gd` - typed metadata contract for Phase 2 actions.
- `three-kingdoms-simulator/scripts/runtime/ActionResolution.gd` - typed action result payload for UI and summary flows.
- `three-kingdoms-simulator/scripts/runtime/RuntimeRelationState.gd` - directional favor/trust/respect/vigilance/obligation container.
- `three-kingdoms-simulator/scripts/runtime/XunSummaryData.gd` - typed xun-end summary payload.
- `three-kingdoms-simulator/scripts/runtime/GameSession.gd` - mutable relation/action history storage helpers.
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` - relation bootstrap seeds and city/faction character queries.

## Decisions Made
- Used static `create(...)` helpers on all new Phase 2 DTOs so later plans can instantiate runtime payloads without ad hoc field assembly.
- Kept prototype relationship data in bootstrap code to preserve definition/runtime separation while still giving Phase 2 UI and resolver code deterministic sample data.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Restored `DataRepository` class registration after patching**
- **Found during:** Task 1 (Extend session storage and repository bootstrap for Phase 2 runtime data)
- **Issue:** The initial patch accidentally dropped `class_name DataRepository`, which would break the established autoload contract.
- **Fix:** Re-added `class_name DataRepository` before committing the task.
- **Files modified:** `three-kingdoms-simulator/scripts/autoload/DataRepository.gd`
- **Verification:** Re-ran the repository/session string checks and confirmed the file still exposed the required helpers plus `class_name DataRepository`.
- **Committed in:** `f5e3cb2` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix preserved the existing Phase 1/2 bootstrap contract without changing scope.

## Issues Encountered
- The provided PowerShell verification snippet failed due to shell quoting when invoked through the executor shell, so verification was re-run with direct `Get-Content`/`Contains` checks and `Select-String` commands that matched the same acceptance markers.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `GameRoot` and resolver work can now rely on stable typed contracts instead of dictionaries.
- HUD and relation UI plans can query local city/faction targets from `DataRepository` and mutate relation state through `GameSession`.

## Self-Check: PASSED
