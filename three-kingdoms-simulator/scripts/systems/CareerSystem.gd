extends RefCounted
class_name CareerSystem

func evaluate_promotion(session: GameSession, repository: Node, settlement: Dictionary) -> Dictionary:
	return evaluate_qualification(session, repository, settlement)


func evaluate_qualification(session: GameSession, repository: Node, settlement: Dictionary) -> Dictionary:
	var career_state: PlayerCareerState = session.player_career_state as PlayerCareerState
	if career_state == null:
		return _failure_result("任务未达标", {}, "当前无有效仕途状态。")
	var current_office = repository.call("get_office", career_state.current_office_id)
	if current_office == null or str(current_office.next_office_id).is_empty():
		return _failure_result("无空缺", {}, "当前暂无更高任命可供擢升。")
	var rule = _find_rule_for_office(repository, career_state.current_office_id)
	if rule == null:
		return _failure_result("无空缺", {}, "未找到对应任命规则。")
	if not bool(session.vacancy_states.get(str(rule.vacancy_key), false)):
		return _failure_result("无空缺", {"vacancy": str(rule.vacancy_key)}, "当前无空缺")
	if bool(rule.require_task_success_this_month) and str(settlement.get("task_result", "failed")) == "failed":
		return _failure_result("任务未达标", {}, "本月主任务未达标")
	if career_state.total_merit < int(rule.required_merit):
		return _failure_result("功绩不足", {"required_merit": int(rule.required_merit), "current_merit": career_state.total_merit}, "距离目标官职仍差 %d 功绩" % [int(rule.required_merit) - career_state.total_merit])
	if career_state.current_fame < int(rule.required_fame):
		return _failure_result("名望不足", {"required_fame": int(rule.required_fame), "current_fame": career_state.current_fame}, "距离目标官职仍差 %d 名望" % [int(rule.required_fame) - career_state.current_fame])
	if career_state.months_in_current_office < int(rule.min_months_in_office):
		return _failure_result("任务未达标", {"min_months_in_office": int(rule.min_months_in_office)}, "当前任职月数尚不足。")
	if str(rule.notification_source_character_id).is_empty():
		return _failure_result("无空缺", {}, "尚无正式任命通知来源。")
	return {
		"success": true,
		"qualification_passed": true,
		"vacancy_available": true,
		"failure_label": "",
		"missing_values": {},
		"hint": str(rule.success_note),
		"rule_id": str(rule.id),
		"vacancy_key": str(rule.vacancy_key),
		"notification_source_character_id": str(rule.notification_source_character_id),
		"new_office_id": str(rule.to_office_id),
	}


func _find_rule_for_office(repository: Node, office_id: String) -> Variant:
	for rule in repository.call("get_promotion_rules"):
		if rule != null and str(rule.from_office_id) == office_id:
			return rule
	return null


func _failure_result(label: String, missing_values: Dictionary, hint: String) -> Dictionary:
	return {
		"success": false,
		"qualification_passed": false,
		"vacancy_available": false,
		"failure_label": label,
		"missing_values": missing_values.duplicate(true),
		"hint": hint,
		"rule_id": "",
		"vacancy_key": "",
		"notification_source_character_id": "",
		"new_office_id": "",
	}
