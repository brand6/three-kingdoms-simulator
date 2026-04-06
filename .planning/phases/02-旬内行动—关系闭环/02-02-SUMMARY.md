---
phase: 02-旬内行动—关系闭环
plan: "02"
subsystem: gameplay
tags: [godot, gdscript, action-system, resolver, runtime-state, tests]
requires:
  - phase: 02-旬内行动—关系闭环
    provides: Phase 2 DTOs, relation seeds, and session runtime storage.
provides:
  - Canonical five-action catalog with hidden-vs-disabled availability filtering.
  - Deterministic action settlement through GameRoot APIs.
  - Headless regression for action metadata, settlement deltas, failure feedback, and history appends.
affects: [02-03, 02-04, main-hud, xun-summary, relation-ui]
tech-stack:
  added: []
  patterns: [catalog-plus-resolver split, headless SceneTree gameplay regression, GameRoot orchestration for HUD-safe action calls]
key-files:
  created:
    - three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
    - three-kingdoms-simulator/scripts/systems/Phase2ActionResolver.gd
    - three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd
  modified:
    - three-kingdoms-simulator/scripts/autoload/GameRoot.gd
    - three-kingdoms-simulator/scripts/runtime/RuntimeCharacterState.gd
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd
    - three-kingdoms-simulator/scripts/runtime/GameSession.gd
    - three-kingdoms-simulator/scripts/runtime/Phase2ActionSpec.gd
    - three-kingdoms-simulator/scripts/runtime/ActionResolution.gd
    - three-kingdoms-simulator/scripts/runtime/RuntimeRelationState.gd
    - three-kingdoms-simulator/scripts/runtime/XunSummaryData.gd
key-decisions:
  - "Phase 2 action availability is split into a static catalog plus GameRoot-target-aware filtering instead of embedding UI rules in MainHUD."
  - "Deterministic settlement flows through a dedicated resolver and appends structured ActionResolution objects into session history for later xun summaries."
patterns-established:
  - "Catalog pattern: fixed category rail stays stable while visible actions are filtered by permission, AP, energy, location, and target availability."
  - "Resolver pattern: each action mutates RuntimeCharacterState and relation state, then returns one structured ActionResolution for UI and summary consumers."
requirements-completed: [CORE-03, ACTN-03, ACTN-04, ACTN-05, CHAR-03, RELA-01, RELA-03]
duration: 8min
completed: 2026-04-06
---

# Phase 2 Plan 02: Action Catalog + Resolver Summary

**Five deterministic旬内 actions now resolve through GameRoot with exact stat and relationship deltas, failure feedback, and headless regression coverage.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-04-06T00:32:47Z
- **Completed:** 2026-04-06T00:40:40Z
- **Tasks:** 2
- **Files modified:** 10

## Accomplishments
- Added a canonical Phase 2 action catalog with the five shipped actions, fixed category rail, and hidden-vs-disabled availability rules.
- Added deterministic resolver logic for `训练 / 读书 / 休整 / 拜访 / 巡察`, including failed-visit clue feedback and session history appends.
- Added a headless regression that validates action metadata, exact runtime deltas, relation updates, and non-silent failure behavior through the real autoload path.

## Task Commits

1. **Task 1: Implement the five-action catalog with exact Phase 2 metadata and availability rules** - `b9f6766` (test), `95b1b1e` (feat)
2. **Task 2: Implement deterministic action settlement, partial-failure feedback, and a headless resolver regression** - `f06c42d` (test), `2c28dac` (feat)

## Files Created/Modified
- `three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd` - fixed category list and availability filtering for the five actions.
- `three-kingdoms-simulator/scripts/systems/Phase2ActionResolver.gd` - deterministic action settlement and failed-visit feedback.
- `three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd` - headless regression for metadata, deltas, and history appends.
- `three-kingdoms-simulator/scripts/autoload/GameRoot.gd` - HUD-facing query and execute APIs for Phase 2 actions.
- `three-kingdoms-simulator/scripts/runtime/RuntimeCharacterState.gd` - martial/strategy/governance experience tracking.
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` - preload-safe GameSession bootstrap and relation seeding call path.
- `three-kingdoms-simulator/scripts/runtime/GameSession.gd` - variant-safe relation/action history storage for Godot compilation stability.
- `three-kingdoms-simulator/scripts/runtime/Phase2ActionSpec.gd` - preload-safe DTO factory return path.
- `three-kingdoms-simulator/scripts/runtime/ActionResolution.gd` - preload-safe DTO factory return path.
- `three-kingdoms-simulator/scripts/runtime/RuntimeRelationState.gd` - preload-safe DTO factory return path.
- `three-kingdoms-simulator/scripts/runtime/XunSummaryData.gd` - preload-safe DTO factory return path.

## Decisions Made
- Kept availability logic outside the HUD and inside `Phase2ActionCatalog` so Plan 03 can render menu state without duplicating permission or disabled-reason rules.
- Routed all execution through `GameRoot.execute_phase2_action(...)` so the HUD and later xun-summary flow consume the same structured results and session history.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed autoload/class-name collisions and preload-order typing failures**
- **Found during:** Task 1 and Task 2 implementation
- **Issue:** Godot 4.6 treated several custom-class references and the `DataRepository` class name as compile blockers when combined with autoload names and warning-as-error typed inference.
- **Fix:** Switched the affected Phase 2 DTO/catalog/bootstrap paths to preload-safe factories/variants, removed the `DataRepository` class-name collision, and normalized strict typed locals in tests and GameRoot.
- **Files modified:** `three-kingdoms-simulator/scripts/autoload/DataRepository.gd`, `three-kingdoms-simulator/scripts/runtime/GameSession.gd`, `three-kingdoms-simulator/scripts/runtime/Phase2ActionSpec.gd`, `three-kingdoms-simulator/scripts/runtime/ActionResolution.gd`, `three-kingdoms-simulator/scripts/runtime/RuntimeRelationState.gd`, `three-kingdoms-simulator/scripts/runtime/XunSummaryData.gd`, `three-kingdoms-simulator/scripts/autoload/GameRoot.gd`, `three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd`
- **Verification:** Re-ran the headless Godot regression until the real autoload-backed action tests exited `0`.
- **Committed in:** `95b1b1e` and `2c28dac` (part of task commits)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fixes were required to make the planned backend compile and run under the project’s Godot 4.6 environment; no product scope changed.

## Issues Encountered
- Godot warning-as-error behavior surfaced several typed GDScript edge cases during TDD, so the implementation had to be made preload-safe before gameplay assertions could be trusted.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Plan 03 can now render real action rows, target lists, relationship context, and result dialogs using stable `GameRoot` APIs.
- Plan 04 can consume `current_xun_action_history` and latest action results to generate end-xun summaries and multi-xun regressions.

## Self-Check: PASSED
