---
status: awaiting_human_verify
trigger: "Investigate issue: month-report-exclusive-child\n\n**Summary:** 月末自动触发月报时，Godot 报错“Attempting to make child window exclusive, but the parent window already has another exclusive child”。报错后虽然能关掉月报界面，但下方按钮都是灰的、无法点击。"
created: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:51:00Z
---

## Current Focus

hypothesis: 已应用修复：月末先消费并设置 evaluation，再刷新 HUD；显示月报前额外隐藏 TaskSelectPanel，可阻止 exclusive child 冲突并避免输入阻塞残留。
test: 自动检查已完成初步验证；现在需要用户在真实月末流程中确认关闭月报/晋升后按钮是否恢复正常、且无 exclusive child 报错。
expecting: 月报弹出时不报错；月报与晋升弹窗关闭后，下层 HUD 不会卡灰，且下月任务选择器只在正确时机出现。
next_action: wait for user confirmation from real workflow

## Symptoms

expected: 月末时应正常弹出月报，不报错，关闭月报后底层 HUD/按钮恢复可点击。
actual: 月末自动触发时出现 exclusive child 报错；月报界面可以关闭，但关闭后下方按钮都变灰，无法点击。
errors: E 0:00:27:185   MonthReportPanel.gd:16 @ show_report(): Attempting to make child window exclusive, but the parent window already has another exclusive child. This window: /root/MainScene/MonthReportPanel, parent window: /root, current exclusive child window: /root/MainScene/TaskSelectPanel
  <C++ 源文件>     scene/main/window.cpp:1069 @ _set_transient_exclusive_child()
  <栈追踪>         MonthReportPanel.gd:16 @ show_report()
                MainHUD.gd:723 @ _show_month_end_feedback()
                MainHUD.gd:621 @ _on_end_xun_confirmed()
附带还有一个不一定相关的警告：W 0:00:00:622 GDScript::reload: The local variable "ap_value" is declared but never used in the block. If this is intended, prefix it with an underscore: "_ap_value". MainHUD.gd:131
reproduction: 正常推进流程到月末自动触发时复现。
started: 以前正常，最近某次改动后开始出现。

## Eliminated

## Evidence

- timestamp: 2026-04-07T00:04:00Z
  checked: .planning/debug/knowledge-base.md
  found: 文件不存在，当前没有可复用的已知模式记录。
  implication: 需要从代码路径自行建立初始假设并验证。

- timestamp: 2026-04-07T00:04:30Z
  checked: 脚本路径定位
  found: MainHUD.gd 与 TaskSelectPanel.gd 位于 three-kingdoms-simulator/scripts/ui/，初始猜测的 three-kingdoms-simulator/ui/ 路径不正确。
  implication: 后续需按 scripts/ui 目录追踪真实调用栈，避免基于错误路径推断。

- timestamp: 2026-04-07T00:09:00Z
  checked: MainHUD.gd / MonthReportPanel.gd / TaskSelectPanel.gd
  found: _on_end_xun_confirmed() 先调用 show_success_state()；show_success_state() 会执行 _open_month_task_picker_if_needed()。若月份已轮转且 session.month_action_locked 为 true，则 TaskSelectPanel.show_task_picker() 会 popup_centered()。随后同一函数继续 consume_last_month_evaluation()，若有 evaluation 则 _show_month_end_feedback() 调用 MonthReportPanel.show_report()->popup()。
  implication: 月末同一帧内存在“先重新打开 TaskSelectPanel，再打开 MonthReportPanel”的直接代码路径，完全匹配报错栈与 exclusive child 冲突症状。

- timestamp: 2026-04-07T00:09:30Z
  checked: MainHUD.gd month-end gating
  found: _open_month_task_picker_if_needed() 只在 _is_month_end_feedback_active() 为 true 时阻止任务面板打开；但 _active_month_end_evaluation 直到 show_success_state() 之后才赋值，导致月末结算早期门禁失效。_sync_month_task_ui_state() 也仅在 feedback active 时才主动 hide TaskSelectPanel。
  implication: 月末反馈激活标志设置过晚，是 TaskSelectPanel 抢先 popup 的高概率机制原因；如果 popup 失败或状态残留，就会留下输入阻塞与按钮灰置。

