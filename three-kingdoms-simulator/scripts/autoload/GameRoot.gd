extends Node

const DEFAULT_SCENARIO_ID := "scenario_190_smoke"
const DEFAULT_PROTAGONIST_ID := "cao_cao"
const PHASE2_ACTION_CATALOG_SCRIPT := preload("res://scripts/systems/Phase2ActionCatalog.gd")
const PHASE2_ACTION_RESOLVER_SCRIPT := preload("res://scripts/systems/Phase2ActionResolver.gd")
const XUN_SUMMARY_DATA_SCRIPT := preload("res://scripts/runtime/XunSummaryData.gd")
const CHARACTER_SELECTOR_ROW_SCRIPT := preload("res://scripts/runtime/CharacterSelectorRow.gd")
const CHARACTER_PROFILE_VIEW_DATA_SCRIPT := preload("res://scripts/runtime/CharacterProfileViewData.gd")
const ACTION_RESOLUTION_SCRIPT := preload("res://scripts/runtime/ActionResolution.gd")
const TASK_SYSTEM_SCRIPT := preload("res://scripts/systems/TaskSystem.gd")
const CAREER_SYSTEM_SCRIPT := preload("res://scripts/systems/CareerSystem.gd")
const POLITICAL_SYSTEM_SCRIPT := preload("res://scripts/systems/PoliticalSystem.gd")
const FACTION_SYSTEM_SCRIPT := preload("res://scripts/systems/FactionSystem.gd")
const APPOINTMENT_RESOLVER_SCRIPT := preload("res://scripts/systems/AppointmentResolver.gd")
const MONTHLY_EVALUATION_RESULT_SCRIPT := preload("res://scripts/runtime/MonthlyEvaluationResult.gd")

var current_session: GameSession
var last_boot_error: String = ""
var _hud: MainHUD
var _phase2_action_catalog: Variant = PHASE2_ACTION_CATALOG_SCRIPT.new()
var _phase2_action_resolver: Variant = PHASE2_ACTION_RESOLVER_SCRIPT.new()
var _task_system: Variant = TASK_SYSTEM_SCRIPT.new()
var _career_system: Variant = CAREER_SYSTEM_SCRIPT.new()
var _political_system: Variant = POLITICAL_SYSTEM_SCRIPT.new()
var _faction_system: Variant = FACTION_SYSTEM_SCRIPT.new()
var _appointment_resolver: Variant = APPOINTMENT_RESOLVER_SCRIPT.new()
var _latest_action_resolution: Variant = null


func _data_repository() -> Node:
	return get_node("/root/DataRepository")


func _time_manager() -> Node:
	return get_node("/root/TimeManager")


func bootstrap_default_entry() -> void:
	last_boot_error = ""
	if _hud != null:
		_hud.show_loading_state()

	_data_repository().call("load_phase1_smoke_sample")
	var setup_patch = _data_repository().call("get_setup_patch_for_scenario", DEFAULT_SCENARIO_ID)
	var effective_protagonist_id := DEFAULT_PROTAGONIST_ID
	if setup_patch != null and not str(setup_patch.default_player_character_id).is_empty():
		effective_protagonist_id = str(setup_patch.default_player_character_id)
	current_session = _data_repository().call("bootstrap_session", DEFAULT_SCENARIO_ID, effective_protagonist_id) as GameSession
	if current_session == null:
		show_boot_error("默认数据集或主角 ID 无法载入。")
		return
	_initialize_month_start_state()

	_time_manager().call("initialize", current_session.current_year, current_session.current_month, current_session.current_xun)
	if _hud != null:
		_hud.show_success_state(current_session)


func show_boot_error(message: String) -> void:
	last_boot_error = message
	push_error(message)
	if _hud != null:
		_hud.show_error_state(message)


func register_hud(hud: MainHUD) -> void:
	_hud = hud


