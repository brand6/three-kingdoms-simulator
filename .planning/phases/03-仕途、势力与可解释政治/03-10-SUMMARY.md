---
phase: 03-仕途、势力与可解释政治
plan: "10"
subsystem: task-card-ui
tags: [godot, gdscript, task-card, institution-source, regression]

# Dependency graph
requires:
  - phase: 03-02
    provides: 月任务来源字段、候选 payload 与 MonthlyTaskState 来源快照基础合同
  - phase: 03-08
    provides: 结构化任务卡与首轮来源/请求方单行布局基线
provides:
  - authority_institution_name 显式任务来源机构字段链路
  - 月初任务卡来源机构 / 请求方语义分离显示
  - 第二轮任务卡可读性边距与最小高度契约回归
affects: [03-03, 03-05, 03-07, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [authority-institution-source, requester-fallback-header, readable-task-card-spacing]

key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scripts/tests/phase3_task_source_regression.gd
    - three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd
    - three-kingdoms-simulator/scripts/data/resources/TaskTemplateData.gd
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd
    - three-kingdoms-simulator/scripts/systems/TaskSystem.gd
    - three-kingdoms-simulator/scripts/runtime/MonthlyTaskState.gd
    - three-kingdoms-simulator/data/generated/190/task_templates.json
    - three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd

key-decisions:
  - "authority_institution_name 成为来源机构唯一字段，独立于 request_character_id。"
  - "任务卡首行固定为 任务名｜来源：机构名｜请求方：具体人物，请求方优先使用 request_character_id，缺失时回退 issuer_character_id。"
  - "任务卡通过更高的最小高度与更强的 content margin 提升可读性，同时保持确认按钮门控不变。"

patterns-established:
  - "authority-institution-source: TaskTemplateData → DataRepository → TaskSystem → MonthlyTaskState 全链路使用同一 authority_institution_name 字段。"
  - "requester-fallback-header: UI 只把 request_character_id / issuer_character_id 用于请求方，不再参与来源渲染。"
  - "readable-task-card-spacing: 回归测试直接锁定任务卡 min-height 与 stylebox content margins。"

requirements-completed: [CARE-01, POLI-03]

# Metrics
duration: 4 min
completed: 2026-04-09
---

# Phase 3 Plan 10: 任务卡来源机构与排版收敛 Summary

**月初任务卡现在用独立权力机构字段展示来源、用具体下达人展示请求方，并以更稳的边距与卡片高度锁定可扫读政治信息。**

## Performance

- **Duration:** 4 min
- **Started:** 2026-04-09T01:37:23Z
- **Completed:** 2026-04-09T01:41:16Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments
- 先重写两条回归测试，锁死“来源=机构、请求方=具体下达人、卡片更易读”的新真值。
- 为任务模板、候选 payload 和 MonthlyTaskState 增加 `authority_institution_name`，把尚书台 / 军功集团 / 宗族长老会等机构名贯通到运行时。
- 调整 TaskSelectPanel 首行渲染与卡片 spacing，让来源和请求方语义分离，同时保留 03-08 的结构化卡片与确认按钮门控。

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite regressions around institution-vs-requester semantics and card readability** - `c1b534d` (test)
2. **Task 2: Thread an explicit authority-institution field through task data, payloads, and frozen snapshots** - `c1df9ba` (feat)
3. **Task 3: Render institution-based task cards with concrete requester and improved typography** - `0c19ff7` (feat)

**Plan metadata:** Pending metadata commit

## Files Created/Modified
- `three-kingdoms-simulator/scripts/tests/phase3_task_source_regression.gd` - 锁定候选 payload 与 MonthlyTaskState 必须包含独立来源机构字段。
- `three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd` - 锁定来源机构/请求方文案语义和卡片 spacing 契约。
- `three-kingdoms-simulator/scripts/data/resources/TaskTemplateData.gd` - 为任务模板新增 `authority_institution_name` 字段。
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` - 从生成 JSON 加载来源机构字段。
- `three-kingdoms-simulator/scripts/systems/TaskSystem.gd` - 将来源机构写入候选 payload。
- `three-kingdoms-simulator/scripts/runtime/MonthlyTaskState.gd` - 冻结来源机构字段到月任务快照。
- `three-kingdoms-simulator/data/generated/190/task_templates.json` - 为 4 个样本任务补齐机构名并保持请求方语义独立。
- `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd` - 以机构名渲染来源、以具体人物渲染请求方，并增强卡片边距与高度。

## Decisions Made
- 用 `authority_institution_name` 而不是 `related_bloc_id` 或 `source_summary` 承载来源机构，避免再次混淆机构、人物和摘要三种语义。
- 请求方展示逻辑固定为 `request_character_id` 优先、`issuer_character_id` 回退，确保 faction_order 任务也能显示具体下达人。
- 第二轮排版收敛直接通过回归断言卡片最小高度与 stylebox margin，而不只靠文案快照。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Known Stubs

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 后续推荐 / 反对 / 官职后果计划可以直接复用冻结后的来源机构字段，不必再从摘要文本反推政治来源。
- 月初任务卡的语义与 spacing 已有 headless 回归保护，后续 UI 调整可以在此基线上继续演进。

## Self-Check: PASSED

- FOUND: `.planning/phases/03-仕途、势力与可解释政治/03-10-SUMMARY.md`
- FOUND: `c1b534d`
- FOUND: `c1df9ba`
- FOUND: `0c19ff7`

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-09*
