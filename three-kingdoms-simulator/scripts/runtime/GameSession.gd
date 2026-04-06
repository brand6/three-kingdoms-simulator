extends RefCounted
class_name GameSession

const schema_version: int = 1

var scenario_id: String = ""
var current_year: int = 0
var current_month: int = 0
var current_xun: int = 0
var protagonist_id: String = ""
var character_states: Dictionary = {}
var relation_states: Dictionary = {}
var current_xun_action_history: Array = []
var latest_xun_summary: Variant = null


func set_character_state(character_id: String, state: RuntimeCharacterState) -> void:
	character_states[character_id] = state


func get_character_state(character_id: String) -> RuntimeCharacterState:
	return character_states.get(character_id) as RuntimeCharacterState


func set_relation_state(key: String, state: Variant) -> void:
	relation_states[key] = state


func get_relation_state(key: String) -> Variant:
	return relation_states.get(key)


func append_action_resolution(result: Variant) -> void:
	current_xun_action_history.append(result)


func clear_xun_action_history() -> void:
	current_xun_action_history.clear()


func get_relation_keys_for_character(character_id: String) -> Array[String]:
	var keys: Array[String] = []
	for relation_key in relation_states.keys():
		var relation_state: Variant = relation_states.get(relation_key)
		if relation_state == null:
			continue
		if relation_state.source_character_id == character_id or relation_state.target_character_id == character_id:
			keys.append(str(relation_key))
	return keys
