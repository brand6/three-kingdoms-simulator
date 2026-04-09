extends SceneTree

const POLITICAL_SYSTEM_SCRIPT := preload("res://scripts/systems/PoliticalSystem.gd")

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var repo := _boot_repository()
	var task_system := TaskSystem.new()
	var political_system = POLITICAL_SYSTEM_SCRIPT.new()
	var session: GameSession = repo.bootstrap_session("scenario_190_smoke", "xun_yu")
	if session == null:
		_fail("bootstrap_session returned null")
		return

	session.pending_month_task_candidates = task_system.generate_month_candidates(session, repo)
	var relation_index := _find_candidate_index(session.pending_month_task_candidates, "relation_request")
	if relation_index < 0:
		_fail("Expected relation_request candidate.")
		return
	var selected_candidate := Dictionary(session.pending_month_task_candidates[relation_index])
	var source_character_id := str(selected_candidate.get("request_character_id", ""))
	if source_character_id.is_empty():
		_fail("Expected selected relation_request candidate to carry request_character_id.")
		return
	var task_state: MonthlyTaskState = task_system.select_month_task(session, repo, relation_index)
	if task_state == null:
		_fail("Expected selecting relation_request task to succeed.")
		return
	var relation_key := "%s->%s" % [source_character_id, session.protagonist_id]
	var relation: RuntimeRelationState = session.get_relation_state(relation_key)
	if relation == null:
		relation = RuntimeRelationState.create(source_character_id, session.protagonist_id, 36, 32, 40, 10, 4)
		session.set_relation_state(relation_key, relation)
	task_state.status = "success"
	var settlement := {"task_result": "success"}

	var baseline: PoliticalSupportSnapshot = political_system.build_snapshot(session, repo, settlement)
	if baseline.primary_recommender_ids.is_empty():
		_fail("Expected baseline snapshot to produce at least one recommender.")
		return
	if not baseline.bloc_attitudes.has("bloc_yingchuan_civil"):
		_fail("Expected bloc attitudes to include bloc_yingchuan_civil.")
		return
	relation.trust = 5
	relation.favor = 12
	var shifted: PoliticalSupportSnapshot = political_system.build_snapshot(session, repo, settlement)
	if shifted.primary_recommender_ids.has(source_character_id):
		_fail("Dropping relation trust should remove the requester from primary_recommender_ids.")
		return
	if baseline.primary_recommender_ids == shifted.primary_recommender_ids and baseline.bloc_attitudes == shifted.bloc_attitudes:
		_fail("Mutating relation facts should alter recommender or bloc outcome.")
		return

	var career_state: PlayerCareerState = session.player_career_state as PlayerCareerState
	career_state.current_trust = 3
	var opposed: PoliticalSupportSnapshot = political_system.build_snapshot(session, repo, settlement)
	if opposed.primary_opposer_ids.is_empty() and opposed.blocker_tags.is_empty():
		_fail("Low trust should surface primary_opposer_ids or blocker_tags.")
		return

	print("[phase3_political_snapshot_regression] All tests passed.")
	quit()


func _boot_repository() -> Node:
	var repo_script := load("res://scripts/autoload/DataRepository.gd")
	var repo: Node = repo_script.new()
	repo.load_phase1_smoke_sample()
	return repo


func _find_candidate_index(candidates: Array, source_type: String, request_character_id: String = "") -> int:
	for index in range(candidates.size()):
		var candidate := Dictionary(candidates[index])
		if str(candidate.get("task_source_type", "")) != source_type:
			continue
		if not request_character_id.is_empty() and str(candidate.get("request_character_id", "")) != request_character_id:
			continue
		return index
	return -1


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
