extends RefCounted
class_name PoliticalSystem

const POLITICAL_SNAPSHOT_SCRIPT := preload("res://scripts/runtime/PoliticalSupportSnapshot.gd")
const REASON_LINE_SCRIPT := preload("res://scripts/runtime/PoliticalReasonLine.gd")


func finalize_month_snapshot(session: GameSession, repository: Node, settlement: Dictionary = {}) -> PoliticalSupportSnapshot:
	var snapshot := build_snapshot(session, repository, settlement)
	if session != null:
		session.current_month_political_snapshot = snapshot
	return snapshot


func build_snapshot(session: GameSession, repository: Node, settlement: Dictionary = {}) -> PoliticalSupportSnapshot:
	if session == null or session.player_career_state == null:
		return POLITICAL_SNAPSHOT_SCRIPT.create("", "", [], [], {}, 0, 0, [], [], [], [])
	var month_key := "%d-%02d" % [session.current_year, session.current_month]
	var support_total := 0
	var opposition_total := 0
	var primary_recommenders: Array[String] = []
	var primary_opposers: Array[String] = []
	var qualification_tags: Array[String] = []
	var blocker_tags: Array[String] = []
	var opportunity_tags: Array[String] = []
	var bloc_attitudes: Dictionary = {}
	var protagonist_id := session.protagonist_id
	var protagonist = repository.call("get_character", protagonist_id) as CharacterDefinition
	var faction_id := str(protagonist.faction_id if protagonist != null else "")
	var career_state: PlayerCareerState = session.player_career_state as PlayerCareerState
	var current_task: MonthlyTaskState = session.current_month_task as MonthlyTaskState
	var candidate_office_ids: Array[String] = []
	var current_office = repository.call("get_office", career_state.current_office_id)
	if current_office != null and not str(current_office.next_office_id).is_empty():
		candidate_office_ids.append(str(current_office.next_office_id))

	for bloc in repository.call("get_faction_blocs", faction_id):
		bloc_attitudes[str(bloc.id)] = str(bloc.default_attitude)

	for rule in repository.call("get_recommendation_rules"):
		if not _recommendation_rule_matches(rule, current_task, career_state, settlement):
			continue
		var source_character_id := _recommendation_source_character_id(rule, current_task)
		var relation = _get_relation(session, source_character_id, protagonist_id)
		if relation == null:
			continue
		if relation.favor < int(rule.relation_threshold) or relation.trust < int(rule.trust_threshold):
			continue
		var support_delta := int(rule.support_delta) + int(relation.trust / 20)
		if career_state.total_merit >= int(rule.merit_threshold):
			support_delta += 1
		if not primary_recommenders.has(source_character_id):
			primary_recommenders.append(source_character_id)
		support_total += support_delta

	for rule in repository.call("get_opposition_rules"):
		if not _opposition_rule_matches(rule, current_task, career_state):
			continue
		var opposition_source_id := _opposition_source_character_id(rule)
		var relation = _get_relation(session, opposition_source_id, protagonist_id)
		var vigilance := int(relation.vigilance if relation != null else 0)
		var trust := int(relation.trust if relation != null else career_state.current_trust)
		trust = min(trust, career_state.current_trust)
		if trust > int(rule.trust_lower_bound) and vigilance < int(rule.relation_lower_bound):
			continue
		if not opposition_source_id.is_empty() and not primary_opposers.has(opposition_source_id):
			primary_opposers.append(opposition_source_id)
		opposition_total += int(rule.opposition_delta) + int(max(vigilance - trust, 0) / 20)
		for blocker_tag in Array(rule.blocker_tags):
			if not blocker_tags.has(str(blocker_tag)):
				blocker_tags.append(str(blocker_tag))

	for bloc in repository.call("get_faction_blocs", faction_id):
		var score := _default_attitude_score(str(bloc.default_attitude))
		for core_id in Array(bloc.core_character_ids):
			if primary_recommenders.has(str(core_id)):
				score += 1
			if primary_opposers.has(str(core_id)):
				score -= 1
		if current_task != null:
			if str(current_task.related_bloc_id) == str(bloc.id):
				score += 1
			for risk_tag in Array(current_task.political_risk_tags):
				if _bloc_matches_risk(str(bloc.id), str(risk_tag)):
					score -= 1
			for reward_tag in Array(current_task.political_reward_tags):
				if _bloc_matches_reward(str(bloc.id), str(reward_tag)):
					score += 1
		bloc_attitudes[str(bloc.id)] = _attitude_from_score(score)

	if career_state.total_merit >= 10:
		qualification_tags.append("merit_sufficient")
	if career_state.current_trust >= 10:
		qualification_tags.append("trust_sufficient")
	if current_task != null and str(current_task.task_source_type) == "relation_request":
		opportunity_tags.append("relation_backing")
	if current_task != null and str(current_task.task_source_type) == "faction_order":
		opportunity_tags.append("direct_order_visibility")
	for vacancy_key in session.vacancy_states.keys():
		if bool(session.vacancy_states.get(vacancy_key, false)):
			opportunity_tags.append("vacancy_open")
			break

	return POLITICAL_SNAPSHOT_SCRIPT.create(
		month_key,
		protagonist_id,
		primary_recommenders,
		primary_opposers,
		bloc_attitudes,
		support_total,
		opposition_total,
		qualification_tags,
		blocker_tags,
		candidate_office_ids,
		opportunity_tags
	)


