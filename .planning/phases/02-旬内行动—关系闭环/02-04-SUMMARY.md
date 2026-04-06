---
phase: 02-旬内行动—关系闭环
plan: "04"
subsystem: loop
tags: [godot, xun-loop, time-manager, hud, regression, summaries]
requires:
  - phase: 02-旬内行动—关系闭环
    provides: Action execution APIs, HUD overlays, runtime action history, and relation feedback.
provides:
  - Stable xun advancement with month rollover and formatted labels.
  - End-xun summary generation from real action history plus AP reset orchestration.
  - Headless three-xun regression covering confirmation flow, summary visibility, and AP persistence rules.
affects: [phase-2-complete, future-month-end-systems, save-load, debugging]
tech-stack:
  added: []
  patterns: [time-manager rollover API, GameRoot summary orchestration, HUD confirmation-to-summary flow, end-to-end SceneTree regression]
key-files:
  created:
    - three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd
  modified:
    - three-kingdoms-simulator/scripts/autoload/GameRoot.gd
    - three-kingdoms-simulator/scripts/autoload/TimeManager.gd
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
key-decisions:
  - "Xun summaries are built from accumulated ActionResolution history before time advances, so the summary always describes the finishing xun rather than the next one."
  - "The end-xun HUD flow uses explicit confirmation and summary dialogs, and the regression closes the summary between loops to mirror real player flow."
patterns-established:
  - "Time pattern: TimeManager owns xun/month rollover and formatted labels, while GameRoot copies the advanced values back into GameSession."
  - "Summary pattern: MainHUD presents sections in the exact order 本旬行动摘要 → 主要数值变化 → 关系变化摘要 → 新提示."
requirements-completed: [CORE-04, CORE-05, UI-04, ACTN-05, RELA-03]
duration: 10min
completed: 2026-04-06
---

# Phase 2 Plan 04: End-Xun Loop Summary

**The full旬内 loop now advances time, resets AP, explains xun results, and passes a headless three-transition regression including the rollover to 190年 / 2月 / 第1旬.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-04-06T00:45:40Z
- **Completed:** 2026-04-06T00:56:00Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Extended `TimeManager` and `GameRoot` so xun advancement, month rollover, AP reset, and xun summaries all run through stable runtime APIs.
- Added end-xun confirmation and xun-summary dialogs to the HUD, with summary content rendered in the contract’s required section order.
- Added and passed a headless integration regression that executes real actions, advances three xun, checks AP reset/persistence, and verifies summary visibility.

## Task Commits

1. **Task 1: Implement end-xun orchestration, AP reset, and summary generation** - `cad26bb` (feat)
2. **Task 2: Wire the end-xun HUD flow and prove three stable transitions with a headless regression** - `e65dfa8` (test), `48cc8e6` (feat)

## Files Created/Modified
- `three-kingdoms-simulator/scripts/autoload/TimeManager.gd` - xun rollover logic and reusable label formatting helpers.
- `three-kingdoms-simulator/scripts/autoload/GameRoot.gd` - xun-end summary generation, AP reset, and session/time synchronization.
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` - end-xun confirmation handling, summary rendering, and next-xun prompt refresh.
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - `EndXunDialog` and `XunSummaryDialog` HUD overlays.
- `three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd` - three-xun headless integration regression.

## Decisions Made
- Built the summary from action history before advancing time so the xun label and explanation always refer to the xun the player just finished.
- Kept AP reset separate from cumulative fame/merit/energy/stress/relation state so repeated xun loops preserve meaningful consequences while refreshing only the action budget.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed modal dialog exclusivity during repeated end-xun flow**
- **Found during:** Task 2 (Wire the end-xun HUD flow and prove three stable transitions with a headless regression)
- **Issue:** The xun summary dialog initially opened while the confirmation dialog was still exclusive, and the next loop iteration then failed when reopening the confirmation dialog.
- **Fix:** Hid `EndXunDialog` before opening the summary and updated the regression to close the summary between xun loops, matching real user flow.
- **Files modified:** `three-kingdoms-simulator/scripts/ui/MainHUD.gd`, `three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd`
- **Verification:** Re-ran the headless three-xun regression until it exited `0` with all summary and rollover assertions passing.
- **Committed in:** `48cc8e6` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix was necessary for the planned repeatable xun loop to work correctly; scope stayed within the end-xun flow.

## Issues Encountered
- The TDD regression needed a few strict-typing fixes before it could express the real missing end-xun flow, due to Godot warning-as-error behavior in test scripts and helper locals.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 2 is now functionally complete: actions, relation feedback, HUD interaction, and end-xun progression all run in one repeatable loop.
- Later phases can build month-end evaluation, persistence, and debug tooling on top of stable multi-xun progression and summary history.

## Self-Check: PASSED