func get_available_phase2_actions() -> Array:
	if current_session == null:
		return []
	var protagonist := _data_repository().call("get_character", current_session.protagonist_id) as CharacterDefinition
	var runtime_state := current_session.get_character_state(current_session.protagonist_id)
	var visit_targets := _get_visit_targets(protagonist, runtime_state)
	return _phase2_action_catalog.get_available_actions(current_session, protagonist, runtime_state, visit_targets)


func get_phase2_action_categories() -> Array:
	return _phase2_action_catalog.get_categories()


func get_relation_overview() -> Array:
	var relations: Array = []
	if current_session == null:
		return relations
	for key in current_session.get_relation_keys_for_character(current_session.protagonist_id):
		var relation: Variant = current_session.get_relation_state(key)
		if relation != null:
			relations.append(relation)
	return relations


func get_character_selector_rows(context_id: String) -> Array:
	var rows: Array = []
	if current_session == null:
		return rows
	var protagonist := _data_repository().call("get_character", current_session.protagonist_id) as CharacterDefinition
	var runtime_state := current_session.get_character_state(current_session.protagonist_id)
	for character in _get_selector_characters():
		if character == null:
			continue
		if protagonist != null and character.id == protagonist.id:
			continue
		var relation = current_session.get_relation_state("%s->%s" % [current_session.protagonist_id, character.id])
		var faction = _data_repository().call("get_faction", character.faction_id)
		var city = _data_repository().call("get_city", character.city_id)
		var disabled_reason := ""
		var interaction_status := "可查看"
		var selectable := true
		if context_id == "visit":
			if runtime_state == null or character.city_id != runtime_state.current_city_id:
				disabled_reason = "当前不在同地"
				interaction_status = "不可拜访"
				selectable = false
			else:
				interaction_status = "可拜访"
		rows.append(CHARACTER_SELECTOR_ROW_SCRIPT.create(
			character.id,
			character.name,
			str(faction.name if faction != null else "—"),
			str(city.name if city != null else "—"),
			int(relation.favor if relation != null else 0),
			int(relation.trust if relation != null else 0),
			int(relation.respect if relation != null else 0),
			int(relation.vigilance if relation != null else 0),
			interaction_status,
			selectable,
			disabled_reason
		))
	return rows


func get_character_profile_view_data(character_id: String) -> Variant:
	if current_session == null:
		return null
	var character := _data_repository().call("get_character", character_id) as CharacterDefinition
	if character == null:
		return null
	var relation = current_session.get_relation_state("%s->%s" % [current_session.protagonist_id, character.id])
	var faction = _data_repository().call("get_faction", character.faction_id)
	var city = _data_repository().call("get_city", character.city_id)
	var notes: Array[String] = []
	var political_role_label := _political_role_label(character.id)
	notes.append("当前所在地：%s" % str(city.name if city != null else "未知"))
	notes.append("与主角关系可直接用于拜访、观察与后续政治判断。")
	notes.append("政治角色：%s" % political_role_label)
	return CHARACTER_PROFILE_VIEW_DATA_SCRIPT.create(
		character.id,
		character.name,
		_localized_identity(character.identity_type),
		str(faction.name if faction != null else "—"),
		str(city.name if city != null else "—"),
		_localized_office(character.office_id),
		int(relation.favor if relation != null else 0),
		int(relation.trust if relation != null else 0),
		int(relation.respect if relation != null else 0),
		int(relation.vigilance if relation != null else 0),
		int(relation.obligation if relation != null else 0),
		political_role_label,
		notes
	)


