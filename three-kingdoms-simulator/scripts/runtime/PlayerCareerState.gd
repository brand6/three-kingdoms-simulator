extends RefCounted
class_name PlayerCareerState

var character_id: String = ""
var current_office_id: String = ""
var office_tier: int = 0
var total_merit: int = 0
var current_fame: int = 0
var current_trust: int = 0
var months_in_current_office: int = 0
var promotion_history: Array[Dictionary] = []
var last_evaluation_result: Variant = null
var unlocked_task_tags: Array[String] = []
var career_flags: Array[String] = []
var office_tags: Array[String] = []
var visible_political_panels: Array[String] = []
var recommendation_power: int = 0
var candidate_office_tags: Array[String] = []
var political_risk_level: String = "low"
var action_permission_tags: Array[String] = []


static func create(
	character_id_value: String,
	current_office_id_value: String,
	office_tier_value: int,
	total_merit_value: int,
	current_fame_value: int,
	current_trust_value: int,
	months_in_current_office_value: int = 0,
	promotion_history_value: Array[Dictionary] = [],
	last_evaluation_result_value: Variant = null,
	unlocked_task_tags_value: Array[String] = [],
	career_flags_value: Array[String] = [],
	office_tags_value: Array[String] = [],
	visible_political_panels_value: Array[String] = [],
	recommendation_power_value: int = 0,
	candidate_office_tags_value: Array[String] = [],
	political_risk_level_value: String = "low",
	action_permission_tags_value: Array[String] = []
) -> PlayerCareerState:
	var state := PlayerCareerState.new()
	state.character_id = character_id_value
	state.current_office_id = current_office_id_value
	state.office_tier = office_tier_value
	state.total_merit = total_merit_value
	state.current_fame = current_fame_value
	state.current_trust = current_trust_value
	state.months_in_current_office = months_in_current_office_value
	state.promotion_history = promotion_history_value.duplicate(true)
	state.last_evaluation_result = last_evaluation_result_value
	state.unlocked_task_tags = unlocked_task_tags_value.duplicate()
	state.career_flags = career_flags_value.duplicate()
	state.office_tags = office_tags_value.duplicate()
	state.visible_political_panels = visible_political_panels_value.duplicate()
	state.recommendation_power = recommendation_power_value
	state.candidate_office_tags = candidate_office_tags_value.duplicate()
	state.political_risk_level = political_risk_level_value
	state.action_permission_tags = action_permission_tags_value.duplicate()
	return state
