extends RefCounted
class_name ScenarioDefinition

var id: String = ""
var name: String = ""
var start_year: int = 0
var start_month: int = 0
var start_xun: int = 0
var title: String = ""
var description: String = ""
var city_ids: Array[String] = []
var faction_ids: Array[String] = []
var character_ids: Array[String] = []
var default_player_character_id: String = ""
var available_office_ids: Array[String] = []
var available_task_template_ids: Array[String] = []


static func from_dictionary(data: Dictionary) -> ScenarioDefinition:
	var definition := ScenarioDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.start_year = int(data.get("start_year", 0))
	definition.start_month = int(data.get("start_month", 0))
	definition.start_xun = int(data.get("start_xun", 0))
	definition.title = str(data.get("title", ""))
	definition.description = str(data.get("description", ""))
	definition.city_ids = _to_string_array(data.get("city_ids", []))
	definition.faction_ids = _to_string_array(data.get("faction_ids", []))
	definition.character_ids = _to_string_array(data.get("character_ids", []))
	definition.default_player_character_id = str(data.get("default_player_character_id", ""))
	definition.available_office_ids = _to_string_array(data.get("available_office_ids", []))
	definition.available_task_template_ids = _to_string_array(data.get("available_task_template_ids", []))
	return definition


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item in value:
		result.append(str(item))
	return result
