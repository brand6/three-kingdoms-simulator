---
phase: 02-旬内行动—关系闭环
plan: "03"
subsystem: ui
tags: [godot, hud, popup-panel, dialogs, ui-feedback, relations]
requires:
  - phase: 02-旬内行动—关系闭环
    provides: Action catalog, GameRoot action APIs, relation overview, and deterministic action results.
provides:
  - MainScene popup/dialog surfaces for action selection, target choice, relation inspection, and result feedback.
  - HUD rendering logic for category rails, action metadata, disabled reasons, relation context, and result summaries.
  - Enabled main-HUD entry points for Phase 2 action and relation flow.
affects: [02-04, hud-regression, action-loop, xun-summary]
tech-stack:
  added: []
  patterns: [popup-based hud workflow, action metadata rendering from GameRoot, relation/result overlays inside MainScene]
key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
    - three-kingdoms-simulator/themes/PrototypeTheme.tres
key-decisions:
  - "Phase 2 HUD interaction stays fully inside MainScene using PopupPanel and dialog overlays instead of scene changes."
  - "MainHUD renders action and relation details directly from GameRoot APIs, keeping UI state derived from runtime data rather than duplicated local models."
patterns-established:
  - "Overlay pattern: ActionMenuPopup, TargetPickerDialog, RelationPopup, and ActionResultDialog are named anchors for later headless integration tests."
  - "Feedback pattern: executed actions immediately update TaskBody, EventBody, and RelationSummaryBody alongside a modal result dialog."
requirements-completed: [ACTN-01, ACTN-02, UI-01, UI-02, UI-04, RELA-02]
duration: 5min
completed: 2026-04-06
---

# Phase 2 Plan 03: HUD Action + Relation UI Summary

**MainScene now hosts a playable HUD-first Phase 2 loop with action popups, target selection, relation inspection, and structured action-result feedback.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-04-06T00:40:40Z
- **Completed:** 2026-04-06T00:45:40Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Enabled the main HUD action entry and added popup/dialog nodes for action menu, target selection, relation viewing, and action results.
- Rendered fixed action categories plus metadata fields, disabled reasons, and visit target details directly from GameRoot-backed runtime data.
- Added relation overview and post-action feedback updates so the player can inspect context and see results without leaving MainScene.

## Task Commits

1. **Task 1: Build the floating action menu and target-selection flow inside MainScene** - `43fee99` (feat)
2. **Task 2: Wire relation inspection and action-result feedback into the main HUD flow** - `8e25525` (feat)

## Files Created/Modified
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - enabled action/relation buttons and added `ActionMenuPopup`, `TargetPickerDialog`, `RelationPopup`, and `ActionResultDialog`.
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` - popup wiring, action metadata rendering, target picker logic, relation overview rendering, and result feedback updates.
- `three-kingdoms-simulator/themes/PrototypeTheme.tres` - reused existing accent/disabled styling contract for the new overlays.

## Decisions Made
- Kept all Phase 2 interaction inside the existing HUD shell and used named overlay nodes so Plan 04 can drive them in headless regression without scene swaps.
- Rendered action details and relation context straight from `GameRoot` query APIs instead of caching separate UI-only state, keeping gameplay truth centralized.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed typed-GDScript inference in target picker wiring**
- **Found during:** Task 2 (Wire relation inspection and action-result feedback into the main HUD flow)
- **Issue:** The first target-picker implementation hit warning-as-error typed inference failures in `MainHUD.gd`, blocking HUD script compilation.
- **Fix:** Added explicit types for relation/character locals and removed a no-op action loop so the target picker could compile cleanly.
- **Files modified:** `three-kingdoms-simulator/scripts/ui/MainHUD.gd`
- **Verification:** Re-ran the HUD acceptance-marker check and confirmed the script loaded far enough for the only remaining regression failures to be unrelated pre-existing Phase 1 label-copy expectations.
- **Committed in:** `8e25525` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The fix was required for the planned Phase 2 HUD overlays to compile; no functional scope changed.

## Issues Encountered
- The existing `phase1_topbar_time_regression.gd` still expects older top-bar copy (`当前城市：...`, raw identity/office IDs, bare time label) and fails independently of this plan’s Phase 2 HUD work.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Plan 04 can now reuse `ActionResultDialog` and the enabled HUD shell to implement end-xun confirmation, summary display, and multi-xun regression.
- The Phase 2 action loop is now visible enough for xun summaries to explain what changed using real action history.

## Self-Check: PASSED
