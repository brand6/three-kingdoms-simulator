---
phase: 03-仕途、势力与可解释政治
plan: "09"
subsystem: politics-ui
tags: [godot, gdscript, ui, popup, theme, regression]

# Dependency graph
requires:
  - phase: 03-06
    provides: Faction popup / Character profile drilldown / politics HUD regression baseline
provides:
  - 共享 PopupPanel 不透明样式兜底
  - FactionPanel / CharacterProfilePanel 不透明 popup 配置
  - 锁定势力 popup 下钻人物链路的不透明视觉回归
affects: [03-07, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [shared-popup-theme-fallback, opaque-popup-drilldown-regression]

key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/themes/PrototypeTheme.tres

key-decisions:
  - "FactionPanel 与 CharacterProfilePanel 继续沿用 MainScene 单场景 popup 下钻流程，不改导航结构。"
  - "PopupPanel 的不透明视觉规则上收到 PrototypeTheme，而不是复制节点级 panel override。"

patterns-established:
  - "shared-popup-theme-fallback: PopupPanel 共享 panel StyleBox 由 PrototypeTheme 提供统一兜底。"
  - "opaque-popup-drilldown-regression: UI 回归同时断言 popup 视觉契约与 Faction → Character 下钻链路。"

requirements-completed: [FACT-01, FACT-03]

# Metrics
duration: 0 min
completed: 2026-04-09
---

# Phase 03 Plan 09: 势力/人物政治 popup 不透明化 Summary

**FactionPanel 与 CharacterProfilePanel 现已通过共享 Theme 使用不透明 PopupPanel 样式，并由回归测试锁定势力总览到人物详情的下钻链路。**

## Performance

- **Duration:** 0 min
- **Started:** 2026-04-09T01:02:46Z
- **Completed:** 2026-04-09T01:02:46Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- 将 Phase 3 政治 HUD 回归升级为同时验证 popup 不透明视觉契约与势力→人物详情下钻流程。
- 在 `PrototypeTheme.tres` 中补上 `PopupPanel` 共享 panel StyleBox，给政治 popup 提供统一不透明兜底。
- 在 `MainScene.tscn` 中为 `FactionPanel` 和 `CharacterProfilePanel` 显式关闭透明背景与透明渲染，同时保持既有 popup 尺寸与流程不变。

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend the Phase 3 HUD regression to require opaque faction and character popups** - `90aeb31` (test)
2. **Task 2: Move faction and character popup styling onto the shared opaque PopupPanel theme path** - `16e473b` (feat)

**Plan metadata:** `Pending final docs commit`

## Files Created/Modified
- `three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd` - 新增 popup 不透明断言与势力按钮下钻人物回归。
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - 为 `FactionPanel` / `CharacterProfilePanel` 显式关闭透明属性。
- `three-kingdoms-simulator/themes/PrototypeTheme.tres` - 增加 `PopupPanel` 共享 panel StyleBox fallback。

## Decisions Made
- 保持 `FactionButton -> FactionPanel -> CharacterProfilePanel` 的单场景 popup 流程，只修复视觉一致性，不调整交互架构。
- 复用与 `TaskSelectPanel` 一致的卡片视觉参数，但将规则沉到共享 Theme，避免未来 popup 再次走回裸 `PopupPanel` 默认样式。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- 首轮回归断言直接查询 `Theme.has_stylebox()`，未按 `Control` 的继承主题解析路径工作，已改为 `PopupPanel.has_theme_stylebox("panel")` 进行真实 UI 断言。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 3 的势力总览与人物详情 popup 视觉已统一，可继续作为后续 UAT / 验证基线。
- 当前计划无残留 blocker，已满足 `FACT-01` 与 `FACT-03` 对政治信息 popup 可读性的收口要求。

## Self-Check: PASSED

- FOUND: `.planning/phases/03-仕途、势力与可解释政治/03-09-SUMMARY.md`
- FOUND: commit `90aeb31`
- FOUND: commit `16e473b`
