extends SceneTree

const PHASE2_ACTION_CATALOG_SCRIPT := preload("res://scripts/systems/Phase2ActionCatalog.gd")
const EXPECTED_CATEGORIES := ["成长", "关系", "政务", "军事", "家族", "移动"]
const EXPECTED_ACTIONS := {
	"train": {"display_name": "训练", "category_id": "成长", "ap_cost": 1, "energy_delta": -10, "target_type": "none", "effect_summary": "效果: 武艺历练 +6，压力 +3，功绩 +1"},
	"study": {"display_name": "读书", "category_id": "成长", "ap_cost": 1, "energy_delta": -8, "target_type": "none", "effect_summary": "效果: 智略历练 +6，压力 +2，名望 +1"},
	"rest": {"display_name": "休整", "category_id": "成长", "ap_cost": 1, "energy_delta": 20, "target_type": "none", "effect_summary": "效果: 精力 +20，压力 -12"},
	"visit": {"display_name": "拜访", "category_id": "关系", "ap_cost": 1, "energy_delta": -8, "target_type": "character", "effect_summary": "效果: 好感 +10，信任 +6，敬重 +2，戒备 -4"},
	"inspect": {"display_name": "巡察", "category_id": "政务", "ap_cost": 1, "energy_delta": -10, "target_type": "none", "effect_summary": "效果: 功绩 +5，政务历练 +4，压力 +4"}
}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_inspect_enabled_for_xun_yu()
	_test_inspect_location_block_still_applies()
	quit()


func _test_inspect_enabled_for_xun_yu() -> void:
	var game_root: Node = _game_root()
	var repository: Node = _data_repository()
	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "xun_yu")
	var xun_yu_actions: Array = game_root.get_available_phase2_actions()
	var inspect_spec = _find_action(xun_yu_actions, "inspect")
	if inspect_spec == null:
		_fail("Inspect should stay visible for xun_yu.")
	_assert_equal(inspect_spec.display_name, EXPECTED_ACTIONS["inspect"]["display_name"], "inspect display_name")
	_assert_equal(inspect_spec.category_id, EXPECTED_ACTIONS["inspect"]["category_id"], "inspect category")
	_assert_equal(inspect_spec.disabled_reason, "", "inspect should be enabled for xun_yu")


func _test_inspect_location_block_still_applies() -> void:
	var game_root: Node = _game_root()
	var repository: Node = _data_repository()

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "xun_yu")
	var protagonist: RuntimeCharacterState = game_root.current_session.get_character_state("xun_yu")
	if protagonist == null:
		_fail("Expected runtime state for xun_yu.")
	protagonist.current_city_id = "chenliu"
	var xun_yu_actions: Array = game_root.get_available_phase2_actions()
	var inspect_spec = _find_action(xun_yu_actions, "inspect")
	if inspect_spec == null:
		_fail("Inspect should remain visible for xun_yu when blocked by location.")
	_assert_equal(inspect_spec.disabled_reason, "当前地点不可执行", "inspect location disabled reason")


func _find_action(actions: Array, action_id: String):
	for action in actions:
		if action.id == action_id:
			return action
	return null


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _game_root():
	return root.get_node("/root/GameRoot")


func _data_repository():
	return root.get_node("/root/DataRepository")


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
