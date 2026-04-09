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
	var faction_button := hud.get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/FactionButton") as Button
	if picker == null:
		_fail("TaskSelectPanel should be mounted under MainScene.")
	if month_report == null:
		_fail("MonthReportPanel should be mounted under MainScene.")
	if promotion_popup == null:
		_fail("PromotionPopup should be mounted under MainScene.")
	if faction_button == null or faction_button.disabled:
		_fail("FactionButton should be available after Phase 3 UI wiring.")

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
	if picker.size.x < 720 or picker.size.y < 520:
		_fail("Task picker should use the stable month-start popup size on first open.")
	if _action_button(hud).disabled == false:
		_fail("Action button should stay locked until a monthly task is confirmed.")
	if not _label_text(picker, "PanelMargin/PanelContent/TitleLabel").contains("领取本月任务"):
		_fail("Task picker should show the month-start CTA copy.")
	var gate_label := picker.get_node_or_null("PanelMargin/PanelContent/GateLabel") as Label
	if gate_label == null or gate_label.visible:
		_fail("Task picker should hide the hint copy above the confirm CTA.")

	var card_text := _first_task_card_text(picker)
	var first_line := card_text.split("\n")[0]
	if not first_line.contains(selected_task_name):
		_fail("Task cards should keep the task name in the first scan line.")
	if first_line.contains(char(0xff5c)) or first_line.contains("|"):
		_fail("Task card header should stop using vertical separators between title metadata.")
	if not first_line.contains("来源："):
		_fail("Task cards should expose source copy in the first scan line.")
	if not first_line.contains("请求方："):
		_fail("Task cards should include requester copy.")
	if not (first_line.contains("尚书台") or first_line.contains("军功集团") or first_line.contains("宗族长老会")):
		_fail("Task card source should display an authority institution label.")
	if first_line.contains("势力指令") or first_line.contains("关系请求"):
		_fail("Task card source should stop rendering source-type text in the header.")
	if first_line.contains("来源：陈宫") or first_line.contains("来源：荀攸") or first_line.contains("来源：曹操"):
		_fail("Task card source should not reuse a person name as the institution.")
	if not (first_line.contains("请求方：曹操") or first_line.contains("请求方：陈宫") or first_line.contains("请求方：荀攸")):
		_fail("Task card requester should resolve to the concrete issuing person.")
	if card_text.contains("来源类型："):
		_fail("Task cards should stop rendering a standalone source-type row.")
	if card_text.contains("关联派系："):
		_fail("Task cards should rename linked faction copy to 来源.")
	if not card_text.contains("预计奖励："):
		_fail("Task cards should include expected reward copy.")
	if not card_text.contains("目标："):
		_fail("Task cards should include target copy.")
	if not card_text.contains("机遇和风险"):
		_fail("Task cards should include the opportunity/risk block.")
	if card_text.contains("目标：\n\n") or card_text.contains("\n\n\n"):
		_fail("Task card body should not render extra blank lines after the description block.")
	if card_text.contains("政治标签："):
		_fail("Task cards should stop using the old political-tag heading.")
	if card_text.contains("机会:") or card_text.contains("风险:"):
		_fail("Task cards should remove literal opportunity/risk prefixes from the old contract.")

	var confirm_button := _confirm_button(picker)
	if not confirm_button.visible:
		_fail("Confirm CTA should be visible as soon as the task picker opens.")
	if not confirm_button.disabled:
		_fail("Confirm CTA should stay disabled until a task card is clicked.")
	var selected_reward_label := picker.get_node_or_null("PanelMargin/PanelContent/SelectedRewardLabel") as Label
	if selected_reward_label == null:
		_fail("Task picker should expose the selected reward label.")
	if selected_reward_label.visible or selected_reward_label.text.strip_edges() != "":
		_fail("Task picker should not show task info above the confirm CTA before a task is selected.")

	_assert_card_readability_contract(picker)

	picker.call("_on_card_pressed", 0, root.get_node("/root/DataRepository"))
	await process_frame
	await process_frame
	if not confirm_button.visible:
		_fail("Clicking a task card should reveal the confirm CTA immediately.")
	if confirm_button.disabled:
		_fail("Clicking a task card should enable the confirm CTA immediately.")
	if selected_reward_label.visible or selected_reward_label.text.strip_edges() != "":
		_fail("Selecting a task should still keep the area above the confirm CTA free of task info.")
	if not picker.exclusive:
		_fail("Task picker should run in exclusive mode so outside clicks do not dismiss it during month selection.")

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
	if picker.visible:
		_fail("Task picker must stay hidden while the month report is active.")
	if promotion_popup.visible:
		_fail("Promotion popup must not open before the month report is confirmed.")
	var month_report_ok := month_report.get_node_or_null("PanelMargin/PanelContent/ActionRow/ConfirmButton") as Button
	if month_report_ok == null or not month_report_ok.visible:
		_fail("Month report should expose a visible confirm button.")
	var report_text := _label_text(month_report, "PanelMargin/PanelContent/BodyLabel")
	if not report_text.contains("结论："):
		_fail("Month report should show explainable verdict headline.")
	if not report_text.contains("政治力量："):
		_fail("Month report should show political forces line.")
	if not report_text.contains("下月建议："):
		_fail("Month report should show next-month advice.")

	month_report.call("confirm")
	await process_frame
	if not promotion_popup.visible:
		_fail("Promotion popup should open after month report confirmation.")
	var promotion_ok := promotion_popup.get_node_or_null("PanelMargin/PanelContent/ActionRow/ConfirmButton") as Button
	if promotion_ok == null or not promotion_ok.visible:
		_fail("Promotion popup should expose a visible confirm button.")
	if picker.visible:
		_fail("Next-month task picker must stay hidden until promotion confirmation finishes.")
	var promotion_text := _label_text(promotion_popup, "PanelMargin/PanelContent/BodyLabel")
	if not (promotion_text.contains("未获任命") or promotion_text.contains("任命缘由：")):
		_fail("Promotion popup should show explainable appointment verdict.")

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
		var content_root := first_card.get_node_or_null("CardPadding")
		var content := content_root.get_node_or_null("CardContent") if content_root != null else first_card.get_node_or_null("CardContent")
		if content != null:
			var parts: Array[String] = []
			var header_node := content.get_node_or_null("HeaderLabel")
			if header_node is Label:
				var header := header_node as Label
				if not header.text.strip_edges().is_empty():
					parts.append(header.text)
			elif header_node is HBoxContainer:
				var header_parts: Array[String] = []
				for child in header_node.get_children():
					if child is Label:
						var label := child as Label
						if not label.text.strip_edges().is_empty():
							header_parts.append(label.text.strip_edges())
				if not header_parts.is_empty():
					parts.append("    ".join(header_parts))
			var body_node := content.get_node_or_null("BodyLabel")
			if body_node is RichTextLabel:
				var rich_body := body_node as RichTextLabel
				var parsed_text := rich_body.get_parsed_text()
				if not parsed_text.strip_edges().is_empty():
					parts.append(parsed_text)
			elif body_node is Label:
				var plain_body := body_node as Label
				if not plain_body.text.strip_edges().is_empty():
					parts.append(plain_body.text)
			if not parts.is_empty():
				return "\n".join(parts)
		return first_card.text
	var body := first_card.get_node_or_null("BodyLabel") as Label
	return body.text if body != null else ""


