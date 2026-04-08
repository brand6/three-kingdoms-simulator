extends RefCounted
class_name ScenarioRepository

var scenario_by_id: Dictionary = {}
var character_by_id: Dictionary = {}
var faction_by_id: Dictionary = {}
var city_by_id: Dictionary = {}
var action_by_id: Dictionary = {}
var task_template_by_id: Dictionary = {}
var office_by_id: Dictionary = {}


func ingest_dataset(dataset: Dictionary) -> void:
	scenario_by_id.clear()
	character_by_id.clear()
	faction_by_id.clear()
	city_by_id.clear()
	action_by_id.clear()
	task_template_by_id.clear()
	office_by_id.clear()

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

	for item in dataset.get("actions", []):
		var action_record: Dictionary = Dictionary(item).duplicate(true)
		var action_id := str(action_record.get("id", ""))
		if not action_id.is_empty():
			action_by_id[action_id] = action_record

	for item in dataset.get("task_templates", []):
		var task_template_record: Dictionary = Dictionary(item).duplicate(true)
		var task_template_id := str(task_template_record.get("id", ""))
		if not task_template_id.is_empty():
			task_template_by_id[task_template_id] = task_template_record

	for item in dataset.get("offices", []):
		var office_record: Dictionary = Dictionary(item).duplicate(true)
		var office_id := str(office_record.get("id", ""))
		if not office_id.is_empty():
			office_by_id[office_id] = office_record


func get_scenario(id: String) -> ScenarioDefinition:
	return scenario_by_id.get(id) as ScenarioDefinition


func get_character(id: String) -> CharacterDefinition:
	return character_by_id.get(id) as CharacterDefinition


func get_faction(id: String) -> FactionDefinition:
	return faction_by_id.get(id) as FactionDefinition


func get_city(id: String) -> CityDefinition:
	return city_by_id.get(id) as CityDefinition


func get_action(id: String) -> Dictionary:
	return Dictionary(action_by_id.get(id, {})).duplicate(true)


func get_actions() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for action in action_by_id.values():
		items.append(Dictionary(action).duplicate(true))
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("menu_order", 0)) < int(b.get("menu_order", 0))
	)
	return items


func get_task_template_record(id: String) -> Dictionary:
	return Dictionary(task_template_by_id.get(id, {})).duplicate(true)


func get_task_template_records() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for task_template in task_template_by_id.values():
		items.append(Dictionary(task_template).duplicate(true))
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("ui_priority", 0)) > int(b.get("ui_priority", 0))
	)
	return items


func get_office_record(id: String) -> Dictionary:
	return Dictionary(office_by_id.get(id, {})).duplicate(true)


func get_office_records() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for office in office_by_id.values():
		items.append(Dictionary(office).duplicate(true))
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("sort_order", 0)) < int(b.get("sort_order", 0))
	)
	return items
