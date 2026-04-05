---
mode: quick
plan: 260405-ums
type: execute
autonomous: true
files_modified:
  - three-kingdoms-simulator/scenes/main/MainScene.tscn
  - three-kingdoms-simulator/scripts/ui/MainHUD.gd
  - three-kingdoms-simulator/themes/PrototypeTheme.tres
requirements:
  - CORE-04
  - ACTN-01
  - UI-01
  - UI-02
  - UI-04
must_haves:
  truths:
    - 玩家一眼能看出当前旬状态、所在地点、身份和势力归属。
    - 玩家能从主界面直接识别“先做什么”和“如何结束本旬”。
    - 玩家能在主 HUD 里看到关系、派系、家族/士族的摘要入口，而不是只看到占位说明。
  artifacts:
    - path: three-kingdoms-simulator/scenes/main/MainScene.tscn
      provides: 主 HUD 新布局、决策区、摘要卡和结束本旬按钮
    - path: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      provides: 中文文案绑定、推荐行动文案、摘要卡占位数据
    - path: three-kingdoms-simulator/themes/PrototypeTheme.tres
      provides: 主按钮/结束本旬按钮的强调样式
  key_links:
    - from: three-kingdoms-simulator/scenes/main/MainScene.tscn
      to: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      via: onready node path binding
      pattern: MarginContainer/VBoxContainer
    - from: three-kingdoms-simulator/scenes/main/MainScene.tscn
      to: three-kingdoms-simulator/themes/PrototypeTheme.tres
      via: theme + theme_type_variation
      pattern: theme_type_variation|ExtResource\("1_theme"\)
---

<objective>
把当前主界面从“Phase 1 占位骨架”升级成可服务旬内主循环的原型 HUD，直接落实《主界面 UI 评审与修改建议 v1》中的 P0/P1 改动。

Purpose: 让玩家进入主界面后立刻知道“我是谁、现在该做什么、如何推进本旬”，并提前露出关系/派系/家族这三个项目特色层。
Output: 一个更新后的 MainScene/MainHUD/Theme 组合，含决策区、摘要卡、主行动强调和结束本旬按钮。
</objective>

<execution_context>
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/workflows/execute-plan.md
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/STATE.md
@.planning/ROADMAP.md
@.planning/REQUIREMENTS.md
@.planning/phases/02-旬内行动—关系闭环/02-CONTEXT.md
@.planning/phases/02-旬内行动—关系闭环/02-UI-SPEC.md
@design/主界面 UI 评审与修改建议 v1.md
@three-kingdoms-simulator/scenes/main/MainScene.tscn
@three-kingdoms-simulator/scripts/ui/MainHUD.gd
@three-kingdoms-simulator/themes/PrototypeTheme.tres

<interfaces>
Current scene anchors:

```text
TopBar -> TopBarContent -> TimeLabel / CityLabel / IdentityLabel / FactionLabel / OfficeLabel
MiddleBody -> LeftOverview / CenterSummary / RightContext
BottomBar -> BottomBarContent -> NavigationRow -> ActionButton ... LogButton
```

Current HUD bindings:

```gdscript
func show_loading_state() -> void
func show_success_state(session: GameSession) -> void
func show_error_state(message: String) -> void
func _pair_text(label_text: String, value: Variant) -> String
func _metric_text(label_text: String, runtime_state: RuntimeCharacterState, property_name: StringName) -> String
```

