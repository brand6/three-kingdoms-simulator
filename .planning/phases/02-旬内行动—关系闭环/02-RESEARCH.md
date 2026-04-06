# Phase 2: 旬内行动—关系闭环 - Research

**Researched:** 2026-04-06  
**Status:** Complete

## Question

What does the project need to know to plan Phase 2 well, given the locked HUD-first loop, the approved UI contract, and the current Phase 1 Godot codebase?

## Files Read

- `.planning/STATE.md`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/phases/02-旬内行动—关系闭环/02-CONTEXT.md`
- `.planning/phases/02-旬内行动—关系闭环/02-UI-SPEC.md`
- `.planning/phases/01-190/01-190-04-SUMMARY.md`
- `.planning/phases/01-190/01-190-05-SUMMARY.md`
- `design/行动菜单结构设计 v1.md`
- `design/系统设计/核心系统详细设计 v1.md` §§2-3
- `design/原型与实现/原型任务拆解清单 v1.md` T06-T08
- `design/UIUX/原型 UI 流程图 v1.md` §§4-7
- `three-kingdoms-simulator/scenes/main/MainScene.tscn`
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd`
- `three-kingdoms-simulator/scripts/autoload/GameRoot.gd`
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd`
- `three-kingdoms-simulator/scripts/autoload/TimeManager.gd`
- `three-kingdoms-simulator/scripts/runtime/GameSession.gd`
- `three-kingdoms-simulator/scripts/runtime/RuntimeCharacterState.gd`
- `three-kingdoms-simulator/data/generated/190/*.json`
- `three-kingdoms-simulator/themes/PrototypeTheme.tres`

## Locked Decisions To Preserve

- **D-01 / D-03:** Phase 2 must extend the existing `MainScene + MainHUD + GameRoot + DataRepository + TimeManager` stack instead of introducing a new entry flow.
- **D-04 / D-05 / D-06:** The action entry must be a light popup above the bottom `行动` button, with a two-step in-panel flow (`一级分类 -> 二级动作`) and a separate target dialog when needed.
- **D-07:** The category rail must always show `成长 / 关系 / 政务 / 军事 / 家族`.
- **D-08 / D-09 / D-10:** Only five Phase 2 actions ship now: `拜访 / 训练 / 读书 / 巡察 / 休整`, where `inspect` is concretely `巡察`.
- **D-11 / D-12 / D-13:** Permission-locked actions are hidden; condition-locked actions stay visible but disabled with an explicit reason string.

## Current Codebase Reality

### Stable foundation already in place

- `MainHUD.gd` already owns boot, loading, success, and error rendering.
- `GameRoot.gd` already coordinates bootstrap and stores the current `GameSession`.
- `DataRepository.gd` already loads deterministic Phase 1 JSON and bootstraps runtime state without mutating definitions.
- `TimeManager.gd` already owns the visible year/month/xun label state.
- `GameSession.gd` and `RuntimeCharacterState.gd` already establish the runtime-state pattern used by later systems.

### Missing for Phase 2

- No action catalog or action execution service exists.
- No runtime relationship state exists.
- No xun history or xun summary state exists.
- `MainScene.tscn` still has disabled `ActionButton`, `RelationButton`, and `EndTurnButton`.
- No headless test exists for action resolution or multi-xun progression.

## Recommended Architecture

### 1. Keep the Phase 2 loop inside the existing HUD scene

Use Godot `Control` nodes inside `MainScene.tscn`, not scene swaps.

- **Action menu:** `PopupPanel`
- **Target chooser:** `ConfirmationDialog`
- **Action result:** `AcceptDialog`
- **End-xun confirmation:** `ConfirmationDialog`
- **Xun-end summary:** `AcceptDialog` or dedicated summary `PopupPanel`

Why:

- Fits the approved UI contract.
- Keeps top bar and left status visible.
- Matches Godot 4 popup APIs (`popup_centered*`, modal close notifications, explicit close handling).

### 2. Add typed runtime DTOs before wiring UI

The executor will need stable contracts before implementing behavior.

Recommended new runtime files:

- `scripts/runtime/Phase2ActionSpec.gd`
- `scripts/runtime/ActionResolution.gd`
- `scripts/runtime/RuntimeRelationState.gd`
- `scripts/runtime/XunSummaryData.gd`

Recommended responsibility split:

- `DataRepository`: definition lookup and runtime seeding helpers
- `GameSession`: mutable session-owned action history, relation state, summary buffers
- `GameRoot`: high-level orchestration API for HUD calls
- `scripts/systems/*`: pure-ish gameplay logic for action availability and settlement

### 3. Seed directional relationships in runtime state, not in static definitions

Phase 2 needs `RELA-01..03`, but current definition JSON contains no relation dataset.

Best prototype move: seed directional runtime relations during session bootstrap.

Recommended seed table for `cao_cao` visibility:

| Source -> Target | favor | trust | respect | vigilance | obligation | Notes |
|---|---:|---:|---:|---:|---:|---|
| cao_cao -> chen_gong | 44 | 30 | 53 | 18 | 14 | local visit target |
| chen_gong -> cao_cao | 28 | 20 | 46 | 50 | 8 | asymmetric tension |
| cao_cao -> xun_yu | 52 | 48 | 60 | 8 | 22 | remote ally |
| xun_yu -> cao_cao | 58 | 61 | 64 | 6 | 24 | strong support |
| cao_cao -> le_jin | 46 | 44 | 55 | 10 | 18 | same faction military officer |
| le_jin -> cao_cao | 51 | 56 | 63 | 6 | 21 | subordinate trust |
| cao_cao -> yuan_shao | 10 | 6 | 28 | 70 | 0 | hostile rival |
| yuan_shao -> cao_cao | 8 | 4 | 24 | 76 | 0 | hostile rival |

This is small, directional, readable, and enough to power the relation panel plus one local visit target.

### 4. Use a deterministic Phase 2 action catalog, not hand-written UI-only buttons

The five shipped actions should live in one typed catalog with exact metadata so UI and resolver share one source of truth.

Recommended action specs:

| id | label | category | ap | energy | target | permission rule | expected effect |
|---|---|---|---:|---:|---|---|---|
| `train` | 训练 | 成长 | 1 | -10 | none | visible to all Phase 1 identities | `武艺历练 +6，压力 +3，功绩 +1` |
| `study` | 读书 | 成长 | 1 | -8 | none | visible to all | `智略/政务历练 +6，压力 +2，名望 +1` |
| `rest` | 休整 | 成长 | 1 | +20 | none | visible to all | `精力恢复，压力 -12` |
| `visit` | 拜访 | 关系 | 1 | -8 | character | visible to all; target must be in same city and not self | `好感/信任上升，小幅名望变化` |
| `inspect` | 巡察 | 政务 | 1 | -10 | none | only for identities with `inspect` or `lead` permission tag | `功绩 +5，政务历练 +4，压力 +4` |

Recommended disabled reasons when visible-but-blocked:

- `AP 不足`
- `精力不足`
- `当前地点不可执行`
- `暂无可拜访对象`

Recommended hidden case:

- `巡察` hidden entirely when the protagonist lacks `inspect` and `lead` permission tags.

### 5. Failed actions must still produce some feedback

To satisfy `ACTN-05`, execution should not be binary silence.

Recommended prototype failure cases:

- stale `visit` target moved / invalid -> `行动失败` + `压力 +2` + `获得“目标暂不可见”的线索`
- stale city/permission condition for `inspect` -> `行动失败` + explicit reason + no state mutation except optional `压力 +1`

This keeps failure informative without overbuilding probability systems.

## UI Guidance From Docs + Contract

### Godot-specific notes

- `PopupPanel`/`Popup` is invisible until `popup_*` methods are called.
- Modal popup closure is explicit; custom controls can respond to `NOTIFICATION_MODAL_CLOSE`.
- `ButtonGroup` is the cleanest way to keep one selected category in the popup.
- Disabled and focus states should come from `PrototypeTheme.tres`, not per-node ad hoc styling.

### Recommended Phase 2 scene additions

Add these nodes under `MainScene.tscn` instead of replacing the current shell:

- `ActionMenuPopup`
- `TargetPickerDialog`
- `ActionResultDialog`
- `RelationPopup`
- `EndXunDialog`
- `XunSummaryDialog`

Keep `ActionButton`, `RelationButton`, and `EndTurnButton` enabled in Phase 2. Other buttons can remain disabled.

## Testing Strategy

### Required automated coverage

1. **Pure action resolver regression**
   - headless script under `scripts/tests/phase2_action_resolver_test.gd`
   - assert exact AP/energy/stress/fame/merit and relation deltas

2. **HUD multi-xun integration regression**
   - headless script under `scripts/tests/phase2_xun_loop_regression.gd`
   - boot real `MainScene.tscn`
   - perform at least three `结束本旬` transitions
   - assert time rolls `1 -> 2 -> 3 -> next month 1`
   - assert summary dialog text and relation summary text update

### Environment note

The repo already hit a PATH issue with Godot CLI. Use the explicit local binary in verification commands:

`D:/Godot/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64_console.exe`

## Common Pitfalls

- Do **not** mutate static city/faction/character definition objects for Phase 2 gameplay effects.
- Do **not** hide condition failures that should be shown as disabled reasons.
- Do **not** move the player into a separate action scene; the HUD shell is the product decision.
- Do **not** invent a full probability simulator yet; deterministic or lightly conditional results are enough for this phase.
- Do **not** depend on runtime-discovered contracts; define the typed DTOs first.

## Planning Implications

The cleanest phase split is:

1. **Contracts + session storage**
2. **Action catalog + resolver + GameRoot APIs**
3. **HUD action/relation UI wiring**
4. **End-xun flow + summary + regression**

This preserves interface-first sequencing while still allowing backend and UI work to run in parallel after the contracts land.

---

*Phase: 02-旬内行动—关系闭环*  
*Research completed: 2026-04-06*
