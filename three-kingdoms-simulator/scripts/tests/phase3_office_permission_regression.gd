extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var repo := root.get_node("/root/DataRepository")
	repo.load_phase1_smoke_sample()
	var game_root := root.get_node("/root/GameRoot")
	game_root.current_session = repo.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "xun_yu")
	var session: GameSession = game_root.current_session
	if session == null:
		_fail("Expected session after bootstrap.")

	var congshi_actions: Array = game_root.get_available_phase2_actions()
	if _find_action(congshi_actions, "review_memorials") != null:
		_fail("office_congshi should not see review_memorials without required_office_tags.")
		return
	if _find_action(congshi_actions, "inspect_subordinates") != null:
		_fail("office_congshi should not see inspect_subordinates without required_office_tags.")
		return

	var career_state: PlayerCareerState = session.player_career_state as PlayerCareerState
	var runtime_state: RuntimeCharacterState = session.get_character_state(session.protagonist_id)
	career_state.current_office_id = "office_zhubu"
	career_state.office_tier = 2
	career_state.office_tags = ["mid_career", "personnel_track", "admin_track"]
	career_state.unlocked_task_tags = ["logistics", "admin", "politics_basic", "personnel", "politics_mid", "dispatch"]
	if runtime_state != null:
		runtime_state.current_city_id = "no_such_city"

	var promoted_actions: Array = game_root.get_available_phase2_actions()
	var inspect_subordinates = _find_action(promoted_actions, "inspect_subordinates")
	if inspect_subordinates == null:
		_fail("Authorized office should see inspect_subordinates.")
		return
	if str(inspect_subordinates.disabled_reason) == "":
		_fail("Authorized office without valid targets should see inspect_subordinates disabled with a reason.")
		return
	var review_memorials = _find_action(promoted_actions, "review_memorials")
	if review_memorials == null:
		_fail("Authorized office should see review_memorials.")
		return

	var task_system := TaskSystem.new()
	session.pending_month_task_candidates = task_system.generate_month_candidates(session, repo)
	var has_personnel_task := false
	for candidate in session.pending_month_task_candidates:
		if str(Dictionary(candidate).get("task_template_id", "")) == "task_recommend_talent":
			has_personnel_task = true
	if not has_personnel_task:
		_fail("Promoted office should unlock personnel-oriented monthly task candidates.")
		return

	print("[phase3_office_permission_regression] All tests passed.")
	quit()

func _find_action(actions: Array, action_id: String):
	for action in actions:
		if action.id == action_id:
			return action
	return null


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
