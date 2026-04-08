---
phase: quick-260408-rjt
plan: 260408-rjt
subsystem: ui
tags: [godot, hud, ui, gdscript, summary-cards]
requires:
  - phase: quick-260406-ojk
    provides: MainScene fixed HUD shell, MainHUD refresh chain, three center summary cards
provides:
  - 中部三摘要卡的 primary/secondary 双层节点结构
  - 关系、政治、家族三类动态提醒文案生成规则
  - “默认一句、必要时两句”的运行时摘要显示
affects: [phase-03-ui, main-hud, quick-tasks]
tech-stack:
  added: []
  patterns: [MainHUD renders summary_line_primary and optional summary_line_secondary from existing GameRoot HUD summary data]
key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
key-decisions:
  - "保留三张摘要卡标题不变，只把正文结构升级为 primary + optional secondary。"
  - "继续复用 GameRoot.get_hud_political_summary() 入口，在 HUD 侧把旧的字段式政治摘要转成动态提醒句。"
  - "仅在存在时限、损失或立即可响应牵引时显示第二句，避免中部区域退回说明书式文案。"
patterns-established:
  - "中心摘要卡统一通过 _apply_summary_lines 控制 secondary 显隐，后续摘要卡扩展可复用同一模式。"
  - "HUD 可接受旧摘要种子字段，但在渲染前清洗标签前缀并重写为玩家下一步导向句。"
requirements-completed: [UI-01, UI-02, UI-04]
duration: 20min
completed: 2026-04-08
---

# Quick Task 260408-rjt Summary

**主 HUD 中部三卡已从静态说明改成关系维护、政治机会与家族牵引三类动态提醒，并支持按风险/时限自动补第二句。**

## Performance

- **Duration:** 20 min
- **Started:** 2026-04-08T11:39:05Z
- **Completed:** 2026-04-08T11:59:06Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- 将 MainScene 三张中部摘要卡改为标题 + 主摘要 + 次摘要的稳定节点结构。
- 更新 MainHUD 绑定与刷新路径，使三张卡都能渲染 `summary_line_primary` 和可选 `summary_line_secondary`。
- 用动态提醒句替代旧的字段式摘要，让三卡分别聚焦谁要维护、哪里有政治窗口、家族正在施加什么牵引。

## Task Commits

1. **Task 1: 把中部三摘要卡改成 primary/secondary 双层结构** - `7be9eaf` (feat)
2. **Task 2: 用动态提醒规则重写三摘要卡的 HUD 绑定与文案生成** - `915d94d` (feat)

**Plan metadata:** pending final docs commit

## Files Created/Modified

- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - 为三张摘要卡提供 primary/secondary 正文节点并保留原有标题与布局骨架。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` - 绑定双层摘要节点，清洗旧政治摘要种子，并生成动态提醒式主/次摘要文案。

## Decisions Made

- 保持 MainScene + MainHUD + GameRoot 的既有刷新链路，不新增独立控制器或切场景流程。
- 将 secondary 文本显示规则集中到 `_apply_summary_lines()`，确保“默认一句、必要时两句”在三张卡上行为一致。
- 对现有政治摘要入口做 HUD 侧清洗与重写，而不是反向扩散旧字段式文案到场景结构中。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Task 2 首次自动校验失败，因为脚本里仍保留了旧字段标题常量字符串；随后将标签清洗逻辑改成通用前缀识别后通过校验。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 三张卡已具备统一的双层摘要渲染模式，后续可直接接更细的派系/家族数据而不必改 UI 结构。
- 若后续政治系统提供更明确的 tone 或时限字段，HUD 只需补充判定条件即可增强 secondary 出现规则。

## Verification

- 运行计划内 2 条自动校验，确认场景节点和 HUD 绑定都已切换到双层摘要结构，并且脚本中不再保留旧字段式摘要标题。

## Self-Check: PASSED

- FOUND: `.planning/quick/260408-rjt-design-uiux-v1-md/260408-rjt-SUMMARY.md`
- FOUND: `three-kingdoms-simulator/scenes/main/MainScene.tscn`
- FOUND: `three-kingdoms-simulator/scripts/ui/MainHUD.gd`
- FOUND commit: `7be9eaf`
- FOUND commit: `915d94d`
