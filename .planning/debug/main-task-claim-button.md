---
status: investigating
trigger: "TaskSelectPanel 在点击面板外部后重置领取按钮状态，且按钮上方仍出现提示性文字。"
created: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:16:00Z
---

## Current Focus

hypothesis: 问题不是单纯“按钮消失”，而是 PopupPanel 点击外部后被关闭，MainHUD 在月初锁定态下立即自动重开任务面板，导致按钮状态被重新初始化；而“按钮上方提示文字”很可能来自 SelectedRewardLabel 的空状态文案，而不是已隐藏的 GateLabel
test: 核对 MainHUD 的 _sync_month_task_ui_state() 自动 reopen 流程、PopupPanel 外部点击关闭语义，以及 TaskSelectPanel 中 GateLabel/SelectedRewardLabel 两个上方文本来源
expecting: 分离出两个独立根因：1) 外点导致 popup hide + reopen reset；2) 上方文案来自错误的空状态 label
next_action: 向用户报告根因并确认是否立即修复

## Symptoms

expected: 进入主界面后，玩家应以荀彧身份开局，并在新的一月开始时先看到主任务选择弹窗；点击任务后应立即出现领取任务按钮，无需额外点击弹窗外区域
actual: 有出现任务弹窗，但点击任务后没有出现领取任务按钮，点击任务面板外部的区域才出现“领取主主任务”的按钮
errors: 无明确报错，表现为 UI 更新时机异常
reproduction: 进入主界面 -> 等主任务选择弹窗出现 -> 点击一个任务 -> 按钮未出现 -> 点击任务面板外部区域 -> 按钮才出现
started: Phase 2.1 UAT test 1

## Eliminated

## Evidence

- timestamp: 2026-04-07T00:04:00Z
  checked: .planning/phases/02.1-/02.1-UAT.md
  found: UAT test 1 failure is specifically that task popup appears, but claim button only appears after clicking outside task panel.
  implication: issue is likely in popup interaction / refresh timing, not popup entry conditions.

- timestamp: 2026-04-07T00:08:00Z
  checked: scripts/ui/TaskSelectPanel.gd and scenes/main/MainScene.tscn
  found: ConfirmButton exists in scene at TaskSelectPanel/PanelMargin/PanelContent/ActionRow/ConfirmButton and is never hidden in script; show_task_picker() even preselects index 0 and enables the confirm button immediately when candidates exist.
  implication: the reported "button appears later" is not caused by business state staying unset; it points to a presentation/layout refresh issue in the popup UI.

- timestamp: 2026-04-07T00:09:00Z
  checked: scripts/ui/MainHUD.gd
  found: MainHUD only opens TaskSelectPanel via show_task_picker() and handles task_confirmed; it does not manage per-card selection UI or claim-button visibility after popup opens.
  implication: concrete defect is localized to TaskSelectPanel scene/layout/render flow rather than MainHUD gate logic.

- timestamp: 2026-04-07T00:14:00Z
  checked: scripts/ui/TaskSelectPanel.gd vs scripts/ui/MainHUD.gd popup helpers
  found: Action and selector popups elsewhere in MainHUD use deferred popup/reset_size handling after dynamic content changes, but TaskSelectPanel mutates card list, reward label, and confirm state synchronously with no reset_size/minimum_size_changed/queued layout refresh at popup open or card click.
  implication: TaskSelectPanel is the only popup in this flow missing an explicit post-render layout refresh, matching the symptom that UI updates only after a later external click.

- timestamp: 2026-04-07T00:15:00Z
  checked: scripts/tests/phase21_monthly_hud_regression.gd
  found: regression test validates popup open and then bypasses the actual click-confirm UI by calling game_root.select_month_task(0) directly, without asserting ConfirmButton visibility after a card click.
  implication: the broken interactive picker path was not covered, allowing the stale-layout issue to ship into UAT.

- timestamp: 2026-04-07T10:45:00Z
  checked: scripts/ui/MainHUD.gd:705-719
  found: 当 session.month_action_locked 为 true 且 TaskSelectPanel 不可见时，_sync_month_task_ui_state() 会每帧调用 _open_month_task_picker_if_needed() 重新打开任务面板。
  implication: 如果 PopupPanel 因点击外部而被隐藏，HUD 会立刻重开它，用户看到的不是“按钮单独消失”，而是“面板被重置后按钮恢复隐藏状态”。

- timestamp: 2026-04-07T10:46:00Z
  checked: Godot Popup / Window docs
  found: Popup 默认是 popup_window；用户点击外部时会触发 close_requested / modal close 语义并关闭 popup。
  implication: TaskSelectPanel 若保持默认 popup 行为，就会响应外部点击关闭，这是第一个症状的直接触发条件。

- timestamp: 2026-04-07T10:47:00Z
  checked: scenes/main/MainScene.tscn and scripts/ui/TaskSelectPanel.gd
  found: GateLabel 在场景与脚本中都已 visible = false；但 SelectedRewardLabel 位于按钮上方，且 _render_selected_reward() 在未选任务时会写入 EMPTY_BODY 文案。
  implication: 用户看到的“按钮上方提示性文字”更可能来自 SelectedRewardLabel 的空状态内容，而不是 GateLabel 未隐藏。

## Resolution

root_cause: 当前剩余的两个 UAT 症状来自两个不同原因：
  1) 点击任务面板外部时，PopupPanel 会按 Godot 默认 popup 行为关闭；MainHUD 又因为 month_action_locked 仍为 true，在 _process() 中立刻自动重开 TaskSelectPanel，于是按钮状态被 show_task_picker() 重置为 hidden/disabled，看起来像“点外部后按钮消失”。
  2) 按钮上方仍有提示性文字，不是 GateLabel 还在显示，而是 SelectedRewardLabel 在未选任务时仍显示 EMPTY_BODY 空状态文案。
fix: 
  1) 禁止 TaskSelectPanel 因外部点击而关闭，或在 hide/reopen 链路中保留已选索引状态；最小修复优先应放在禁止外部点击关闭。
  2) 将 SelectedRewardLabel 的未选状态改为空白、短横线，或“请先选择一项本月任务”这类非误导性占位文案；若目标是完全无提示，则直接置空。
verification: diagnosis only
 files_changed: []
