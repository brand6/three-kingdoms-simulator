---
phase: 03-仕途、势力与可解释政治
verified: 2026-04-09T04:36:06.9344540Z
status: gaps_found
score: 3/4 must-haves verified
gaps:
  - truth: "Player can inspect the current faction's ruler, cities, major officers, resources, and broad strategic posture."
    status: failed
    reason: "Faction data, query code, and UI expose ruler/cities/officers/resources/blocs, but no strategic-posture field is defined, loaded, or rendered."
    artifacts:
      - path: "three-kingdoms-simulator/scripts/data/definitions/FactionDefinition.gd"
        issue: "No typed strategic posture field exists."
      - path: "three-kingdoms-simulator/data/generated/190/factions.json"
        issue: "Faction samples contain resources and political_resource_summary only; no posture value."
      - path: "three-kingdoms-simulator/scripts/systems/FactionSystem.gd"
        issue: "get_faction_overview() does not return any posture field."
      - path: "three-kingdoms-simulator/scripts/ui/FactionPanel.gd"
        issue: "Faction popup renders player position, blocs, ruler, cities, and resources, but not strategic posture."
    missing:
      - "Add a typed faction strategic-posture field to faction definitions and generated data."
      - "Thread posture through DataRepository and FactionSystem.get_faction_overview()."
      - "Render broad strategic posture in FactionPanel so FACT-01 is fully satisfied."
---

# Phase 3: 仕途、势力与可解释政治 Verification Report

**Phase Goal:** 玩家的行动与关系会进入月末仕途结算，形成任务、任命、权限变化和派系博弈的可解释政治循环。
**Verified:** 2026-04-09T04:36:06.9344540Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Player can receive at least two task sources, complete work, and see merit/fame/trust move in response. | ✓ VERIFIED | `TaskSystem.generate_month_candidates()` emits `faction_order` + `relation_request`; `settle_month_task()` writes merit/fame/trust deltas; `phase3_task_source_regression.gd` and `phase21_monthly_career_regression.gd` pass. |
| 2 | Month-end evaluation can produce appointment / rejection / deferred or rivalry-loss outcomes with visible reasons and next-step guidance. | ✓ VERIFIED | `GameRoot._process_month_end_evaluation()` runs qualification → political snapshot → `AppointmentResolver.evaluate_month_end()` → `MonthlyEvaluationResult.create(...)`; `phase3_appointment_resolver_regression.gd` and `phase3_end_to_end_regression.gd` pass. |
| 3 | Office changes alter later permissions, action options, and political standing without changing the single-character loop. | ✓ VERIFIED | `GameRoot` rewrites office tags/permissions on promotion; `Phase2ActionCatalog` hides office-forbidden actions and disables temporarily blocked ones; `phase3_office_permission_regression.gd` passes. |
| 4 | Player can inspect faction leadership, cities, major officers, resources, internal groups, and broad strategic posture. | ✗ FAILED | `FactionPanel` and `FactionSystem` cover leadership/cities/officers/resources/blocs, but no strategic-posture field exists in `FactionDefinition.gd`, `factions.json`, `FactionSystem.gd`, or `FactionPanel.gd`. |

