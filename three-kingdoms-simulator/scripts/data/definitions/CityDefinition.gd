extends RefCounted
class_name CityDefinition

var id: String = ""
var name: String = ""
var region: String = ""
var owner_faction_id: String = ""
var governor_id: String = ""
var character_ids: Array[String] = []
var values: Dictionary = {}


static func from_dictionary(data: Dictionary) -> CityDefinition:
	var definition := CityDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.region = str(data.get("region", ""))
	definition.owner_faction_id = str(data.get("owner_faction_id", ""))
	definition.governor_id = str(data.get("governor_id", ""))
	definition.character_ids = _to_string_array(data.get("character_ids", []))
	definition.values = Dictionary(data.get("values", {}))
	return definition


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item in value:
		result.append(str(item))
	return result
