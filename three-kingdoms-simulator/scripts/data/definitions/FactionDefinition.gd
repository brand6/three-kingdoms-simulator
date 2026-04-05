extends RefCounted
class_name FactionDefinition

var id: String = ""
var name: String = ""
var ruler_id: String = ""
var capital_city_id: String = ""
var city_ids: Array[String] = []
var officer_ids: Array[String] = []
var resources: Dictionary = {}


static func from_dictionary(data: Dictionary) -> FactionDefinition:
	var definition := FactionDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.ruler_id = str(data.get("ruler_id", ""))
	definition.capital_city_id = str(data.get("capital_city_id", ""))
	definition.city_ids = _to_string_array(data.get("city_ids", []))
	definition.officer_ids = _to_string_array(data.get("officer_ids", []))
	definition.resources = Dictionary(data.get("resources", {}))
	return definition


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item in value:
		result.append(str(item))
	return result
