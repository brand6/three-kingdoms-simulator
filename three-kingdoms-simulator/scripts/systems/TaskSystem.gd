extends RefCounted
class_name TaskSystem

const MONTHLY_TASK_STATE_SCRIPT := preload("res://scripts/runtime/MonthlyTaskState.gd")
const TASK_PROGRESS_SNAPSHOT_SCRIPT := preload("res://scripts/runtime/TaskProgressSnapshot.gd")

const PROGRESS_RULE_MAP := {
	"logistics_balanced": {"inspect": 4, "study": 2, "visit": 1, "rest": 1, "train": 0},
	"clan_pacify_social": {"visit": 4, "study": 1, "rest": 1, "inspect": 0, "train": 0},
	"document_cleanup_admin": {"study": 4, "inspect": 3, "rest": 1, "visit": 1, "train": 0},
	"recommend_talent_network": {"visit": 3, "study": 2, "inspect": 1, "rest": 0, "train": 0},
}


func generate_month_candidates(session: GameSession, repository: Node) -> Array:
	var candidates: Array = []
	if session == null or session.player_career_state == null:
		return candidates
	var career_state: PlayerCareerState = session.player_career_state as PlayerCareerState
	for rule in repository.call("get_task_pool_rules"):
		if rule == null:
			continue
		if not Array(rule.scenario_ids).is_empty() and not Array(rule.scenario_ids).has(session.scenario_id):
			continue
		if not Array(rule.character_ids).is_empty() and not Array(rule.character_ids).has(session.protagonist_id):
			continue
		if career_state.office_tier < int(rule.office_tier_min) or career_state.office_tier > int(rule.office_tier_max):
			continue
		var stable_task_id := _stable_first_month_task_id(career_state.career_flags)
		if not stable_task_id.is_empty():
			var stable_task = repository.call("get_task_template", stable_task_id)
			if stable_task != null:
				candidates.append(_candidate_payload(stable_task))
		for task in repository.call("get_task_templates"):
			if task == null:
				continue
			if not stable_task_id.is_empty() and str(task.id) == stable_task_id:
				continue
			if int(task.min_office_tier) > career_state.office_tier or int(task.max_office_tier) < career_state.office_tier:
				continue
			if not _task_matches_rule(task, rule):
				continue
			candidates.append(_candidate_payload(task))
			if candidates.size() >= int(rule.candidate_count):
				break
		if candidates.is_empty():
			for fallback_id in rule.fallback_task_ids:
				var fallback_task = repository.call("get_task_template", str(fallback_id))
				if fallback_task != null:
					candidates.append(_candidate_payload(fallback_task))
		while candidates.size() > int(rule.candidate_count):
			candidates.pop_back()
		break
	return candidates


func select_month_task(session: GameSession, repository: Node, selected_index: int) -> MonthlyTaskState:
	if session == null:
		return null
	if selected_index < 0 or selected_index >= session.pending_month_task_candidates.size():
		return null
	var candidate: Dictionary = Dictionary(session.pending_month_task_candidates[selected_index])
	var template = repository.call("get_task_template", str(candidate.get("task_template_id", "")))
	if template == null:
		return null
	var progress_snapshot: TaskProgressSnapshot = TASK_PROGRESS_SNAPSHOT_SCRIPT.create(
		0,
		int(Dictionary(template.success_condition).get("current_value", 0)),
		int(Dictionary(template.excellent_condition).get("current_value", 0)),
		[],
		_month_key(session),
		"in_progress"
	)
	var task_state: MonthlyTaskState = MONTHLY_TASK_STATE_SCRIPT.create(
		_month_key(session),
		str(template.id),
		str(template.issuer_character_id),
		session.current_xun,
		_month_key(session),
		"in_progress",
		progress_snapshot,
		selected_index,
		"",
		{}
	)
	session.current_month_task = task_state
	session.month_action_locked = false
	return task_state


func remaining_xun_count(session: GameSession) -> int:
	if session == null:
		return 0
	return max(0, 3 - session.current_xun)


func append_progress_from_action(session: GameSession, repository: Node, action_id: String) -> int:
	if session == null or session.current_month_task == null:
		return 0
	var task_state: MonthlyTaskState = session.current_month_task as MonthlyTaskState
	var template = repository.call("get_task_template", task_state.task_template_id)
	if template == null:
		return 0
	var progress_rules: Dictionary = Dictionary(PROGRESS_RULE_MAP.get(str(template.progress_rule_id), {}))
	var delta := int(progress_rules.get(action_id, 0))
	task_state.progress_snapshot.current_value += delta
	task_state.progress_snapshot.last_update_time = "%s-xun-%d" % [_month_key(session), session.current_xun]
	task_state.progress_snapshot.step_records.append({
		"action_id": action_id,
		"delta": delta,
		"xun": session.current_xun,
	})
	task_state.progress_snapshot.derived_status = _derive_status(task_state.progress_snapshot)
	return delta