- timestamp: 2026-04-07T00:12:00Z
  checked: PromotionPopup.gd + MainScene popup node grep
  found: MonthReportPanel 与 PromotionPopup 都是 AcceptDialog，通过 popup() 打开；TaskSelectPanel 是 PopupPanel，且脚本中 _ready() 明确设置 exclusive = true。
  implication: 一旦 TaskSelectPanel 未先隐藏/释放 exclusive child，后续月报或晋升弹窗都会命中 Godot 的 exclusive child 冲突约束。

- timestamp: 2026-04-07T00:16:00Z
  checked: GameRoot.gd + TaskSystem.gd + MainScene.tscn + godot debug output
  found: end_current_xun() 在月末先 _process_month_end_evaluation()，再 advance_xun()，并在新月份 xun1 调用 _initialize_month_start_state() 把 current_session.month_action_locked 设回 true；与此同时当前场景中的 TaskSelectPanel 节点也声明了 exclusive = true。Godot 运行输出仅出现 MainHUD.gd:131 未使用变量警告，暂无其他独立线索可解释该报错。
  implication: exclusive child 冲突可完全由本地业务顺序解释，不需要额外归因到引擎或其他弹窗脚本。

- timestamp: 2026-04-07T00:19:30Z
  checked: MainHUD.gd patch
  found: _on_end_xun_confirmed() 已改为先 consume_last_month_evaluation()/设置 _active_month_end_evaluation，再调用 show_success_state()；_show_month_end_feedback() 在 popup 月报前会显式 hide TaskSelectPanel。
  implication: 月末反馈激活标志现在会在 HUD 刷新前生效，且即使未来有其他路径误开任务选择器，也会在月报展示前被防御性关闭。

- timestamp: 2026-04-07T00:21:30Z
  checked: phase21_monthly_hud_regression.gd
  found: 已新增断言，要求 month_report.visible 时 picker.visible 必须为 false。
  implication: 后续自动回归将直接覆盖本次 bug 的核心时序，防止“月报期间任务选择器被提前打开”再次回归。

- timestamp: 2026-04-07T00:23:30Z
  checked: godot_run_project + debug output
  found: 当前可获取到的运行输出中仅剩 MainHUD.gd:131 未使用变量警告，未见 exclusive child 报错或回归断言失败。
  implication: 修复方向得到初步支持，但还需一次更直接的 CLI 回归执行来增强验证置信度。

- timestamp: 2026-04-07T00:29:00Z
  checked: 用户复测反馈
  found: exclusive child 报错已消失，但月报界面没有“确认”按钮；点击右上角关闭后也没有进入后续弹窗链，因此下月任务领取界面未出现。
  implication: 月报/晋升弹窗的关闭路径与确认路径未统一，且 AcceptDialog 的确认按钮显示/布局存在问题，需要补齐 canceled 信号处理并显式保证 OK 按钮可见。

- timestamp: 2026-04-07T00:30:30Z
  checked: MonthReportPanel.gd / PromotionPopup.gd + Godot docs
  found: Godot 4 文档说明 AcceptDialog 关闭窗口会发出 canceled；当前脚本只处理 confirmed，不处理 canceled。若用户点击窗口右上角关闭，MainHUD 不会收到 confirmed_report，也就不会继续打开 PromotionPopup。两个弹窗脚本也没有显式保证 OK 按钮显示。
  implication: 需要把 canceled 与 confirm 流程打通，并在 show_report/show_promotion 时显式 show OK 按钮、使用 popup_centered 重新布局。

- timestamp: 2026-04-07T00:35:30Z
  checked: 用户二次反馈 + MainScene.tscn
  found: “首次月报没有确认按钮，第二个月正常；首次旬末总结也异常，第二次正常” 说明问题不只在月报逻辑，而是多个 AcceptDialog 首次打开时正文容器占满整窗，压住底部默认按钮区。当前 XunSummaryDialog / MonthReportPanel / PromotionPopup 的内容 MarginContainer 都 anchors 到整窗，但没有为底部按钮保留空间。
  implication: 需要在场景层为这些 AcceptDialog 的自定义内容区域预留底部空间，否则首次布局时 OK 按钮可能被内容区域遮住；这也能解释为何后续某些弹窗在再次打开时表现“正常”。

