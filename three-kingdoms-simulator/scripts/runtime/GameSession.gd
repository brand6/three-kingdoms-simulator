extends RefCounted
class_name GameSession

const schema_version: int = 1

var scenario_id: String = ""
var current_year: int = 0
var current_month: int = 0
var current_xun: int = 0
var protagonist_id: String = ""
var character_states: Dictionary = {}


func set_character_state(character_id: String, state: RuntimeCharacterState) -> void:
	character_states[character_id] = state


func get_character_state(character_id: String) -> RuntimeCharacterState:
	return character_states.get(character_id) as RuntimeCharacterState
