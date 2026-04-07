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
	var hud: Node = root.get_node("/root/MainScene")
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

	var blocked: Variant = game_root.execute_phase2_action("study")
	if blocked.success:
		_fail("Actions should be blocked before month task selection.")

	var task_state: MonthlyTaskState = game_root.select_month_task(0)
	if task_state == null:
		_fail("Expected selecting the first month task to succeed.")
	if session.month_action_locked:
		_fail("Month action gate should unlock after task selection.")

	var before_progress: int = task_state.progress_snapshot.current_value
	game_root.execute_phase2_action("study")
	if task_state.progress_snapshot.current_value <= before_progress:
		_fail("Expected study to increase selected month task progress.")
	if task_state.progress_snapshot.current_value != 4:
		_fail("Expected the stable admin task to gain +4 progress from study.")

	game_root.execute_phase2_action("study")
	game_root.execute_phase2_action("study")
	if task_state.progress_snapshot.current_value < task_state.progress_snapshot.target_value:
		_fail("Expected first-month stable path to reach success threshold before month end.")
	var pre_settlement_state: RuntimeCharacterState = session.get_character_state(session.protagonist_id)
	var pre_settlement_merit: int = pre_settlement_state.merit
	var pre_settlement_fame: int = pre_settlement_state.fame
	var pre_settlement_trust: int = pre_settlement_state.trust

	for _i in range(3):
		hud._on_end_turn_button_pressed()
		hud._on_end_xun_confirmed()
		await process_frame

	var evaluation: MonthlyEvaluationResult = hud.get("_active_month_end_evaluation") as MonthlyEvaluationResult
	if evaluation == null:
		_fail("Expected HUD to hold the consumed month-end evaluation after third xun settlement.")
	if game_root.call("get_last_month_evaluation") != null:
		_fail("Expected month-end evaluation to be consumed from session state once the HUD flow starts.")
	if str(evaluation.task_result).is_empty():
		_fail("Expected task result in month evaluation.")
	if evaluation.task_name != "整顿文书":
		_fail("Expected month evaluation to persist the completed task name snapshot.")
	if evaluation.progress_current_value != 12 or evaluation.progress_target_value != 8 or evaluation.progress_bonus_value != 11:
		_fail("Expected month evaluation to persist the completed task progress snapshot.")
	if evaluation.task_result != "excellent":
		_fail("Expected stable first-month task to resolve as excellent, got %s." % evaluation.task_result)
	if evaluation.merit_delta != 10 or evaluation.fame_delta != 2 or evaluation.trust_delta != 2:
		_fail("Expected excellent rewards to be written back to month evaluation.")
	if not evaluation.office_changed:
		_fail("Stable first-month task should grant promotion on the positive path.")
	if evaluation.new_office_id != "office_zhubu":
		_fail("Expected promotion target to be office_zhubu, got %s." % evaluation.new_office_id)
	if evaluation.promotion_failure_label != "":
		_fail("Successful promotion should not keep a failure label, got %s." % evaluation.promotion_failure_label)

	var summary_lines: Array[String] = evaluation.summary_lines
	if summary_lines.is_empty():
		_fail("Expected summary lines in month evaluation.")
	var found_political_summary := false
	for line in summary_lines:
		if line.contains("政治含义"):
			found_political_summary = true
	if not found_political_summary:
		_fail("Expected visible political summary line in month evaluation.")

	var runtime_state: RuntimeCharacterState = session.get_character_state(session.protagonist_id)
	if runtime_state.merit != pre_settlement_merit + evaluation.merit_delta or runtime_state.fame != pre_settlement_fame + evaluation.fame_delta or runtime_state.trust != pre_settlement_trust + evaluation.trust_delta:
		_fail("Expected month-end settlement to write merit/fame/trust back to runtime state.")
	if session.player_career_state.current_office_id != "office_zhubu":
		_fail("Expected career office to update after successful promotion.")
	var office_label := (hud.get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/OfficeInfoLabel") as Label).text
	if office_label != "官职：主簿级辅官":
		_fail("Expected HUD office label to reflect promoted career office, got %s." % office_label)
	if not session.month_action_locked:
		_fail("Expected new month to reopen the task gate after settlement.")

	hud.get_node("MonthReportPanel").call("confirm")
	await process_frame
	hud.get_node("PromotionPopup").call("confirm")
	await process_frame
	if game_root.call("get_last_month_evaluation") != null:
		_fail("Expected month-end evaluation to be cleared after the UI flow consumes it.")

	game_root.select_month_task(0)
	hud._on_end_turn_button_pressed()
	hud._on_end_xun_confirmed()
	await process_frame
	if not hud._xun_summary_dialog.visible:
		_fail("Expected ordinary next-month xun endings to use xun summary flow, not stale month-end UI.")

	main_scene.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
