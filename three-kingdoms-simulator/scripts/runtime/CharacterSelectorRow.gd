extends RefCounted
class_name CharacterSelectorRow

var character_id: String = ""
var display_name: String = ""
var faction_name: String = ""
var city_name: String = ""
var favor: int = 0
var trust: int = 0
var respect: int = 0
var vigilance: int = 0
var interaction_status: String = ""
var selectable: bool = false
var disabled_reason: String = ""


static func create(
	character_id_value: String,
	display_name_value: String,
	faction_name_value: String,
	city_name_value: String,
	favor_value: int,
	trust_value: int,
	respect_value: int,
	vigilance_value: int,
	interaction_status_value: String,
	selectable_value: bool,
	disabled_reason_value: String
) -> Variant:
	var row := new()
	row.character_id = character_id_value
	row.display_name = display_name_value
	row.faction_name = faction_name_value
	row.city_name = city_name_value
	row.favor = favor_value
	row.trust = trust_value
	row.respect = respect_value
	row.vigilance = vigilance_value
	row.interaction_status = interaction_status_value
	row.selectable = selectable_value
	row.disabled_reason = disabled_reason_value
	return row
