extends SceneTree

# Phase 3 任务来源回归测试
# 验证 ensure_diversity 候选生成包含两类来源，选中后来源快照正确冻结


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var repo: Node = _boot_repository()
	var session: GameSession = repo.bootstrap_session("scenario_190_smoke", "xun_yu")
	if session == null:
		_fail("bootstrap_session returned null")
		return

	_test_candidates_have_both_source_types(session, repo)
	_test_candidate_payload_carries_political_fields(session, repo)
	_test_select_freezes_source_snapshot(session, repo)

	print("[phase3_task_source_regression] All tests passed.")
	quit()


func _boot_repository() -> Node:
	var repo_script := load("res://scripts/autoload/DataRepository.gd")
	var repo: Node = repo_script.new()
	repo.load_phase1_smoke_sample()
	return repo


func _test_candidates_have_both_source_types(session: GameSession, repo: Node) -> void:
	var task_system := TaskSystem.new()
	var candidates := task_system.generate_month_candidates(session, repo)
	_assert_true(candidates.size() > 0, "candidates should not be empty")

	var source_types: Dictionary = {}
	for c in candidates:
		var st: String = str(Dictionary(c).get("task_source_type", ""))
		if not st.is_empty():
			source_types[st] = true

	_assert_true(source_types.has("faction_order"), "candidates should include faction_order source type")
	_assert_true(source_types.has("relation_request"), "candidates should include relation_request source type")
	print("  [PASS] candidates contain both faction_order and relation_request source types")


func _test_candidate_payload_carries_political_fields(session: GameSession, repo: Node) -> void:
	var task_system := TaskSystem.new()
	var candidates := task_system.generate_month_candidates(session, repo)
	for c in candidates:
		var d := Dictionary(c)
		_assert_true(d.has("task_source_type"), "candidate should have task_source_type key")
		_assert_true(d.has("authority_institution_name"), "candidate should have authority_institution_name key")
		_assert_true(d.has("request_character_id"), "candidate should have request_character_id key")
		_assert_true(d.has("related_bloc_id"), "candidate should have related_bloc_id key")
		_assert_true(d.has("source_summary"), "candidate should have source_summary key")
		_assert_true(d.has("political_reward_tags"), "candidate should have political_reward_tags key")
		_assert_true(d.has("political_risk_tags"), "candidate should have political_risk_tags key")
		_assert_true(not str(d.get("authority_institution_name", "")).is_empty(), "candidate authority institution should not be empty")
	print("  [PASS] all candidates carry Phase 3 political fields")


func _test_select_freezes_source_snapshot(session: GameSession, repo: Node) -> void:
	var task_system := TaskSystem.new()
	var candidates := task_system.generate_month_candidates(session, repo)
	session.pending_month_task_candidates = candidates

	# 找一个 relation_request 类型的候选来选中
	var target_index := -1
	for i in range(candidates.size()):
		if str(Dictionary(candidates[i]).get("task_source_type", "")) == "relation_request":
			target_index = i
			break
	if target_index < 0:
		_fail("no relation_request candidate found to select")
		return

	var task_state := task_system.select_month_task(session, repo, target_index)
	_assert_true(task_state != null, "select_month_task should return non-null state")
	_assert_equal(task_state.task_source_type, "relation_request", "frozen source type")
	_assert_true(not task_state.authority_institution_name.is_empty(), "frozen authority institution should not be empty")
	_assert_true(not task_state.request_character_id.is_empty(), "frozen request_character_id should not be empty")
	_assert_true(not task_state.source_summary.is_empty(), "frozen source_summary should not be empty")
	print("  [PASS] selected task correctly freezes source snapshot into MonthlyTaskState")


func _assert_true(condition: bool, label: String) -> void:
	if not condition:
		_fail("Assertion failed: %s" % label)


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
