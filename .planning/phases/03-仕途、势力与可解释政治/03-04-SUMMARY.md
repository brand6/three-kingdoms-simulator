---
phase: 03-仕途、势力与可解释政治
plan: "04"
subsystem: appointment-resolver
tags: [godot, gdscript, politics, appointment, explainable]

# Dependency graph
requires:
  - phase: 03-03
    provides: PoliticalSystem / FactionSystem / PoliticalSupportSnapshot 冻结政治快照与势力查询
  - phase: 02.1
    provides: 月末任务结算、CareerSystem 基础升迁规则、MonthlyEvaluationResult 基础结构
provides:
  - AppointmentResolver 五层原因树（qualification / vacancy / recommendation / opposition / competition）
  - MonthlyEvaluationResult explainable payload 扩展字段
  - GameRoot 月末主链接入 finalize_month_snapshot + evaluate_month_end
  - phase3_appointment_resolver_regression.gd 三类任命回归
affects: [03-06, 03-07, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [five-stage-appointment, limited-rival-comparison, shared-month-end-payload]

key-files:
  created:
    - three-kingdoms-simulator/scripts/systems/AppointmentResolver.gd
    - three-kingdoms-simulator/scripts/tests/phase3_appointment_resolver_regression.gd
  modified:
    - three-kingdoms-simulator/scripts/systems/CareerSystem.gd
    - three-kingdoms-simulator/scripts/runtime/MonthlyEvaluationResult.gd
    - three-kingdoms-simulator/scripts/runtime/GameSession.gd
    - three-kingdoms-simulator/scripts/runtime/PlayerCareerState.gd
    - three-kingdoms-simulator/scripts/autoload/GameRoot.gd

key-decisions:
  - "CareerSystem 保留资格判定与官职写回职责；AppointmentResolver 负责 explainable 任命比较与结论组装。"
  - "competition 只比较 1–2 个 AI 候选，不构建全势力排名。"
  - "office_zhubu 保持稳定首月正向路径，不引入 rival 抢位干扰。"
  - "MonthlyEvaluationResult 统一承载月报、任命弹窗与后续 UI 消费字段。"

patterns-established:
  - "five-stage-appointment: 资格 → 空缺 → 推荐 → 反对 → 竞争 的固定解释顺序，headline 取最早阻断层。"
  - "limited-rival-comparison: 只在更高阶职位上引入有限竞争样本，避免原型数据爆炸。"
  - "shared-month-end-payload: GameRoot 只负责编排，所有 explainable payload 由 resolver 产出后统一缓存到 session。"

requirements-completed: [CARE-03, CARE-04, POLI-02, POLI-03]

# Metrics
duration: 1h
completed: 2026-04-08
---

# Plan 03-04: 可解释任命解析 Summary

**把 Phase 2.1 的阈值式升官反馈升级为可解释政治任命流程，让玩家能明确区分没资格、没空缺、没人推、有人压、竞争落败。**

## Accomplishments
- 新增 `AppointmentResolver.gd`，实现五层原因树、有限 rival 比较、top-line decision 与下月建议。
- 扩展 `MonthlyEvaluationResult.gd`，新增 `appointment_result`、`candidate_evaluation_results`、`primary_support_lines`、`primary_blocker_lines`、`missed_opportunity_note`、`next_month_political_hint`、`political_forces_summary` 等字段。
- 更新 `GameRoot._process_month_end_evaluation()`，在月末链路中插入 `PoliticalSystem.finalize_month_snapshot()` 与 `AppointmentResolver.evaluate_month_end()`。
- 保持 `CareerSystem` 的 qualification 责任与官职写回边界，不把所有月末逻辑重新耦死回去。
- 新增 `phase3_appointment_resolver_regression.gd`，覆盖成功任命、最早阻断失败、竞争失利三类真值。

## Verification
- `phase3_appointment_resolver_regression.gd` 已通过。
- 兼容性关键点：首月稳定正向路线仍可从 `office_congshi -> office_zhubu` 成功推进。

## Decisions Made
- 任命成功与否不再由单个 if/else 决定，而由 explainable payload 汇总形成统一 UI 语义。
- 月末 payload 采用 UI 可直接消费的字符串/DTO 混合结构，避免每个面板自行二次推导政治含义。

## Next Phase Readiness
- 03-06 可直接消费 `MonthlyEvaluationResult` 的 explainable 字段驱动月报与任命弹窗。
- 03-07 可基于已有 resolver 稳定地做成功/失败双路径 acceptance 测试。

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-08*
