extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _run_success_route()
	await _run_failure_route()
	print("[phase3_end_to_end_regression] All tests passed.")
	quit()


func _run_success_route() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"
	await process_frame
	await process_frame
	await process_frame
	var hud: Node = root.get_node("/root/MainScene")
	var game_root: Node = root.get_node("/root/GameRoot")
	hud.get_node("TaskSelectPanel").call("_on_card_pressed", 0, root.get_node("/root/DataRepository"))
	await process_frame
	hud.get_node("TaskSelectPanel").call("_on_confirm_button_pressed")
	await process_frame
	game_root.execute_phase2_action("study")
	game_root.execute_phase2_action("inspect")
	game_root.execute_phase2_action("study")
	for _i in range(3):
		hud._on_end_turn_button_pressed()
		hud._on_end_xun_confirmed()
		await process_frame
	var evaluation: MonthlyEvaluationResult = hud.get("_active_month_end_evaluation") as MonthlyEvaluationResult
	if evaluation == null or evaluation.appointment_result != "appointed":
		_fail("Success route should end with appointed result.")
	main_scene.queue_free()
	await process_frame


func _run_failure_route() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"
	await process_frame
	await process_frame
	await process_frame
	var hud: Node = root.get_node("/root/MainScene")
	var game_root: Node = root.get_node("/root/GameRoot")
	var session: GameSession = game_root.current_session
	(session.player_career_state as PlayerCareerState).total_merit = 0
	(session.player_career_state as PlayerCareerState).current_fame = 0
	hud.get_node("TaskSelectPanel").call("_on_card_pressed", 0, root.get_node("/root/DataRepository"))
	await process_frame
	hud.get_node("TaskSelectPanel").call("_on_confirm_button_pressed")
	await process_frame
	for _i in range(3):
		hud._on_end_turn_button_pressed()
		hud._on_end_xun_confirmed()
		await process_frame
	var evaluation: MonthlyEvaluationResult = hud.get("_active_month_end_evaluation") as MonthlyEvaluationResult
	if evaluation == null:
		_fail("Failure route should still yield month-end evaluation.")
	if evaluation.appointment_result != "rejected":
		_fail("Failure route should end with rejected result from earliest blocking layer.")
	if evaluation.next_month_political_hint.strip_edges().is_empty():
		_fail("Failure route should emit next-month advice line.")
	main_scene.queue_free()
	await process_frame


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