**Score:** 3/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `three-kingdoms-simulator/scripts/systems/TaskSystem.gd` | Source-diverse monthly candidates and frozen task-source snapshots | ✓ VERIFIED | Exists, substantive, wired to `MonthlyTaskState`, and backed by generated task data. |
| `three-kingdoms-simulator/scripts/runtime/MonthlyTaskState.gd` | Frozen month-task political source snapshot | ✓ VERIFIED | Stores source type, institution, requester, bloc, and political tags; populated by `freeze_source_snapshot()`. |
| `three-kingdoms-simulator/scripts/systems/PoliticalSystem.gd` | Shared political snapshot aggregation | ✓ VERIFIED | Aggregates relations, task source, bloc attitudes, blockers, and opportunities into `PoliticalSupportSnapshot`. |
| `three-kingdoms-simulator/scripts/systems/AppointmentResolver.gd` | Explainable appointment competition and reason tree | ✓ VERIFIED | Produces candidate evaluations, verdict, support/blocker summaries, and next hint. |
| `three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd` | Office-aware hidden vs disabled actions | ✓ VERIFIED | Filters office-forbidden actions out and preserves disabled reasons for temporary blockers. |
| `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd` | Readable task cards with institution/requester split | ✓ VERIFIED | Renders source institution, requester, rewards, and opportunity/risk tags; gated confirm flow passes regression. |
| `three-kingdoms-simulator/scripts/ui/FactionPanel.gd` | Faction political overview popup | ⚠️ PARTIAL | Wired and data-backed, but omits broad strategic posture required by FACT-01. |
| `three-kingdoms-simulator/scripts/runtime/MonthlyEvaluationResult.gd` | Shared month-end result payload for report + promotion popup | ✓ VERIFIED | Carries appointment result, support/blocker lines, candidate evaluations, and next-month hint. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `DataRepository.gd` | `res://data/politics/recommendations`, `.../oppositions`, `.../blocs` | `_load_phase3_political_rules()` + getters | ✓ WIRED | Lines 454-491 load and expose recommendation/opposition/bloc rules. |
| `TaskSystem.gd` | `MonthlyTaskState.gd` | `freeze_source_snapshot()` | ✓ WIRED | `select_month_task()` freezes source type, institution, requester, bloc, and tags into runtime state. |
| `GameRoot.gd` | `PoliticalSystem.gd` + `AppointmentResolver.gd` | month-end pipeline | ✓ WIRED | `_process_month_end_evaluation()` calls `finalize_month_snapshot()` then `evaluate_month_end()`. |
| `Phase2ActionCatalog.gd` | `phase2_action_menu_config.tres` | `required_office_tags` / `disabled_reason` | ✓ WIRED | Menu config is merged into action records, then used for hidden-vs-disabled behavior. |
| `MainScene.tscn` / `MainHUD.gd` | `FactionPanel.gd` | `FactionButton` popup flow | ✓ WIRED | Mounted in scene, enabled in HUD, and verified by `phase3_politics_hud_regression.gd`. |
| `FactionSystem.gd` | `FactionPanel.gd` | faction overview payload | ⚠️ PARTIAL | Leadership/cities/officers/resources/blocs flow through, but no strategic-posture data is exposed. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `TaskSelectPanel.gd` | `_candidates` | `GameRoot.get_pending_month_tasks()` → `TaskSystem.generate_month_candidates()` → `task_templates.json` | Yes — four concrete task samples with institution/requester/tag data | ✓ FLOWING |
| `MainHUD.gd` | political summary dict | `GameRoot.get_hud_political_summary()` → `_current_political_snapshot()` → `PoliticalSystem.build_snapshot()` | Yes — relation/task-driven snapshot values | ✓ FLOWING |
| `MonthReportPanel.gd` | `MonthlyEvaluationResult` | `GameRoot._process_month_end_evaluation()` → `AppointmentResolver.evaluate_month_end()` | Yes — month-end settlement and resolver outputs | ✓ FLOWING |
| `PromotionPopup.gd` | `MonthlyEvaluationResult` | Same month-end payload as month report | Yes — shared payload, not local recomputation | ✓ FLOWING |
| `FactionPanel.gd` | payload overview / bloc rows / resources | `GameRoot.get_faction_overview_payload()` → `FactionSystem` + `factions.json` + bloc `.tres` | Yes, but posture datum is absent upstream | ⚠️ PARTIAL FLOW |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Phase 3 DTO contracts are usable | `Godot --headless --script res://scripts/tests/phase3_contract_regression.gd` | All tests passed | ✓ PASS |
| Task source diversity and frozen source snapshots work | `... phase3_task_source_regression.gd` | Both source types present; snapshot freeze passed | ✓ PASS |
| Political snapshot changes with relation/task facts | `... phase3_political_snapshot_regression.gd` | Snapshot mutation assertions passed | ✓ PASS |
| Appointment resolver handles success / blocked / rivalry-loss | `... phase3_appointment_resolver_regression.gd` | All tests passed | ✓ PASS |
| Office permissions and post-promotion action/task deltas work | `... phase3_office_permission_regression.gd` | All tests passed | ✓ PASS |
| HUD / popup / month-end integration works | `... phase3_politics_hud_regression.gd`, `... phase21_monthly_hud_regression.gd`, `... phase3_end_to_end_regression.gd` | Exit code 0 for all three | ✓ PASS |

### Requirements Coverage

