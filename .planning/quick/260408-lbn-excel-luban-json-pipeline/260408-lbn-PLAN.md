---
mode: quick
plan: 260408-lbn
type: execute
autonomous: true
files_modified:
  - data-authoring/excel/190_smoke_sample.xlsx
  - data-authoring/luban/defines/__root__.xml
  - data-authoring/luban/defines/action.xml
  - data-authoring/luban/defines/task.xml
  - data-authoring/luban/defines/office.xml
  - tools/luban/export_phase1.ps1
  - tools/luban/README.md
  - three-kingdoms-simulator/data/generated/190/index.json
  - three-kingdoms-simulator/data/generated/190/actions.json
  - three-kingdoms-simulator/data/generated/190/task_templates.json
  - three-kingdoms-simulator/data/generated/190/offices.json
  - three-kingdoms-simulator/scripts/data/JsonDefinitionLoader.gd
  - three-kingdoms-simulator/scripts/data/ScenarioRepository.gd
  - three-kingdoms-simulator/scripts/autoload/DataRepository.gd
  - three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
  - three-kingdoms-simulator/scripts/tests/luban_json_pipeline_regression.gd
requirements:
  - DATA-03
  - DATA-04
  - CARE-02
  - CARE-03
must_haves:
  truths:
    - 策划能在现有 `190_smoke_sample.xlsx` 中直接维护最小行动、任务、官职样本，而不是再维护第二套手写运行时源。
    - 运行现有 Luban Phase 1 wrapper 后，`res://data/generated/190/` 会新增 action/task/office JSON，并通过同一个 `index.json` 被运行时发现。
    - 游戏启动后的 `DataRepository` 能从导出的 JSON 读到至少 1 条行动、1 条任务、1 条官职配置，并让现有任务/官职/行动入口使用这些数据而不是只依赖 `.tres`。
  artifacts:
    - path: data-authoring/excel/190_smoke_sample.xlsx
      provides: 行动、任务、官职的 Excel 样本源数据
    - path: data-authoring/luban/defines/__root__.xml
      provides: Action/Task/Office 新表注册与导出入口
    - path: three-kingdoms-simulator/data/generated/190/index.json
      provides: action/task/office JSON 文件映射
    - path: three-kingdoms-simulator/scripts/autoload/DataRepository.gd
      provides: 从生成 JSON 装配行动/任务/官职运行时数据的主入口
  key_links:
    - from: tools/luban/export_phase1.ps1
      to: three-kingdoms-simulator/data/generated/190/*.json
      via: Luban wrapper output tables
      pattern: output:tables|actions.json|task_templates.json|offices.json
    - from: three-kingdoms-simulator/scripts/data/JsonDefinitionLoader.gd
      to: three-kingdoms-simulator/data/generated/190/index.json
      via: dataset file lookup
      pattern: index.json|actions|task_templates|offices
    - from: three-kingdoms-simulator/scripts/autoload/DataRepository.gd
      to: three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
      via: generated action metadata lookup
      pattern: get_action|get_available_phase2_actions|effect_summary
---

<objective>
把“行动 / 任务 / 官职”接到现有 Phase 1 Excel→Luban→JSON 管线，并让 Godot 运行时从生成 JSON 读取这三类最小样本数据。

Purpose: 去掉这三类配置只能手写 `.tres` 的瓶颈，复用已经存在的 Phase 1 数据流，为后续扩量保留同一条数据驱动路径。
Output: 一个单路径的最小可用链路：Excel 样本、Luban 导出、generated JSON、以及 DataRepository/ActionCatalog 运行时读取闭环。
</objective>

<execution_context>
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/workflows/execute-plan.md
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/ROADMAP.md
@.planning/phases/01-190/01-190-02-SUMMARY.md
@Agent.md
@CLAUDE.md
@tools/luban/README.md
@tools/luban/export_phase1.ps1
@data-authoring/luban/defines/__root__.xml
@three-kingdoms-simulator/scripts/data/JsonDefinitionLoader.gd
@three-kingdoms-simulator/scripts/data/ScenarioRepository.gd
@three-kingdoms-simulator/scripts/autoload/DataRepository.gd
@three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
@three-kingdoms-simulator/scripts/systems/TaskSystem.gd

<interfaces>
Current generated dataset contract:

```gdscript
func load_dataset(dataset_id: String) -> Dictionary
# returns keys: scenario, characters, factions, cities
```

Current repository ingestion contract:

```gdscript
func ingest_dataset(dataset: Dictionary) -> void
func get_scenario(id: String) -> ScenarioDefinition
func get_character(id: String) -> CharacterDefinition
func get_faction(id: String) -> FactionDefinition
func get_city(id: String) -> CityDefinition
```

Current runtime split that this task must reduce, not duplicate:

```gdscript
func _load_phase21_resources() -> void:
	_offices_by_id = _load_resources_by_id("res://data/offices")
	_task_templates_by_id = _load_resources_by_id("res://data/tasks")
```

Current task/office consumers that must stay compatible:

```gdscript
@export var id: String = ""
@export var name: String = ""
@export var tier: int = 0
@export var merit_threshold: int = 0

@export var progress_rule_id: String = ""
@export var success_condition: Dictionary = {}
@export var base_rewards: Dictionary = {}
```

Current action metadata is hardcoded in `Phase2ActionCatalog._build_base_specs_by_id()` for `train`, `study`, `rest`, `visit`, `inspect`.
This quick task should externalize only the menu/config metadata needed by the catalog; do not rewrite the existing resolver/effect logic.
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: 把行动/任务/官职样本并入现有 Excel 与 Luban Phase 1 导出链路</name>
  <files>data-authoring/excel/190_smoke_sample.xlsx, data-authoring/luban/defines/__root__.xml, data-authoring/luban/defines/action.xml, data-authoring/luban/defines/task.xml, data-authoring/luban/defines/office.xml, tools/luban/export_phase1.ps1, tools/luban/README.md, three-kingdoms-simulator/data/generated/190/index.json, three-kingdoms-simulator/data/generated/190/actions.json, three-kingdoms-simulator/data/generated/190/task_templates.json, three-kingdoms-simulator/data/generated/190/offices.json</files>
  <action>在现有 `190_smoke_sample.xlsx` 内新增最小可用的 Action / Task / Office 工作表，至少覆盖当前运行时已经真实用到的 `inspect`、`task_document_cleanup`、`office_zhubu` 等样本 ID，并让字段名与现有 `Phase2ActionCatalog`、`TaskTemplateData`、`OfficeData` 的消费字段一一对应。更新 `__root__.xml` 和新增的 per-table define 文件，把这三张表接进同一个 Luban define root；保持 Phase 1 既有 Scenario/Character/Faction/City 仍从同一个 wrapper 导出，不允许另起第二个脚本或第二个 generated 根目录。随后扩展 `export_phase1.ps1` 和 README，让 `--output:tables` 与预期输出明确包含 `actions.json`、`task_templates.json`、`offices.json`，并提交新的 generated JSON 与 `index.json` 映射。不要改成 CSV 直读，不要把 `.tres` 继续作为这三类数据的唯一真源。</action>
  <verify>
    <automated>python -c "from pathlib import Path; root=Path(r'D:/Projects/Godot/三国模拟器'); txt=(root/'tools/luban/export_phase1.ps1').read_text(encoding='utf-8'); assert all(s in txt for s in ['Action','Task','Office']); idx=(root/'three-kingdoms-simulator/data/generated/190/index.json').read_text(encoding='utf-8'); assert all(s in idx for s in ['actions','task_templates','offices']); define=(root/'data-authoring/luban/defines/__root__.xml').read_text(encoding='utf-8'); assert all(s in define for s in ['<table name=\"Action\"','<table name=\"Task\"','<table name=\"Office\"'])"</automated>
  </verify>
  <done>同一个 Excel/Luban/JSON 管线已经能产出 action/task/office 三类 generated JSON，且文件命名与 index 映射稳定可供 Godot 运行时读取。</done>
</task>

<task type="auto">
  <name>Task 2: 扩展 JSON loader 与 DataRepository，让行动/任务/官职改从 generated JSON 装配</name>
  <files>three-kingdoms-simulator/scripts/data/JsonDefinitionLoader.gd, three-kingdoms-simulator/scripts/data/ScenarioRepository.gd, three-kingdoms-simulator/scripts/autoload/DataRepository.gd, three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd</files>
  <action>扩展 `JsonDefinitionLoader.load_dataset()`，在不破坏 Phase 1 既有四表读取的前提下，新增 `actions`、`task_templates`、`offices` 三个 dataset key，并允许 `index.json` 从同一 dataset id 发现这些文件。更新 `ScenarioRepository` 作为统一静态定义缓存，接收并缓存这三类 JSON；`DataRepository` 改为优先从 generated JSON 装配 `OfficeData` / `TaskTemplateData` 兼容对象和 action metadata，而不是继续只扫 `res://data/offices` 与 `res://data/tasks` 目录。为保持最小改动，`TaskPoolRuleData`、`PromotionRuleData`、`CharacterSetupPatchData` 仍可暂时保留 `.tres` 读取；但官职、任务、行动菜单元数据必须走 JSON 主路径。同步让 `Phase2ActionCatalog` 读取 DataRepository 提供的 action metadata 来构建 `train/study/rest/visit/inspect` 菜单规格，保留 resolver 里按 action id 结算的现有逻辑，不要在这个 quick task 里重写行动效果系统。</action>
  <verify>
    <automated>python -c "from pathlib import Path; root=Path(r'D:/Projects/Godot/三国模拟器/three-kingdoms-simulator/scripts'); loader=(root/'data/JsonDefinitionLoader.gd').read_text(encoding='utf-8'); repo=(root/'data/ScenarioRepository.gd').read_text(encoding='utf-8'); datarepo=(root/'autoload/DataRepository.gd').read_text(encoding='utf-8'); catalog=(root/'systems/Phase2ActionCatalog.gd').read_text(encoding='utf-8'); assert all(s in loader for s in ['actions','task_templates','offices']); assert all(s in repo for s in ['action','task_template','office']); assert 'res://data/offices' not in datarepo and 'res://data/tasks' not in datarepo; assert ('get_action' in datarepo or 'action' in datarepo) and ('_data_repository()' in catalog or 'DataRepository' in catalog)"</automated>
  </verify>
  <done>DataRepository 启动后能从 generated JSON 提供任务、官职、行动定义，现有任务系统与行动菜单可继续按原接口工作，但真源已切到导出的 JSON 文件。</done>
</task>

<task type="auto">
  <name>Task 3: 补一个端到端回归，证明导出的 JSON 真正驱动月任务/官职/行动读取</name>
  <files>three-kingdoms-simulator/scripts/tests/luban_json_pipeline_regression.gd</files>
  <action>新增一个 headless regression，直接启动必要 autoload 或主场景引导，验证 `DataRepository.load_phase1_smoke_sample()` 后：1) `get_office('office_zhubu')` 返回从 generated JSON 装配出的对象并带正确名称/层级/阈值；2) `get_task_template('task_document_cleanup')` 返回从 generated JSON 装配出的对象并能被 `TaskSystem.generate_month_candidates()` 选入首月稳定路径；3) `get_available_phase2_actions()` 中 `inspect` 等 action spec 的显示名/AP/效果摘要来自 generated JSON 提供的数据而非 catalog 常量硬编码。测试要明确失败信息，且不依赖手工打开 Godot 编辑器。</action>
  <verify>
    <automated>godot4 --headless --path three-kingdoms-simulator -s res://scripts/tests/luban_json_pipeline_regression.gd</automated>
  </verify>
  <done>存在一个可重复运行的自动回归，能直接证明 authoring/export/runtime-read 三段已经接通，而不是只完成文件落地。</done>
</task>

</tasks>

<verification>
- 先运行 Task 1 的静态校验，确认 Excel/Luban/export/index 四处都已经把 Action/Task/Office 接到同一条导出链路。
- 再运行 headless regression，确认运行时实际从 generated JSON 读到并消费这三类定义。
</verification>

<success_criteria>
- `190_smoke_sample.xlsx` 成为行动/任务/官职的最小作者源，且无第二条平行导出路径。
- `three-kingdoms-simulator/data/generated/190/` 下稳定存在 action/task/office JSON 与 index 映射。
- Godot 运行时能从这些 JSON 读到官职、任务与行动元数据，并通过自动回归证明至少一个真实月任务/官职/行动样本被消费。
</success_criteria>

<output>
After completion, create `.planning/quick/260408-lbn-excel-luban-json-pipeline/260408-lbn-SUMMARY.md`
</output>