func _assert_card_readability_contract(picker: Node) -> void:
	var container := picker.get_node_or_null("PanelMargin/PanelContent/CardScroll/CardList") as VBoxContainer
	if container == null or container.get_child_count() == 0:
		_fail("Task picker should render at least one task card for layout assertions.")
	var first_card := container.get_child(0) as Button
	if first_card == null:
		_fail("First task card should be a Button.")
	var normal_style := first_card.get_theme_stylebox("normal")
	if normal_style == null:
		_fail("Task card should expose a normal stylebox for spacing checks.")
	if normal_style.content_margin_left < 20.0 or normal_style.content_margin_right < 20.0:
		_fail("Task card should use stronger horizontal content margins.")
	if normal_style.content_margin_top < 16.0 or normal_style.content_margin_bottom < 16.0:
		_fail("Task card should use stronger vertical content margins.")
	var padding := first_card.get_node_or_null("CardPadding") as MarginContainer
	if padding == null:
		_fail("Task card should expose a dedicated inner padding container.")
	if padding.get_theme_constant("margin_left") < 20 or padding.get_theme_constant("margin_right") < 20:
		_fail("Task card inner padding should enforce readable horizontal breathing room.")
	if padding.get_theme_constant("margin_top") < 16 or padding.get_theme_constant("margin_bottom") < 16:
		_fail("Task card inner padding should enforce readable vertical breathing room.")
	var content := padding.get_node_or_null("CardContent") as VBoxContainer
	if content == null:
		_fail("Task card should still expose the content container for layout checks.")
	var header_row := content.get_node_or_null("HeaderLabel") as HBoxContainer
	if header_row == null:
		_fail("Task card should render the header as a dedicated row container.")
	if header_row.get_theme_constant("separation") < 12:
		_fail("Task card header row should visibly separate title, source, and requester blocks.")
	var title_label := header_row.get_node_or_null("TitleLabel") as Label
	var source_label := header_row.get_node_or_null("SourceLabel") as Label
	var requester_label := header_row.get_node_or_null("RequesterLabel") as Label
	if title_label == null or source_label == null or requester_label == null:
		_fail("Task card header should expose title, source, and requester labels explicitly.")
	if title_label.size_flags_horizontal != Control.SIZE_EXPAND_FILL or source_label.size_flags_horizontal != Control.SIZE_EXPAND_FILL or requester_label.size_flags_horizontal != Control.SIZE_EXPAND_FILL:
		_fail("Task card header columns should all expand so the three title blocks distribute evenly.")
	if requester_label.horizontal_alignment != HORIZONTAL_ALIGNMENT_RIGHT:
		_fail("Task card requester column should align to the right edge within its third.")
	var body := content.get_node_or_null("BodyLabel") as RichTextLabel
	if body == null:
		_fail("Task card should keep the rich-text body for multiline sizing checks.")
	var body_height := float(body.get_content_height())
	if body_height <= 0.0:
		body_height = body.get_combined_minimum_size().y
	var expected_min_height := float(padding.get_theme_constant("margin_top") + padding.get_theme_constant("margin_bottom"))
	expected_min_height += float(content.get_theme_constant("separation"))
	expected_min_height += header_row.get_combined_minimum_size().y
	expected_min_height += body_height
	if float(first_card.size.y) + 1.0 < expected_min_height:
		_fail("Task card height should expand to fit wrapped multiline body content.")


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