Constraint reminders:
- 继续走 HUD + 面板主循环，不改成地图流（D-01）。
- 必须接在现有 MainScene + MainHUD 骨架上扩展（D-03）。
- 行动入口保持底部主按钮定位，不做整页切换（D-04）。
```
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: 重构主 HUD 布局为“决策区 + 摘要卡 + 旬推进”结构</name>
  <files>three-kingdoms-simulator/scenes/main/MainScene.tscn</files>
  <action>按评审文档的第一轮/第二轮建议重排主界面，但仍保持 HUD + 面板框架不切场景（per D-01, D-03）。把现有中心“190 样本总览”说明区改成“当前决策区”，内容至少容纳推荐行动、当前目标/阶段目标、可接任务、本旬重点；把右栏保留为“当前任务 / 最近事件 / 重要提示”但改成更像可玩反馈区；在中部新增第二行三张摘要卡：关键关系摘要、派系摘要、家族/士族摘要；顶部状态条改为中文分组文案；底部导航保留原六个入口，同时新增高亮的 `结束本旬` 按钮，并让 `行动` 成为明确主入口。不要保留“已进入 190 样本”“后续阶段开放”这类 Phase 1 占位说明作为中心主文案。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scenes/main/MainScene.tscn').read_text(encoding='utf-8'); required=['当前决策区','关键关系摘要','派系摘要','家族/士族摘要','结束本旬','行动']; missing=[s for s in required if s not in t]; assert not missing, missing"</automated>
  </verify>
  <done>主场景不再是样本说明页；玩家在一个屏幕内可见决策区、三类特色摘要和旬推进按钮。</done>
</task>

<task type="auto">
  <name>Task 2: 用主题和按钮变体突出主操作层级</name>
  <files>three-kingdoms-simulator/themes/PrototypeTheme.tres, three-kingdoms-simulator/scenes/main/MainScene.tscn</files>
  <action>基于 02-UI-SPEC 的配色和层级合同，给 `行动` 与 `结束本旬` 提供明确的强调样式：`行动` 使用主强调按钮，`结束本旬` 使用更强但仍符合原型风格的高亮/危险确认样式；普通导航按钮继续维持次级层级。优先通过 Theme type variation 或专用 button style 落地，不要在单个节点上堆大量临时 override。保持 60/30/10 的主题关系和 Phase 1 已建立的统一 Theme 管理方式。</action>
  <verify>
    <automated>python -c "from pathlib import Path; theme=Path(r'three-kingdoms-simulator/themes/PrototypeTheme.tres').read_text(encoding='utf-8'); scene=Path(r'three-kingdoms-simulator/scenes/main/MainScene.tscn').read_text(encoding='utf-8'); assert 'PrimaryButton' in theme and 'DangerButton' in theme and 'theme_type_variation = &\"PrimaryButton\"' in scene and 'theme_type_variation = &\"DangerButton\"' in scene"</automated>
  </verify>
  <done>`行动` 与 `结束本旬` 的视觉优先级明显高于普通导航项，且样式集中在 PrototypeTheme 中维护。</done>
</task>

<task type="auto">
  <name>Task 3: 更新 MainHUD 绑定与占位文案，让主界面直接指导下一步</name>
  <files>three-kingdoms-simulator/scripts/ui/MainHUD.gd</files>
  <action>重写 MainHUD 的文案与节点绑定，让成功态和加载态都符合新版 HUD 结构。顶部改成中文可读组合文案；当前决策区在没有真实行动系统前也要给出稳定的推荐行动/阶段目标/本旬重点；右栏在“暂无任务”时改成 3 条推荐行动，而不是空白；新增关键关系摘要、派系摘要、家族/士族摘要的占位绑定，文案要能体现本项目特色而不是泛化提示。保持现有 autoload-driven 绑定模式，不新增场景切换或独立 UI 控制器（per D-03），并避免提前实现 Phase 3/4 的真实系统逻辑，只提供可验证的 HUD 文案和摘要骨架。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scripts/ui/MainHUD.gd').read_text(encoding='utf-8'); required=['推荐行动','关键关系摘要','派系摘要','家族/士族摘要','结束本旬']; missing=[s for s in required if s not in t]; assert not missing, missing"</automated>
  </verify>
  <done>即使行动系统尚未接通，主 HUD 也能用中文可读文案明确告诉玩家本旬先做什么、哪些政治关系值得关注、如何推进到旬末。</done>
</task>

</tasks>

<verification>
- 运行自动校验命令，确认场景、主题、脚本文案都包含新版 HUD 的关键结构。
- 在 Godot 编辑器中打开 `MainScene.tscn`，确认中部不再显示 Phase 1 样本说明页，且底部存在明显的 `行动` 与 `结束本旬` 双主操作层级。
</verification>

<success_criteria>
- 顶栏、中心区、摘要卡、底部主操作栏都改成服务主循环的中文 HUD。
- 玩家无需额外说明就能识别“先点行动”和“可直接结束本旬”。
- 主界面能直接露出关系/派系/家族三类特色信息摘要，而不是只剩通用数值面板。
</success_criteria>

<output>
After completion, create `.planning/quick/260405-ums-design-ui-v1-md-ui/260405-ums-SUMMARY.md`
</output>
