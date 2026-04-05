extends Node
class_name DataRepository

const PHASE1_SCENARIO_ID := "scenario_190_smoke"

var _loader := JsonDefinitionLoader.new()
var _repository := ScenarioRepository.new()
var _is_loaded: bool = false


func load_phase1_smoke_sample() -> void:
	if _is_loaded:
		return

	var dataset := _loader.load_dataset(PHASE1_SCENARIO_ID)
	if dataset.is_empty():
		push_error("Failed to load Phase 1 smoke sample dataset.")
		return

	_repository.ingest_dataset(dataset)
	_is_loaded = true


func get_scenario(id: String) -> Variant:
	return _repository.get_scenario(id)


func get_character(id: String) -> Variant:
	return _repository.get_character(id)


func get_faction(id: String) -> Variant:
	return _repository.get_faction(id)


func get_city(id: String) -> Variant:
	return _repository.get_city(id)


func bootstrap_session(scenario_id: String, protagonist_id: String) -> GameSession:
	load_phase1_smoke_sample()

	var scenario := get_scenario(scenario_id) as ScenarioDefinition
	var protagonist := get_character(protagonist_id) as CharacterDefinition
	if scenario == null or protagonist == null:
		push_error("Unable to bootstrap session for scenario=%s protagonist=%s" % [scenario_id, protagonist_id])
		return null

	var session := GameSession.new()
	session.scenario_id = scenario.id
	session.current_year = scenario.start_year
	session.current_month = scenario.start_month
	session.current_xun = scenario.start_xun
	session.protagonist_id = protagonist.id
	session.set_character_state(
		protagonist.id,
		RuntimeCharacterState.from_definition(
			protagonist.id,
			protagonist.city_id,
			protagonist.status_values.duplicate(true),
			protagonist.reputation_values.duplicate(true)
		)
	)
	return session
