extends SceneTree

const POLITICAL_SYSTEM_SCRIPT := preload("res://scripts/systems/PoliticalSystem.gd")
const FACTION_SYSTEM_SCRIPT := preload("res://scripts/systems/FactionSystem.gd")
const APPOINTMENT_RESOLVER_SCRIPT := preload("res://scripts/systems/AppointmentResolver.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_success_path()
	_test_earliest_blocked_failure_path()
	_test_competition_loss_path()
	print("[phase3_appointment_resolver_regression] All tests passed.")
	quit()


func _test_success_path() -> void:
	var ctx := _make_context("task_document_cleanup")
	ctx.career.total_merit = 35
	ctx.career.current_fame = 18
	ctx.career.current_trust = 18
	ctx.session.vacancy_states["vacancy_zhubu"] = true
	var result := _evaluate(ctx, {"task_result": "excellent"})
	var player: AppointmentCandidateEvaluation = result.player_evaluation
	_assert_equal(player.final_decision, "appointed", "success path should appoint player")
	_assert_equal(player.get_top_line_decision(), "appointed", "success top-line decision")


func _test_earliest_blocked_failure_path() -> void:
	var ctx := _make_context("task_document_cleanup")
	ctx.career.total_merit = 12
	ctx.career.current_fame = 11
	ctx.career.current_trust = 9
	ctx.session.vacancy_states["vacancy_zhubu"] = true
	var result := _evaluate(ctx, {"task_result": "success"})
	var player: AppointmentCandidateEvaluation = result.player_evaluation
	_assert_equal(player.final_decision, "rejected", "low merit should reject player at earliest blocking stage")
	_assert_true(player.reason_lines.size() >= 1, "failure path should carry reason lines")
	_assert_true(str(result.next_month_political_hint).length() > 0, "failure path should emit next-month advice")


func _test_competition_loss_path() -> void:
	var ctx := _make_context("task_recommend_talent")
	ctx.career.current_office_id = "office_zhubu"
	ctx.career.office_tier = 2
	ctx.career.months_in_current_office = 1
	ctx.career.total_merit = 50
	ctx.career.current_fame = 24
	ctx.career.current_trust = 16
	ctx.session.vacancy_states["vacancy_central_aide"] = true
	var competition_task: MonthlyTaskState = ctx.task as MonthlyTaskState
	competition_task.task_template_id = "task_recommend_talent"
	competition_task.task_source_type = "relation_request"
	competition_task.request_character_id = "xun_yu"
	competition_task.political_risk_tags = ["派系猜忌"]
	var result := _evaluate(ctx, {"task_result": "success"})
	var player: AppointmentCandidateEvaluation = result.player_evaluation
	_assert_equal(player.final_decision, "lost_to_rival", "competition path should lose to rival")
	_assert_equal(player.get_top_line_decision(), "lost_to_rival", "competition loss top-line")


func _make_context(task_template_id: String) -> Dictionary:
	var repo := _boot_repository()
	var session: GameSession = repo.bootstrap_session("scenario_190_smoke", "xun_yu")
	var task_state := MonthlyTaskState.create("190-01", task_template_id, "cao_cao", 1, "190-01", "in_progress", TaskProgressSnapshot.create(11, 8, 11, [], "190-01", "excellent"))
	task_state.task_source_type = "faction_order"
	task_state.request_character_id = ""
	task_state.political_reward_tags = ["府署认可"]
	task_state.political_risk_tags = []
	session.current_month_task = task_state
	var career: PlayerCareerState = session.player_career_state as PlayerCareerState
	var political_system = POLITICAL_SYSTEM_SCRIPT.new()
	var faction_system = FACTION_SYSTEM_SCRIPT.new()
	var resolver = APPOINTMENT_RESOLVER_SCRIPT.new()
	return {"repo": repo, "session": session, "task": task_state, "career": career, "political_system": political_system, "faction_system": faction_system, "resolver": resolver}


func _evaluate(ctx: Dictionary, settlement: Dictionary) -> Dictionary:
	var qualification := CareerSystem.new().evaluate_qualification(ctx.session, ctx.repo, settlement)
	var snapshot: PoliticalSupportSnapshot = ctx.political_system.finalize_month_snapshot(ctx.session, ctx.repo, settlement)
	return ctx.resolver.evaluate_month_end(ctx.session, ctx.repo, ctx.faction_system, snapshot, qualification, settlement)


func _boot_repository() -> Node:
	var repo_script := load("res://scripts/autoload/DataRepository.gd")
	var repo: Node = repo_script.new()
	repo.load_phase1_smoke_sample()
	return repo


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _assert_true(condition: bool, label: String) -> void:
	if not condition:
		_fail("Assertion failed: %s" % label)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