func get_hud_political_summary() -> Dictionary:
	if current_session == null:
		return {}
	var repository := _data_repository()
	var snapshot = _current_political_snapshot()
	var recommender_name := "暂无明确推荐人"
	var blocker_name := "暂无明确阻力"
	var opportunity_text := "当前机会：先领受一项政治来源任务。"
	if snapshot != null:
		if not snapshot.primary_recommender_ids.is_empty():
			recommender_name = "%s 愿意继续出面。" % _character_name(snapshot.primary_recommender_ids[0])
		if not snapshot.primary_opposer_ids.is_empty():
			blocker_name = "%s 仍在观望甚至反对。" % _character_name(snapshot.primary_opposer_ids[0])
		elif not snapshot.blocker_tags.is_empty():
			blocker_name = "主要阻力：%s" % str(snapshot.blocker_tags[0])
		if not snapshot.opportunity_tags.is_empty():
			opportunity_text = "当前机会：%s" % _localized_opportunity(str(snapshot.opportunity_tags[0]))
		elif not snapshot.qualification_tags.is_empty():
			opportunity_text = "资格短板：尚需继续稳固 %s。" % str(snapshot.qualification_tags[0])
	return {
		"recommender": recommender_name,
		"blocker": blocker_name,
		"opportunity": opportunity_text,
	}


func get_faction_overview_payload() -> Dictionary:
	if current_session == null:
		return {}
	var protagonist := _data_repository().call("get_character", current_session.protagonist_id) as CharacterDefinition
	var faction_id := str(protagonist.faction_id if protagonist != null else "")
	var snapshot: Variant = _current_political_snapshot()
	var overview: Dictionary = _faction_system.get_faction_overview(faction_id, current_session)
	var bloc_rows: Array[Dictionary] = _faction_system.get_bloc_rows(faction_id, current_session, snapshot)
	var resource_summary: Dictionary = _faction_system.get_resource_summary(faction_id)
	var city_names: Array[String] = []
	var faction = _data_repository().call("get_faction", faction_id) as FactionDefinition
	if faction != null:
		for city_id in faction.city_ids:
			city_names.append(_city_name(str(city_id)))
	return {
		"overview": overview,
		"bloc_rows": bloc_rows,
		"resource_summary": resource_summary,
		"major_officer_ids": Array(overview.get("major_officer_ids", [])).duplicate(),
		"city_names": city_names,
		"political_summary": get_hud_political_summary(),
	}


func _current_political_snapshot() -> Variant:
	if current_session == null:
		return null
	if current_session.current_month_political_snapshot != null:
		return current_session.current_month_political_snapshot
	if current_session.current_month_task != null:
		return _political_system.build_snapshot(current_session, _data_repository(), {"task_result": str((current_session.current_month_task as MonthlyTaskState).status)})
	return null


func _character_name(character_id: String) -> String:
	var character = _data_repository().call("get_character", character_id) as CharacterDefinition
	return str(character.name if character != null else character_id)


func _city_name(city_id: String) -> String:
	var city = _data_repository().call("get_city", city_id) as CityDefinition
	return str(city.name if city != null else city_id)


func _localized_opportunity(tag: String) -> String:
	match tag:
		"relation_backing":
			return "关系请求已形成背书，可继续巩固请求方。"
		"direct_order_visibility":
			return "主公直接交办，当前可见度已经打开。"
		"vacancy_open":
			return "当前确有空缺，可争取本月任命。"
		_:
			return tag


func _political_role_label(character_id: String) -> String:
	var snapshot = _current_political_snapshot()
	if snapshot == null:
		return "观察者"
	if snapshot.primary_recommender_ids.has(character_id):
		return "推荐人"
	if snapshot.primary_opposer_ids.has(character_id):
		return "阻力来源"
	return "观察者"


func execute_phase2_action(action_id: String, target_character_id: String = "") -> Variant:
	if current_session == null:
		return null
	if current_session.month_action_locked:
		_latest_action_resolution = ACTION_RESOLUTION_SCRIPT.create(
			action_id,
			"本月尚未领受公事",
			false,
			"本月尚未领受公事，请先择定一项本月任务。",
			target_character_id,
			{},
			{},
			"待本月任务锁定后，旬内行动才会计入本月事务。",
			"本月行动被暂缓，等待先领本月任务。"
		)
		return _latest_action_resolution
	var protagonist := _data_repository().call("get_character", current_session.protagonist_id) as CharacterDefinition
	var target_character: Variant = null
	if not target_character_id.is_empty():
		target_character = _data_repository().call("get_character", target_character_id) as CharacterDefinition
	_latest_action_resolution = _phase2_action_resolver.execute(action_id, current_session, protagonist, target_character)
	current_session.append_action_resolution(_latest_action_resolution)
	if _latest_action_resolution != null and bool(_latest_action_resolution.success):
		_task_system.append_progress_from_action(current_session, _data_repository(), action_id)
	return _latest_action_resolution


