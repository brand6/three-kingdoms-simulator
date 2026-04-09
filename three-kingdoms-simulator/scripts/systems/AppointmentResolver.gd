extends RefCounted
class_name AppointmentResolver

const EVALUATION_SCRIPT := preload("res://scripts/runtime/AppointmentCandidateEvaluation.gd")
const REASON_LINE_SCRIPT := preload("res://scripts/runtime/PoliticalReasonLine.gd")


func evaluate_month_end(
	session: GameSession,
	repository: Node,
	faction_system: FactionSystem,
	snapshot: PoliticalSupportSnapshot,
	qualification_result: Dictionary,
	settlement: Dictionary
) -> Dictionary:
	var protagonist_id := session.protagonist_id
	var protagonist = repository.call("get_character", protagonist_id) as CharacterDefinition
	var faction_id := str(protagonist.faction_id if protagonist != null else "")
	var player_position := faction_system.get_player_position_summary(session)
	var bloc_rows := faction_system.get_bloc_rows(faction_id, session)
	var resource_summary := faction_system.get_resource_summary(faction_id)
	var office_id := str(qualification_result.get("new_office_id", ""))
	var qualification_passed := bool(qualification_result.get("success", false))
	var vacancy_available := qualification_passed or str(qualification_result.get("failure_label", "")) != "无空缺"
	var support_lines := _build_support_lines(snapshot, repository)
	var blocker_lines := _build_blocker_lines(snapshot, repository, qualification_result)
	var player_evaluation = _build_player_evaluation(session, snapshot, qualification_result, support_lines, blocker_lines, player_position, bloc_rows, office_id)
	var evaluations: Array = [player_evaluation]
	if qualification_passed:
		for rival in _build_rival_evaluations(session, repository, snapshot, office_id, player_position, bloc_rows):
			evaluations.append(rival)
	_assign_competition_rankings(evaluations)
	var player_rank := int(player_evaluation.competition_rank)
	if qualification_passed:
		if player_rank == 1:
			player_evaluation.final_decision = "appointed"
		else:
			player_evaluation.final_decision = "lost_to_rival"
			player_evaluation.reason_lines.append(_reason("competition", "competition", "ai_candidate", _top_rival_id(evaluations, protagonist_id), "", "oppose", "major", "竞争名额被更高优先级候选抢先占据。", "竞争结果", 50, true))
	else:
		player_evaluation.final_decision = _map_failure_to_decision(str(qualification_result.get("failure_label", "")))
	player_evaluation.evaluation_status = "evaluated"
	player_evaluation.qualification_passed = qualification_passed
	player_evaluation.vacancy_available = vacancy_available
	player_evaluation.next_goal_hint = _build_next_hint(player_evaluation, qualification_result)
	var visible_reason_lines := player_evaluation.get_visible_reason_lines(3)
	return {
		"appointment_result": str(player_evaluation.final_decision),
		"candidate_evaluations": evaluations,
		"player_evaluation": player_evaluation,
		"primary_support_lines": _to_summary_lines(support_lines, 2),
		"primary_blocker_lines": _to_summary_lines(blocker_lines, 2),
		"missed_opportunity_note": "本月与 %s 失之交臂。" % office_id if str(player_evaluation.final_decision) == "lost_to_rival" else "",
		"next_month_political_hint": player_evaluation.next_goal_hint,
		"primary_support_identity": _primary_identity(snapshot.primary_recommender_ids, repository),
		"primary_blocker_identity": _primary_identity(snapshot.primary_opposer_ids, repository),
		"political_forces_summary": _build_forces_summary(snapshot, resource_summary),
		"visible_reason_lines": visible_reason_lines,
	}


