---
status: diagnosed
trigger: "点击“关系”按钮后，应在主界面内打开关系查看面板；面板中应能看到至少一部分当前人物关系信息或摘要，例如对象、好感/信任/戒备等上下文，而不是空白占位。实际表现为打开通用目标选择界面并在选中角色后打开角色信息面板。"
created: 2026-04-06T12:00:00+08:00
updated: 2026-04-06T12:18:00+08:00
---

## Current Focus

hypothesis: 根因已确认：Phase 2 把“关系”入口设计并实现成专用 RelationPopup，而不是通用目标选择器 + 角色信息面板流。
test: 已完成代码、场景、Phase 02 计划与主场景入口交叉核对。
expecting: 代码与计划都应一致指向专用关系弹窗实现，且仓库内不存在角色详情面板/通用选择组件资产。
next_action: return diagnosis

## Symptoms

expected: 点击“关系”按钮后，应在主界面内打开关系查看面板；面板中应能看到至少一部分当前人物关系信息或摘要，例如对象、好感/信任/戒备等上下文，而不是空白占位。
actual: 点击“关系”按钮后，打开通用的目标选择界面；点击对应角色后打开该角色信息面板。
errors: 无显式报错；行为与 UAT 预期不符。
reproduction: Phase 02 UAT test 5；进入主界面后点击“关系”按钮。
started: Phase 02 UAT

## Eliminated

## Evidence

- timestamp: 2026-04-06T12:05:00+08:00
  checked: grep relation/character-detail references in ui scripts
  found: MainHUD.gd 同时包含 RelationButton、RelationPopup、_on_relation_button_pressed、_refresh_relation_popup，也包含 TargetPickerDialog 与目标列表流程。
  implication: 关系查看与目标选择两套 UI 流程共存；需进一步确认“关系”按钮实际连到哪条路径。

- timestamp: 2026-04-06T12:12:00+08:00
  checked: complete read of MainHUD.gd, MainScene.tscn, GameRoot.gd, DataRepository.gd, RuntimeRelationState.gd
  found: 当前代码中 RelationButton 在 _ready() 明确连接到 _on_relation_button_pressed()；该函数只调用 _refresh_relation_popup() 并弹出 RelationPopup。RelationPopup 的内容由 get_relation_overview() 返回的 RuntimeRelationState 数据填充，种子数据已在 bootstrap_session() 中写入。
  implication: 若运行的是这套代码，点击“关系”应直接看到关系总览且不会走 TargetPickerDialog；当前仓库代码与 UAT 报告的运行行为不一致。

- timestamp: 2026-04-06T12:18:00+08:00
  checked: project.godot entrypoint + repo-wide scene/script search + Phase 02 implementation plan
  found: project.godot 的 run/main_scene 直接指向 scenes/main/MainScene.tscn；该场景只挂载 scripts/ui/MainHUD.gd。02-03-PLAN Task 2 明确要求“Enable RelationButton ... wire RelationButton to open RelationPopup”，仓库中也不存在 CharacterPanel/DetailPanel/通用角色选择组件场景或脚本。
  implication: 这是按旧计划实现的产品/架构偏差，不是某个节点误连；当前实现从设计上就没有“关系按钮 -> 通用目标选择 -> 角色信息面板”的能力。

## Resolution

root_cause: 
Phase 2 的“关系”入口在设计与实现上被硬编码为专用 `RelationPopup` 关系总览弹窗。`RelationButton` 只会打开 `RelationPopup`，而仓库内没有通用角色选择组件或角色详情面板资产；同时 02-03 计划也把这一旧交互写成正式要求。因此当前代码结构天然无法满足 UAT 所要求的“先打开通用目标选择表格，再进入角色信息面板”的关系查看流。
fix: 
verification: 
files_changed: []
