---
mode: quick
plan: 260409-bgu
type: execute
autonomous: true
files_modified:
  - three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd
  - three-kingdoms-simulator/scripts/ui/MainHUD.gd
requirements:
  - UI-02
  - UI-04
must_haves:
  truths:
    - 三张中部摘要卡的主句能直接说清最近最值得注意的人际、势力与家族变化。
    - 只有在预警、机会、危机或明确时限存在时，摘要卡才显示第二句补充文案。
    - 中部三摘要不再出现教程化、字段化或旧版“推荐人/阻力/机会短板”式表达。
  artifacts:
    - path: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      provides: 按文案模板生成 relation/faction/clan 主摘要与可选补充句的规则
    - path: three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd
      provides: 锁定中部三摘要文案风格与双层显示规则的 HUD 回归校验
  key_links:
    - from: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      to: GameRoot.get_hud_political_summary
      via: _render_political_summaries + *_summary_lines builders
      pattern: get_hud_political_summary|summary_line_primary|summary_line_secondary
    - from: three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd
      to: three-kingdoms-simulator/scripts/ui/MainHUD.gd
      via: headless MainScene instantiation and label assertions
      pattern: RelationSummaryPrimary|FactionSummaryPrimary|ClanSummaryPrimary
---

<objective>
根据 `design/UIUX/中部三摘要文案模板 v1.md` 微调中部三摘要的运行时文案生成，让三张卡更接近模板里的历史模拟语气与“一句主摘要优先”的表达。

Purpose: 让玩家扫一眼就知道“谁在变冷/哪股风向在变/家族在施加什么牵引”，同时避免摘要退回教程提示或字段说明。
Output: 一个更新后的 `MainHUD.gd` 文案生成规则，以及一个锁定文风与显示规则的 HUD 回归脚本。
</objective>

<execution_context>
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/workflows/execute-plan.md
@D:/Projects/Godot/三国模拟器/.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@design/UIUX/中部三摘要文案模板 v1.md
@three-kingdoms-simulator/scripts/ui/MainHUD.gd
@.planning/quick/260408-rjt-design-uiux-v1-md/260408-rjt-SUMMARY.md

<interfaces>
Current summary rendering contract in `MainHUD.gd`:

```gdscript
func _render_political_summaries(summary: Dictionary) -> void:
	_apply_summary_lines(_relation_summary_primary, _relation_summary_secondary, _build_relation_summary_lines(summary))
	_apply_summary_lines(_faction_summary_primary, _faction_summary_secondary, _build_faction_summary_lines(summary))
	_apply_summary_lines(_clan_summary_primary, _clan_summary_secondary, _build_clan_summary_lines(summary))

func _make_summary_lines(primary_text: String, secondary_text: String = "") -> Dictionary
func _build_relation_summary_lines(summary: Dictionary) -> Dictionary
func _build_faction_summary_lines(summary: Dictionary) -> Dictionary
func _build_clan_summary_lines(summary: Dictionary) -> Dictionary
```

