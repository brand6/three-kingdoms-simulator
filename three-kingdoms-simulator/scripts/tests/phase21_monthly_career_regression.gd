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
	var session: GameSession = game_root.current_session
	if session == null:
		_fail("Expected session after bootstrap.")

	var candidates: Array = game_root.get_pending_month_tasks()
	if candidates.is_empty():
		_fail("Expected month task candidates.")
	var stable_found := false
	for candidate in candidates:
		if str(candidate.get("task_template_id", "")) == "task_document_cleanup":
			stable_found = true
	if not stable_found:
		_fail("Expected stable first-promotion candidate in first month pool.")

	var blocked = game_root.execute_phase2_action("study")
	if blocked.success:
		_fail("Actions should be blocked before month task selection.")

	var task_state = game_root.select_month_task(0)
	if task_state == null:
		_fail("Expected selecting the first month task to succeed.")
	if session.month_action_locked:
		_fail("Month action gate should unlock after task selection.")

	var before_progress := task_state.progress_snapshot.current_value
	game_root.execute_phase2_action("study")
	if task_state.progress_snapshot.current_value <= before_progress:
		_fail("Expected study to increase selected month task progress.")

	while session.current_xun < 3:
		game_root.end_current_xun()
	await process_frame

	main_scene.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
