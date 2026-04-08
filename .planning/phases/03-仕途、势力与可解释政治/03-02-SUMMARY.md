---
phase: 03-仕途、势力与可解释政治
plan: "02"
subsystem: task-source
tags: [godot, gdscript, task-system, political-source, source-mix]

# Dependency graph
requires:
  - phase: 03-01
    provides: RecommendationRuleData / OppositionRuleData / FactionBlocData Resource 合同、DataRepository 政治规则查询入口
  - phase: 02.1
    provides: TaskTemplateData / TaskPoolRuleData / TaskSystem / MonthlyTaskState 基础结构
provides:
  - TaskTemplateData 9 个政治来源字段（task_source_type / request_character_id / related_bloc_id / political_reward_tags / political_risk_tags / recommendation_hint_tags / opposition_hint_tags / source_summary / source_priority）
  - TaskPoolRuleData 4 个来源混合策略字段（required_source_types / source_mix_policy / related_bloc_bias / fallback_source_types）
  - TaskSystem source-mix 候选生成与来源快照冻结逻辑
  - MonthlyTaskState 6 个来源快照字段 + freeze_source_snapshot() 静态方法
affects: [03-03, 03-04, 03-05, 03-06, 03-07]

# Tech tracking
tech-stack:
  added: []
  patterns: [source-mix-generation, source-snapshot-freeze, ensure-diversity-policy]

key-files:
  created:
    - three-kingdoms-simulator/scripts/tests/phase3_task_source_regression.gd
  modified:
    - three-kingdoms-simulator/scripts/data/resources/TaskTemplateData.gd
    - three-kingdoms-simulator/scripts/data/resources/TaskPoolRuleData.gd
    - three-kingdoms-simulator/data/generated/190/task_templates.json
    - three-kingdoms-simulator/data/task_rules/task_pool_xunyu_early_career.tres
    - three-kingdoms-simulator/scripts/systems/TaskSystem.gd
    - three-kingdoms-simulator/scripts/runtime/MonthlyTaskState.gd
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd

key-decisions:
  - "task_clan_pacify 和 task_recommend_talent 使用 task_source_type: relation_request，各指定 request_character_id"
  - "task_document_cleanup 和 task_grain_audit 保持 task_source_type: faction_order"
  - "source_mix_policy = ensure_diversity：候选集缺少某类来源时从全量模板中补充"
  - "MonthlyTaskState.freeze_source_snapshot() 是静态方法，在 select_month_task 中调用，将候选 payload 中的政治来源字段冻结到运行时状态"
  - "DataRepository._build_generated_task_templates_by_id() 扩展加载 Phase 3 JSON 字段，保持单一数据源"

patterns-established:
  - "source-mix-generation: _apply_source_mix() 按 required_source_types 检查候选集覆盖度，缺失时从全量模板补充，按 source_priority 降序排列后裁剪"
  - "source-snapshot-freeze: 选中任务时通过 freeze_source_snapshot() 将 payload 中的政治来源字段一次性写入 MonthlyTaskState，月末结算读快照而非回查模板"
  - "ensure-diversity-policy: TaskPoolRuleData 的 source_mix_policy 控制候选生成策略，ensure_diversity 保证至少每种 required_source_type 出现一条"

requirements-completed: [CARE-01, CARE-02, FACT-03]

# Metrics
duration: 40min
completed: 2026-04-08
---

# Plan 03-02: 任务来源扩展 Summary

**将月任务来源从上级指派扩展到至少两类可解释政治来源，并把来源事实冻结到月任务快照供月末解释复用。**

## Performance

- **Duration:** ~40 min
- **Started:** 2026-04-08T07:15:00Z
- **Completed:** 2026-04-08T07:55:00Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- 扩展 TaskTemplateData 添加 9 个 Phase 3 政治来源字段，覆盖来源类型、请求人、关联派系、政治标签与来源摘要
- 扩展 TaskPoolRuleData 添加 4 个来源混合策略字段，支持 ensure_diversity 策略保证候选集来源多样性
- 更新 task_templates.json 中全部 4 个任务样本，2 个 faction_order + 2 个 relation_request，各带具体请求人和政治标签
- 更新 task_pool_xunyu_early_career.tres 添加 ensure_diversity 策略配置
- 扩展 TaskSystem 实现 _candidate_payload 政治字段输出、_apply_source_mix 来源混合、select_month_task 快照冻结
- 扩展 MonthlyTaskState 添加 6 个来源快照字段和 freeze_source_snapshot() 静态方法
- 扩展 DataRepository 加载 Phase 3 JSON 字段到 TaskTemplateData
- 创建 phase3_task_source_regression.gd 回归测试（3 个测试函数，全部通过）

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend task definitions with political source fields and deterministic source-mix rules** - `26daebd` (feat)
2. **Task 2: Generate source-aware month candidates and persist accepted source snapshots** - `3882100` (feat)

**Plan metadata:** (this commit) (docs: complete plan 03-02)

## Files Created/Modified
- `scripts/data/resources/TaskTemplateData.gd` - 添加 9 个 Phase 3 政治来源 @export 字段
- `scripts/data/resources/TaskPoolRuleData.gd` - 添加 4 个来源混合策略 @export 字段
- `data/generated/190/task_templates.json` - 4 个任务全部带政治来源字段（2 faction_order + 2 relation_request）
- `data/task_rules/task_pool_xunyu_early_career.tres` - 添加 ensure_diversity 策略
- `scripts/systems/TaskSystem.gd` - 扩展 _candidate_payload、_apply_source_mix、select_month_task 冻结快照
- `scripts/runtime/MonthlyTaskState.gd` - 添加 6 个来源快照字段 + freeze_source_snapshot() 方法
- `scripts/autoload/DataRepository.gd` - _build_generated_task_templates_by_id 加载 Phase 3 字段
- `scripts/tests/phase3_task_source_regression.gd` - 3 个回归测试函数

## Decisions Made
- 两类 relation_request 任务分别指定不同的 request_character_id（chen_gong、xun_you），体现"谁递来的"
- source_mix_policy 使用字符串枚举而非 Godot enum，保持 .tres 可读性
- freeze_source_snapshot() 设计为 MonthlyTaskState 的静态方法而非 TaskSystem 实例方法，保持 DTO 自包含
- DataRepository 仍保持单一仓库模式，Phase 3 字段为 additive 扩展

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Godot headless 类型推断问题：测试脚本中 `var session := repo.bootstrap_session(...)` 触发 "Cannot infer the type" 解析错误，需显式标注 `var session: GameSession = repo.bootstrap_session(...)` 解决。

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 03-03（推荐/反对累积）可以直接消费 MonthlyTaskState 的 task_source_type / political_reward_tags / recommendation_hint_tags 来驱动推荐/反对累积
- 03-04（任命竞争解释）可以直接消费冻结的 source_summary 和 related_bloc_id 来生成任命原因行
- 03-05（官职权限后果）可以读取当前官职对应的权限，task_source_type 影响权限变化触发
- 03-06（UI）可以直接消费 candidate payload 中的 source_summary、political_reward_tags、political_risk_tags 渲染任务卡

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-08*