func settle_month_task(session: GameSession, repository: Node) -> Dictionary:
	if session == null or session.current_month_task == null:
		return {
			"task_result": "failed",
			"merit_delta": 0,
			"fame_delta": 0,
			"trust_delta": 0,
			"summary_lines": ["本月未能形成有效事务记录。"],
			"political_summary": "本月未领受有效公事，暂无新的仕途评价。",
		}
	var task_state: MonthlyTaskState = session.current_month_task as MonthlyTaskState
	var template = repository.call("get_task_template", task_state.task_template_id)
	if template == null:
		return {}
	var result_key := _derive_status(task_state.progress_snapshot)
	var merit_delta := 0
	var fame_delta := 0
	var trust_delta := 0
	var note := ""
	if result_key == "excellent":
		merit_delta = int(Dictionary(template.base_rewards).get("merit", 0)) + int(Dictionary(template.bonus_rewards).get("merit", 0))
		fame_delta = int(Dictionary(template.base_rewards).get("fame", 0)) + int(Dictionary(template.bonus_rewards).get("fame", 0))
		trust_delta = int(Dictionary(template.base_rewards).get("trust", 0)) + int(Dictionary(template.bonus_rewards).get("trust", 0))
		note = str(Dictionary(template.bonus_rewards).get("success_note", Dictionary(template.base_rewards).get("success_note", "")))
	elif result_key == "success":
		merit_delta = int(Dictionary(template.base_rewards).get("merit", 0))
		fame_delta = int(Dictionary(template.base_rewards).get("fame", 0))
		trust_delta = int(Dictionary(template.base_rewards).get("trust", 0))
		note = str(Dictionary(template.base_rewards).get("success_note", ""))
	else:
		merit_delta = int(Dictionary(template.fail_result).get("merit_delta", 0))
		fame_delta = int(Dictionary(template.fail_result).get("fame_delta", 0))
		trust_delta = int(Dictionary(template.fail_result).get("trust_delta", 0))
		note = str(Dictionary(template.fail_result).get("failure_note", ""))
	task_state.status = result_key
	task_state.completion_note = note
	task_state.reward_snapshot = {
		"merit": merit_delta,
		"fame": fame_delta,
		"trust": trust_delta,
	}
	var political_summary := _political_summary_line(trust_delta, note)
	return {
		"task_result": result_key,
		"merit_delta": merit_delta,
		"fame_delta": fame_delta,
		"trust_delta": trust_delta,
		"summary_lines": [
			"任务：%s" % str(template.name),
			"结果：%s" % result_key,
			"进度：%d/%d（优秀阈值 %d）" % [task_state.progress_snapshot.current_value, task_state.progress_snapshot.target_value, task_state.progress_snapshot.bonus_value],
			"功绩 %+d / 名望 %+d / 信任 %+d" % [merit_delta, fame_delta, trust_delta],
			political_summary,
		],
		"political_summary": political_summary,
	}


func _candidate_payload(task: Variant) -> Dictionary:
	return {
		"task_template_id": str(task.id),
		"name": str(task.name),
		"issuer_character_id": str(task.issuer_character_id),
		"description": str(task.description),
		"base_rewards": Dictionary(task.base_rewards).duplicate(true),
	}


func _task_matches_rule(task: Variant, rule: Variant) -> bool:
	var include_tags: Array = Array(rule.include_task_tags)
	for task_tag in task.task_tags:
		if include_tags.has(task_tag):
			return true
	return false


func _stable_first_month_task_id(flags: Array[String]) -> String:
	for flag in flags:
		if str(flag).begins_with("stable_first_promotion_path:"):
			return str(flag).trim_prefix("stable_first_promotion_path:")
	return ""


func _month_key(session: GameSession) -> String:
	return "%d-%02d" % [session.current_year, session.current_month]


func _derive_status(snapshot: TaskProgressSnapshot) -> String:
	if snapshot.current_value >= snapshot.bonus_value and snapshot.bonus_value > 0:
		return "excellent"
	if snapshot.current_value >= snapshot.target_value:
		return "success"
	return "failed"


func _political_summary_line(trust_delta: int, note: String) -> String:
	if trust_delta > 0:
		return "政治含义：上意更信，%s" % note
	if trust_delta < 0:
		return "政治含义：疑虑未消，%s" % note
	return "政治含义：评价持平，%s" % note