func get_pending_month_tasks() -> Array:
	if current_session == null:
		return []
	return current_session.pending_month_task_candidates.duplicate(true)


func select_month_task(selected_index: int) -> Variant:
	if current_session == null:
		return null
	var task_state = _task_system.select_month_task(current_session, _data_repository(), selected_index)
	if task_state != null and _hud != null:
		_hud.show_success_state(current_session)
	return task_state


func _initialize_month_start_state() -> void:
	if current_session == null:
		return
	current_session.pending_month_task_candidates = _task_system.generate_month_candidates(current_session, _data_repository())
	current_session.current_month_task = null
	current_session.month_action_locked = true


func get_latest_action_resolution() -> Variant:
	return _latest_action_resolution


func end_current_xun() -> Variant:
	if current_session == null:
		return null
	var finishing_label: String = str(_time_manager().call("get_xun_label", current_session.current_year, current_session.current_month, current_session.current_xun))
	var summary: Variant = _build_xun_summary(finishing_label)
	current_session.latest_xun_summary = summary
	if current_session.current_xun == 3:
		_process_month_end_evaluation()
	_reset_protagonist_ap()
	current_session.clear_xun_action_history()
	_time_manager().call("advance_xun")
	current_session.current_year = int(_time_manager().call("get_current_year"))
	current_session.current_month = int(_time_manager().call("get_current_month"))
	current_session.current_xun = int(_time_manager().call("get_current_xun"))
	if current_session.current_xun == 1:
		_initialize_month_start_state()
	return summary


func get_last_month_evaluation() -> Variant:
	if current_session == null:
		return null
	return current_session.last_month_evaluation


func consume_last_month_evaluation() -> Variant:
	if current_session == null:
		return null
	var evaluation = current_session.last_month_evaluation
	current_session.clear_last_month_evaluation()
	return evaluation


