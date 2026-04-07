---
status: fixing
trigger: "点击"行动"按钮后，面板打开但内容为空。期望显示一级分类列表，点击分类后显示二级分类。"
created: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:10:00Z
---

## Current Focus

hypothesis: (已确认) ActionMenuMargin visible=false 导致空面板
test: 已修复空面板问题；现在实施 UI 改造
expecting: 一级面板只显示6个分类按钮、自适应大小；二级面板独立弹窗、只显示行动名、tooltip 显示描述
next_action: 修改 MainScene.tscn（精简 ActionMenuPopup + 新增 ActionSubMenuPopup）和 MainHUD.gd（重写行动菜单逻辑）

## Symptoms
<!-- Written during gathering, then IMMUTABLE -->

expected: 面板打开后显示行动的一级分类按钮（如"仕途"、"人际"、"修炼"等分类），点击某分类后进入二级分类
actual: 面板打开但完全为空，什么内容都没有（之前曾经有内容，现在消失了；且之前的内容显示项目过多，现在希望只显示一级分类）
errors: |
  W 0:00:00:685   load: res://scenes/main/MainScene.tscn:6 - ext_resource, invalid UID: uid://dl7km7stqvsb1 - using text path instead: res://scripts/ui/CharacterProfilePanel.gd
reproduction: 每次点击"行动"按钮都是空的，100% 复现
started: 不确定，可能是最近某次修改后导致的

## Eliminated
<!-- APPEND only - prevents re-investigating -->

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2026-04-07T00:01:00Z
  checked: MainScene.tscn line 326
  found: ActionMenuMargin (MarginContainer, parent of all action menu content) has `visible = false` explicitly set
  implication: 弹窗打开时，PopupPanel 变为可见，但其子节点 ActionMenuMargin 始终不可见，导致所有内容（CategoryList, ActionList 等）都不渲染在屏幕上

- timestamp: 2026-04-07T00:01:30Z
  checked: MainHUD.gd - _popup_action_menu() and _refresh_action_menu()
  found: 脚本中没有任何地方重新设置 ActionMenuMargin.visible = true；_refresh_action_menu() 只操作 _category_list 和 _action_list 子节点
  implication: visible = false 在场景文件中设置，脚本从未恢复它，导致内容永久不可见

- timestamp: 2026-04-07T00:02:00Z
  checked: Phase2ActionCatalog.gd - get_categories() and _get_menu_rules()
  found: get_categories() 返回硬编码的6个分类（永不为空）；_get_menu_rules() 依赖 phase2_action_menu_config.tres，该文件有5条规则
  implication: 数据层是正常的，分类列表和行动规则都存在；问题纯粹是 UI 可见性问题

- timestamp: 2026-04-07T00:02:30Z
  checked: phase2_action_menu_config.tres 和 Phase2ActionMenuConfig.gd
  found: 配置文件有效，包含5条规则；get_sorted_rules() 方法正确实现
  implication: 数据加载链完整正常，不是数据问题

## Resolution
<!-- OVERWRITE as understanding evolves -->

root_cause: MainScene.tscn 第326行，ActionMenuPopup 的直接子节点 ActionMenuMargin（MarginContainer）被设置了 visible = false。当行动弹窗打开时，PopupPanel 本身变为可见，但其唯一的内容容器始终不可见，导致分类列表、行动列表等所有内容均不渲染。脚本中没有任何地方重新设置该节点为可见。

fix: 从 MainScene.tscn 中移除 ActionMenuMargin 节点上的 `visible = false` 行（恢复为默认的 visible = true）
verification:
files_changed: ["three-kingdoms-simulator/scenes/main/MainScene.tscn"]
