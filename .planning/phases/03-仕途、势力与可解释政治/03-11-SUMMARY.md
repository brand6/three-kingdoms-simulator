---
phase: 03-仕途、势力与可解释政治
plan: "11"
subsystem: politics-ui
tags: [godot, gdscript, data, popup, regression, gap-closure]

# Dependency graph
requires:
  - phase: 03-09
    provides: opaque faction popup baseline and officer drilldown regression route
provides:
  - 势力战略态势 definition → payload → popup 数据链路
  - FACT-01 broad strategic posture 缺口关闭
  - 战略态势 UI 回归断言
affects: [03-VERIFICATION, Phase-4]

# Tech tracking
tech-stack:
  added: []
  patterns: [typed-faction-posture-field, faction-popup-posture-regression]

key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scripts/data/definitions/FactionDefinition.gd
    - three-kingdoms-simulator/data/generated/190/factions.json
    - three-kingdoms-simulator/scripts/systems/FactionSystem.gd
    - three-kingdoms-simulator/scripts/ui/FactionPanel.gd
    - three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd

key-decisions:
  - "战略态势作为独立 typed faction definition 字段存在，不混入 political_resource_summary。"
  - "继续沿用 FactionButton -> FactionPanel 单场景 popup 路线，只补齐 FACT-01 缺失字段。"

patterns-established:
  - "typed-faction-posture-field: generated faction JSON 通过 FactionDefinition 明确承载宽泛战略态势。"
  - "faction-popup-posture-regression: UI 回归直接断言 popup 展示真实 posture 文案，防止回退到占位文案或丢字段。"

requirements-completed: [FACT-01]

# Metrics
duration: 0 min
completed: 2026-04-09
---

# Phase 03 Plan 11: 势力战略态势缺口关闭 Summary

**补齐了 Phase 3 势力总览 popup 缺失的“战略态势”字段，让 FACT-01 最后一处 blocker 走通真实数据链路并被回归测试锁定。**

## Accomplishments
- 在 `FactionDefinition.gd` 中新增 typed `strategic_posture` 字段，并在 `from_dictionary()` 中加载。
- 为 `factions.json` 三个样本势力补入宽泛战略态势文案：曹操、袁绍、中立地方势力各自拥有真实 posture 值。
- 在 `FactionSystem.get_faction_overview()` 中把 `strategic_posture` 暴露到 overview payload。
- 在 `FactionPanel.gd` 中于“城池”与“资源摘要”之间新增 `战略态势` 行，保持既有 popup 顺序和 officer drilldown 不变。
- 扩展 `phase3_politics_hud_regression.gd`，要求 popup 必须显示 `战略态势：` 且包含曹操样本文案 `东线承压，需稳住兖州与许下通道`。

## Verification
- `Godot_v4.6.1-stable_mono_win64_console.exe --headless --path three-kingdoms-simulator --script res://scripts/tests/phase3_politics_hud_regression.gd`
- 结果：通过。

## Files Created/Modified
- `three-kingdoms-simulator/scripts/data/definitions/FactionDefinition.gd` - 新增 posture typed 字段与加载逻辑。
- `three-kingdoms-simulator/data/generated/190/factions.json` - 为三家样本势力补入战略态势。
- `three-kingdoms-simulator/scripts/systems/FactionSystem.gd` - overview payload 增加 `strategic_posture`。
- `three-kingdoms-simulator/scripts/ui/FactionPanel.gd` - popup 正文新增战略态势展示行。
- `three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd` - 锁定 posture 文案真实渲染。

## Decisions Made
- 不新增新缓存或额外 UI 页面；继续使用现有 `overview` payload 驱动 popup。
- posture 保持为独立概念，避免与资源摘要语义混杂。

## Deviations from Plan

None - plan executed directly as specified.

## Next Phase Readiness
- Phase 3 的 `FactionPanel` 现已覆盖 ruler / cities / major officers / resources / blocs / strategic posture 全量信息。
- 可重新执行 Phase 3 verification / gaps-only 流程，确认 `FACT-01` blocker 已关闭。
