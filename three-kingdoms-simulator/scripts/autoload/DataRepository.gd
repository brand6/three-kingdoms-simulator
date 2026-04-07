extends Node

const RUNTIME_RELATION_STATE_SCRIPT := preload("res://scripts/runtime/RuntimeRelationState.gd")
const GAME_SESSION_SCRIPT := preload("res://scripts/runtime/GameSession.gd")
const PLAYER_CAREER_STATE_SCRIPT := preload("res://scripts/runtime/PlayerCareerState.gd")

const PHASE1_SCENARIO_ID := "scenario_190_smoke"

var _loader := JsonDefinitionLoader.new()
var _repository := ScenarioRepository.new()
var _is_loaded: bool = false
var _offices_by_id: Dictionary = {}
var _task_templates_by_id: Dictionary = {}
var _task_pool_rules_by_id: Dictionary = {}
var _promotion_rules_by_id: Dictionary = {}
var _setup_patches_by_id: Dictionary = {}


func load_phase1_smoke_sample() -> void:
	if _is_loaded:
		return

	var dataset := _loader.load_dataset(PHASE1_SCENARIO_ID)
	if dataset.is_empty():
		push_error("Failed to load Phase 1 smoke sample dataset.")
		return

	_repository.ingest_dataset(dataset)
	_load_phase21_resources()
	_is_loaded = true


func get_scenario(id: String) -> Variant:
	return _repository.get_scenario(id)


func get_character(id: String) -> Variant:
	return _repository.get_character(id)


func get_faction(id: String) -> Variant:
	return _repository.get_faction(id)


func get_city(id: String) -> Variant:
	return _repository.get_city(id)


func get_office(id: String) -> Variant:
	return _offices_by_id.get(id)


func get_task_template(id: String) -> Variant:
	return _task_templates_by_id.get(id)


func get_task_pool_rule(id: String) -> Variant:
	return _task_pool_rules_by_id.get(id)


func get_promotion_rule(id: String) -> Variant:
	return _promotion_rules_by_id.get(id)


func get_setup_patch(id: String) -> Variant:
	return _setup_patches_by_id.get(id)


func get_setup_patch_for_scenario(scenario_id: String) -> Variant:
	for patch in _setup_patches_by_id.values():
		if patch != null and str(patch.scenario_id) == scenario_id:
			return patch
	return null


func get_task_templates() -> Array:
	return _task_templates_by_id.values()


func get_task_pool_rules() -> Array:
	return _task_pool_rules_by_id.values()


func get_promotion_rules() -> Array:
	return _promotion_rules_by_id.values()


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
	var setup_patch = get_setup_patch_for_scenario(scenario_id)
	var effective_protagonist_id := protagonist_id
	if setup_patch != null and not str(setup_patch.default_player_character_id).is_empty():
		effective_protagonist_id = str(setup_patch.default_player_character_id)
	var protagonist := get_character(effective_protagonist_id) as CharacterDefinition
	if scenario == null or protagonist == null:
		push_error("Unable to bootstrap session for scenario=%s protagonist=%s" % [scenario_id, protagonist_id])
		return null

	var session: GameSession = GAME_SESSION_SCRIPT.new()
	session.scenario_id = scenario.id
	session.current_year = scenario.start_year
	session.current_month = scenario.start_month
	session.current_xun = scenario.start_xun
	session.protagonist_id = protagonist.id
	session.vacancy_states = {
		"vacancy_congshi": true,
		"vacancy_zhubu": true,
		"vacancy_central_aide": true,
	}
	var patched_city_id := protagonist.city_id
	var patched_merit := int(protagonist.reputation_values.get("merit", 0))
	var patched_fame := int(protagonist.reputation_values.get("fame", 0))
	var patched_trust := 0
	var patched_office_id := protagonist.office_id
	var patched_flags: Array[String] = []
	if setup_patch != null and str(setup_patch.default_player_character_id) == protagonist.id:
		patched_city_id = str(setup_patch.start_city_id)
		patched_merit = int(setup_patch.start_merit)
		patched_fame = int(setup_patch.start_fame)
		patched_trust = int(setup_patch.start_trust)
		patched_office_id = str(setup_patch.start_office_id)
		patched_flags = Array(setup_patch.start_flags).duplicate()
	session.set_character_state(
		protagonist.id,
		RuntimeCharacterState.from_definition(
			protagonist.id,
			patched_city_id,
			protagonist.status_values.duplicate(true),
			{
				"fame": patched_fame,
				"merit": patched_merit,
				"loyalty": protagonist.reputation_values.get("loyalty", 0),
				"honor": protagonist.reputation_values.get("honor", 0),
				"infamy": protagonist.reputation_values.get("infamy", 0),
			},
			patched_trust
		)
	)
	var office = get_office(patched_office_id)
	session.player_career_state = PLAYER_CAREER_STATE_SCRIPT.create(
		protagonist.id,
		patched_office_id,
		int(office.tier if office != null else 0),
		patched_merit,
		patched_fame,
		patched_trust,
		0,
		[],
		null,
		Array(office.unlock_task_tags).duplicate() if office != null else [],
		patched_flags
	)
	_seed_phase2_relations(session)
	_apply_setup_patch_relations(session, setup_patch)
	return session


func _load_phase21_resources() -> void:
	_offices_by_id = _load_resources_by_id("res://data/offices")
	_promotion_rules_by_id = _load_resources_by_id("res://data/office_rules")
	_task_templates_by_id = _load_resources_by_id("res://data/tasks")
	_task_pool_rules_by_id = _load_resources_by_id("res://data/task_rules")
	_setup_patches_by_id = _load_resources_by_id("res://data/scenario_patches")


func _load_resources_by_id(dir_path: String) -> Dictionary:
	var resources_by_id: Dictionary = {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return resources_by_id
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource = ResourceLoader.load("%s/%s" % [dir_path, file_name])
			if resource != null and str(resource.get("id")) != "":
				resources_by_id[str(resource.get("id"))] = resource
		file_name = dir.get_next()
	dir.list_dir_end()
	return resources_by_id


func _apply_setup_patch_relations(session: GameSession, setup_patch: Variant) -> void:
	if setup_patch == null:
		return
	for override in setup_patch.start_relation_overrides:
		var source_id := str(override.get("source_character_id", ""))
		var target_id := str(override.get("target_character_id", ""))
		if source_id.is_empty() or target_id.is_empty():
			continue
		var key := _build_relation_key(source_id, target_id)
		var relation_state = session.get_relation_state(key)
		if relation_state == null:
			relation_state = RUNTIME_RELATION_STATE_SCRIPT.create(source_id, target_id, 0, 0, 0, 0, 0)
			session.set_relation_state(key, relation_state)
		if override.has("favor"):
			relation_state.favor = int(override.get("favor", relation_state.favor))
		if override.has("trust"):
			relation_state.trust = int(override.get("trust", relation_state.trust))
		if override.has("respect"):
			relation_state.respect = int(override.get("respect", relation_state.respect))
		if override.has("vigilance"):
			relation_state.vigilance = int(override.get("vigilance", relation_state.vigilance))
		if override.has("obligation"):
			relation_state.obligation = int(override.get("obligation", relation_state.obligation))


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
