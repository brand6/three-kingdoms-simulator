extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")
const HUD_PATH := NodePath("/root/MainScene")
const TASK_SELECT_PANEL_PATH := NodePath("/root/MainScene/TaskSelectPanel")


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
	if picker == null:
		_fail("TaskSelectPanel should be mounted under MainScene.")

	if not game_root.has_method("get_pending_month_tasks"):
		_fail("GameRoot should expose get_pending_month_tasks for monthly HUD flow.")
	if not game_root.has_method("select_month_task"):
		_fail("GameRoot should expose select_month_task for monthly HUD flow.")

	var tasks: Array = game_root.call("get_pending_month_tasks")
	if tasks.is_empty():
		_fail("A new month should expose selectable monthly tasks.")

	if not picker.visible:
		_fail("Task picker should auto-open at month start.")
	if _action_button(hud).disabled == false:
		_fail("Action button should stay locked until a monthly task is confirmed.")
	if not _label_text(picker, "TitleLabel").contains("领取主任务"):
		_fail("Task picker should show the month-start CTA copy.")
	if _label_text(picker, "GateLabel") != "本月尚未领受公事，请先择定一项主任务。":
		_fail("Task picker should use the institutional month-start gate copy.")

	var card_text := _first_task_card_text(picker)
	if not card_text.contains("发布人："):
		_fail("Task cards should include issuer copy.")
	if not card_text.contains("任务描述："):
		_fail("Task cards should include description copy.")
	if not card_text.contains("预计奖励："):
		_fail("Task cards should include expected reward copy.")

	game_root.call("select_month_task", tasks[0].task_id)
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

	main_scene.queue_free()
	await process_frame
	quit()


func _action_button(hud: Node) -> Button:
	return hud.get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/ActionButton") as Button


func _task_summary(hud: Node) -> String:
	return (hud.get_node("MarginContainer/VBoxContainer/MainContent/RightContext/TaskPanel/TaskPanelContent/TaskListScroll/TaskList") as Label).text


func _label_text(picker: Node, name: String) -> String:
	var label := picker.get_node_or_null(name) as Label
	return label.text if label != null else ""


func _first_task_card_text(picker: Node) -> String:
	var container := picker.get_node_or_null("CardScroll/CardList") as VBoxContainer
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
