---
phase: 03-仕途、势力与可解释政治
plan: "05"
subsystem: office-permissions
tags: [godot, gdscript, office, permissions, actions]

# Dependency graph
requires:
  - phase: 02.1
    provides: 月任务闭环、官职基础合同与月末升官路径
  - phase: 03-02
    provides: source-aware 月任务候选生成与来源冻结快照
provides:
  - office-aware 月任务来源差异
  - hidden-vs-disabled 的官职动作可见性规则
  - representative office-only action regression
affects: [03-06, 03-07, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [office-tag-driven-task-eligibility, hidden-vs-disabled-action-visibility, representative-office-actions]

key-files:
  created:
    - three-kingdoms-simulator/scripts/tests/phase3_office_permission_regression.gd
  modified:
    - three-kingdoms-simulator/scripts/data/resources/OfficeData.gd
    - three-kingdoms-simulator/data/generated/190/offices.json
    - three-kingdoms-simulator/data/generated/190/actions.json
    - three-kingdoms-simulator/data/config/phase2_action_menu_config.tres
    - three-kingdoms-simulator/data/task_rules/task_pool_xunyu_early_career.tres
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd
    - three-kingdoms-simulator/scripts/systems/TaskSystem.gd
    - three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd

key-decisions:
  - "官职变化优先通过 office_tags / candidate_office_tags / permission_tags 改变下一月任务来源和动作权限，而不是创建第二套玩法模式。"
  - "永久无权限动作直接隐藏；临时不可执行动作保留并显示 disabled_reason。"
  - "Phase 3 只增加 0–2 个代表性官职动作，验证玩法差异而不扩成完整官职动作树。"

patterns-established:
  - "office-tag-driven-task-eligibility: TaskSystem 以 office_tier + unlocked_task_tags + candidate_office_tags 共同决定候选任务。"
  - "hidden-vs-disabled-action-visibility: Phase2ActionCatalog 先过滤 office permission，再对临时阻断填 disabled_reason。"
  - "representative-office-actions: actions.json 与 menu config 只录入少量 office-only 行为，避免范围膨胀。"

requirements-completed: [CARE-01, CARE-02, CARE-05]

# Metrics
duration: 12 min
completed: 2026-04-09
---

# Phase 03 Plan 05: 官职权限与来源差异 Summary

**升官后的官职标签现在会真实改变下一月任务候选与动作可见性，且行动菜单已按“无权限隐藏 / 临时受阻禁用”新口径运行。**

## Performance

- **Duration:** 12 min
- **Started:** 2026-04-09T12:24:26.1228422+08:00
- **Completed:** 2026-04-09T12:24:26.1228422+08:00
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- 扩展 `OfficeData.gd` / `offices.json` 的 Phase 3 官职后果字段，并让 `TaskSystem.gd` 实际消费这些字段改变候选任务范围。
- 将 `task_pool_xunyu_early_career.tres` 扩到 `office_tier=2` 且保留 `ensure_diversity` 来源混合，修复了 02.1 中“升官后新月任务池为空”的断链。
- 为 `review_memorials` / `inspect_subordinates` 建立代表性 office-only 动作，并让 `Phase2ActionCatalog.gd` 明确区分隐藏与禁用两类状态。
- 用 `phase3_office_permission_regression.gd` 证明升官前看不到动作、升官后可见但受上下文限制时会给出禁用原因，同时新月候选会出现人员类任务。

## Task Commits

Each task was committed atomically:

1. **Task 1: Make office definitions change next-month source access and candidate scope** - `ff61056`, `3882100` (feat)
2. **Task 2: Enforce office-aware action visibility and representative office-only actions** - `43742d5` (feat)

**Plan metadata:** Pending final docs commit

## Files Created/Modified
- `three-kingdoms-simulator/scripts/data/resources/OfficeData.gd` - Phase 3 官职 consequences / permission 字段。
- `three-kingdoms-simulator/data/generated/190/offices.json` - 四级官职链的 office tags、candidate scope、permission tags。
- `three-kingdoms-simulator/data/generated/190/actions.json` - representative office-only actions。
- `three-kingdoms-simulator/data/config/phase2_action_menu_config.tres` - office restriction 与 disabled reason 配置。
- `three-kingdoms-simulator/data/task_rules/task_pool_xunyu_early_career.tres` - 升官后仍可生成多来源候选任务。
- `three-kingdoms-simulator/scripts/systems/TaskSystem.gd` - office-aware 任务筛选。
- `three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd` - hidden vs disabled 行为实现。
- `three-kingdoms-simulator/scripts/tests/phase3_office_permission_regression.gd` - 官职权限回归。

## Decisions Made
- 把 CARE-05 的“官职变化”落在任务来源与动作权限两处最小但可验证的后果上，而不扩张为完整官职玩法树。
- 用 `required_office_tags` / `office_restrictions` 表达永久权限门槛，继续让临时阻断原因走 disabled-state 文案。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 03-06 与 03-07 已可直接依赖官职权限差异和升官后新月候选变化，CARE-05 不再只是文案升级。
- `phase3_office_permission_regression.gd` 为后续政治 UI 与月末闭环提供了稳定的 office-aware 行为基线。

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-09*
