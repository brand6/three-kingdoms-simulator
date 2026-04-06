extends RefCounted
class_name Phase2ActionCatalog

const PHASE2_ACTION_SPEC_SCRIPT := preload("res://scripts/runtime/Phase2ActionSpec.gd")

const CATEGORY_GROWTH := "成长"
const CATEGORY_RELATION := "关系"
const CATEGORY_GOVERNANCE := "政务"
const CATEGORY_MILITARY := "军事"
const CATEGORY_FAMILY := "家族"

const REASON_NO_AP := "AP 不足"
const REASON_NO_ENERGY := "精力不足"
const REASON_WRONG_LOCATION := "当前地点不可执行"
const REASON_NO_VISIT_TARGET := "暂无可拜访对象"

const CATEGORIES := [
	CATEGORY_GROWTH,
	CATEGORY_RELATION,
	CATEGORY_GOVERNANCE,
	CATEGORY_MILITARY,
	CATEGORY_FAMILY,
]


func get_categories() -> Array:
	return CATEGORIES.duplicate()


func get_available_actions(
	protagonist: CharacterDefinition,
	runtime_state: RuntimeCharacterState,
	visit_targets: Array[CharacterDefinition]
) -> Array:
	var actions: Array = []
	for base_spec in _build_base_specs():
		if _is_permission_locked(base_spec, protagonist):
			continue
		var spec = PHASE2_ACTION_SPEC_SCRIPT.create(
			base_spec.id,
			base_spec.display_name,
			base_spec.category_id,
			base_spec.ap_cost,
			base_spec.energy_delta,
			base_spec.target_type,
			base_spec.effect_summary,
			base_spec.required_permission_tags,
			"",
			base_spec.hidden_when_locked
		)
		spec.disabled_reason = _get_disabled_reason(spec, protagonist, runtime_state, visit_targets)
		actions.append(spec)
	return actions


func _build_base_specs() -> Array:
	var specs: Array = []
	specs.append(PHASE2_ACTION_SPEC_SCRIPT.create("train", "训练", CATEGORY_GROWTH, 1, -10, "none", "效果: 武艺历练 +6，压力 +3，功绩 +1"))
	specs.append(PHASE2_ACTION_SPEC_SCRIPT.create("study", "读书", CATEGORY_GROWTH, 1, -8, "none", "效果: 智略历练 +6，压力 +2，名望 +1"))
	specs.append(PHASE2_ACTION_SPEC_SCRIPT.create("rest", "休整", CATEGORY_GROWTH, 1, 20, "none", "效果: 精力 +20，压力 -12"))
	specs.append(PHASE2_ACTION_SPEC_SCRIPT.create("visit", "拜访", CATEGORY_RELATION, 1, -8, "character", "效果: 好感 +10，信任 +6，敬重 +2，戒备 -4"))
	specs.append(PHASE2_ACTION_SPEC_SCRIPT.create("inspect", "巡察", CATEGORY_GOVERNANCE, 1, -10, "none", "效果: 功绩 +5，政务历练 +4，压力 +4", ["inspect", "lead"], "", true))
	return specs


func _is_permission_locked(spec: Variant, protagonist: CharacterDefinition) -> bool:
	if protagonist == null:
		return spec.hidden_when_locked
	if spec.required_permission_tags.is_empty():
		return false
	for tag in spec.required_permission_tags:
		if protagonist.permission_tags.has(tag):
			return false
	return spec.hidden_when_locked


func _get_disabled_reason(
	spec: Variant,
	protagonist: CharacterDefinition,
	runtime_state: RuntimeCharacterState,
	visit_targets: Array[CharacterDefinition]
) -> String:
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
	return ""
