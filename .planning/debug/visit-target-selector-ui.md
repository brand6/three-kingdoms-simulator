---
status: diagnosed
trigger: "Phase 02 UAT test 4: 拜访流程符合，但目标选择界面需要改成可排序的表格形式，并做成可复用组件；仅诊断根因，不修复代码。"
created: 2026-04-06T00:00:00Z
updated: 2026-04-06T00:18:00Z
---

## Current Focus

hypothesis: 已确认根因：当前目标选择 UI 是 Phase 2 为“拜访”单独写死的最小弹窗列表，而不是抽象出的通用角色选择组件；关系查看也单独实现为另一套弹窗，因此无法满足表格化、可排序、可在其他入口复用的 UAT 目标。
test: 已完成代码与场景核对。
expecting: N/A
next_action: 返回根因诊断。

## Symptoms

expected: 选择“拜访”后，应先出现目标选择，而不是直接结算；选定可拜访角色后，会得到一次明确结果反馈。若成功，结果或关系区域应体现与该角色关系的变化；若失败，也应给出非静默提示说明原因或线索。
actual: 流程符合，但界面要修改。目标选择界面需要修改成表格的形式，玩家可以点击不同的属性来排序，类似我发的图片。另外这个目标选择要做成通用的组件，可以在其他地方调用。
errors: Phase 02 UAT test 4 major issue; 目标选择界面不是可排序表格，也不是通用组件。
reproduction: Phase 02 UAT test 4
started: Phase 02 UAT

## Eliminated

## Evidence

- timestamp: 2026-04-06T00:04:00Z
  checked: .planning/debug/knowledge-base.md
  found: 文件不存在，本次没有可直接复用的已知模式。
  implication: 需要直接从当前 Phase 2 HUD 实现定位根因。
- timestamp: 2026-04-06T00:09:00Z
  checked: three-kingdoms-simulator/scenes/main/MainScene.tscn + scripts/ui/MainHUD.gd + .planning/phases/02-旬内行动—关系闭环/02-03-SUMMARY.md
  found: Phase 2 明确采用 MainScene 内 Popup/Dialog 覆层模式；场景里单独定义了 TargetPickerDialog 和 RelationPopup；MainHUD 中 visit 分支调用 _refresh_target_picker() 后直接 popup TargetPickerDialog，关系按钮则调用 _refresh_relation_popup() 后打开 RelationPopup。
  implication: 目标选择与关系查看从架构上就是两套独立 UI，不是同一个可复用选择器，因此无法满足 UAT 要求的“通用组件”。
- timestamp: 2026-04-06T00:13:00Z
  checked: three-kingdoms-simulator/scripts/autoload/GameRoot.gd
  found: GameRoot 只提供 get_available_phase2_actions、get_relation_overview 和 execute_phase2_action；visit 目标来源仅是 _get_visit_targets() 返回的“当前城市其他角色”数组，没有任何面向通用角色筛选、排序或多场景复用的 selector 数据契约。
  implication: 不仅 UI 层是专用实现，连上层接口也只是为 visit/关系总览最小闭环提供数据，说明缺口来自架构未抽象出通用目标选择能力，而非单纯样式未调。
- timestamp: 2026-04-06T00:17:00Z
  checked: three-kingdoms-simulator 全项目 grep + scripts/tests/phase2_xun_loop_regression.gd
  found: 项目内除 MainHUD 的 TargetPickerDialog 外，没有任何 selector/table/sort 相关实现；现有回归测试只验证拜访/行动/旬末流程存在，不验证目标选择是否为表格、是否支持排序、是否可被关系入口复用。
  implication: 当前实现从组件与测试层面都把“能选目标”视为完成标准，遗漏了 UAT 所需的通用表格选择器能力，因此该差距会稳定存在而不是偶发接线错误。
## Resolution

root_cause: 
root_cause: Phase 2 的 HUD 方案和代码只实现了“拜访专用目标弹窗 + 独立关系弹窗”的最小闭环。MainScene 里 `TargetPickerDialog` 与 `RelationPopup` 是两套分离节点；`MainHUD._handle_action_selected()` 仅在 `spec.id == "visit"` 时硬编码打开 `TargetPickerDialog`，而 `_refresh_target_picker()` 只是往 `VBoxContainer` 中动态塞入多行 `Button`。因此当前目标选择器既不是表格结构，也没有列头/排序状态，更没有被抽象成可供关系按钮或其他入口复用的通用组件。
fix: 未执行（诊断模式）
verification: 
files_changed: []
