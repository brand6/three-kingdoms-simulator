---
phase: 03-仕途、势力与可解释政治
plan: "01"
subsystem: politics
tags: [godot, gdscript, resource, dto, explainable-politics]

# Dependency graph
requires:
  - phase: 02.1
    provides: DataRepository 加载管线、MonthlyEvaluationResult DTO 模式、OfficeData/TaskTemplateData Resource 模式
provides:
  - RecommendationRuleData / OppositionRuleData / FactionBlocData 三种政治静态 Resource
  - PoliticalReasonLine / PoliticalSupportSnapshot / AppointmentCandidateEvaluation 三种运行时 DTO
  - DataRepository 政治规则查询入口 (get_recommendation_rules / get_opposition_rules / get_faction_blocs_for_faction)
affects: [03-02, 03-03, 03-04, 03-05, 03-06, 03-07]

# Tech tracking
tech-stack:
  added: []
  patterns: [political-resource-contract, political-dto-refcounted, reason-line-architecture]

key-files:
  created:
    - three-kingdoms-simulator/scripts/data/resources/RecommendationRuleData.gd
    - three-kingdoms-simulator/scripts/data/resources/OppositionRuleData.gd
    - three-kingdoms-simulator/scripts/data/resources/FactionBlocData.gd
    - three-kingdoms-simulator/scripts/runtime/PoliticalReasonLine.gd
    - three-kingdoms-simulator/scripts/runtime/PoliticalSupportSnapshot.gd
    - three-kingdoms-simulator/scripts/runtime/AppointmentCandidateEvaluation.gd
    - three-kingdoms-simulator/scripts/tests/phase3_contract_regression.gd
  modified:
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd

key-decisions:
  - "政治静态规则使用 .tres Resource，与 Phase 2.1 OfficeData/TaskTemplateData 同源模式"
  - "运行时 DTO 使用 RefCounted + static create() 工厂方法，与 MonthlyEvaluationResult 同源模式"
  - "原因行（PoliticalReasonLine）作为可解释政治的唯一原因单位，HUD/月报/任命反馈共用"
  - "DataRepository 保持单一仓库，政治规则为 additive 扩展，不引入第二个 repository"

patterns-established:
  - "political-resource-contract: 政治静态规则（推荐/反对/派系）使用 @export typed Resource，存放在 res://data/politics/ 和 res://data/factions/blocs/"
  - "reason-line-architecture: PoliticalReasonLine 是五层解释树的唯一叶子节点，所有政治解释最终落为 reason_lines 数组"
  - "political-dto-create: RefCounted DTO 使用 static func create(...) 工厂 + to_save_dict() 序列化，与 Phase 2.1 模式一致"

requirements-completed: [RELA-04, CARE-04, FACT-03, POLI-01, POLI-02, POLI-03]

# Metrics
duration: 35min
completed: 2026-04-08
---

# Plan 03-01: 合同冻结 Summary

**冻结 Phase 3 政治静态合同（推荐/反对/派系 Resource）与运行时 DTO（原因行/支持快照/候选评估），建立 DataRepository 政治规则查询入口**

## Performance

- **Duration:** ~35 min
- **Started:** 2026-04-08T06:34:14Z
- **Completed:** 2026-04-08T07:09:00Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- 创建 3 个政治静态 Resource（RecommendationRuleData、OppositionRuleData、FactionBlocData），字段完全对齐 03-RESEARCH 数据合同
- 创建 3 个运行时 DTO（PoliticalReasonLine、PoliticalSupportSnapshot、AppointmentCandidateEvaluation），使用 RefCounted + create() + to_save_dict() 模式
- 扩展 DataRepository 新增政治规则加载与查询方法，保持单一仓库不引入第二来源
- 创建 phase3_contract_regression.gd 回归测试（5 个测试函数），验证 DTO 实例化、字段复制安全性、候选评估原因行过滤

## Task Commits

Each task was committed atomically:

1. **Task 1: Freeze static political rule resources and repository loaders** - `1c5d2c7` (feat)
2. **Task 2: Create core Phase 3 DTOs and contract regression test** - `164cf32` (feat)

**Plan metadata:** (this commit) (docs: complete plan 03-01)

## Files Created/Modified
- `scripts/data/resources/RecommendationRuleData.gd` - 推荐规则 Resource（id、source_type、阈值、support_delta 等）
- `scripts/data/resources/OppositionRuleData.gd` - 反对规则 Resource（id、source_type、阈值、opposition_delta、blocker_tags 等）
- `scripts/data/resources/FactionBlocData.gd` - 派系块 Resource（id、faction_id、bloc_type、core_character_ids、agenda_tags 等）
- `scripts/runtime/PoliticalReasonLine.gd` - 原因行 DTO（reason_type、stage、direction、weight_tier、summary_text 等）
- `scripts/runtime/PoliticalSupportSnapshot.gd` - 政治支持快照 DTO（month_key、recommender/opposer_ids、bloc_attitudes、scores 等）
- `scripts/runtime/AppointmentCandidateEvaluation.gd` - 候选评估 DTO（office_id、scores、reason_lines、final_decision、next_goal_hint）
- `scripts/autoload/DataRepository.gd` - 新增 _load_phase3_political_rules() 和 3 个查询方法
- `scripts/tests/phase3_contract_regression.gd` - 5 个回归测试函数

## Decisions Made
- 政治静态规则沿用 Phase 2.1 的 Resource + DataRepository 模式，保持架构一致性
- 运行时 DTO 沿用 RefCounted + static create() 模式，与 MonthlyEvaluationResult 一致
- PoliticalReasonLine 作为 explainable-politics 的唯一原因单位，后续所有解释层共享此结构
- DataRepository 是唯一的政治规则读取入口，不引入 UI-local cache 或第二仓库

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Godot headless 模式首次运行测试时 class_name 未被识别（global_script_class_cache.cfg 未更新）。通过 `--editor --quit-after 5` 触发编辑器扫描更新缓存后解决。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 03-02（任务来源扩展）可以直接消费 RecommendationRuleData / FactionBlocData 来生成政治类任务
- 03-03（推荐/反对累积）可以直接消费 PoliticalReasonLine + PoliticalSupportSnapshot 来累积月内政治状态
- 03-04（任命竞争解释）可以直接消费 AppointmentCandidateEvaluation 来生成五层解释
- DataRepository 的查询入口已就位，后续计划不需要再猜数据从哪里读

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-08*
