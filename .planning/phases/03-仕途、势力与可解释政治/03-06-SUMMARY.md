---
phase: 03-仕途、势力与可解释政治
plan: "06"
subsystem: politics-ui
tags: [godot, gdscript, ui, hud, popup, explainable]

# Dependency graph
requires:
  - phase: 03-04
    provides: MonthlyEvaluationResult explainable payload / AppointmentResolver
  - phase: 03-05
    provides: office consequence / action permission / task gate consequences
provides:
  - HUD 三张政治摘要卡
  - Faction popup 与 officer drill-down
  - explainable month report / promotion popup UI
  - phase3_politics_hud_regression.gd UI 回归
affects: [03-07, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [shared-political-ui-payload, one-click-faction-popup, month-report-first]

key-files:
  created:
    - three-kingdoms-simulator/scripts/ui/FactionPanel.gd
    - three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd
  modified:
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
    - three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd
    - three-kingdoms-simulator/scripts/ui/MonthReportPanel.gd
    - three-kingdoms-simulator/scripts/ui/PromotionPopup.gd
    - three-kingdoms-simulator/scripts/ui/CharacterProfilePanel.gd
    - three-kingdoms-simulator/scripts/runtime/CharacterProfileViewData.gd
    - three-kingdoms-simulator/scripts/autoload/GameRoot.gd

key-decisions:
  - "HUD 常驻只保留三张政治摘要卡：主要推荐人 / 主要阻力 / 当前机会 / 资格短板。"
  - "FactionButton 保持单击弹 popup，不引入场景切换。"
  - "月报展示完整 explainable 结构；任命弹窗只展示浓缩原因与后果，不重复整份月报。"
  - "TaskSelectPanel 继续保持按钮式任务卡，但移除确认按钮上方的冗余已选说明区域，以保住 Phase 2.1 行为契约。"

patterns-established:
  - "shared-political-ui-payload: HUD / FactionPanel / CharacterProfilePanel / MonthReportPanel / PromotionPopup 全部消费同一份 Phase 3 payload。"
  - "one-click-faction-popup: FactionButton 直接调用 GameRoot 提供的 overview payload 并弹出 PopupPanel。"
  - "month-report-first: 月报先显示 explainable 结论，确认后再进入任命弹窗。"

requirements-completed: [CARE-04, FACT-01, FACT-02, FACT-03, POLI-01, POLI-03]

# Metrics
duration: 1h
completed: 2026-04-08
---

# Plan 03-06: 政治 UI 接线 Summary

**把 Phase 3 的政治状态真正接进 HUD、Faction popup、人物卡、月报与任命弹窗，让 explainable-politics 成为可读 UI。**

## Accomplishments
- 在 `MainScene.tscn` 中挂载 `FactionPanel`，并启用 `FactionButton`。
- 更新 `MainHUD.gd`：
  - 中间列三张摘要卡改为 `主要推荐人 / 主要阻力 / 当前机会 / 资格短板`
  - 接入 `get_hud_political_summary()` 与 `get_faction_overview_payload()`
  - 保持月报先于任命弹窗的 UI 时序
- 新增 `FactionPanel.gd`：
  - 以“玩家位置 → 派系块 → 核心人物与城市 → 资源摘要”顺序展示势力信息
  - 支持 major officer 按钮打开 `CharacterProfilePanel`
- 更新 `TaskSelectPanel.gd`：
  - 任务卡展示来源类型、请求方、关联派系、目标、预计奖励、政治标签
  - 维持确认前禁用 CTA，且不在 CTA 上方重复显示已选任务说明
- 更新 `MonthReportPanel.gd`：
  - 显示结论、2–3 条原因、政治力量、下月建议
- 更新 `PromotionPopup.gd`：
  - 成功时显示官职名、任命缘由、新权限/待遇
  - 失败时显示未获任命、原因、下月建议

## Verification
- `phase3_politics_hud_regression.gd` 已通过。
- `phase21_monthly_hud_regression.gd` 已通过，证明 Phase 3 UI 改造未破坏既有月末时序与任务选择交互。

## Issues Encountered
- Godot 在本仓库启用了“warning treated as error”，需要把 `Variant` 返回的临时变量显式标注为 `Dictionary` / `Array[Dictionary]` 才能通过脚本解析。
- `TaskSelectPanel` 初版仍尝试填充“已选任务预期”文案，导致继承自 Phase 2.1 的 HUD 回归失败，已改为空白隐藏行为。

## Next Phase Readiness
- 03-07 可直接把现有 HUD / month-end UI 作为 acceptance route 的 UI 侧基线。

---
*Phase: 03-仕途、势力与可解释政治*
*Completed: 2026-04-08*
