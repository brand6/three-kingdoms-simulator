extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"

	await process_frame
	await process_frame
	await process_frame

	var game_root = root.get_node("/root/GameRoot")
	var repository = root.get_node("/root/DataRepository")
	var session: GameSession = game_root.current_session
	if session == null:
		_fail("Expected current_session after bootstrap.")

	_assert_equal(session.protagonist_id, "xun_yu", "boot protagonist")
	_assert_equal(repository.get_setup_patch_for_scenario("scenario_190_smoke").id, "xunyu_default_start_patch", "setup patch id")
	_assert_equal(session.player_career_state.current_office_id, "office_congshi", "career office")
	_assert_equal(session.player_career_state.total_merit, 18, "career merit")
	_assert_equal(session.player_career_state.current_fame, 11, "career fame")
	_assert_equal(session.player_career_state.current_trust, 14, "career trust")

	var runtime_state: RuntimeCharacterState = session.get_character_state(session.protagonist_id)
	_assert_equal(runtime_state.merit, 18, "runtime merit")
	_assert_equal(runtime_state.fame, 11, "runtime fame")
	_assert_equal(runtime_state.trust, 14, "runtime trust")
	_assert_equal(session.month_action_locked, true, "month gate active")

	var candidates: Array = game_root.get_pending_month_tasks()
	if candidates.size() < 2 or candidates.size() > 3:
		_fail("Expected 2-3 month-start candidates, got %d." % candidates.size())

	var before_ap := runtime_state.ap
	var blocked_result = game_root.execute_phase2_action("study")
	_assert_equal(blocked_result.success, false, "blocked action success")
	if not str(blocked_result.reason_text).contains("请先择定一项本月任务"):
		_fail("Blocked action should explain the month-start task gate.")
	_assert_equal(runtime_state.ap, before_ap, "AP unchanged before task selection")

	if repository.get_office("office_congshi") == null:
		_fail("Expected office data to load by fixed ID.")
	if repository.get_task_template("task_document_cleanup") == null:
		_fail("Expected task template to load by fixed ID.")
	if repository.get_task_pool_rule("task_pool_xunyu_early_career") == null:
		_fail("Expected task pool rule to load by fixed ID.")
	if repository.get_promotion_rule("promotion_congshi_to_zhubu") == null:
		_fail("Expected promotion rule to load by fixed ID.")

	main_scene.queue_free()
	await process_frame
	quit()


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
