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
	game_root.execute_phase2_action("study")
	game_root.end_current_xun()
	await process_frame

	if session.last_month_evaluation == null:
		_fail("Expected last_month_evaluation after third xun settlement.")
	if str(session.last_month_evaluation.task_result).is_empty():
		_fail("Expected task result in month evaluation.")
	if str(session.last_month_evaluation.promotion_failure_label) not in ["", "功绩不足", "名望不足", "无空缺", "任务未达标"]:
		_fail("Unexpected promotion failure label: %s" % session.last_month_evaluation.promotion_failure_label)

	var summary_lines: Array[String] = session.last_month_evaluation.summary_lines
	if summary_lines.is_empty():
		_fail("Expected summary lines in month evaluation.")
	var found_political_summary := false
	for line in summary_lines:
		if line.contains("政治含义"):
			found_political_summary = true
	if not found_political_summary:
		_fail("Expected visible political summary line in month evaluation.")

	main_scene.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
