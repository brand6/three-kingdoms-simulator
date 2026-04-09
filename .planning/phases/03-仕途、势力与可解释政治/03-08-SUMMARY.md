---
phase: 03-仕途、势力与可解释政治
plan: "08"
subsystem: politics-ui
tags: [godot, gdscript, ui, task-card, regression]

# Dependency graph
requires:
  - phase: 03-06
    provides: 月初任务卡基础 popup、政治来源字段展示入口
  - phase: 03-07
    provides: explainable-politics 联调基线与月初/月末回归保护
provides:
  - 月初任务卡单行来源头部布局
  - 机遇和风险彩色标签文案契约
  - 锁定新任务卡文案的回归测试
affects: [03-03, 03-05, 03-07, 03-09, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [structured-task-card, richtext-risk-tags, tdd-regression-contract]

key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd
    - three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd

key-decisions:
  - "任务卡继续保留 Button 选择交互，但内容改为 HeaderLabel + RichTextLabel 结构化渲染。"
  - "来源类型不再独立成行，而是内联到首行的 来源：{来源类型} · {来源对象}。"
  - "机遇和风险保留单标题，用颜色区分标签，不再输出 机会:/风险: 前缀。"

patterns-established:
  - "structured-task-card: 任务卡按钮承载子控件而非依赖 Button.text，多段信息可独立布局。"
  - "richtext-risk-tags: 机遇/风险标签通过 RichTextLabel BBCode 着色，保持可扫读且不数值化。"

requirements-completed: [CARE-01, POLI-03]

# Metrics
duration: 8 min
completed: 2026-04-09
---

# Phase 3 Plan 08: 月初任务卡布局修复 Summary

**月初任务卡改为单行来源头部与彩色机遇/风险标签，让玩家首屏即可扫读任务政治来路。**

## Performance

- **Duration:** 8 min
- **Started:** 2026-04-09T01:01:35Z
- **Completed:** 2026-04-09T01:10:20Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- 将继承自 03-06 的月初 HUD 回归改写为新任务卡契约，先锁死 UAT 反馈中的单行来源布局与“机遇和风险”文案。
- 用结构化子控件替换纯 `Button.text` 任务卡渲染，保留原有点击选择与确认按钮门控行为。
- 将来源类型内联到 `来源` 字段，并用 RichText 颜色区分机遇/风险标签，移除旧版 `来源类型 / 关联派系 / 政治标签 / 机会: / 风险:` 文案。

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite the inherited month-start regression to the new task-card contract** - `eff970b` (test)
2. **Task 2: Replace the old plain-text task-card renderer with the new single-line source layout** - `5b59f73` (feat)

**Plan metadata:** Pending metadata commit

## Files Created/Modified
- `three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd` - 断言新任务卡首行来源布局、机遇和风险标题与旧文案禁用规则。
- `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd` - 用结构化 HeaderLabel + RichTextLabel 卡片替换旧多行纯文本按钮渲染。

## Decisions Made
- 任务卡继续使用按钮卡片交互，避免改动月初选择流程与 popup 架构。
- 首行统一承载 `任务名｜来源｜请求方` 三段信息，把来源类型与来源对象一起内联显示。
- 机遇与风险继续保持标签式表达，但只保留一个标题并通过颜色区分政治正负向。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `phase21_monthly_hud_regression.gd` 在 RED 阶段按预期失败，直接暴露旧任务卡仍依赖纯文本模板与旧文案契约。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 后续政治任务样本可以继续复用当前结构化卡片，在不重写选择逻辑的前提下增加更多来源字段或标签样式。
- 03-03 / 03-05 / 后续 UAT 可直接把 `phase21_monthly_hud_regression.gd` 当作月初任务卡展示契约基线。

## Self-Check: PASSED

- FOUND: `.planning/phases/03-仕途、势力与可解释政治/03-08-SUMMARY.md`
- FOUND: `eff970b`
- FOUND: `5b59f73`