Template constraints to preserve:
- 主摘要必有，补充句只在预警/机会/危机/时限场景出现。
- 不写成“当前变化：/建议行动：”这种字段式说明。
- 不写明显教程口吻，不反复使用“建议你……”。
- 不改 GameRoot 数据入口，不扩散到其他 UI 面板或系统。
</interfaces>
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: 先补一条锁定摘要文风的 HUD 回归</name>
  <files>three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd</files>
  <behavior>
    - Test 1: 三张卡读取 `RelationSummaryPrimary/FactionSummaryPrimary/ClanSummaryPrimary`，不再依赖旧的 `*_summary_body` 节点。
    - Test 2: 主摘要不包含“主要推荐人 / 主要阻力 / 当前机会 / 资格短板 / 建议你 / 当前变化”这类旧字段或教程化表达。
    - Test 3: 次摘要仅在非空时显示，且用于时限、风险或机会补充，不要求三张卡永远都有第二句。
  </behavior>
  <action>更新现有 `phase3_politics_hud_regression.gd`，让它围绕本 quick task 的真实目标校验中部三摘要文案：实例化 `MainScene` 后直接读取三张卡的 primary/secondary 标签，断言主句存在且为短句式提醒；断言不会出现模板文档第 9 节明确禁止的旧式字段词和教程口吻；断言 secondary 的可见性与文本内容是“可选补充句”语义而不是固定第二段。不要把这个回归扩展成整套派系/月报/UI 面板重测，范围只锁 HUD 中部三卡。</action>
  <verify>
    <automated>python -c "from pathlib import Path; t=Path(r'three-kingdoms-simulator/scripts/tests/phase3_politics_hud_regression.gd').read_text(encoding='utf-8'); required=['RelationSummaryPrimary','FactionSummaryPrimary','ClanSummaryPrimary']; missing=[s for s in required if s not in t]; assert not missing, missing; banned=['主要推荐人','主要阻力','当前机会','资格短板']; assert all(s not in t for s in banned), banned"</automated>
  </verify>
  <done>HUD 回归脚本已明确表达新的三摘要文案契约，后续改文案时若退回旧语气会立刻失败。</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: 重写 MainHUD 三摘要生成句式以贴近模板文风</name>
  <files>three-kingdoms-simulator/scripts/ui/MainHUD.gd</files>
  <behavior>
    - Test 1: 关系卡主句优先描述“谁与你来往渐疏/仍愿出面/值得继续维系”，而不是系统字段总结。
    - Test 2: 势力卡主句优先描述“哪项议题正在升温/哪股风向值得留意”，补充句只在风险或机会明显时出现。
    - Test 3: 家族卡避免直接重复右栏任务状态，改为“宗族正在观望/期待/施压”的局势表述。
  </behavior>
  <action>在 `MainHUD.gd` 中仅调整三张摘要卡相关常量、helper 和 builder：参考模板文档第 4-10 节，把当前较直白的“你现在就可……”或偏系统化的句式改成更凝练、叙事化、带局势感的历史模拟表达。优先保留“主句说明正在变化的局势，补句自然嵌入时限/风险/机会”这一骨架；必要时新增局部 helper 来判断 tone 或清洗种子，但不要改 `GameRoot.get_hud_political_summary()` 返回结构，也不要触碰任务栏、月报、FactionPanel 或其他非摘要系统。</action>
  <verify>
    <automated>pwsh -NoProfile -Command "python -c \"from pathlib import Path; t=Path(r'three-kingdoms-simulator/scripts/ui/MainHUD.gd').read_text(encoding='utf-8'); banned=['建议你','当前变化：','建议行动：','主要推荐人','主要阻力','资格短板']; bad=[s for s in banned if s in t]; assert not bad, bad\"; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; & 'D:/Godot/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64_console.exe' --headless --path 'three-kingdoms-simulator' --script 'res://scripts/tests/phase3_politics_hud_regression.gd'"</automated>
  </verify>
  <done>运行时三张卡的主摘要和补充句都更接近模板文风：短、稳、叙事化，且只在必要时出现第二句。</done>
</task>

</tasks>

<verification>
- 先做静态校验，确认回归脚本与 `MainHUD.gd` 都不再包含旧字段式摘要词。
- 再运行 `phase3_politics_hud_regression.gd`，证明中部三卡在 headless 场景下仍能稳定生成符合模板约束的 primary/secondary 文案。
</verification>

<success_criteria>
- 中部三摘要更接近 `中部三摘要文案模板 v1` 的“先写局势，再自然嵌入时限/风险/行动牵引”准则。
- 关系、势力、家族三张卡各自聚焦不同变化，不重复右栏任务文案。
- 本次改动只收敛在摘要文案生成与对应回归，不影响其他 UI 或系统。
</success_criteria>

<output>
After completion, create `.planning/quick/260409-bgu-v1-md/260409-bgu-SUMMARY.md`
</output>