All Phase 3 requirement IDs requested by the user are present in plan frontmatter and in `.planning/REQUIREMENTS.md`. No orphaned requirement IDs were found for this phase set.

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `RELA-04` | `03-01`, `03-03` | Relationship values influence later gameplay outcomes. | ✓ SATISFIED | `PoliticalSystem.build_snapshot()` gates recommenders/opposers on relation trust/favor; `phase3_political_snapshot_regression.gd` proves relation changes alter output. |
| `CARE-01` | `03-02`, `03-05`, `03-07`, `03-08`, `03-10` | At least two task sources exist. | ✓ SATISFIED | `task_pool_xunyu_early_career.tres` requires `faction_order` + `relation_request`; `phase3_task_source_regression.gd` passes. |
| `CARE-02` | `03-02`, `03-05` | Actions/tasks can change merit and fame. | ✓ SATISFIED | `TaskSystem.settle_month_task()` writes merit/fame deltas; `phase21_monthly_career_regression.gd` confirms writeback. |
| `CARE-03` | `03-04`, `03-07` | Month-end evaluation can produce multiple outcome types. | ✓ SATISFIED | `AppointmentResolver` returns `appointed`, `rejected`, `deferred`, `lost_to_rival`; regressions cover success, blocked, and rivalry-loss. |
| `CARE-04` | `03-01`, `03-04`, `03-06`, `03-07` | Month-end results explain main reasons. | ✓ SATISFIED | `MonthlyEvaluationResult` stores support/blocker lines and next hint; month report and promotion popup render them. |
| `CARE-05` | `03-05`, `03-07` | Office changes alter permissions/options/political standing. | ✓ SATISFIED | Promotion rewrites office tags/permissions in `GameRoot`; `Phase2ActionCatalog` and task filtering respond to new office state. |
| `FACT-01` | `03-03`, `03-06`, `03-07`, `03-09` | Player can view ruler, cities, major officers, resources, and broad strategic posture. | ✗ BLOCKED | Ruler/cities/officers/resources exist, but no strategic-posture field is defined or rendered anywhere in the faction data/query/UI chain. |
| `FACT-02` | `03-03`, `03-06`, `03-07` | Faction-level resources are tracked for political/military feedback. | ✓ SATISFIED | `political_resource_summary` exists in `factions.json`, loaded via `FactionDefinition` and shown in `FactionPanel`. |
| `FACT-03` | `03-01`, `03-02`, `03-06`, `03-07`, `03-09` | Player can see main internal groups influencing politics. | ✓ SATISFIED | Bloc `.tres` data, `FactionSystem.get_bloc_rows()`, and `FactionPanel` show support/观望/反对 attitudes. |
| `POLI-01` | `03-01`, `03-03`, `03-06` | Internal political groups have visible stances. | ✓ SATISFIED | `PoliticalSupportSnapshot.bloc_attitudes` plus faction popup output expose bloc stance. |
| `POLI-02` | `03-01`, `03-03`, `03-04` | Political groups support/oppose/neutral on appointments. | ✓ SATISFIED | Bloc scores feed `AppointmentResolver`; opposition/support rules alter recommendation and opposition totals. |
| `POLI-03` | `03-01`, `03-03`, `03-04`, `03-06`, `03-07`, `03-08`, `03-10` | Player-facing feedback identifies political forces behind outcomes. | ✓ SATISFIED | HUD summaries, month report, promotion popup, and faction popup all surface shared recommender/blocker/bloc/resource signals. |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| — | — | No blocker stub/placeholder patterns found in the verified production Phase 3 codepaths. | — | — |
| test runs | — | `phase3_task_source_regression.gd`, `phase3_political_snapshot_regression.gd`, and `phase3_appointment_resolver_regression.gd` emit resource-leak warnings on exit. | ℹ️ Info | Does not block goal verification, but test cleanup could be tightened. |

### Human Verification Required

None beyond the failed automated gap. Visual polish can still be playtested, but the blocking issue here is code-level and programmatically visible.

### Gaps Summary

Phase 3 largely achieves the intended explainable political loop: task-source diversity exists, relations feed political recommendation/opposition, month-end appointment logic is explainable, office changes affect permissions, and the UI reads shared political payloads instead of recomputing them locally.

The remaining blocker is `FACT-01`. The faction overview path stops short of exposing a broad strategic posture. The codebase has no posture field in faction definitions, no loader/query support for it, and no UI rendering for it. Until that missing data path is added, the phase does not fully satisfy all required must-haves and requirement IDs.

---

_Verified: 2026-04-09T04:36:06.9344540Z_
_Verifier: the agent (gsd-verifier)_
