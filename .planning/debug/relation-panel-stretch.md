---
status: awaiting_human_verify
trigger: "点击"关系"按钮，第一次打开界面显示正常，关闭后再次点击，界面被横向拉伸。"
created: 2026-04-06T11:00:00Z
updated: 2026-04-07T00:00:00Z
---

## Current Focus

hypothesis: 原拉伸 bug 已修复（confirmed）。追加优化：表头 Button 和数据行 Label 均无水平居中设置，文字靠左对齐。
test: 在 _render_headers() 给 Button 加 alignment = HORIZONTAL_ALIGNMENT_CENTER；在 _render_rows() 给 Label 加 horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER + size_flags_horizontal = SIZE_FILL
expecting: 表头列标题和数据单元格文字都水平居中显示
next_action: 应用修改后 human-verify

## Symptoms

expected: 第二次打开的关系界面与第一次完全相同，尺寸和布局不变，无拉伸变形
actual: 整个面板被拉宽（横向拉伸），布局异常
errors: 无任何报错，运行正常，只有视觉异常
reproduction: 1. 启动游戏进入主界面；2. 点击"关系"按钮，界面正常打开；3. 关闭关系界面；4. 再次点击"关系"按钮，界面被横向拉伸
started: 不确定具体起始时间，关系面板相关代码实现后可能一直存在

## Eliminated

- hypothesis: RelationPopup (PopupPanel) 本身尺寸污染
  evidence: MainHUD._on_relation_button_pressed() 实际调用的是 _open_character_selector("relation")，并非直接打开 RelationPopup。关系按钮打开的是 CharacterSelectorDialog，而非 RelationPopup。
  timestamp: 2026-04-06T11:00:00Z

## Evidence

- timestamp: 2026-04-06T11:00:00Z
  checked: MainHUD.gd line 336-338 (_on_relation_button_pressed)
  found: 关系按钮调用 _open_character_selector("relation")，不是直接弹出 RelationPopup
  implication: 问题出在 CharacterSelectorDialog，而非 RelationPopup

- timestamp: 2026-04-06T11:00:00Z
  checked: MainHUD.gd line 503-509 (_open_character_selector)
  found: 每次打开前调用 _character_selector_dialog.reset_size() 然后 popup_centered(Vector2i(880, 420))
  implication: reset_size() 被调用，但若内部子节点宽度超过 880，对话框仍会被撑宽

- timestamp: 2026-04-06T11:00:00Z
  checked: CharacterSelectorDialog.gd line 79-87 (_render_headers)
  found: 每次调用都用 queue_free() 清除旧 Button，然后立即添加新 Button
  implication: queue_free() 是延迟释放，在同一帧内旧节点和新节点共存，HBoxContainer 的最小宽度 = 旧列宽 + 新列宽，撑开容器

- timestamp: 2026-04-06T11:00:00Z
  checked: CharacterSelectorDialog.gd line 156-158 (_apply_column_width)
  found: 每个 Button 和 Label 都通过 custom_minimum_size = Vector2(width, 0) 设置固定最小宽度
  implication: 这些最小宽度不会自动清零，queue_free() 延迟释放时节点的 minimum_size 仍对父容器的 get_minimum_size() 有效

- timestamp: 2026-04-07T00:00:00Z
  checked: CharacterSelectorDialog.gd _render_headers() line 83-88 和 _render_rows() line 107-115
  found: 表头 Button 默认 alignment = HORIZONTAL_ALIGNMENT_LEFT；数据行 Label 无 horizontal_alignment 设置（默认左对齐），且 size_flags_horizontal 未设置 FILL
  implication: 所有列文字靠左，需要加 alignment/horizontal_alignment = CENTER + size_flags_horizontal = FILL

## Resolution

root_cause: CharacterSelectorDialog._render_headers() 使用 queue_free() 清除旧列标题 Button，但 queue_free() 是延迟释放（下一帧才真正移除）。在 configure() → _render() → _render_headers() 的同步调用链中，旧节点仍在 _header_row (HBoxContainer) 内，新节点也被加入，导致该帧内 HBoxContainer 包含双倍数量的固定宽 Button（每列两个），最小宽度翻倍，超过 reset_size() 的目标宽度 880px，撑开整个 ConfirmationDialog。_render_rows() 存在相同问题但因 SIZE_EXPAND_FILL 的行宽自适应，拉伸主要表现在 header row 上。
fix: |
  1. [已验证] queue_free() → free()（第81行、第92行）：修复拉伸问题。
  2. [待验证] 表头 Button 加 alignment = HORIZONTAL_ALIGNMENT_CENTER（第85行）。
  3. [待验证] 数据行 Label 加 horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER（第112行）+ size_flags_horizontal = Control.SIZE_FILL（第113行）。
verification: 拉伸已修复（用户确认）。居中优化待人工验证。
files_changed: [three-kingdoms-simulator/scripts/ui/CharacterSelectorDialog.gd]