func _process_month_end_evaluation() -> void:
	var task_state: MonthlyTaskState = current_session.current_month_task as MonthlyTaskState
	var progress_snapshot = task_state.progress_snapshot if task_state != null else null
	var task_template = _data_repository().call("get_task_template", task_state.task_template_id if task_state != null else "")
	var settlement: Dictionary = _task_system.settle_month_task(current_session, _data_repository())
	var runtime_state: RuntimeCharacterState = current_session.get_character_state(current_session.protagonist_id)
	var career_state: PlayerCareerState = current_session.player_career_state as PlayerCareerState
	if runtime_state != null:
		runtime_state.merit += int(settlement.get("merit_delta", 0))
		runtime_state.fame += int(settlement.get("fame_delta", 0))
		runtime_state.trust += int(settlement.get("trust_delta", 0))
	if career_state != null:
		career_state.total_merit = runtime_state.merit if runtime_state != null else career_state.total_merit
		career_state.current_fame = runtime_state.fame if runtime_state != null else career_state.current_fame
		career_state.current_trust = runtime_state.trust if runtime_state != null else career_state.current_trust
		career_state.months_in_current_office += 1
	var qualification_result: Dictionary = _career_system.evaluate_qualification(current_session, _data_repository(), settlement)
	var political_snapshot: PoliticalSupportSnapshot = _political_system.finalize_month_snapshot(current_session, _data_repository(), settlement)
	var appointment_result: Dictionary = _appointment_resolver.evaluate_month_end(current_session, _data_repository(), _faction_system, political_snapshot, qualification_result, settlement)
	current_session.current_month_candidate_evaluations = Array(appointment_result.get("candidate_evaluations", [])).duplicate(true)
	var player_evaluation: AppointmentCandidateEvaluation = appointment_result.get("player_evaluation") as AppointmentCandidateEvaluation
	var old_office_id := career_state.current_office_id if career_state != null else ""
	var new_office_id := old_office_id
	var office_changed := false
	if player_evaluation != null and str(player_evaluation.final_decision) == "appointed" and career_state != null:
		new_office_id = str(qualification_result.get("new_office_id", old_office_id))
		office_changed = new_office_id != old_office_id
		career_state.current_office_id = new_office_id
		career_state.months_in_current_office = 0
		var new_office = _data_repository().call("get_office", new_office_id)
		career_state.office_tier = int(new_office.tier if new_office != null else career_state.office_tier)
		career_state.unlocked_task_tags = Array(new_office.unlock_task_tags).duplicate() if new_office != null else career_state.unlocked_task_tags
		career_state.office_tags = Array(new_office.office_tags).duplicate() if new_office != null else career_state.office_tags
		career_state.visible_political_panels = Array(new_office.visible_political_panels).duplicate() if new_office != null else career_state.visible_political_panels
		career_state.recommendation_power = int(new_office.recommendation_power if new_office != null else career_state.recommendation_power)
		career_state.candidate_office_tags = Array(new_office.candidate_office_tags).duplicate() if new_office != null else career_state.candidate_office_tags
		career_state.political_risk_level = str(new_office.political_risk_level if new_office != null else career_state.political_risk_level)
		career_state.action_permission_tags = Array(new_office.permission_tags).duplicate() if new_office != null else career_state.action_permission_tags
	var summary_lines: Array[String] = []
	for line in Array(settlement.get("summary_lines", [])):
		summary_lines.append(str(line))
	if office_changed:
		summary_lines.append("任命结果：已擢升至 %s" % new_office_id)
	else:
		summary_lines.append("任命结果：%s" % str(player_evaluation.final_decision if player_evaluation != null else qualification_result.get("failure_label", "")))
	var visible_reason_lines: Array = Array(appointment_result.get("visible_reason_lines", []))
	var support_lines: Array[String] = Array(appointment_result.get("primary_support_lines", []))
	var blocker_lines: Array[String] = Array(appointment_result.get("primary_blocker_lines", []))
	current_session.set_last_month_evaluation(MONTHLY_EVALUATION_RESULT_SCRIPT.create(
		"%d-%02d" % [current_session.current_year, current_session.current_month],
		current_session.protagonist_id,
		str(settlement.get("task_result", "failed")),
		int(settlement.get("merit_delta", 0)),
		int(settlement.get("fame_delta", 0)),
		int(settlement.get("trust_delta", 0)),
		office_changed,
		old_office_id,
		new_office_id,
		str(qualification_result.get("rule_id", "")),
		str(task_template.name if task_template != null else task_state.task_template_id if task_state != null else "—"),
		int(progress_snapshot.current_value if progress_snapshot != null else 0),
		int(progress_snapshot.target_value if progress_snapshot != null else 0),
		int(progress_snapshot.bonus_value if progress_snapshot != null else 0),
		summary_lines,
		str(player_evaluation.next_goal_hint if player_evaluation != null else qualification_result.get("hint", "")),
		Dictionary(qualification_result.get("missing_values", {})).duplicate(true),
		str(qualification_result.get("failure_label", "")),
		str(appointment_result.get("appointment_result", "pending")),
		Array(appointment_result.get("candidate_evaluations", [])).duplicate(true),
		support_lines,
		blocker_lines,
		str(appointment_result.get("missed_opportunity_note", "")),
		str(appointment_result.get("next_month_political_hint", "")),
		str(appointment_result.get("primary_support_identity", "")),
		str(appointment_result.get("primary_blocker_identity", "")),
		str(appointment_result.get("political_forces_summary", ""))
	))


func get_latest_xun_summary() -> Variant:
	if current_session == null:
		return null
	return current_session.latest_xun_summary


