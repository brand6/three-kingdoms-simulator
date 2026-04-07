---
status: awaiting_human_verify
trigger: "任务领取（TaskSelectPanel）弹窗太窄，宽度与其他面板不一致，导致文字把面板纵向拉得很长而不是横向展开"
created: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:00:00Z
---

## Current Focus

hypothesis: _refresh_popup_layout() 在 popup_centered(size) 时 size 已经被 reset_size() 收缩为内容最小尺寸，导致宽度远小于期望的 720px
test: 对比 show_task_picker() 的 popup_centered(Vector2i(720, 520)) 和 _refresh_popup_layout() 的 popup_centered(size)
expecting: _refresh_popup_layout() 中 size 在 reset_size() 后是由内容决定的最小尺寸，而不是 720px，所以弹窗变窄
next_action: 确认 root cause，修复 _refresh_popup_layout() 使其保留原始宽度设定

## Symptoms

expected: 弹窗宽度应与其他面板（关系面板、行动面板等）保持一致，能横向完整显示任务名称和描述
actual: 弹窗很窄，文字无法横向展开，面板被纵向拉得很长
errors: 无运行时错误，纯 UI 布局问题
reproduction: 进入游戏 -> 月初出现任务选择弹窗 -> 弹窗宽度明显窄于其他面板
started: 用户刚发现，不确定何时引入

## Eliminated

(none yet)

## Evidence

- timestamp: 2026-04-07T00:00:00Z
  checked: TaskSelectPanel.gd - show_task_picker()
  found: 调用 popup_centered(Vector2i(720, 520)) 设置了 720px 宽度
  implication: 初次弹出时宽度是正确的 720px

- timestamp: 2026-04-07T00:00:00Z
  checked: TaskSelectPanel.gd - _refresh_popup_layout()
  found: 调用 reset_size() 然后 popup_centered(size)，此时 size 已经是 reset_size() 后的收缩值
  implication: 每次点击任务卡片后，_queue_popup_relayout -> _refresh_popup_layout 会把弹窗宽度重置为内容最小宽度

- timestamp: 2026-04-07T00:00:00Z
  checked: MainScene.tscn - TaskSelectPanel 节点
  found: size = Vector2i(720, 520) 在 .tscn 中定义，但 show_task_picker 和 _refresh_popup_layout 都通过代码控制
  implication: .tscn 的 size 被代码覆盖；_refresh_popup_layout 的 popup_centered(size) 使用了错误的尺寸

- timestamp: 2026-04-07T00:00:00Z
  checked: TaskSelectPanel/PanelMargin/PanelContent/CardScroll 节点
  found: custom_minimum_size = Vector2(0, 280) — 只设置了最小高度，没有设置最小宽度
  implication: reset_size() 后，宽度会收缩到内容的自然宽度（可能很窄）

- timestamp: 2026-04-07T00:00:00Z
  checked: show_task_picker() 调用流程
  found: 先调用 _queue_popup_relayout()，再调用 popup_centered(Vector2i(720, 520))
  implication: _queue_popup_relayout 里的 call_deferred("_refresh_popup_layout") 会在 popup_centered(720,520) 之后执行，所以 _refresh_popup_layout 最终用 reset_size() 后的小尺寸覆盖了正确尺寸

## Resolution

root_cause: show_task_picker() 中先调用 _queue_popup_relayout()（deferred），再调用 popup_centered(Vector2i(720, 520))。由于 call_deferred，_refresh_popup_layout 在同帧稍后执行，调用 reset_size() 将 size 收缩为内容最小尺寸后再以该小尺寸调用 popup_centered(size)，完全覆盖了期望的 720x520 宽度。
fix: 在 _refresh_popup_layout() 中，reset_size() 后用 max(size.x, PANEL_MIN_WIDTH) 确保宽度不低于 720px，然后 popup_centered(new_size)。同时新增 const PANEL_MIN_WIDTH := 720 常量。
verification: 待用户确认
files_changed: [scripts/ui/TaskSelectPanel.gd]
