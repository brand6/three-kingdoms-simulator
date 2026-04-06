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
	_test_character_selector_and_profile_apis()
	_test_action_resolution_behaviors()
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
	_assert_equal(_action_ids(actions), ["train", "study", "rest", "visit", "inspect"], "menu order")

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
	var xun_yu_inspect = _find_action(xun_yu_actions, "inspect")
	if xun_yu_inspect == null:
		_fail("Inspect should stay visible for characters lacking the required identity.")
	_assert_equal(xun_yu_inspect.disabled_reason, "当前身份不可执行", "inspect identity disabled reason")

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
	if inspect_visible == null:
		_fail("Inspect should stay visible for xun_yu.")
	_assert_equal(inspect_visible.disabled_reason, "当前身份不可执行", "inspect identity reason remains visible")

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")
	var protagonist: RuntimeCharacterState = game_root.current_session.get_character_state("cao_cao")
	protagonist.current_city_id = "xuchang"
	var cao_cao_actions: Array = game_root.get_available_phase2_actions()
	var inspect_spec = _find_action(cao_cao_actions, "inspect")
	if inspect_spec == null:
		_fail("Inspect should remain visible for Cao Cao when blocked by location.")
	_assert_equal(inspect_spec.disabled_reason, "当前地点不可执行", "inspect location disabled reason")


func _test_character_selector_and_profile_apis() -> void:
	var game_root: Node = _game_root()
	var repository: Node = _data_repository()
	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")

	if not game_root.has_method("get_character_selector_rows"):
		_fail("GameRoot is missing get_character_selector_rows().")
	if not game_root.has_method("get_character_profile_view_data"):
		_fail("GameRoot is missing get_character_profile_view_data().")

	var visit_rows: Array = game_root.get_character_selector_rows("visit")
	var relation_rows: Array = game_root.get_character_selector_rows("relation")
	if visit_rows.is_empty() or relation_rows.is_empty():
		_fail("Character selector rows should be available for visit and relation contexts.")
	if _find_row(visit_rows, "cao_cao") != null or _find_row(relation_rows, "cao_cao") != null:
		_fail("Selector rows must not include the protagonist.")

	var chen_gong_row = _find_row(visit_rows, "chen_gong")
	if chen_gong_row == null:
		_fail("Visit selector should include Chen Gong.")
	_assert_equal(chen_gong_row.selectable, true, "chen_gong visit selectable")
	_assert_equal(chen_gong_row.faction_name, "中立地方势力", "chen_gong faction name")
	_assert_equal(chen_gong_row.city_name, "陈留", "chen_gong city name")

	var chen_gong_profile = game_root.get_character_profile_view_data("chen_gong")
	if chen_gong_profile == null:
		_fail("Character profile view data should exist for chen_gong.")
	_assert_equal(chen_gong_profile.identity_label, "游士", "chen_gong identity label")
	_assert_equal(chen_gong_profile.faction_label, "中立地方势力", "chen_gong faction label")
	_assert_equal(chen_gong_profile.city_label, "陈留", "chen_gong city label")
	_assert_equal(chen_gong_profile.office_label, "无官职", "chen_gong office label")
	_assert_equal(chen_gong_profile.favor, 44, "chen_gong favor")
	_assert_equal(chen_gong_profile.trust, 30, "chen_gong trust")
	_assert_equal(chen_gong_profile.respect, 53, "chen_gong respect")
	_assert_equal(chen_gong_profile.vigilance, 18, "chen_gong vigilance")
	_assert_equal(chen_gong_profile.obligation, 14, "chen_gong obligation")


func _test_action_resolution_behaviors() -> void:
	var game_root: Node = _game_root()
	var repository: Node = _data_repository()

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")
	if not game_root.has_method("execute_phase2_action"):
		_fail("GameRoot is missing execute_phase2_action().")
	if not game_root.has_method("get_latest_action_resolution"):
		_fail("GameRoot is missing get_latest_action_resolution().")

	var session: GameSession = game_root.current_session
	var state: RuntimeCharacterState = session.get_character_state("cao_cao")
	var initial_history_size := session.current_xun_action_history.size()

	var train_result = game_root.execute_phase2_action("train")
	_assert_equal(train_result.success, true, "train success")
	_assert_equal(state.ap, 2, "train AP")
	_assert_equal(state.energy, 78, "train energy")
	_assert_equal(state.stress, 27, "train stress")
	_assert_equal(state.merit, 76, "train merit")
	_assert_equal(state.martial_exp, 6, "train martial_exp")

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")
	session = game_root.current_session
	state = session.get_character_state("cao_cao")
	var rest_result = game_root.execute_phase2_action("rest")
	_assert_equal(rest_result.success, true, "rest success")
	_assert_equal(state.ap, 2, "rest AP")
	_assert_equal(state.energy, 108, "rest energy")
	_assert_equal(state.stress, 12, "rest stress")
	_assert_equal(state.merit, 75, "rest merit unchanged")

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")
	session = game_root.current_session
	state = session.get_character_state("cao_cao")
	var visit_result = game_root.execute_phase2_action("visit", "chen_gong")
	var relation = session.get_relation_state("cao_cao->chen_gong")
	_assert_equal(visit_result.success, true, "visit success")
	_assert_equal(state.ap, 2, "visit AP")
	_assert_equal(state.energy, 80, "visit energy")
	_assert_equal(state.fame, 83, "visit fame")
	_assert_equal(relation.favor, 54, "visit favor")
	_assert_equal(relation.trust, 36, "visit trust")
	_assert_equal(relation.respect, 55, "visit respect")
	_assert_equal(relation.vigilance, 14, "visit vigilance")
	_assert_equal(relation.obligation, 15, "visit obligation")

	game_root.current_session = repository.bootstrap_session(game_root.DEFAULT_SCENARIO_ID, "cao_cao")
	session = game_root.current_session
	state = session.get_character_state("cao_cao")
	var failed_visit = game_root.execute_phase2_action("visit", "yuan_shao")
	_assert_equal(failed_visit.success, false, "failed visit success flag")
	_assert_equal(failed_visit.title, "行动失败", "failed visit title")
	_assert_equal(state.stress, 26, "failed visit stress")
	if str(failed_visit.clue_text).strip_edges().is_empty():
		_fail("Failed visit should provide non-empty clue_text.")

	if session.current_xun_action_history.size() < initial_history_size + 1:
		_fail("Action resolution history was not appended to the session.")
	var latest_result = game_root.get_latest_action_resolution()
	if latest_result == null:
		_fail("Expected latest action resolution after executing actions.")


func _find_action(actions: Array, action_id: String):
	for action in actions:
		if action.id == action_id:
			return action
	return null


func _find_row(rows: Array, character_id: String):
	for row in rows:
		if row.character_id == character_id:
			return row
	return null


func _action_ids(actions: Array) -> Array:
	var ids: Array = []
	for action in actions:
		ids.append(str(action.id))
	return ids


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