func build_reason_lines(snapshot: PoliticalSupportSnapshot, repository: Node) -> Dictionary:
	var support_lines: Array = []
	var blocker_lines: Array = []
	var order := 1
	for character_id in snapshot.primary_recommender_ids:
		var character = repository.call("get_character", character_id) as CharacterDefinition
		support_lines.append(REASON_LINE_SCRIPT.create("recommendation", "recommendation", "character", character_id, "", "support", "major", "%s 出面背书，近期关系与信任处于上行。" % str(character.name if character != null else character_id), "主要推荐人", order, true))
		order += 1
	for character_id in snapshot.primary_opposer_ids:
		var character = repository.call("get_character", character_id) as CharacterDefinition
		blocker_lines.append(REASON_LINE_SCRIPT.create("opposition", "opposition", "character", character_id, "", "oppose", "major", "%s 对你仍有疑虑，当前支持明显不足。" % str(character.name if character != null else character_id), "主要阻力", order, true))
		order += 1
	for bloc_id in snapshot.bloc_attitudes.keys():
		var attitude := str(snapshot.bloc_attitudes[bloc_id])
		if attitude == "neutral":
			continue
		var bloc = repository.call("get_faction_bloc", str(bloc_id))
		var target := support_lines if attitude == "support" else blocker_lines
		target.append(REASON_LINE_SCRIPT.create("bloc", "recommendation" if attitude == "support" else "opposition", "bloc", "", str(bloc_id), attitude, "minor", "%s 当前态度：%s。" % [str(bloc.name if bloc != null else bloc_id), _localized_attitude(attitude)], "派系态度", order, false))
		order += 1
	return {"support_lines": support_lines, "blocker_lines": blocker_lines}


func _recommendation_rule_matches(rule: Variant, current_task: MonthlyTaskState, career_state: PlayerCareerState, settlement: Dictionary) -> bool:
	if rule == null or current_task == null:
		return false
	if str(current_task.task_source_type) != str(rule.source_type):
		return false
	if career_state.total_merit < int(rule.merit_threshold):
		return false
	if str(settlement.get("task_result", current_task.status)) == "failed":
		return false
	return true


func _opposition_rule_matches(rule: Variant, current_task: MonthlyTaskState, career_state: PlayerCareerState) -> bool:
	if rule == null:
		return false
	if str(rule.id).contains("old_guard"):
		return career_state.current_trust <= int(rule.trust_lower_bound) or (current_task != null and Array(current_task.political_risk_tags).has("旧吏阻力↑"))
	if str(rule.id).contains("frontline"):
		return current_task != null and (Array(current_task.political_risk_tags).has("派系猜忌") or str(current_task.task_template_id) == "task_recommend_talent")
	return false


func _recommendation_source_character_id(rule: Variant, current_task: MonthlyTaskState) -> String:
	if current_task == null:
		return ""
	if str(rule.id).contains("relation_request") and not str(current_task.request_character_id).is_empty():
		return str(current_task.request_character_id)
	if not str(current_task.issuer_character_id).is_empty():
		return str(current_task.issuer_character_id)
	return ""


func _opposition_source_character_id(rule: Variant) -> String:
	if str(rule.id).contains("frontline"):
		return "le_jin"
	if str(rule.id).contains("old_guard"):
		return "cao_cao"
	return ""


func _get_relation(session: GameSession, source_character_id: String, target_character_id: String) -> Variant:
	if session == null or source_character_id.is_empty() or target_character_id.is_empty():
		return null
	return session.get_relation_state("%s->%s" % [source_character_id, target_character_id])


func _default_attitude_score(attitude: String) -> int:
	match attitude:
		"support":
			return 1
		"oppose":
			return -1
		_:
			return 0


func _attitude_from_score(score: int) -> String:
	if score >= 1:
		return "support"
	if score <= -1:
		return "oppose"
	return "neutral"


func _bloc_matches_risk(bloc_id: String, risk_tag: String) -> bool:
	return (bloc_id.contains("old_guard") and risk_tag.contains("旧吏")) or (bloc_id.contains("hawks") and risk_tag.contains("猜忌"))


func _bloc_matches_reward(bloc_id: String, reward_tag: String) -> bool:
	return (bloc_id.contains("yingchuan") and reward_tag.contains("认可")) or (bloc_id.contains("hawks") and reward_tag.contains("后勤"))


func _localized_attitude(attitude: String) -> String:
	match attitude:
		"support":
			return "支持"
		"oppose":
			return "反对"
		_:
			return "观望"
