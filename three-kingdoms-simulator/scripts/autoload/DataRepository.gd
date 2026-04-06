extends Node

const RUNTIME_RELATION_STATE_SCRIPT := preload("res://scripts/runtime/RuntimeRelationState.gd")
const GAME_SESSION_SCRIPT := preload("res://scripts/runtime/GameSession.gd")

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


func get_characters_in_city(city_id: String) -> Array[CharacterDefinition]:
	var characters: Array[CharacterDefinition] = []
	var city := get_city(city_id) as CityDefinition
	if city == null:
		return characters

	for character_id in city.character_ids:
		var character := get_character(character_id) as CharacterDefinition
		if character != null:
			characters.append(character)
	return characters


func get_faction_characters(faction_id: String) -> Array[CharacterDefinition]:
	var characters: Array[CharacterDefinition] = []
	var faction := get_faction(faction_id) as FactionDefinition
	if faction == null:
		return characters

	for character_id in faction.officer_ids:
		var character := get_character(character_id) as CharacterDefinition
		if character != null:
			characters.append(character)
	return characters


func bootstrap_session(scenario_id: String, protagonist_id: String) -> GameSession:
	load_phase1_smoke_sample()

	var scenario := get_scenario(scenario_id) as ScenarioDefinition
	var protagonist := get_character(protagonist_id) as CharacterDefinition
	if scenario == null or protagonist == null:
		push_error("Unable to bootstrap session for scenario=%s protagonist=%s" % [scenario_id, protagonist_id])
		return null

	var session: GameSession = GAME_SESSION_SCRIPT.new()
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
	_seed_phase2_relations(session)
	return session


func _seed_phase2_relations(session: GameSession) -> void:
	var seed_rows: Array[Dictionary] = [
		{
			"source": "cao_cao", "target": "chen_gong", "favor": 44, "trust": 30,
			"respect": 53, "vigilance": 18, "obligation": 14
		},
		{
			"source": "chen_gong", "target": "cao_cao", "favor": 28, "trust": 20,
			"respect": 46, "vigilance": 50, "obligation": 8
		},
		{
			"source": "cao_cao", "target": "xun_yu", "favor": 52, "trust": 48,
			"respect": 60, "vigilance": 8, "obligation": 22
		},
		{
			"source": "xun_yu", "target": "cao_cao", "favor": 58, "trust": 61,
			"respect": 64, "vigilance": 6, "obligation": 24
		},
		{
			"source": "cao_cao", "target": "le_jin", "favor": 46, "trust": 44,
			"respect": 55, "vigilance": 10, "obligation": 18
		},
		{
			"source": "le_jin", "target": "cao_cao", "favor": 51, "trust": 56,
			"respect": 63, "vigilance": 6, "obligation": 21
		},
		{
			"source": "cao_cao", "target": "yuan_shao", "favor": 10, "trust": 6,
			"respect": 28, "vigilance": 70, "obligation": 0
		},
		{
			"source": "yuan_shao", "target": "cao_cao", "favor": 8, "trust": 4,
			"respect": 24, "vigilance": 76, "obligation": 0
		}
	]

	for row in seed_rows:
		var relation_state = RUNTIME_RELATION_STATE_SCRIPT.create(
			str(row.get("source", "")),
			str(row.get("target", "")),
			int(row.get("favor", 0)),
			int(row.get("trust", 0)),
			int(row.get("respect", 0)),
			int(row.get("vigilance", 0)),
			int(row.get("obligation", 0))
		)
		session.call("set_relation_state", _build_relation_key(relation_state.source_character_id, relation_state.target_character_id), relation_state)


func _build_relation_key(source_character_id: String, target_character_id: String) -> String:
	return "%s->%s" % [source_character_id, target_character_id]
