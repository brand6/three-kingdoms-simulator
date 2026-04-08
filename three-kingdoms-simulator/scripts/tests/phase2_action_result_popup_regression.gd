extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")
const HUD_PATH := NodePath("/root/MainScene")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"

	await process_frame
	await process_frame
	await process_frame

	var hud = root.get_node(HUD_PATH)
	var picker := hud.get_node("TaskSelectPanel")
	if not picker.visible:
		_fail("TaskSelectPanel should auto-open before first action result test.")
	picker.call("_on_card_pressed", 0, root.get_node("/root/DataRepository"))
	await process_frame
	await process_frame
	picker.call("_on_confirm_button_pressed")
	await process_frame
	await process_frame
	if picker.visible:
		_fail("TaskSelectPanel should close after initial month task selection.")
	if hud._action_button.disabled:
		_fail("Action button should unlock after initial month task selection.")

	var actions: Array = root.get_node("/root/GameRoot").get_available_phase2_actions()
	var train_spec = _find_action(actions, "train")
	if train_spec == null:
		_fail("Train action should be available for popup regression.")

	hud._handle_action_selected(train_spec)
	await process_frame
	await process_frame

	if not hud._action_result_dialog.visible:
		_fail("Action result dialog should open on first action execution.")
	if hud._action_result_dialog.size != Vector2i(560, 360):
		_fail("Action result dialog should keep the stable first-open size, got %s." % [hud._action_result_dialog.size])
	var confirm_button := hud.get_node_or_null("ActionResultDialog/ActionResultMargin/ActionResultContent/ActionRow/ConfirmButton") as Button
	if confirm_button == null or not confirm_button.visible:
		_fail("Action result dialog should expose a visible custom confirm button on first open.")
	if hud._action_result_dialog.get_ok_button().visible:
		_fail("Built-in AcceptDialog OK button should stay hidden for action result dialog.")
	var body_text: String = hud._action_result_body.text
	for token in ["行动名：", "成败结论：", "原因说明：", "数值变化：", "关系变化：", "新线索："]:
		if not body_text.contains(token):
			_fail("Action result dialog omitted required content token '%s': %s" % [token, body_text])

	confirm_button.emit_signal("pressed")
	await process_frame
	if hud._action_result_dialog.visible:
		_fail("Action result dialog should hide after custom confirmation.")

	main_scene.queue_free()
	await process_frame
	quit()


func _find_action(actions: Array, action_id: String):
	for action in actions:
		if action.id == action_id:
			return action
	return null


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
