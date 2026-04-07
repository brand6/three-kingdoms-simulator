---
mode: quick
plan: 260406-ojk
type: execute
autonomous: true
files_modified:
  - three-kingdoms-simulator/scenes/main/MainScene.tscn
  - three-kingdoms-simulator/scripts/ui/MainHUD.gd
requirements:
  - CORE-04
  - UI-01
  - UI-02
  - UI-04
must_haves:
  truths:
    - 玩家一眼能看出自己是谁、在哪、属于哪个势力，以及对应的士族/家族身份。
    - 玩家能在窄左栏、中部三摘要、右侧任务/事件列表里快速扫读当前旬的核心政治信息。
    - 主界面整体不滚动，底部主操作栏稳定常驻，且“行动”与“结束本旬”仍是最明确的推进入口。
  artifacts:
    - path: three-kingdoms-simulator/scenes/main/MainScene.tscn
      provides: 符合布局草案 v1 的固定 HUD 结构、内部列表滚动区和底部操作栏
    - path: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      provides: 新节点绑定、短文本摘要、任务/事件列表文案与左栏状态渲染
  key_links:
    - from: three-kingdoms-simulator/scenes/main/MainScene.tscn
      to: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      via: onready node path binding
      pattern: TopBarContent|LeftOverviewContent|TaskList|EventList
    - from: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      to: GameRoot / DataRepository runtime APIs
      via: show_success_state + action result refresh
      pattern: show_success_state|_show_action_result|_show_xun_summary
---

<objective>
根据 `design/主界面改版布局草案 v1.md` 把当前主界面从“可用主 HUD”改成更稳定的长期驻留版主 HUD。

Purpose: 强化主循环操作路径、提高扫读效率，并把政治/家族特色信息前置到主界面。
Output: 一个更新后的 MainScene/MainHUD 组合，落实“窄左栏 + 中部三摘要 + 右侧双列表 + 底部主操作栏”。
</objective>

<execution_context>
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/workflows/execute-plan.md
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/STATE.md
@.planning/ROADMAP.md
@design/主界面改版布局草案 v1.md
@three-kingdoms-simulator/scenes/main/MainScene.tscn
@three-kingdoms-simulator/scripts/ui/MainHUD.gd

<interfaces>
Current HUD script entry points:

```gdscript
func show_loading_state() -> void
func show_success_state(session: GameSession) -> void
func show_error_state(message: String) -> void
func _show_action_result(result: Variant) -> void
func _show_xun_summary(summary: Variant) -> void
```

Current scene bindings that will change:

```text
TopBarContent -> TimeLabel / CityLabel / IdentityLabel / FactionLabel / OfficeLabel
PrimaryRow -> LeftOverview / CenterSummary / RightContext
RightContextContent -> TaskBody / EventBody / NoticeBody
BottomBarContent -> ExplanationLabel / NavigationRow
```

Implementation constraints:
- 继续保持 Phase 2 的 HUD + 面板主循环，不改为地图流或切场景流程。
- 只改主界面结构与 HUD 绑定，不提前实现 Phase 3/4 真实政治系统。
- 任务/事件要列表化，但数据仍来自当前 GameRoot/DataRepository 能提供的内容或稳定占位文案。
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: 将 MainScene 重构为布局草案 v1 的固定 HUD 结构</name>
  <files>three-kingdoms-simulator/scenes/main/MainScene.tscn</files>
  <action>按 `design/主界面改版布局草案 v1.md` 第 3-10 节重排主场景：顶栏保留时间/地点/身份/势力，并新增士族/家族身份字段，把官职从顶栏移到左侧人物栏；左栏收窄到人物状态栏并补上官职、状态标签、健康占位；移除当前整页 `MiddleScroll` 式主内容滚动，改成固定三栏主体；中部改为三个短文本摘要卡（关键关系、势力/派系、家族/士族），不再保留长段“当前决策区”文案块；右栏拆成“当前任务”和“最近事件”两个独立面板，并只允许这两个列表区内部滚动；删除右栏常驻提示区与底栏说明条，让底部只保留导航按钮和 `结束本旬`。不要保留整页滚动、Notice 面板或按钮上方说明文字。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scenes/main/MainScene.tscn').read_text(encoding='utf-8'); required=['士族/家族','关键关系摘要','势力/派系摘要','家族/士族摘要','TaskListScroll','EventListScroll','结束本旬']; missing=[s for s in required if s not in t]; assert not missing, missing; forbidden=['[node name=\"NoticeHeading\"','[node name=\"ExplanationLabel\"']; assert all(s not in t for s in forbidden), forbidden"</automated>
  </verify>
  <done>主场景符合“窄左栏 + 中部三摘要 + 右侧双列表 + 底栏导航”的稳定 HUD 结构，且整页滚动与冗余提示区被移除。</done>
</task>

<task type="auto">
  <name>Task 2: 更新 MainHUD 绑定与文案，让新版结构在运行时可读且可扫读</name>
  <files>three-kingdoms-simulator/scripts/ui/MainHUD.gd</files>
  <action>同步更新 MainHUD 的 `@onready` 路径、加载态/成功态/错误态渲染逻辑和占位文案，使其适配新版场景结构。顶栏输出时间、地点、身份、势力、士族/家族身份；左栏输出姓名、AP、精力、压力、名望、功绩、官职、状态、健康；中部三摘要卡改成 1-3 条短句，不再输出长段决策说明；右栏任务/事件改成列表式文本，空任务状态使用设计稿建议的短引导（如“当前暂无正式任务”与“从行动中选择拜访、巡察或探亲来创造新机会”），不要再保留 `_notice_body` 或 `_explanation_label` 逻辑。保持现有 autoload 驱动与旬末/行动结果回刷流程，不新增独立 UI 控制器。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scripts/ui/MainHUD.gd').read_text(encoding='utf-8'); required=['当前暂无正式任务','关键关系摘要','势力/派系摘要','家族/士族摘要','士族/家族']; missing=[s for s in required if s not in t]; assert not missing, missing; forbidden=['_notice_body','_explanation_label']; assert all(s not in t for s in forbidden), forbidden"</automated>
  </verify>
  <done>新版 HUD 在运行时能稳定渲染紧凑的政治摘要、列表化任务/事件和左栏人物状态，玩家无需额外说明即可理解下一步。</done>
</task>

</tasks>

<verification>
- 运行两个自动校验命令，确认场景结构和脚本绑定都已切换到新版布局。
- 启动项目后，主界面应保持固定页高；只有任务/事件区可滚动，底栏不再有额外说明条。
</verification>

<success_criteria>
- 顶栏、左栏、中部摘要、右栏列表、底栏导航都符合《主界面改版布局草案 v1》的结构意图。
- 玩家一眼能识别人物状态、政治环境、家族背景、当前任务与最近事件。
- 主 HUD 不再被长段说明文案或整页滚动破坏稳定性。
</success_criteria>

<output>
After completion, create `.planning/quick/260406-ojk-design-v1-md/260406-ojk-SUMMARY.md`
</output>
