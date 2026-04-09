---
phase: 03-仕途、势力与可解释政治
plan: "07"
subsystem: acceptance-regression
tags: [godot, gdscript, regression, acceptance, month-loop]

# Dependency graph
requires:
  - phase: 03-04
    provides: explainable appointment backend
  - phase: 03-06
    provides: politics HUD / faction popup / month-end UI wiring
provides:
  - strengthened Phase 2.1 regressions
  - final Phase 3 end-to-end regression
  - acceptance gate for Phase 3 monthly political loop
affects: [Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [inherit-and-strengthen-regression, success-failure-acceptance-route]

key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd
    - three-kingdoms-simulator/scripts/tests/phase21_monthly_career_regression.gd
    - three-kingdoms-simulator/scripts/tests/phase3_end_to_end_regression.gd

key-decisions:
  - "Phase 2.1 回归不替换，只强化。"
  - "端到端 acceptance 仅锁成功/失败真值，不在最终计划中继续调权重。"
  - "UI 一致性与月末顺序由继承回归 + Phase 3 UI 回归共同担保。"

patterns-established:
  - "inherit-and-strengthen-regression: 旧回归继续验证月报先于任命、任务门控与正反馈升官，同时新增 Phase 3 UI/政治断言。"
  - "success-failure-acceptance-route: 新增 focused end-to-end 脚本，分别跑通 deterministic success / failure 路径。"

requirements-completed: [CARE-01, CARE-03, CARE-04, CARE-05, FACT-01, FACT-02, FACT-03, POLI-03]

# Metrics
duration: 45min
completed: 2026-04-08
---

# Plan 03-07: 联调与 acceptance Summary

**完成 Phase 3 的最终联调，锁住可解释政治月循环的成功/失败闭环，并确保 Phase 2.1 的原有顺序与正反馈路径不回归。**

## Accomplishments
- 强化 `phase21_monthly_hud_regression.gd`：
  - 检查 FactionButton 可用
  - 检查任务卡政治来源结构
  - 检查月报 explainable copy 与任命弹窗时序
- 强化 `phase21_monthly_career_regression.gd`：
  - 保持首月稳定正向升官路径
  - 验证升官后的 office consequence tags 与 HUD 官职展示
- 新增 / 完成 `phase3_end_to_end_regression.gd`：
  - 一条 deterministic success route
  - 一条 deterministic failure route
  - 失败路径确认存在 next-month advice line

## Verification
- `phase21_monthly_hud_regression.gd` 已通过。
- `phase21_monthly_career_regression.gd` 已通过。
- `phase3_politics_hud_regression.gd` 已通过。
- `phase3_end_to_end_regression.gd` 已通过。

## Final Acceptance State
- Phase 3 已具备稳定的政治成功路径与政治失败路径。
- HUD、Faction popup、月报、任命弹窗已对同一结果给出一致解释。
- Phase 2.1 的月报先于任命弹窗、任务门控、首月正反馈升官路径均被保住。

## Next Phase Readiness
- Phase 4 可以直接消费 `MonthlyEvaluationResult`、政治摘要与官职后果，不必返工月循环底层。

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-08*
