extends RefCounted
class_name RuntimeCharacterState

var character_id: String = ""
var ap: int = 0
var energy: int = 0
var stress: int = 0
var fame: int = 0
var merit: int = 0
var loyalty: int = 0
var honor: int = 0
var infamy: int = 0
var current_city_id: String = ""
var flags: Array[String] = []
var martial_exp: int = 0
var strategy_exp: int = 0
var governance_exp: int = 0


static func from_definition(character_id_value: String, city_id: String, status_values: Dictionary, reputation_values: Dictionary) -> RuntimeCharacterState:
	var state := RuntimeCharacterState.new()
	state.character_id = character_id_value
	state.ap = int(status_values.get("ap", 0))
	state.energy = int(status_values.get("energy", 0))
	state.stress = int(status_values.get("stress", 0))
	state.fame = int(reputation_values.get("fame", 0))
	state.merit = int(reputation_values.get("merit", 0))
	state.loyalty = int(reputation_values.get("loyalty", 0))
	state.honor = int(reputation_values.get("honor", 0))
	state.infamy = int(reputation_values.get("infamy", 0))
	state.current_city_id = city_id
	state.martial_exp = 0
	state.strategy_exp = 0
	state.governance_exp = 0
	return state
