---
phase: 03-仕途、势力与可解释政治
plan: "03"
subsystem: politics-aggregation
tags: [godot, gdscript, politics, faction, regression]

# Dependency graph
requires:
  - phase: 03-01
    provides: 推荐 / 反对 / bloc / 快照 DTO 与仓库合同
  - phase: 03-02
    provides: 月任务政治来源字段与冻结来源快照
provides:
  - 最小推荐 / 反对 / bloc 样本集
  - FactionSystem 势力位置 / bloc / 资源摘要查询层
  - PoliticalSystem 月内政治支持快照聚合与关系驱动回归
affects: [03-04, 03-06, 03-07, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [typed-faction-overview-query, relationship-driven-political-snapshot, repository-backed-resource-summary]

key-files:
  created:
    - three-kingdoms-simulator/scripts/systems/FactionSystem.gd
    - three-kingdoms-simulator/scripts/systems/PoliticalSystem.gd
    - three-kingdoms-simulator/scripts/tests/phase3_political_snapshot_regression.gd
  modified:
    - three-kingdoms-simulator/data/politics/recommendations/reco_cao_cao_admin_success.tres
    - three-kingdoms-simulator/data/politics/recommendations/reco_xun_you_relation_request.tres
    - three-kingdoms-simulator/data/politics/oppositions/opp_old_guard_low_trust.tres
    - three-kingdoms-simulator/data/politics/oppositions/opp_frontline_hawk_dispatch_doubt.tres
    - three-kingdoms-simulator/data/factions/blocs/bloc_yingchuan_civil.tres
    - three-kingdoms-simulator/data/factions/blocs/bloc_qiao_old_guard.tres
    - three-kingdoms-simulator/data/factions/blocs/bloc_frontline_hawks.tres
    - three-kingdoms-simulator/scripts/data/definitions/FactionDefinition.gd
    - three-kingdoms-simulator/data/generated/190/factions.json
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd

key-decisions:
  - "Faction 资源摘要通过 DataRepository + FactionSystem 查询层统一暴露，而不是让 UI 或 resolver 直接读取原始 resources 字典。"
  - "PoliticalSystem 成为推荐人 / 反对者 / bloc 态度 / 机会标签的单一结构化事实源。"
  - "Phase 3 的最小政治样本固定为 2 条 recommendation、2 条 opposition、3 个 bloc，保持 deterministic 闭环而不扩内容广度。"

patterns-established:
  - "typed-faction-overview-query: 势力页与任命解释统一走 FactionSystem / DataRepository 的 typed summary 查询。"
  - "relationship-driven-political-snapshot: 关系、任务来源与 trust 变化可直接改变 snapshot 输出，而不依赖月末 UI 流。"
  - "repository-backed-resource-summary: faction political_resource_summary 优先读定义，缺省时由仓库层回退生成分档摘要。"

requirements-completed: [RELA-04, FACT-01, FACT-02, POLI-01, POLI-02, POLI-03]

# Metrics
duration: 16 min
completed: 2026-04-09
---

# Phase 03 Plan 03: 月内政治支持快照 Summary

**月内政治支持现已由 PoliticalSystem 聚合成统一快照，FactionSystem 与最小政治样本集为 HUD、任命解释和势力总览提供了共用的政治事实源。**

## Performance

- **Duration:** 16 min
- **Started:** 2026-04-09T12:24:26.1228422+08:00
- **Completed:** 2026-04-09T12:24:26.1228422+08:00
- **Tasks:** 2
- **Files modified:** 13

## Accomplishments
- 固定了 2 条推荐、2 条反对、3 个 bloc 的最小政治样本，并让 faction 定义具备可复用的政治资源摘要合同。
- 建立 `FactionSystem.gd` 查询层，统一提供玩家位置、bloc 列表、势力总览与资源摘要，避免 UI 直接拼原始数据。
- 建立 `PoliticalSystem.gd` 和 `phase3_political_snapshot_regression.gd`，证明关系 / trust / 任务来源变化会即时改变推荐人、反对者与 bloc 态度输出。
- 补齐 `DataRepository.gd` 的 faction resource summary 查询，使 03-03 的后端合同在 repository 层完整闭环。

## Task Commits

Each task was committed atomically:

1. **Task 1: Author the minimum political sample set and the faction overview contract it depends on** - `1c5d2c7`, `a33cb20` (feat/fix)
2. **Task 2: Implement PoliticalSystem aggregation and prove relationship-driven snapshot shifts** - `43742d5` (feat)

**Plan metadata:** Pending final docs commit

## Files Created/Modified
- `three-kingdoms-simulator/data/politics/recommendations/reco_cao_cao_admin_success.tres` - 曹操正向举荐样本。
- `three-kingdoms-simulator/data/politics/recommendations/reco_xun_you_relation_request.tres` - 关系请求型正向举荐样本。
- `three-kingdoms-simulator/data/politics/oppositions/opp_old_guard_low_trust.tres` - 低 trust 旧吏阻力样本。
- `three-kingdoms-simulator/data/politics/oppositions/opp_frontline_hawk_dispatch_doubt.tres` - 主战派派系阻力样本。
- `three-kingdoms-simulator/data/factions/blocs/*.tres` - 三个最小 bloc 样本。
- `three-kingdoms-simulator/scripts/data/definitions/FactionDefinition.gd` - faction political resource summary 定义字段。
- `three-kingdoms-simulator/data/generated/190/factions.json` - faction 摘要样本数据。
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` - 政治规则加载与 faction resource summary 查询。
- `three-kingdoms-simulator/scripts/systems/FactionSystem.gd` - 势力与 bloc 查询层。
- `three-kingdoms-simulator/scripts/systems/PoliticalSystem.gd` - 月内政治支持快照聚合器。
- `three-kingdoms-simulator/scripts/tests/phase3_political_snapshot_regression.gd` - 关系驱动 snapshot 变化回归。

## Decisions Made
- 让 `DataRepository` 直接提供 faction resource summary 查询，以便 `FactionSystem` 与 `AppointmentResolver` 共用同一条后端路径。
- 将推荐 / 反对 / bloc 态度的解释统一冻结在 `PoliticalSupportSnapshot`，避免 HUD、任命和势力页重复计算政治状态。

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] 补齐 faction 资源摘要的仓库级查询合同**
- **Found during:** Task 1（acceptance contract review）
- **Issue:** `FactionDefinition.gd` 已有 `political_resource_summary` 字段，但 `DataRepository.gd` 未直接暴露对应摘要查询，导致 03-03 的后端合同缺一层统一入口。
- **Fix:** 在 `DataRepository.gd` 中新增 `get_faction_resource_summary()` 与统一的摘要回退分档逻辑。
- **Files modified:** `three-kingdoms-simulator/scripts/autoload/DataRepository.gd`
- **Verification:** `grep` 命中 `political_resource_summary|military_pressure|governance_load|grain_reserve_level|staffing_tension`；Phase 3 回归仍通过。
- **Committed in:** `a33cb20`

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** 仅补齐 03-03 原本声明但缺失的一层 repository 合同，无额外范围膨胀。

## Issues Encountered
- PowerShell 环境缺少 `rg` 可执行文件，执行期改用平台可用的搜索方式完成 acceptance 检查；不影响 Godot 回归结果。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 03-04 / 03-06 / 03-07 已可稳定读取统一的政治快照与 faction 摘要，不必再各自拼装推荐 / 阻力 / bloc 数据。
- `phase3_political_snapshot_regression.gd` 已证明政治支持会随关系变化而变动，为 explainable-politics 的月内感知提供了回归基线。

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-09*
