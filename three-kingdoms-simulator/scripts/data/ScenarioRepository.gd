extends RefCounted
class_name ScenarioRepository

var scenario_by_id: Dictionary = {}
var character_by_id: Dictionary = {}
var faction_by_id: Dictionary = {}
var city_by_id: Dictionary = {}


func ingest_dataset(dataset: Dictionary) -> void:
	scenario_by_id.clear()
	character_by_id.clear()
	faction_by_id.clear()
	city_by_id.clear()

	var scenario_data: Dictionary = dataset.get("scenario", {})
	if not scenario_data.is_empty():
		var scenario := ScenarioDefinition.from_dictionary(scenario_data)
		scenario_by_id[scenario.id] = scenario

	for item in dataset.get("characters", []):
		var character := CharacterDefinition.from_dictionary(item)
		character_by_id[character.id] = character

	for item in dataset.get("factions", []):
		var faction := FactionDefinition.from_dictionary(item)
		faction_by_id[faction.id] = faction

	for item in dataset.get("cities", []):
		var city := CityDefinition.from_dictionary(item)
		city_by_id[city.id] = city


func get_scenario(id: String) -> ScenarioDefinition:
	return scenario_by_id.get(id) as ScenarioDefinition


func get_character(id: String) -> CharacterDefinition:
	return character_by_id.get(id) as CharacterDefinition


func get_faction(id: String) -> FactionDefinition:
	return faction_by_id.get(id) as FactionDefinition


func get_city(id: String) -> CityDefinition:
	return city_by_id.get(id) as CityDefinition
