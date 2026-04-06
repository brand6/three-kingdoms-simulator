---
phase: 02-旬内行动—关系闭环
plan: "07"
subsystem: ui
tags: [godot, dialog, regression, xun-loop, confirmation]
requires:
  - phase: 02-旬内行动—关系闭环
    provides: 已有旬推进链路与新的 HUD 入口结构。
provides:
  - 首次打开就尺寸正确且按钮可见的结束本旬确认框。
  - 覆盖首开尺寸/按钮可见性的旬推进回归。
  - 保持三次旬推进、旬总结、AP 重置与月份进位稳定。
affects: [phase-2-uat, xun-summary, future-regressions]
tech-stack:
  added: []
  patterns: [content-sized confirmation dialog, first-open layout regression]
key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
    - three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd
key-decisions:
  - "结束本旬确认框改用 ConfirmationDialog 自带 dialog_text 与显式尺寸控制，不再在窗口内部再嵌一个正文容器。"
  - "旬推进回归必须同时验证首次打开布局和原有三旬推进链路，避免只修 visible 不修真实布局。"
patterns-established:
  - "Dialog sizing pattern: lightweight confirmation dialogs use reset_size + explicit popup_centered size instead of ratio popups."
  - "Regression pattern: first-open layout assertions live alongside existing flow assertions in one integration script."
requirements-completed: [CORE-04, CORE-05, UI-04]
duration: 3min
completed: 2026-04-06
---

# Phase 2 Plan 07: End-Xun Confirmation Regression Summary

**The first end-xun confirmation now opens at a compact size with visible confirm/cancel buttons, and the three-xun regression locks that layout in place.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-06T12:25:59+08:00
- **Completed:** 2026-04-06T12:28:37+08:00
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Shrunk the end-xun confirmation dialog to a content-sized footprint and removed the oversized first-open ratio behavior.
- Extended the existing xun loop regression to assert confirm/cancel button visibility and compact first-open dimensions before advancing the xun.
- Preserved the full three-xun summary, AP reset, and month rollover flow after the dialog fix.

## Task Commits

1. **Task 1: 把结束本旬确认框改成内容驱动的小弹窗** - `884c6cc` (fix)
2. **Task 2: 扩展旬推进回归，锁定首次打开尺寸与按钮可见性** - `7e36bd1` (test)

## Files Created/Modified
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - end-xun dialog now relies on `dialog_text` and a compact default size.
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` - end-xun dialog opens through reset-size plus explicit centered sizing.
- `three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd` - first-open layout assertions added to the existing multi-xun regression.

## Decisions Made
- Let `ConfirmationDialog` own its own message text instead of nesting extra layout content, which kept the built-in buttons visible on first open.
- Kept the regression in the existing xun loop script so dialog layout and time progression stay validated together.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed the extra EndXunDialog body container after regression proved it stretched the window vertically**
- **Found during:** Task 2 (扩展旬推进回归，锁定首次打开尺寸与按钮可见性)
- **Issue:** Even after switching to explicit popup sizing, the nested `MarginContainer + Label` path still made the dialog height balloon to 762 px on first open.
- **Fix:** Moved the message into `ConfirmationDialog.dialog_text` and deleted the redundant child container so the built-in layout could size correctly.
- **Files modified:** `three-kingdoms-simulator/scenes/main/MainScene.tscn`, `three-kingdoms-simulator/scripts/ui/MainHUD.gd`
- **Verification:** Re-ran `phase2_xun_loop_regression.gd` until the first-open size/buttons assertions and all three xun transitions passed.
- **Committed in:** `7e36bd1` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix was necessary to truly close the UAT bug; it simplified the dialog structure without expanding scope.

## Issues Encountered
- The first regression run proved that changing popup sizing alone was insufficient because the dialog's child layout still forced an oversized height.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 2 gap closure now covers the last reported end-xun UI defect with automated protection.
- The next verification pass can focus on whether the rebuilt HUD meets user expectations rather than on known first-open dialog bugs.

## Self-Check: PASSED
