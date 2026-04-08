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

	var repository: Node = root.get_node("/root/DataRepository")
	var game_root: Node = root.get_node("/root/GameRoot")
	repository.load_phase1_smoke_sample()

	var office = repository.get_office("office_zhubu")
	if office == null:
		_fail("Expected office_zhubu from generated JSON.")
	if office.name != "主簿级辅官" or int(office.tier) != 2 or int(office.merit_threshold) != 25:
		_fail("office_zhubu should be assembled from generated JSON fields.")

	var task_template = repository.get_task_template("task_document_cleanup")
	if task_template == null:
		_fail("Expected task_document_cleanup from generated JSON.")
	if task_template.name != "整顿文书" or task_template.progress_rule_id != "document_cleanup_admin":
		_fail("task_document_cleanup should preserve generated JSON task fields.")

	var session: GameSession = game_root.current_session
	if session == null:
		_fail("Expected bootstrapped session from main scene.")
	var candidates: Array = game_root.get_pending_month_tasks()
	var found_document_cleanup := false
	for candidate in candidates:
		if str(candidate.get("task_template_id", "")) == "task_document_cleanup":
			found_document_cleanup = true
			break
	if not found_document_cleanup:
		_fail("Expected generated JSON task_document_cleanup in first month candidate pool.")

	var actions: Array = game_root.get_available_phase2_actions()
	var inspect_spec = _find_action(actions, "inspect")
	if inspect_spec == null:
		_fail("Expected inspect action from generated JSON metadata.")
	if inspect_spec.display_name != "巡察":
		_fail("Inspect display name should come from generated JSON.")
	if int(inspect_spec.ap_cost) != 1 or int(inspect_spec.energy_delta) != -10:
		_fail("Inspect AP and energy values should come from generated JSON.")
	if inspect_spec.effect_summary != "效果: 功绩 +5，政务历练 +4，压力 +4":
		_fail("Inspect summary should come from generated JSON, not catalog constants.")

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
