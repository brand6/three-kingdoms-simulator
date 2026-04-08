---
phase: quick
plan: 260408-lbn
subsystem: data-pipeline
tags: [godot, luban, excel, json, datarepository]
requires:
  - phase: 01-190
    provides: phase1 smoke dataset workbook, Luban wrapper, generated dataset loader
provides:
  - action/task/office workbook sheets on the existing Phase 1 authoring source
  - generated action/task/office JSON files mapped through the same index.json dataset
  - DataRepository and Phase2ActionCatalog hydration from generated JSON instead of office/task tres as the primary source
affects: [phase-02.1-career, monthly-task-selection, phase2-action-menu]
tech-stack:
  added: []
  patterns: [single workbook authoring source, generated json as runtime definition source]
key-files:
  created:
    - data-authoring/luban/defines/action.xml
    - data-authoring/luban/defines/task.xml
    - data-authoring/luban/defines/office.xml
    - three-kingdoms-simulator/data/generated/190/actions.json
    - three-kingdoms-simulator/data/generated/190/task_templates.json
    - three-kingdoms-simulator/data/generated/190/offices.json
    - three-kingdoms-simulator/scripts/tests/luban_json_pipeline_regression.gd
  modified:
    - data-authoring/excel/190_smoke_sample.xlsx
    - data-authoring/luban/defines/__root__.xml
    - tools/luban/export_phase1.ps1
    - tools/luban/README.md
    - three-kingdoms-simulator/data/generated/190/index.json
    - three-kingdoms-simulator/scripts/data/JsonDefinitionLoader.gd
    - three-kingdoms-simulator/scripts/data/ScenarioRepository.gd
    - three-kingdoms-simulator/scripts/autoload/DataRepository.gd
    - three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
key-decisions:
  - Keep action/task/office on the existing 190 smoke workbook and Luban wrapper instead of creating a parallel export path.
  - Hydrate OfficeData, TaskTemplateData, and action menu metadata from generated JSON while leaving task pool and promotion rules on existing tres resources.
  - Preserve action resolver behavior and only externalize menu/config metadata for Phase2ActionCatalog.
patterns-established:
  - Generated dataset index entries can grow with new table keys while keeping one dataset id.
  - DataRepository can adapt generated JSON records into existing Resource-shaped runtime objects.
requirements-completed: [DATA-03, DATA-04, CARE-02, CARE-03]
duration: 4 min
completed: 2026-04-08
---

# Quick Task 260408-lbn Summary

**Excel-authored Luban JSON now drives Phase 2.1 action, task, and office definitions through the existing 190 smoke data pipeline.**

## Performance

- **Duration:** 4 min
- **Started:** 2026-04-08T09:27:13+08:00
- **Completed:** 2026-04-08T09:31:32+08:00
- **Tasks:** 3
- **Files modified:** 16

## Accomplishments

- Added `Action`, `Task`, and `Office` sheets to `190_smoke_sample.xlsx` and registered them in the same Luban root and wrapper used by the existing Phase 1 smoke export.
- Published generated `actions.json`, `task_templates.json`, and `offices.json` under `res://data/generated/190/` and exposed them through the shared `index.json` dataset map.
- Switched `DataRepository` and `Phase2ActionCatalog` to read office, task, and action menu definitions from generated JSON, then proved the full path with a headless regression.

## Task Commits

Each task was committed atomically:

1. **Task 1: 把行动/任务/官职样本并入现有 Excel 与 Luban Phase 1 导出链路** - `0acd011` (feat)
2. **Task 2: 扩展 JSON loader 与 DataRepository，让行动/任务/官职改从 generated JSON 装配** - `f4bcbfe` (feat)
3. **Task 3: 补一个端到端回归，证明导出的 JSON 真正驱动月任务/官职/行动读取** - `cae3882` (test)

## Files Created/Modified

- `data-authoring/excel/190_smoke_sample.xlsx` - adds Action/Task/Office authoring sheets in the same workbook.
- `data-authoring/luban/defines/__root__.xml` - registers new tables and includes for the shared Luban root.
- `data-authoring/luban/defines/action.xml` - defines exported action table fields.
- `data-authoring/luban/defines/task.xml` - defines exported task table fields.
- `data-authoring/luban/defines/office.xml` - defines exported office table fields.
- `tools/luban/export_phase1.ps1` - exports Action/Task/Office with the existing smoke wrapper.
- `tools/luban/README.md` - documents the expanded generated dataset contract.
- `three-kingdoms-simulator/data/generated/190/index.json` - maps action/task/office files under the same dataset id.
- `three-kingdoms-simulator/data/generated/190/actions.json` - generated action metadata.
- `three-kingdoms-simulator/data/generated/190/task_templates.json` - generated task template metadata.
- `three-kingdoms-simulator/data/generated/190/offices.json` - generated office metadata.
- `three-kingdoms-simulator/scripts/data/JsonDefinitionLoader.gd` - loads optional action/task/office dataset keys.
- `three-kingdoms-simulator/scripts/data/ScenarioRepository.gd` - caches generated action/task/office records.
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` - adapts generated JSON into runtime office/task objects and action lookups.
- `three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd` - builds action specs from DataRepository JSON metadata.
- `three-kingdoms-simulator/scripts/tests/luban_json_pipeline_regression.gd` - headless regression for workbook → generated JSON → runtime consumption.

## Decisions Made

- Kept workbook authoring, Luban export, generated JSON, and runtime ingestion on one path so planners only maintain one source for smoke-sample action/task/office definitions.
- Continued using existing `.tres` resources only for task pool rules, promotion rules, and setup patches, which minimizes migration risk while moving gameplay-facing definitions to generated JSON.
- Left Phase 2 resolver logic untouched and only externalized menu/config metadata, matching the quick task scope boundary.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Resolved missing `godot4` shell alias by discovering the installed Godot executable path**
- **Found during:** Task 3 (headless regression execution)
- **Issue:** The planned regression command used `godot4`, but this environment only exposed the engine through `D:\Godot\Godot_v4.6.1-stable_mono_win64\Godot_v4.6.1-stable_mono_win64.exe`.
- **Fix:** Located the real executable from the running process and reran the regression headlessly with the explicit path.
- **Files modified:** None
- **Verification:** `D:\Godot\Godot_v4.6.1-stable_mono_win64\Godot_v4.6.1-stable_mono_win64.exe --headless --path three-kingdoms-simulator -s res://scripts/tests/luban_json_pipeline_regression.gd`
- **Committed in:** `cae3882` (task verification only; no code change needed)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** No scope creep. The fix only substituted the executable path needed to run the planned regression.

## Issues Encountered

- The shell environment lacked the `godot4` alias even though Godot 4.6.1 was installed; using the discovered executable path preserved the intended headless verification flow.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Action/task/office smoke data can now scale through the existing Excel → Luban → JSON path without hand-maintaining runtime-only `.tres` definitions for those three categories.
- Future plans can migrate additional gameplay-facing definition types onto the same generated dataset pattern if needed.

## Self-Check: PASSED

- Verified summary target path exists.
- Verified task commits `0acd011`, `f4bcbfe`, and `cae3882` exist in git history.
- Verified the headless regression passed with the installed Godot executable.