func _build_player_evaluation(session: GameSession, snapshot: PoliticalSupportSnapshot, qualification_result: Dictionary, support_lines: Array, blocker_lines: Array, player_position: Dictionary, bloc_rows: Array[Dictionary], office_id: String) -> AppointmentCandidateEvaluation:
	var career_state: PlayerCareerState = session.player_career_state as PlayerCareerState
	var bloc_score := _bloc_score(bloc_rows)
	var recommendation_score := int(snapshot.support_score_total) + int(player_position.get("recommendation_power", 0)) * 2
	var opposition_score := int(snapshot.opposition_score_total)
	var reason_lines: Array = []
	if bool(qualification_result.get("success", false)):
		reason_lines.append(_reason("qualification", "qualification", "system", "", "", "support", "major", "资格审查通过：功绩、名望与任期达到要求。", "资格", 1, true))
		reason_lines.append(_reason("vacancy", "vacancy", "system", "", "", "support", "minor", "当前职位序列存在可争取空缺。", "空缺", 2, false))
	else:
		reason_lines.append(_reason("qualification", "qualification", "system", "", "", "oppose", "major", "资格审查未过：%s。" % str(qualification_result.get("failure_label", "任务未达标")), "资格", 1, true))
	for line in support_lines:
		reason_lines.append(line)
	for line in blocker_lines:
		reason_lines.append(line)
	return EVALUATION_SCRIPT.create(
		office_id,
		session.protagonist_id,
		"pending",
		bool(qualification_result.get("success", false)),
		bool(qualification_result.get("success", false)) or str(qualification_result.get("failure_label", "")) != "无空缺",
		recommendation_score,
		opposition_score,
		bloc_score,
		int(career_state.total_merit if career_state != null else 0),
		int(career_state.current_trust if career_state != null else 0),
		0,
		reason_lines,
		"pending",
		""
	)


func _build_rival_evaluations(session: GameSession, repository: Node, snapshot: PoliticalSupportSnapshot, office_id: String, player_position: Dictionary, bloc_rows: Array[Dictionary]) -> Array:
	var rivals: Array = []
	if office_id == "office_zhubu":
		return rivals
	var rival_ids := ["le_jin"]
	if office_id == "office_central_aide":
		rival_ids = ["cao_cao", "le_jin"]
	for rival_id in rival_ids:
		var rival = repository.call("get_character", rival_id) as CharacterDefinition
		if rival == null:
			continue
		var merit_score := int(rival.reputation_values.get("merit", 0))
		var trust_score := int(rival.reputation_values.get("fame", 0) / 2)
		var bloc_score := _rival_bloc_score(rival_id, bloc_rows)
		var recommendation_score := merit_score / 4 + bloc_score + (4 if rival_id == "cao_cao" else 2)
		var opposition_score := 1 if rival_id == "le_jin" else 0
		var reason_lines := [
			_reason("qualification", "qualification", "system", "", "", "support", "major", "%s 资格满足当前职位争夺。" % rival.name, "资格", 1, true),
			_reason("competition", "competition", "ai_candidate", rival_id, "", "support", "major", "%s 的既有功绩与势力位置更稳。" % rival.name, "竞争", 40, true),
		]
		rivals.append(EVALUATION_SCRIPT.create(office_id, rival_id, "evaluated", true, true, recommendation_score, opposition_score, bloc_score, merit_score, trust_score, 0, reason_lines, "pending", ""))
	return rivals


func _assign_competition_rankings(evaluations: Array) -> void:
	evaluations.sort_custom(func(a: AppointmentCandidateEvaluation, b: AppointmentCandidateEvaluation) -> bool:
		return _score(a) > _score(b)
	)
	for index in range(evaluations.size()):
		evaluations[index].competition_rank = index + 1


func _score(evaluation: AppointmentCandidateEvaluation) -> int:
	if not evaluation.qualification_passed:
		return -999
	return evaluation.recommendation_score + evaluation.bloc_score + evaluation.merit_score + evaluation.trust_score - evaluation.opposition_score * 2


func _build_support_lines(snapshot: PoliticalSupportSnapshot, repository: Node) -> Array:
	var lines: Array = []
	var order := 10
	for character_id in snapshot.primary_recommender_ids:
		var character = repository.call("get_character", character_id) as CharacterDefinition
		lines.append(_reason("recommendation", "recommendation", "character", character_id, "", "support", "major", "%s 表示愿意继续举荐你。" % str(character.name if character != null else character_id), "推荐", order, true))
		order += 1
	return lines


