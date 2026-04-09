extends RefCounted
class_name Phase2ActionCatalog

const PHASE2_ACTION_SPEC_SCRIPT := preload("res://scripts/runtime/Phase2ActionSpec.gd")

const CATEGORY_GROWTH := "成长"
const CATEGORY_RELATION := "关系"
const CATEGORY_GOVERNANCE := "政务"
const CATEGORY_MILITARY := "军事"
const CATEGORY_FAMILY := "家族"
const CATEGORY_MOVE := "移动"

const REASON_NO_AP := "AP 不足"
const REASON_NO_ENERGY := "精力不足"
const REASON_WRONG_LOCATION := "当前地点不可执行"
const REASON_NO_VISIT_TARGET := "暂无可拜访对象"
const REASON_IDENTITY_LOCKED := "当前身份不可执行"

const CATEGORIES := [
	CATEGORY_GROWTH,
	CATEGORY_RELATION,
	CATEGORY_GOVERNANCE,
	CATEGORY_MILITARY,
	CATEGORY_FAMILY,
	CATEGORY_MOVE,
]


func get_categories() -> Array:
	return CATEGORIES.duplicate()


func get_available_actions(
	session: GameSession,
	protagonist: CharacterDefinition,
	runtime_state: RuntimeCharacterState,
	visit_targets: Array[CharacterDefinition]
) -> Array:
	var actions: Array = []
	for action_record in _get_action_records():
		var action_id := str(action_record.get("id", ""))
		if action_id.is_empty():
			continue
		var spec = _build_spec_from_record(action_record)
		if spec == null:
			continue
		if _is_office_forbidden(session, action_record):
			continue
		spec.disabled_reason = _get_disabled_reason(spec, protagonist, runtime_state, visit_targets, action_record)
		actions.append(spec)
	return actions


func _data_repository() -> Node:
	return Engine.get_main_loop().root.get_node("/root/DataRepository")


func _build_spec_from_record(action_record: Dictionary) -> Variant:
	var action_id := str(action_record.get("id", ""))
	if action_id.is_empty():
		return null
	var spec = PHASE2_ACTION_SPEC_SCRIPT.create(
		action_id,
		str(action_record.get("display_name", "")),
		str(action_record.get("category_id", CATEGORY_GROWTH)),
		int(action_record.get("ap_cost", 0)),
		int(action_record.get("energy_delta", 0)),
		str(action_record.get("target_type", "none")),
		str(action_record.get("effect_summary", "")),
		_to_string_array(action_record.get("required_permission_tags", [])),
		"",
		bool(action_record.get("hidden_when_locked", false))
	)
	return spec


func _get_action_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var menu_config = _data_repository().call("get_action_menu_config")
	for item in _data_repository().call("get_actions"):
		var record := Dictionary(item).duplicate(true)
		if menu_config != null and menu_config.has_method("get_rule"):
			record.merge(Dictionary(menu_config.get_rule(str(record.get("id", "")))), true)
		records.append(record)
	return records


func _is_office_forbidden(session: GameSession, rule: Dictionary) -> bool:
	if session == null or session.player_career_state == null:
		return false
	var required_office_tags := _to_string_array(rule.get("required_office_tags", rule.get("office_restrictions", [])))
	if required_office_tags.is_empty():
		return false
	var current_tags := Array((session.player_career_state as PlayerCareerState).office_tags)
	for office_tag in required_office_tags:
		if current_tags.has(str(office_tag)):
			return false
	return true


func _is_identity_locked(rule: Dictionary, protagonist: CharacterDefinition) -> bool:
	if protagonist == null:
		return true
	var allowed_identities := _to_string_array(rule.get("allowed_identity_types", []))
	if allowed_identities.is_empty():
		return false
	return not allowed_identities.has(protagonist.identity_type)


func _get_disabled_reason(
	spec: Variant,
	protagonist: CharacterDefinition,
	runtime_state: RuntimeCharacterState,
	visit_targets: Array[CharacterDefinition],
	rule: Dictionary
) -> String:
	if _is_identity_locked(rule, protagonist):
		return str(rule.get("locked_reason", REASON_IDENTITY_LOCKED))
	if runtime_state == null:
		return REASON_NO_AP
	if runtime_state.ap < spec.ap_cost:
		return REASON_NO_AP
	if spec.energy_delta < 0 and runtime_state.energy < abs(spec.energy_delta):
		return REASON_NO_ENERGY
	if spec.id == "visit" and visit_targets.is_empty():
		return REASON_NO_VISIT_TARGET
	if spec.id == "inspect" and protagonist != null and runtime_state.current_city_id != protagonist.city_id:
		return REASON_WRONG_LOCATION
	if spec.id == "inspect_subordinates" and visit_targets.is_empty():
		return str(rule.get("disabled_reason", "暂无可监察属员"))
	if spec.id == "review_memorials" and protagonist != null and runtime_state.current_city_id != protagonist.city_id:
		return str(rule.get("disabled_reason", REASON_WRONG_LOCATION))
	return ""


func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item in Array(value):
		result.append(str(item))
	return result
