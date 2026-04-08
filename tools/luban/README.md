# Phase 1 Luban Export

## Source of Truth

- Workbook: `data-authoring/excel/190_smoke_sample.xlsx`
- Define root: `data-authoring/luban/defines/__root__.xml`

## Expected Output Folder

- `three-kingdoms-simulator/data/generated/190/`

## Export Command

Run from repo root:

```powershell
pwsh -File .\tools\luban\export_phase1.ps1
```

## Smoke Sample Target

The wrapper exports the Phase 1 smoke dataset for `scenario_190_smoke` and keeps all currently validated authoring tables on the same workbook → Luban → JSON path:

- `Scenario`
- `Character`
- `Faction`
- `City`
- `Action`
- `Task`
- `Office`

The generated folder should contain:

- `index.json`
- `scenario_190_smoke.json`
- `characters.json`
- `factions.json`
- `cities.json`
- `actions.json`
- `task_templates.json`
- `offices.json`

The runtime expects `index.json` to map all seven tables under the same `scenario_190_smoke` dataset entry so `DataRepository` can discover them together.