func _build_blocker_lines(snapshot: PoliticalSupportSnapshot, repository: Node, qualification_result: Dictionary) -> Array:
	var lines: Array = []
	var order := 20
	for character_id in snapshot.primary_opposer_ids:
		var character = repository.call("get_character", character_id) as CharacterDefinition
		lines.append(_reason("opposition", "opposition", "character", character_id, "", "oppose", "major", "%s 仍持保留甚至反对态度。" % str(character.name if character != null else character_id), "阻力", order, true))
		order += 1
	for blocker_tag in snapshot.blocker_tags:
		lines.append(_reason("opposition", "opposition", "system", "", "", "oppose", "minor", "阻断因素：%s。" % str(blocker_tag), "阻力", order, false))
		order += 1
	if not bool(qualification_result.get("success", false)):
		lines.append(_reason("vacancy", "vacancy", "system", "", "", "oppose", "major", "当前结论：%s。" % str(qualification_result.get("failure_label", "任务未达标")), "阻力", 3, true))
	return lines


func _bloc_score(bloc_rows: Array[Dictionary]) -> int:
	var score := 0
	for row in bloc_rows:
		match str(row.get("attitude", "")):
			"支持":
				score += int(row.get("influence_weight", 0))
			"反对":
				score -= int(row.get("influence_weight", 0))
	return score


func _rival_bloc_score(rival_id: String, bloc_rows: Array[Dictionary]) -> int:
	var score := 0
	for row in bloc_rows:
		if Array(row.get("core_character_ids", [])).has(rival_id):
			score += int(row.get("influence_weight", 0))
	return score


func _build_next_hint(player_evaluation: AppointmentCandidateEvaluation, qualification_result: Dictionary) -> String:
	match str(player_evaluation.final_decision):
		"appointed":
			return "新任已定，下月优先用新权限稳住推荐人与派系关系。"
		"lost_to_rival":
			return "下月应先补强推荐链或削弱主要阻力，再争取下一次空缺。"
		_:
			return str(qualification_result.get("hint", "下月继续补足资格与政治支持。"))


func _map_failure_to_decision(label: String) -> String:
	match label:
		"无空缺":
			return "deferred"
		_:
			return "rejected"


func _to_summary_lines(reason_lines: Array, max_count: int) -> Array[String]:
	var lines: Array[String] = []
	for line in reason_lines:
		if lines.size() >= max_count:
			break
		lines.append(str(line.summary_text))
	return lines


func _primary_identity(character_ids: Array[String], repository: Node) -> String:
	if character_ids.is_empty():
		return "—"
	var character = repository.call("get_character", character_ids[0]) as CharacterDefinition
	return str(character.name if character != null else character_ids[0])


func _build_forces_summary(snapshot: PoliticalSupportSnapshot, resource_summary: Dictionary) -> String:
	return "政治力量：支持 %d / 阻力 %d｜军务压力 %s｜治务负荷 %s" % [snapshot.support_score_total, snapshot.opposition_score_total, str(resource_summary.get("military_pressure", "中")), str(resource_summary.get("governance_load", "中"))]


func _top_rival_id(evaluations: Array, protagonist_id: String) -> String:
	for evaluation in evaluations:
		if str(evaluation.candidate_character_id) != protagonist_id:
			return str(evaluation.candidate_character_id)
	return ""


func _reason(reason_type: String, stage: String, source_type: String, source_character_id: String, source_bloc_id: String, direction: String, weight_tier: String, summary_text: String, ui_group: String, sort_order: int, is_major: bool) -> PoliticalReasonLine:
	return REASON_LINE_SCRIPT.create(reason_type, stage, source_type, source_character_id, source_bloc_id, direction, weight_tier, summary_text, ui_group, sort_order, is_major)