func _get_visit_targets(protagonist: CharacterDefinition, runtime_state: RuntimeCharacterState) -> Array[CharacterDefinition]:
	var targets: Array[CharacterDefinition] = []
	if protagonist == null or runtime_state == null:
		return targets
	for character in _data_repository().call("get_characters_in_city", runtime_state.current_city_id):
		if character == null:
			continue
		if character.id == protagonist.id:
			continue
		targets.append(character)
	return targets


func _get_selector_characters() -> Array:
	var characters: Array = []
	if current_session == null:
		return characters
	var scenario = _data_repository().call("get_scenario", current_session.scenario_id)
	if scenario == null:
		return characters
	for character_id in scenario.character_ids:
		var character = _data_repository().call("get_character", str(character_id))
		if character != null:
			characters.append(character)
	return characters


func _localized_identity(value: String) -> String:
	match value:
		"ruler":
			return "君主"
		"civil_official":
			return "文官"
		"military_officer":
			return "武官"
		"free_agent":
			return "游士"
		_:
			return value if not value.is_empty() else "—"


func _localized_office(value: String) -> String:
	match value:
		"lord":
			return "领主"
		"chief_advisor":
			return "首席谋臣"
		"frontline_commander":
			return "前线统兵"
		"hegemon_claimant":
			return "盟主争衡者"
		"":
			return "无官职"
		_:
			return value


func _build_xun_summary(finishing_label: String) -> Variant:
	var action_lines: Array[String] = []
	var stat_delta_totals: Dictionary = {}
	var relation_change_lines: Array[String] = []
	for result in current_session.current_xun_action_history:
		if result == null:
			continue
		action_lines.append(str(result.summary_line).strip_edges() if not str(result.summary_line).strip_edges().is_empty() else str(result.title))
		for key in result.stat_deltas.keys():
			stat_delta_totals[key] = int(stat_delta_totals.get(key, 0)) + int(result.stat_deltas[key])
		if not result.relation_deltas.is_empty():
			var target_name := _relation_target_name(str(result.target_character_id))
			relation_change_lines.append("%s：%s" % [target_name, _format_relation_delta_line(result.relation_deltas)])
	if action_lines.is_empty():
		action_lines.append("本旬未执行行动。")
	if relation_change_lines.is_empty():
		relation_change_lines.append("本旬关系变化较少。")
	var prompt_lines: Array[String] = [_build_prompt_line(stat_delta_totals)]
	return XUN_SUMMARY_DATA_SCRIPT.create(finishing_label, action_lines, stat_delta_totals, relation_change_lines, prompt_lines)


func _reset_protagonist_ap() -> void:
	var protagonist := _data_repository().call("get_character", current_session.protagonist_id) as CharacterDefinition
	var runtime_state := current_session.get_character_state(current_session.protagonist_id)
	if protagonist == null or runtime_state == null:
		return
	runtime_state.ap = int(protagonist.status_values.get("ap", runtime_state.ap))


func _relation_target_name(target_character_id: String) -> String:
	if target_character_id.is_empty():
		return "关系变化"
	var target := _data_repository().call("get_character", target_character_id) as CharacterDefinition
	if target == null:
		return target_character_id
	return target.name


func _format_relation_delta_line(relation_deltas: Dictionary) -> String:
	var parts: Array[String] = []
	for key in relation_deltas.keys():
		parts.append("%s %s" % [key, _signed_delta(int(relation_deltas[key]))])
	return "，".join(parts)


func _build_prompt_line(stat_delta_totals: Dictionary) -> String:
	var runtime_state := current_session.get_character_state(current_session.protagonist_id)
	if runtime_state != null and runtime_state.energy <= 40:
		return "新提示：下旬应优先考虑休整，避免低精力拖累连续行动。"
	if int(stat_delta_totals.get("merit", 0)) > 0:
		return "新提示：本旬功绩已有积累，下旬可继续巡察或扩展关键拜访。"
	return "新提示：根据本旬关系变化规划下一步，优先巩固最有价值的人物联系。"


func _signed_delta(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)
