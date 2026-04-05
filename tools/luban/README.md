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

The wrapper exports the Phase 1 dataset for `scenario_190_smoke` and the four core object tables only:

- `Scenario`
- `Character`
- `Faction`
- `City`

The generated folder should contain:

- `index.json`
- `scenario_190_smoke.json`
- `characters.json`
- `factions.json`
- `cities.json`
