extends Node

const DEFAULT_SCENARIO_ID := "scenario_190_smoke"
const DEFAULT_PROTAGONIST_ID := "cao_cao"
const PHASE2_ACTION_CATALOG_SCRIPT := preload("res://scripts/systems/Phase2ActionCatalog.gd")
const PHASE2_ACTION_RESOLVER_SCRIPT := preload("res://scripts/systems/Phase2ActionResolver.gd")
const XUN_SUMMARY_DATA_SCRIPT := preload("res://scripts/runtime/XunSummaryData.gd")
const CHARACTER_SELECTOR_ROW_SCRIPT := preload("res://scripts/runtime/CharacterSelectorRow.gd")
const CHARACTER_PROFILE_VIEW_DATA_SCRIPT := preload("res://scripts/runtime/CharacterProfileViewData.gd")

var current_session: GameSession
var last_boot_error: String = ""
var _hud: MainHUD
var _phase2_action_catalog: Variant = PHASE2_ACTION_CATALOG_SCRIPT.new()
var _phase2_action_resolver: Variant = PHASE2_ACTION_RESOLVER_SCRIPT.new()
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
	current_session = _data_repository().call("bootstrap_session", DEFAULT_SCENARIO_ID, DEFAULT_PROTAGONIST_ID) as GameSession
	if current_session == null:
		show_boot_error("默认数据集或主角 ID 无法载入。")
		return

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
	return _phase2_action_catalog.get_available_actions(protagonist, runtime_state, visit_targets)


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
	notes.append("当前所在地：%s" % str(city.name if city != null else "未知"))
	notes.append("与主角关系可直接用于拜访、观察与后续政治判断。")
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
		notes
	)


func execute_phase2_action(action_id: String, target_character_id: String = "") -> Variant:
	if current_session == null:
		return null
	var protagonist := _data_repository().call("get_character", current_session.protagonist_id) as CharacterDefinition
	var target_character: Variant = null
	if not target_character_id.is_empty():
		target_character = _data_repository().call("get_character", target_character_id) as CharacterDefinition
	_latest_action_resolution = _phase2_action_resolver.execute(action_id, current_session, protagonist, target_character)
	current_session.append_action_resolution(_latest_action_resolution)
	return _latest_action_resolution


func get_latest_action_resolution() -> Variant:
	return _latest_action_resolution


func end_current_xun() -> Variant:
	if current_session == null:
		return null
	var finishing_label: String = str(_time_manager().call("get_xun_label", current_session.current_year, current_session.current_month, current_session.current_xun))
	var summary: Variant = _build_xun_summary(finishing_label)
	current_session.latest_xun_summary = summary
	_reset_protagonist_ap()
	current_session.clear_xun_action_history()
	_time_manager().call("advance_xun")
	current_session.current_year = int(_time_manager().call("get_current_year"))
	current_session.current_month = int(_time_manager().call("get_current_month"))
	current_session.current_xun = int(_time_manager().call("get_current_xun"))
	return summary


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
