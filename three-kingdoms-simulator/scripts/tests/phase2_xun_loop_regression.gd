extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")
const HUD_PATH := NodePath("/root/MainScene")
const EXPECTED_TIMES := [
	"190年 / 1月 / 第1旬",
	"190年 / 1月 / 第2旬",
	"190年 / 1月 / 第3旬",
	"190年 / 2月 / 第1旬",
]


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
	var game_root = root.get_node("/root/GameRoot")
	var session: GameSession = game_root.current_session
	if session.month_action_locked:
		hud._on_month_task_confirmed(0)
		await process_frame
	_assert_equal(_time_label(hud).text, EXPECTED_TIMES[0], "initial HUD time label")

	for i in range(3):
		game_root.execute_phase2_action("train")
		var expected_merit := session.get_character_state(session.protagonist_id).merit
		var pre_end_ap := session.get_character_state(session.protagonist_id).ap
		if pre_end_ap >= 3:
			_fail("Expected AP to drop after real action before ending xun.")
		hud._on_end_turn_button_pressed()
		if not hud._end_xun_dialog.visible:
			_fail("End-xun confirmation dialog should open before advancing.")
		if not hud._end_xun_dialog.get_ok_button().visible or not hud._end_xun_dialog.get_cancel_button().visible:
			_fail("End-xun confirmation buttons should be visible on first open.")
		if hud._end_xun_dialog.size.x > 520 or hud._end_xun_dialog.size.y > 280:
			_fail("End-xun confirmation dialog should stay compact on first open, got %s." % [hud._end_xun_dialog.size])
		hud._on_end_xun_confirmed()
		await process_frame
		var expected_time: String = EXPECTED_TIMES[i + 1]
		_assert_equal(game_root.current_session.current_year, 190, "year after xun end")
		_assert_equal(game_root.current_session.current_month, 2 if i == 2 else 1, "month after xun end")
		_assert_equal(game_root.current_session.current_xun, 1 if i == 2 else i + 2, "xun after xun end")
		_assert_equal(_time_label(hud).text, expected_time, "HUD time label after xun end")
		_assert_equal(root.get_node("/root/TimeManager").get_current_label(), expected_time, "TimeManager label after xun end")
		var current_state: RuntimeCharacterState = game_root.current_session.get_character_state(game_root.current_session.protagonist_id)
		_assert_equal(current_state.ap, 3, "AP reset after xun end")
		if current_state.merit < expected_merit:
			_fail("Expected merit to persist across xun transitions.")
		if i < 2:
			if hud._xun_summary_dialog == null or not hud._xun_summary_dialog.visible:
				_fail("Xun summary dialog should open after confirmation for non-month-end xun.")
			var xun_summary_ok := hud.get_node_or_null("XunSummaryDialog/XunSummaryMargin/XunSummaryContent/ActionRow/ConfirmButton") as Button
			if xun_summary_ok == null or not xun_summary_ok.visible:
				_fail("Xun summary dialog should expose a visible confirm button on first open.")
			var summary_text: String = hud._xun_summary_body.text
			if not summary_text.contains("本旬行动摘要") or not summary_text.contains("主要数值变化") or not summary_text.contains("关系变化摘要"):
				_fail("Summary dialog omitted required sections: %s" % summary_text)
			hud._xun_summary_dialog.hide()
			await process_frame
		else:
			if hud._xun_summary_dialog.visible:
				_fail("Month-end xun should transition into month feedback, not keep the xun summary dialog open.")
			if hud.get("_active_month_end_evaluation") == null:
				_fail("Month-end xun should preserve the month evaluation for downstream feedback UI.")

	main_scene.queue_free()
	await process_frame
	quit()


func _time_label(hud: Node) -> Label:
	return hud.get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/TimeLabel") as Label


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
