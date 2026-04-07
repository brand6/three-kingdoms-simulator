extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")
const HUD_PATH := NodePath("/root/MainScene")
const TASK_SELECT_PANEL_PATH := NodePath("/root/MainScene/TaskSelectPanel")
const MONTH_REPORT_PANEL_PATH := NodePath("/root/MainScene/MonthReportPanel")
const PROMOTION_POPUP_PATH := NodePath("/root/MainScene/PromotionPopup")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"

	await process_frame
	await process_frame
	await process_frame

	var hud: Node = root.get_node(HUD_PATH)
	var game_root: Node = root.get_node("/root/GameRoot")
	var picker := root.get_node_or_null(TASK_SELECT_PANEL_PATH)
	var month_report := root.get_node_or_null(MONTH_REPORT_PANEL_PATH)
	var promotion_popup := root.get_node_or_null(PROMOTION_POPUP_PATH)
	if picker == null:
		_fail("TaskSelectPanel should be mounted under MainScene.")
	if month_report == null:
		_fail("MonthReportPanel should be mounted under MainScene.")
	if promotion_popup == null:
		_fail("PromotionPopup should be mounted under MainScene.")

	if not game_root.has_method("get_pending_month_tasks"):
		_fail("GameRoot should expose get_pending_month_tasks for monthly HUD flow.")
	if not game_root.has_method("select_month_task"):
		_fail("GameRoot should expose select_month_task for monthly HUD flow.")

	var tasks: Array = game_root.call("get_pending_month_tasks")
	if tasks.is_empty():
		_fail("A new month should expose selectable monthly tasks.")
	var selected_task_name := str(tasks[0].get("name", ""))

	if not picker.visible:
		_fail("Task picker should auto-open at month start.")
	if _action_button(hud).disabled == false:
		_fail("Action button should stay locked until a monthly task is confirmed.")
	if not _label_text(picker, "PanelMargin/PanelContent/TitleLabel").contains("领取主任务"):
		_fail("Task picker should show the month-start CTA copy.")
	if _label_text(picker, "PanelMargin/PanelContent/GateLabel") != "本月尚未领受公事，请先择定一项主任务。":
		_fail("Task picker should use the institutional month-start gate copy.")

	var card_text := _first_task_card_text(picker)
	if not card_text.contains("发布人："):
		_fail("Task cards should include issuer copy.")
	if not card_text.contains("任务描述："):
		_fail("Task cards should include description copy.")
	if not card_text.contains("预计奖励："):
		_fail("Task cards should include expected reward copy.")

	var confirm_button := _confirm_button(picker)
	if confirm_button.visible:
		_fail("Confirm CTA should stay hidden until a task card is clicked.")
	if not confirm_button.disabled:
		_fail("Confirm CTA should stay disabled until a task card is clicked.")

	picker.call("_on_card_pressed", 0, root.get_node("/root/DataRepository"))
	await process_frame
	await process_frame
	if not confirm_button.visible:
		_fail("Clicking a task card should reveal the confirm CTA immediately.")
	if confirm_button.disabled:
		_fail("Clicking a task card should enable the confirm CTA immediately.")

	picker.call("_on_confirm_button_pressed")
	await process_frame
	if picker.visible:
		_fail("Task picker should close after task selection.")
	if _action_button(hud).disabled:
		_fail("Action button should unlock after task selection.")

	var task_summary := _task_summary(hud)
	if not task_summary.contains("当前主任务："):
		_fail("HUD should show the current monthly task.")
	if not task_summary.contains("当前进度："):
		_fail("HUD should show current task progress.")
	if not task_summary.contains("剩余旬数："):
		_fail("HUD should show remaining xun count.")
	var task_name_line := task_summary.split("\n")[0]

	hud._on_end_turn_button_pressed()
	hud._on_end_xun_confirmed()
	await process_frame
	if not hud._xun_summary_dialog.visible:
		_fail("A normal same-month xun ending should still show the xun summary dialog.")
	var post_xun_task_summary := _task_summary(hud)
	if not post_xun_task_summary.contains(task_name_line):
		_fail("Normal same-month xun transitions should keep the current task name in the HUD.")
	if not post_xun_task_summary.contains("当前进度：") or not post_xun_task_summary.contains("剩余旬数："):
		_fail("Normal same-month xun transitions should keep progress and remaining xun in the HUD.")
	if post_xun_task_summary.contains("本旬已结束") or post_xun_task_summary.contains("下旬建议"):
		_fail("Normal same-month xun transitions must not replace the task HUD with placeholder advice copy.")
	hud._xun_summary_dialog.hide()
	await process_frame

	for _i in range(2):
		hud._on_end_turn_button_pressed()
		hud._on_end_xun_confirmed()
		await process_frame

	if not month_report.visible:
		_fail("Month report should open at month end before promotion popup.")
	if promotion_popup.visible:
		_fail("Promotion popup must not open before the month report is confirmed.")
	var report_text := _label_text(month_report, "PanelMargin/PanelContent/BodyLabel")
	if not report_text.contains("任务名称：%s" % selected_task_name):
		_fail("Month report should use the completed task snapshot instead of a cleared live task state.")
	if not report_text.contains("进度：0/8（优秀 11）"):
		_fail("Month report should preserve the completed task progress snapshot after rollover.")
	if not report_text.contains("任务名称："):
		_fail("Month report should show task name.")
	if not report_text.contains("结果："):
		_fail("Month report should show verdict.")
	if not report_text.contains("进度："):
		_fail("Month report should show progress versus threshold.")
	if not report_text.contains("功绩变化：") or not report_text.contains("名望变化：") or not report_text.contains("信任变化："):
		_fail("Month report should show merit/fame/trust deltas.")
	if not report_text.contains("政治含义："):
		_fail("Month report should show political meaning summary.")

	month_report.call("confirm")
	await process_frame
	if not promotion_popup.visible:
		_fail("Promotion popup should open after month report confirmation.")
	if picker.visible:
		_fail("Next-month task picker must stay hidden until promotion confirmation finishes.")
	var promotion_text := _label_text(promotion_popup, "PanelMargin/PanelContent/BodyLabel")
	if not promotion_text.contains("未获任命"):
		_fail("Promotion popup should show the failed-promotion verdict when no appointment is granted.")
	if not (promotion_text.contains("功绩不足") or promotion_text.contains("名望不足") or promotion_text.contains("无空缺") or promotion_text.contains("任务未达标")):
		_fail("Promotion popup should use standardized failure labels.")
	if not (promotion_text.contains("距离") or promotion_text.contains("仍差") or promotion_text.contains("当前无空缺") or promotion_text.contains("当前进度") or promotion_text.contains("成功阈值")):
		_fail("Promotion popup should include a concrete missing-value line.")

	promotion_popup.call("confirm")
	await process_frame
	if month_report.visible or promotion_popup.visible:
		_fail("Month-end dialogs should both close cleanly after confirmation.")
	if not picker.visible:
		_fail("Next-month task picker should open only after promotion confirmation.")

	if game_root.call("get_last_month_evaluation") != null:
		_fail("Month-end evaluation should be consumed after the report flow starts.")

	game_root.call("select_month_task", 0)
	hud._on_end_turn_button_pressed()
	hud._on_end_xun_confirmed()
	await process_frame
	if not hud._xun_summary_dialog.visible:
		_fail("A normal next-month xun ending should show the xun summary instead of replaying stale month-end UI.")
	if month_report.visible or promotion_popup.visible:
		_fail("Later non-month-end xun endings must not replay stale month-end dialogs.")

	main_scene.queue_free()
	await process_frame
	quit()


func _action_button(hud: Node) -> Button:
	return hud.get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/ActionButton") as Button


func _confirm_button(picker: Node) -> Button:
	return picker.get_node("PanelMargin/PanelContent/ActionRow/ConfirmButton") as Button


func _task_summary(hud: Node) -> String:
	return (hud.get_node("MarginContainer/VBoxContainer/MainContent/RightContext/TaskPanel/TaskPanelContent/TaskListScroll/TaskList") as Label).text


func _label_text(picker: Node, name: String) -> String:
	var label := picker.get_node_or_null(name) as Label
	return label.text if label != null else ""


func _first_task_card_text(picker: Node) -> String:
	var container := picker.get_node_or_null("PanelMargin/PanelContent/CardScroll/CardList") as VBoxContainer
	if container == null or container.get_child_count() == 0:
		return ""
	var first_card := container.get_child(0)
	if first_card is BaseButton:
		return first_card.text
	var body := first_card.get_node_or_null("BodyLabel") as Label
	return body.text if body != null else ""


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
