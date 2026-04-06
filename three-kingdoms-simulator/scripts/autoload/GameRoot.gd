extends Node

const DEFAULT_SCENARIO_ID := "scenario_190_smoke"
const DEFAULT_PROTAGONIST_ID := "cao_cao"
const PHASE2_ACTION_CATALOG_SCRIPT := preload("res://scripts/systems/Phase2ActionCatalog.gd")

var current_session: GameSession
var last_boot_error: String = ""
var _hud: MainHUD
var _phase2_action_catalog: Variant = PHASE2_ACTION_CATALOG_SCRIPT.new()
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


func get_relation_overview() -> Array:
	var relations: Array = []
	if current_session == null:
		return relations
	for key in current_session.get_relation_keys_for_character(current_session.protagonist_id):
		var relation: Variant = current_session.get_relation_state(key)
		if relation != null:
			relations.append(relation)
	return relations


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
