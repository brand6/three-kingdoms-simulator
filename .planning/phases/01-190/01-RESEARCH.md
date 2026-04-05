# Phase 1 — 190样本数据骨架与单角色入口 - Research

**Completed:** 2026-04-05
**Scope:** Phase 1 planning support

## Research Question

What needs to be true for Phase 1 to establish a durable Godot prototype foundation while honoring the locked decisions in `01-CONTEXT.md`?

## Inputs Reviewed

- `.planning/PROJECT.md`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `.planning/phases/01-190/01-CONTEXT.md`
- `.planning/phases/01-190/01-UI-SPEC.md`
- `design/总纲/GDD 框架 v1.md`
- `design/总纲/项目总设计方案 v1.md`
- `design/原型与实现/Godot 原型开发拆解 v1.md`
- `design/原型与实现/Godot 系统模块拆分清单 v1.md`
- `design/原型与实现/原型任务拆解清单 v1.md`
- `design/数据/Godot 数据结构草案 v1.md`
- `design/UIUX/原型 UI 流程图 v1.md`
- `design/剧情与样本/190 剧本原型人物-势力样本表 v1.md`
- `three-kingdoms-simulator/project.godot`
- Godot 4.6 docs via Context7
- Luban docs via Context7 and upstream README

## Current Repo Reality

- The checked-in Godot project already exists at `three-kingdoms-simulator/`, but it is effectively empty beyond `project.godot` and the default icon.
- No runtime `.gd`, `.tscn`, `.tres`, or sample data assets exist yet.
- The local environment cannot launch Godot from the default path (`C:\Program Files\Godot\Godot.exe` missing), so planning should not assume editor-driven verification during this phase.

## Key Findings

### 1. Phase 1 should plan around the existing subproject, not create a second Godot root

- The repo root is not the Godot root.
- All executable game assets should live under `three-kingdoms-simulator/`.
- Planning should treat `three-kingdoms-simulator/project.godot` as the canonical runtime entrypoint.

### 2. The first stable architecture should be “single MainScene + autoload managers + HUD shell”

This matches:

- project constraints in `.planning/PROJECT.md`
- `Godot 原型开发拆解 v1.md` §4 and §6
- locked decisions D-13 and D-14
- UI contract constraints from `01-UI-SPEC.md`

Recommended Phase 1 runtime anchors:

- `scenes/main/MainScene.tscn`
- `scripts/autoload/GameRoot.gd`
- `scripts/autoload/DataRepository.gd`
- `scripts/autoload/TimeManager.gd`
- `scripts/ui/MainHUD.gd`
- `themes/PrototypeTheme.tres`

### 3. Excel → Luban → JSON is the right Phase 1 data path

This is directly required by D-09, D-10, D-11, D-12.

Useful Luban findings:

- Luban supports Excel-family source files (`csv`, `xls`, `xlsx`, `xlsm`).
- Luban supports JSON export.
- Luban supports Godot code generation, but Phase 1 does not need to depend on generated runtime classes if typed GDScript wrappers are clearer and faster.
- Luban supports validation features such as `ref` and `path`, which is valuable once the sample grows.

Phase 1 recommendation:

- Keep Excel as the authoritative authoring source.
- Commit generated JSON for the smoke sample so the Godot runtime can load deterministic data immediately.
- Use Luban for schema + export workflow now, but keep Godot-side loading thin and dictionary-backed at first.

### 4. Definition/runtime separation must be explicit in file layout

To satisfy `DATA-02` and the state decision in `.planning/STATE.md`:

- Static definitions must be read from `res://data/generated/190/*.json`
- Runtime session state must be held in distinct scripts/objects (for example `GameSession`, `RuntimeCharacterState`)
- No task should mutate source JSON or cache mutable state back into definition objects

### 5. Phase 1 should preserve future identity expansion without exposing it yet

This is the correct interpretation of D-07 and D-08:

- Only one default protagonist path is visible in Phase 1
- The data model should still store identity/permission fields so later phases can vary access by identity
- The plan should avoid separate “君主模式 / 武将模式 / 文臣模式” scene or system branches

### 6. The HUD plan must follow the approved UI contract literally

The Phase 1 HUD is not a debug dump. It must:

- boot straight into the HUD (D-02)
- show the exact always-visible fields from D-05 / CORE-02
- keep future module entry points visible-but-disabled per D-06
- use `Control`/`Container` layout and one `Theme` resource, matching `01-UI-SPEC.md`

### 7. Verification should be file-based in plans, not Godot-launch dependent

Because Godot is not available in the current environment:

- Every plan should include static verification commands using PowerShell text checks
- Do not make Phase 1 success depend on an editor-only click path
- If executors later gain a working Godot CLI, they can add stronger smoke tests during execution, but the plan should still be runnable from repository files alone

## Recommended File Layout For Phase 1

```text
three-kingdoms-simulator/
  project.godot
  scenes/main/MainScene.tscn
  themes/PrototypeTheme.tres
  scripts/
    autoload/
      GameRoot.gd
      DataRepository.gd
      TimeManager.gd
    data/
      JsonDefinitionLoader.gd
      ScenarioRepository.gd
      definitions/
        ScenarioDefinition.gd
        CharacterDefinition.gd
        FactionDefinition.gd
        CityDefinition.gd
    runtime/
      GameSession.gd
      RuntimeCharacterState.gd
    ui/
      MainHUD.gd
  data/generated/190/
    index.json
    scenario_190_smoke.json
    characters.json
    factions.json
    cities.json

data-authoring/
  excel/
    190_smoke_sample.xlsx
  luban/
    defines/
      __root__.xml
      scenario.xml
      character.xml
      faction.xml
      city.xml
    phase1-smoke-manifest.md

tools/luban/
  export_phase1.ps1
  README.md
```

## Concrete Planning Implications

1. Use at least two Wave 1 plans:
   - one for Godot shell / UI skeleton
   - one for Excel + Luban + generated JSON pipeline
2. Put repository/runtime separation in a later dependent plan.
3. Put default protagonist boot + HUD data binding in the final dependent plan.
4. Use concrete IDs in plans so executors do not invent them:
   - `scenario_190_smoke`
   - `cao_cao`
   - `cao_cao_faction`
   - `chenliu`
5. Make every task cite the decision IDs it implements.

## Risks And Pitfalls

- **Do not create a second Godot project at repo root.**
- **Do not skip Excel just because JSON is easier.** D-09/D-10 forbid that.
- **Do not make the HUD a debug-only inspector.** D-04/D-05 forbid that.
- **Do not activate future navigation buttons.** D-06 forbids placeholder pages.
- **Do not encode runtime state inside definition objects.** Violates `DATA-02`.
- **Do not split identity handling into multiple modes.** Violates D-08 / `CHAR-04` intent.

## Planning Recommendation

Create four execute plans:

1. Godot shell + UI contract skeleton
2. Excel/Luban authoring and generated JSON smoke sample
3. Repository contracts + runtime session separation
4. Default protagonist boot + HUD binding

This gives a clean dependency graph: `01 & 02 -> 03 -> 04`.

---

*Research completed for Phase 1 on 2026-04-05*
