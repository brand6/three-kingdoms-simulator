extends RefCounted
class_name CharacterProfileViewData

var character_id: String = ""
var display_name: String = ""
var identity_label: String = ""
var faction_label: String = ""
var city_label: String = ""
var office_label: String = ""
var favor: int = 0
var trust: int = 0
var respect: int = 0
var vigilance: int = 0
var obligation: int = 0
var notes: Array[String] = []


static func create(
	character_id_value: String,
	display_name_value: String,
	identity_label_value: String,
	faction_label_value: String,
	city_label_value: String,
	office_label_value: String,
	favor_value: int,
	trust_value: int,
	respect_value: int,
	vigilance_value: int,
	obligation_value: int,
	notes_value: Array[String]
) -> Variant:
	var view_data := new()
	view_data.character_id = character_id_value
	view_data.display_name = display_name_value
	view_data.identity_label = identity_label_value
	view_data.faction_label = faction_label_value
	view_data.city_label = city_label_value
	view_data.office_label = office_label_value
	view_data.favor = favor_value
	view_data.trust = trust_value
	view_data.respect = respect_value
	view_data.vigilance = vigilance_value
	view_data.obligation = obligation_value
	view_data.notes = notes_value.duplicate()
	return view_data
