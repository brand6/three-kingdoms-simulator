extends SceneTree

const PHASE2_ACTION_CATALOG_SCRIPT := preload("res://scripts/systems/Phase2ActionCatalog.gd")
const EXPECTED_CATEGORIES := ["成长", "关系", "政务", "军事", "家族"]
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
	_test_catalog_metadata_for_cao_cao()
	_test_hidden_and_disabled_rules()
	quit()


func _test_catalog_metadata_for_cao_cao() -> void:
	var game_root: Node = _game_root()
	game_root.bootstrap_default_entry()

	if not game_root.has_method("get_available_phase2_actions"):
		_fail("GameRoot is missing get_available_phase2_actions().")

	var catalog = PHASE2_ACTION_CATALOG_SCRIPT.new()
	if not catalog.has_method("get_categories"):
		_fail("Phase2ActionCatalog is missing get_categories().")
	var categories: Array = catalog.get_categories()
	if categories != EXPECTED_CATEGORIES:
		_fail("Expected fixed categories %s but found %s." % [EXPECTED_CATEGORIES, categories])

	var actions: Array = game_root.get_available_phase2_actions()
	if actions.size() != EXPECTED_ACTIONS.size():
		_fail("Expected %d visible actions for Cao Cao but found %d." % [EXPECTED_ACTIONS.size(), actions.size()])

	for action_id in EXPECTED_ACTIONS.keys():
		var spec = _find_action(actions, action_id)
		if spec == null:
			_fail("Missing expected action '%s' for Cao Cao." % action_id)
		var expected: Dictionary = EXPECTED_ACTIONS[action_id]
		_assert_equal(spec.display_name, expected["display_name"], "%s display_name" % action_id)
		_assert_equal(spec.category_id, expected["category_id"], "%s category_id" % action_id)
		_assert_equal(spec.ap_cost, expected["ap_cost"], "%s ap_cost" % action_id)
		_assert_equal(spec.energy_delta, expected["energy_delta"], "%s energy_delta" % action_id)
		_assert_equal(spec.target_type, expected["target_type"], "%s target_type" % action_id)
		_assert_equal(spec.effect_summary, expected["effect_summary"], "%s effect_summary" % action_id)
		_assert_equal(spec.disabled_reason, "", "%s should be enabled for Cao Cao" % action_id)


func _test_hidden_and_disabled_rules() -> void:
	var game_root: Node = _game_root()
	var repository: Node = _data_repository()

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "xun_yu")
	var xun_yu_actions: Array = game_root.get_available_phase2_actions()
	if _find_action(xun_yu_actions, "inspect") != null:
		_fail("Inspect should be hidden for characters lacking inspect/lead permission.")

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "le_jin")
	var le_jin_actions: Array = game_root.get_available_phase2_actions()
	var visit_spec = _find_action(le_jin_actions, "visit")
	if visit_spec == null:
		_fail("Visit should remain visible when there are no valid targets.")
	_assert_equal(visit_spec.disabled_reason, "暂无可拜访对象", "visit disabled reason")

	var le_jin_state: RuntimeCharacterState = game_root.current_session.get_character_state("le_jin")
	le_jin_state.ap = 0
	le_jin_actions = game_root.get_available_phase2_actions()
	visit_spec = _find_action(le_jin_actions, "visit")
	_assert_equal(visit_spec.disabled_reason, "AP 不足", "visit AP disabled reason")

	le_jin_state.ap = 3
	le_jin_state.energy = 2
	le_jin_actions = game_root.get_available_phase2_actions()
	var train_spec = _find_action(le_jin_actions, "train")
	if train_spec == null:
		_fail("Train should stay visible when blocked by energy.")
	_assert_equal(train_spec.disabled_reason, "精力不足", "train energy disabled reason")

	le_jin_state.energy = 90
	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "xun_yu")
	xun_yu_actions = game_root.get_available_phase2_actions()
	var inspect_visible: Variant = _find_action(xun_yu_actions, "inspect")
	if inspect_visible != null:
		_fail("Inspect should still be hidden for xun_yu.")

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")
	var protagonist: RuntimeCharacterState = game_root.current_session.get_character_state("cao_cao")
	protagonist.current_city_id = "xuchang"
	var cao_cao_actions: Array = game_root.get_available_phase2_actions()
	var inspect_spec = _find_action(cao_cao_actions, "inspect")
	if inspect_spec == null:
		_fail("Inspect should remain visible for Cao Cao when blocked by location.")
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
