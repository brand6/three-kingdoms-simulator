---
phase: quick-260409-ef2
plan: 260409-ef2
subsystem: ui
tags: [godot, ui, gdscript, monthly-tasks, regression]
requires:
  - phase: quick-260407-rz5
    provides: 月初任务弹窗确认按钮门控与 phase21 月任务 HUD 回归基线
provides:
  - 任务卡标题行改为任务名、来源、请求方三段式排版
  - 任务正文文本归一化，移除描述后的多余空白行
  - 锁定无竖线分隔且无双空行的月任务 HUD 回归断言
affects: [phase-03-ui, monthly-hud, quick-tasks]
tech-stack:
  added: []
  patterns: [TaskSelectPanel uses a segmented HBox header plus normalized RichTextLabel body text for monthly task cards]
key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd
    - three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd
key-decisions:
  - "任务卡首行继续保留任务名、来源、请求方三块信息，但改为 HBox 分段排版而不是竖线拼接。"
  - "任务描述在进入 RichTextLabel 前先做换行归一化，避免正文段落再次出现双空行。"
patterns-established:
  - "月任务回归可通过读取 HeaderLabel 容器子标签来重建首行扫描文本，而不依赖单一拼接字符串。"
  - "任务卡正文一律通过 _normalize_card_text 清洗输入文案，再拼接目标、奖励与机遇风险段落。"
requirements-completed: [UI-02]
duration: 5min
completed: 2026-04-09
---

# Quick Task 260409-ef2 Summary

**月初任务卡现在以分段标题行展示任务名、来源与请求方，并会压平描述后的多余空白行，保持任务领取闭环回归通过。**

## Performance

- **Duration:** 5 min
- **Started:** 2026-04-09T02:24:30Z
- **Completed:** 2026-04-09T02:29:19Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- 将 `TaskSelectPanel.gd` 的任务卡标题从单字符串改成三段式头部布局，移除了竖线分隔。
- 为任务描述增加换行归一化，去掉“目标”段后方用户指出的双空白问题。
- 更新 `phase21_monthly_hud_regression.gd`，锁定新排版合同并保留月初选择、确认、月报与任命闭环断言。

## Task Commits

Each task was committed atomically:

1. **Task 1: 重排任务卡首行与正文间距** - `5e55346` (feat)
2. **Task 2: 更新月任务 HUD 回归以锁定新排版合同** - `a4d9cc3` (test)

**Plan metadata:** pending final docs commit

## Files Created/Modified

- `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd` - 用分段 HeaderRow 渲染任务名、来源、请求方，并在正文渲染前清理多余空行。
- `three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd` - 校验任务卡首行不再使用竖线分隔，且正文不会出现双空行，同时维持整个月任务领取流程回归。

## Decisions Made

- 保留 Button 任务卡和确认按钮门控，不把这次 quick task 扩散到任务选择交互逻辑。
- 首行三块信息仍按“任务名 / 来源 / 请求方”呈现，但由容器排版提供扫读间距，而不是依赖符号分隔。
- 正文空白修复放在文案标准化层处理，避免未来任务描述数据带入重复空行时再次污染 UI。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Task 2 的静态校验第一次失败，因为回归脚本中仍直接写入了全角竖线字符；改为 `char(0xff5c)` 断言后保留检查意图并通过计划校验。
- Task 2 的首次联合验证命令触发了 PowerShell 引号解析错误；修正命令引用后，headless Godot 回归正常通过。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 月初任务卡排版合同已由回归脚本锁定，后续若继续微调视觉样式，可在不改任务闭环测试范围的前提下演进。
- `_normalize_card_text()` 已提供基础文本清洗入口，后续若任务描述来源更复杂，可复用这层处理保持卡片稳定排版。

## Verification

- `python -c "from pathlib import Path; ..."` 通过，确认 `TaskSelectPanel.gd` 中已移除全角竖线分隔实现，且仍保留 `来源：` / `请求方：` 文案。
- `python -c "from pathlib import Path; ..."` + `Godot_v4.6.1-stable_mono_win64_console.exe --headless --path three-kingdoms-simulator --script res://scripts/tests/phase21_monthly_hud_regression.gd` 通过，确认新排版下月任务领取与月报/任命串联闭环仍正常。

## Self-Check: PASSED

- FOUND: `.planning/quick/260409-ef2-1-2/260409-ef2-SUMMARY.md`
- FOUND: `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd`
- FOUND: `three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd`
- FOUND commit: `5e55346`
- FOUND commit: `a4d9cc3`
