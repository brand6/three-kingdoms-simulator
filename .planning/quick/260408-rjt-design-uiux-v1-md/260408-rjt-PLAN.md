---
mode: quick
plan: 260408-rjt
type: execute
autonomous: true
files_modified:
  - three-kingdoms-simulator/scenes/main/MainScene.tscn
  - three-kingdoms-simulator/scripts/ui/MainHUD.gd
requirements:
  - UI-01
  - UI-02
  - UI-04
must_haves:
  truths:
    - 玩家能在 3 秒内看懂三张中部摘要卡分别在提醒什么变化。
    - 三张卡默认只显示一句动态提醒，只有存在时限、风险或立即可响应牵引时才补第二句。
    - 中部三卡不再重复左栏状态数值和右栏明确任务，而是分别指向关系维护、政治机会和家族牵引。
  artifacts:
    - path: three-kingdoms-simulator/scenes/main/MainScene.tscn
      provides: 三张摘要卡的标题 + 主摘要 + 次摘要节点结构
    - path: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      provides: 三张摘要卡的双层文本绑定、文案规则与运行时刷新逻辑
  key_links:
    - from: three-kingdoms-simulator/scenes/main/MainScene.tscn
      to: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      via: onready node path binding
      pattern: RelationSummaryPrimary|FactionSummaryPrimary|ClanSummaryPrimary
    - from: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      to: GameRoot hud political summary
      via: show_success_state + _refresh_overlay_data
      pattern: get_hud_political_summary|summary_line_primary|summary_line_secondary
---

<objective>
根据 `design/UIUX/中部三摘要修改方案 v1.md` 重写主界面中部三摘要卡的显示结构与文案规则，让它们从“静态说明卡”变成“动态提醒卡”。

Purpose: 提高 HUD 中央区域的扫读效率，并把关系维护、政治机会、家族牵引这三类下一步行动信号明确前置。
Output: 一个更新后的 `MainScene.tscn` 与 `MainHUD.gd`，其中三张摘要卡支持“默认一句、必要时两句”的运行时显示。
</objective>

<execution_context>
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/workflows/execute-plan.md
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/STATE.md
@design/UIUX/中部三摘要修改方案 v1.md
@three-kingdoms-simulator/scenes/main/MainScene.tscn
@three-kingdoms-simulator/scripts/ui/MainHUD.gd
@.planning/quick/260406-ojk-design-v1-md/260406-ojk-SUMMARY.md

<interfaces>
Current center-card bindings:

```gdscript
@onready var _relation_summary_body: Label = get_node("MarginContainer/VBoxContainer/MainContent/CenterSummary/RelationSummaryCard/RelationSummaryContent/RelationSummaryBody")
@onready var _faction_summary_body: Label = get_node("MarginContainer/VBoxContainer/MainContent/CenterSummary/FactionSummaryCard/FactionSummaryContent/FactionSummaryBody")
@onready var _clan_summary_body: Label = get_node("MarginContainer/VBoxContainer/MainContent/CenterSummary/ClanSummaryCard/ClanSummaryContent/ClanSummaryBody")
```

Current summary builders:

```gdscript
func _build_recommender_summary(summary: Dictionary) -> String
func _build_blocker_summary(summary: Dictionary) -> String
func _build_opportunity_summary(summary: Dictionary) -> String
```

Implementation constraints from the design doc and existing HUD pattern:
- 保留三张卡：`关键关系摘要`、`势力 / 派系摘要`、`家族 / 士族摘要`。
- 每张卡只支持两层正文：primary + secondary；secondary 可空。
- 不恢复固定字段式文案（如“若不处理 / 建议行动”），而是在句子里自然表达风险、时限或行动牵引。
- 继续复用 `MainScene + MainHUD + GameRoot` 刷新链路，不新增独立 UI 控制器或切场景流程。
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: 把中部三摘要卡改成 primary/secondary 双层结构</name>
  <files>three-kingdoms-simulator/scenes/main/MainScene.tscn</files>
  <action>仅调整 `CenterSummary` 下三张卡的内容结构：每张卡保留现有标题，但把单个 `*SummaryBody` 文本节点改成两层正文节点（例如 `RelationSummaryPrimary` + `RelationSummarySecondary`，其他两卡同理），用于承载文档 8.1 要求的 `summary_line_primary` / `summary_line_secondary`。primary 默认可见；secondary 允许为空并支持隐藏。不要把卡片改成长列表、可展开说明或多段百科文案；不要改动左栏、右栏和底栏布局。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scenes/main/MainScene.tscn').read_text(encoding='utf-8'); required=['RelationSummaryPrimary','RelationSummarySecondary','FactionSummaryPrimary','FactionSummarySecondary','ClanSummaryPrimary','ClanSummarySecondary']; missing=[s for s in required if s not in t]; assert not missing, missing; forbidden=['RelationSummaryBody','FactionSummaryBody','ClanSummaryBody']; assert all(s not in t for s in forbidden), forbidden"</automated>
  </verify>
  <done>三张摘要卡都具备“标题 + 主摘要 + 次摘要”的稳定节点结构，且场景层已为一行/两行模式留出挂点。</done>
</task>

<task type="auto">
  <name>Task 2: 用动态提醒规则重写三摘要卡的 HUD 绑定与文案生成</name>
  <files>three-kingdoms-simulator/scripts/ui/MainHUD.gd</files>
  <action>同步更新 `@onready` 绑定、loading/success/error/refresh 渲染路径和摘要生成函数，使三卡不再输出“主要推荐人 / 主要阻力 / 当前机会 / 资格短板”这类旧标题式说明，而是直接输出符合设计文档的动态提醒。关系卡聚焦“谁需要维护”；势力卡聚焦“哪里有政治机会或矛盾”；家族卡聚焦“家族/士族最近对你提出什么要求”。实现方式上，为每张卡生成 `primary_text` 与可选 `secondary_text`：默认只给一句主摘要；只有存在明确时限、明显损失或可立即响应时才补第二句，并通过节点可见性控制 secondary。保持现有 `get_hud_political_summary()` 数据入口；若当前数据不足，使用不重复左栏/右栏信息的短句占位文案。不要引入固定字段标签或长段说明书式文本。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scripts/ui/MainHUD.gd').read_text(encoding='utf-8'); required=['_relation_summary_primary','_relation_summary_secondary','_faction_summary_primary','_faction_summary_secondary','_clan_summary_primary','_clan_summary_secondary','summary_line_primary','summary_line_secondary']; missing=[s for s in required if s not in t]; assert not missing, missing; forbidden=['主要推荐人','主要阻力','当前机会 / 资格短板']; assert all(s not in t for s in forbidden), forbidden"</automated>
  </verify>
  <done>运行时三张卡都能按“默认一句、必要时两句”的规则刷新，文案定位明确且不再像静态系统说明。</done>
</task>

</tasks>

<verification>
- 运行两条自动校验，确认场景节点和 HUD 绑定都已切换到双层摘要结构。
- 启动项目后，中部三卡应保持短句扫读体验：默认只有一条主摘要，只有在风险/时限/行动牵引明显时才出现第二句。
</verification>

<success_criteria>
- 三张卡分别稳定表达“谁需要维护 / 哪里有政治机会 / 家族正在提出什么要求”。
- 中部不再出现固定字段式说明文案，也不重复左栏状态和右栏任务细节。
- 现有 MainHUD 刷新链路无须新控制器即可驱动新版三摘要卡显示。
</success_criteria>

<output>
After completion, create `.planning/quick/260408-rjt-design-uiux-v1-md/260408-rjt-SUMMARY.md`
</output>
