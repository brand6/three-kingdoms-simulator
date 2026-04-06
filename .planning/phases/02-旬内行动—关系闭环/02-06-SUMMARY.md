---
phase: 02-旬内行动—关系闭环
plan: "06"
subsystem: ui
tags: [godot, hud, popup, selector, profile, regression]
requires:
  - phase: 02-旬内行动—关系闭环
    provides: 配置驱动五行动菜单规则与通用 selector/profile DTO 数据接口。
provides:
  - 上浮五行动首屏菜单与右侧行动详情区。
  - 可排序通用角色选择器与角色信息面板组件。
  - Visit/Relation 共用选择器链路的 HUD 回归测试。
affects: [02-07, phase-2-uat, relation-ui, visit-ui]
tech-stack:
  added: []
  patterns: [floating five-action rail, shared selector dialog, profile panel drill-down, HUD flow regression]
key-files:
  created:
    - three-kingdoms-simulator/scripts/ui/CharacterSelectorDialog.gd
    - three-kingdoms-simulator/scripts/ui/CharacterProfilePanel.gd
    - three-kingdoms-simulator/scripts/tests/phase2_hud_menu_selector_regression.gd
  modified:
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
key-decisions:
  - "行动入口左列固定显示五个基础行动按钮，不再把五大类作为首屏点击层。"
  - "关系入口与拜访入口必须复用同一个排序表格选择器，关系确认后进入角色信息面板。"
patterns-established:
  - "Floating menu pattern: ActionButton anchors a popup above the bottom bar with a five-action rail and detail pane."
  - "Selector/profile pattern: relation and visit both start from CharacterSelectorDialog, then diverge to execute or inspect profile."
requirements-completed: [ACTN-01, ACTN-02, UI-01, UI-02, RELA-02, RELA-03, UI-04]
duration: 10min
completed: 2026-04-06
---

# Phase 2 Plan 06: HUD Menu + Shared Selector Summary

**The Phase 2 HUD now opens a floating five-action menu and routes both visit and relation flows through one sortable selector and profile panel.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-04-06T12:16:21+08:00
- **Completed:** 2026-04-06T12:25:58+08:00
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Added reusable `CharacterSelectorDialog` and `CharacterProfilePanel` overlays to `MainScene` instead of piling more dynamic buttons into `MainHUD`.
- Replaced the category-first action popup with a floating five-action left rail plus detail pane, while keeping disabled reasons visible.
- Added a HUD regression that proves visit and relation both use the shared selector, sorting changes the row order, and relation now lands in the profile panel rather than `RelationPopup`.

## Task Commits

1. **Task 1: 抽象通用可排序角色选择器与角色信息面板组件** - `45e8b69` (feat)
2. **Task 2: 重接 HUD 菜单与关系流程，并用回归测试锁定新交互** - `2424f20` (feat)

## Files Created/Modified
- `three-kingdoms-simulator/scripts/ui/CharacterSelectorDialog.gd` - sortable selector dialog with reusable heading/hint/render APIs.
- `three-kingdoms-simulator/scripts/ui/CharacterProfilePanel.gd` - profile drill-down panel for relation inspection.
- `three-kingdoms-simulator/scripts/tests/phase2_hud_menu_selector_regression.gd` - headless HUD regression for five-action menu and selector reuse.
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - mounted selector/profile overlays in the main HUD scene.
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` - rewired action, visit, and relation flows to the new information architecture.

## Decisions Made
- Kept the five base actions in the left rail and moved all explanation/execute controls into the detail pane so the popup stays compact but explicit.
- Left the legacy `RelationPopup` node unused instead of deleting it immediately, minimizing scene churn while the new relation path becomes the only active flow.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed typed script references and removed a dead legacy execute path during HUD rewiring**
- **Found during:** Task 2 (重接 HUD 菜单与关系流程，并用回归测试锁定新交互)
- **Issue:** `MainHUD.gd` initially referenced new dialog classes too early for parser resolution, and the obsolete `_pending_target_action_id` path caused parse failures once visit moved to the shared selector.
- **Fix:** Relaxed the onready node types to base UI classes for the scene lookup and turned the old target-picker confirm path into a no-op.
- **Files modified:** `three-kingdoms-simulator/scripts/ui/MainHUD.gd`, `three-kingdoms-simulator/scripts/ui/CharacterSelectorDialog.gd`
- **Verification:** Re-ran `phase2_hud_menu_selector_regression.gd` until the scene loaded and the full selector/profile flow passed.
- **Committed in:** `2424f20` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The fix was necessary to make the new HUD flow compile and execute under Godot's typed GDScript rules; no scope change.

## Issues Encountered
- The first HUD regression run surfaced parser failures before behavioral assertions, so the new UI scripts had to be made preload-safe before the intended interaction checks could prove anything.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 02-07 can now focus purely on the end-xun confirmation bug while relying on the rebuilt HUD flow.
- Phase 2 UAT can re-test action menu IA, selector sorting, and relation drill-down against automated coverage instead of manual spot checks only.

## Self-Check: PASSED