- timestamp: 2026-04-07T00:43:30Z
  checked: 用户三次反馈 + 弹窗实现复盘
  found: 仅给 AcceptDialog 预留底部空间仍未解决首次按钮异常，说明问题更接近“内置 OK 按钮首帧布局/显示不稳定”。为彻底规避该不确定性，改为在 XunSummaryDialog / MonthReportPanel / PromotionPopup 的自定义内容树内各放一个明确的确认按钮，并主动隐藏 AcceptDialog 内置 OK 按钮。
  implication: 后续按钮可见性与点击链路完全由项目 UI 控制，不再依赖 Godot 内置 AcceptDialog 按钮首开布局行为。

- timestamp: 2026-04-07T00:45:30Z
  checked: 用户最新报错 + MainHUD onready path
  found: MainScene.tscn 已把 XunSummaryBody 挪到 `XunSummaryDialog/XunSummaryMargin/XunSummaryContent/XunSummaryBody`，但 MainHUD 的 `_xun_summary_body` 仍指向旧路径 `XunSummaryDialog/XunSummaryMargin/XunSummaryBody`，导致首次显示旬末总结时为 null 并在赋值 text 时崩溃。
  implication: 修正 onready 节点路径后，旬末总结应恢复可正常赋值与显示。

- timestamp: 2026-04-07T00:50:30Z
  checked: 用户最新反馈 + 弹窗展示代码
  found: 首次旬末总结/月报仍然“按钮和窗口大小都异常”，说明不仅是按钮问题，首次 popup 时尺寸约束也没有稳定生效。当前实现里仍在首帧直接 `popup_centered(size)` 或 `popup_centered_ratio()`；这种时机可能早于内容树完成最终布局。
  implication: 需要把固定尺寸写成常量，在 `_ready()` 与 `show_*()` 中同步设置 `min_size/max_size/size`，并改为 `call_deferred()` 后再 `popup_centered(fixed_size)`，统一稳定首次展示尺寸。

## Resolution

root_cause: MainHUD._on_end_xun_confirmed() 在月末滚月后先 show_success_state()，使新月份 month_action_locked 立即触发 TaskSelectPanel.show_task_picker()；由于 TaskSelectPanel 是 exclusive PopupPanel，随后 MonthReportPanel.show_report()->popup() 触发 exclusive child 冲突，并留下任务选择器的模态输入阻塞。
fix: 1) 调整 MainHUD 月末流程顺序，先消费并保存 monthly evaluation 再刷新 HUD；显示月报前显式隐藏 TaskSelectPanel。2) MonthReportPanel / PromotionPopup 统一接管 canceled 流程。3) 放弃依赖 AcceptDialog 内置 OK 按钮，改为在 XunSummaryDialog / MonthReportPanel / PromotionPopup 的自定义内容里新增显式“确认”按钮，并在脚本中连接对应 hide/confirm 流程，同时隐藏内置 OK 按钮。4) 进一步统一三个弹窗的首次显示策略：固定常量尺寸，展示前设置 `min_size/max_size/size`，并用 `call_deferred()` 后再 `popup_centered(fixed_size)`，避免首帧布局导致窗口尺寸异常。5) 扩展回归测试，改为检查自定义确认按钮可见，并继续覆盖“月报期间任务选择器隐藏”等关键时序。
verification: 用户已确认 exclusive child 报错消失，且右上角关闭月报后会进入晋升结果并出现任务领取界面；当前待用户重新验证的是“首次旬末总结/首次月报自定义确认按钮与窗口尺寸是否恢复正常”。
files_changed: ["three-kingdoms-simulator/scenes/main/MainScene.tscn", "three-kingdoms-simulator/scripts/ui/MainHUD.gd", "three-kingdoms-simulator/scripts/ui/MonthReportPanel.gd", "three-kingdoms-simulator/scripts/ui/PromotionPopup.gd", "three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd", "three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd"]
