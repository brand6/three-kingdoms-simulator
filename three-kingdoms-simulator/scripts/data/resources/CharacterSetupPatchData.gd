extends Resource
class_name CharacterSetupPatchData

@export var id: String = ""
@export var scenario_id: String = ""
@export var default_player_character_id: String = ""
@export var start_city_id: String = ""
@export var start_faction_id: String = ""
@export var start_office_id: String = ""
@export var start_merit: int = 0
@export var start_fame: int = 0
@export var start_trust: int = 0
@export var start_relation_overrides: Array[Dictionary] = []
@export var start_flags: Array[String] = []
