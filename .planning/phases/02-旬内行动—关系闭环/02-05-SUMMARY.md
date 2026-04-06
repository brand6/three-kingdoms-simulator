---
phase: 02-旬内行动—关系闭环
plan: "05"
subsystem: gameplay
tags: [godot, gdscript, config, action-menu, relationship, dto]
requires:
  - phase: 02-旬内行动—关系闭环
    provides: 已有五行动 resolver、GameRoot 执行接口与 HUD 行动流程骨架。
provides:
  - 配置驱动的五基础行动菜单顺序与身份锁定规则。
  - 通用角色选择行 DTO 与角色信息面板 DTO。
  - GameRoot 通用角色选择/角色详情查询接口与新回归覆盖。
affects: [02-06, 02-07, phase-2-ui, relation-ui]
tech-stack:
  added: []
  patterns: [resource-driven menu rules, reusable selector/profile DTOs, GameRoot aggregated view-data APIs]
key-files:
  created:
    - three-kingdoms-simulator/scripts/runtime/Phase2ActionMenuConfig.gd
    - three-kingdoms-simulator/data/config/phase2_action_menu_config.tres
    - three-kingdoms-simulator/scripts/runtime/CharacterSelectorRow.gd
    - three-kingdoms-simulator/scripts/runtime/CharacterProfileViewData.gd
  modified:
    - three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
    - three-kingdoms-simulator/scripts/autoload/GameRoot.gd
    - three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd
key-decisions:
  - "身份限制动作改为始终可见，但通过配置资源返回禁用原因，而不是在 catalog 中直接隐藏。"
  - "拜访与关系入口共享 CharacterSelectorRow / CharacterProfileViewData 契约，由 GameRoot 统一组装。"
patterns-established:
  - "Menu-config pattern: five base actions are ordered and identity-gated by a Resource instead of script-local hardcoding."
  - "View-data pattern: UI-facing selector/profile payloads are assembled in GameRoot so HUD code consumes stable DTOs."
requirements-completed: [ACTN-02, ACTN-04, RELA-02, UI-04]
duration: 12min
completed: 2026-04-06
---

# Phase 2 Plan 05: Gap-Closure Backend Contracts Summary

**Config-driven action visibility with shared selector/profile DTOs now replaces the old hidden-action path for Phase 2 HUD fixes.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-04-06T12:05:44+08:00
- **Completed:** 2026-04-06T12:16:20+08:00
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Added a resource-backed five-action menu config that preserves the user-required order and returns `当前身份不可执行` instead of hiding locked actions.
- Added reusable `CharacterSelectorRow` and `CharacterProfileViewData` DTOs for the shared visit/relation flows.
- Extended `GameRoot` and the headless resolver regression so selector rows, profile data, and visible-but-disabled inspect behavior are covered automatically.

## Task Commits

1. **Task 1: 写出配置化行动菜单与通用角色浏览契约** - `74d5342` (feat)
2. **Task 2: 用配置替换隐藏规则并暴露通用选择/详情 API** - `74d5342` (feat)

## Files Created/Modified
- `three-kingdoms-simulator/scripts/runtime/Phase2ActionMenuConfig.gd` - Resource contract for menu order, allowed identities, and locked copy.
- `three-kingdoms-simulator/data/config/phase2_action_menu_config.tres` - Five base action rules with user-approved order and inspect lock copy.
- `three-kingdoms-simulator/scripts/runtime/CharacterSelectorRow.gd` - shared selector-row DTO for visit/relation flows.
- `three-kingdoms-simulator/scripts/runtime/CharacterProfileViewData.gd` - character detail DTO for the upcoming profile panel.
- `three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd` - config-driven visibility/ordering with visible disabled reasons.
- `three-kingdoms-simulator/scripts/autoload/GameRoot.gd` - shared selector rows and character profile view-data APIs.
- `three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd` - regression assertions for identity locks, selector rows, and profile payloads.

## Decisions Made
- Used a `.tres` Resource for identity/action rules so future tuning can happen in data rather than script branches.
- Kept selector/profile DTO assembly in `GameRoot` to avoid duplicating relation/faction/city lookup logic in UI scripts.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- PowerShell inline verification needed to be run directly under pwsh syntax instead of nested `pwsh -Command` quoting to avoid parser errors in this shell environment.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 02-06 can now build the shared sortable selector UI directly against stable GameRoot contracts.
- Identity-locked actions are no longer hidden, so the HUD rework can focus on information architecture instead of backend exceptions.

## Self-Check: PASSED
