extends RefCounted
class_name Phase2ActionSpec

var id: String = ""
var display_name: String = ""
var category_id: String = ""
var ap_cost: int = 0
var energy_delta: int = 0
var target_type: String = ""
var effect_summary: String = ""
var required_permission_tags: Array[String] = []
var disabled_reason: String = ""
var hidden_when_locked: bool = false


static func create(
	action_id: String,
	action_display_name: String,
	category: String,
	ap: int,
	energy: int,
	target: String,
	summary: String,
	permission_tags: Array[String] = [],
	reason: String = "",
	hide_when_locked: bool = false
) -> Phase2ActionSpec:
	var spec := Phase2ActionSpec.new()
	spec.id = action_id
	spec.display_name = action_display_name
	spec.category_id = category
	spec.ap_cost = ap
	spec.energy_delta = energy
	spec.target_type = target
	spec.effect_summary = summary
	spec.required_permission_tags = permission_tags.duplicate()
	spec.disabled_reason = reason
	spec.hidden_when_locked = hide_when_locked
	return spec
