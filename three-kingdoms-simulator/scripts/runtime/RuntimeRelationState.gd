extends RefCounted
class_name RuntimeRelationState

var source_character_id: String = ""
var target_character_id: String = ""
var favor: int = 0
var trust: int = 0
var respect: int = 0
var vigilance: int = 0
var obligation: int = 0


static func create(
	source_id: String,
	target_id: String,
	favor_value: int,
	trust_value: int,
	respect_value: int,
	vigilance_value: int,
	obligation_value: int
) -> Variant:
	var state := new()
	state.source_character_id = source_id
	state.target_character_id = target_id
	state.favor = favor_value
	state.trust = trust_value
	state.respect = respect_value
	state.vigilance = vigilance_value
	state.obligation = obligation_value
	return state
