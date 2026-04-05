extends RefCounted
class_name CharacterDefinition

var id: String = ""
var name: String = ""
var courtesy_name: String = ""
var identity_type: String = ""
var faction_id: String = ""
var city_id: String = ""
var office_id: String = ""
var family_id: String = ""
var clan_id: String = ""
var personality_tags: Array[String] = []
var permission_tags: Array[String] = []
var stats: Dictionary = {}
var status_values: Dictionary = {}
var reputation_values: Dictionary = {}


static func from_dictionary(data: Dictionary) -> CharacterDefinition:
	var definition := CharacterDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.courtesy_name = str(data.get("courtesy_name", ""))
	definition.identity_type = str(data.get("identity_type", ""))
	definition.faction_id = str(data.get("faction_id", ""))
	definition.city_id = str(data.get("city_id", ""))
	definition.office_id = str(data.get("office_id", ""))
	definition.family_id = str(data.get("family_id", ""))
	definition.clan_id = str(data.get("clan_id", ""))
	definition.personality_tags = _to_string_array(data.get("personality_tags", []))
	definition.permission_tags = _to_string_array(data.get("permission_tags", data.get("available_action_tags", [])))
	definition.stats = Dictionary(data.get("stats", {}))
	definition.status_values = Dictionary(data.get("status_values", {}))
	definition.reputation_values = Dictionary(data.get("reputation_values", {}))
	return definition


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item in value:
		result.append(str(item))
	return result
