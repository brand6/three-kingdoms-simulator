extends RefCounted
class_name Phase2ActionResolver

const ACTION_RESOLUTION_SCRIPT := preload("res://scripts/runtime/ActionResolution.gd")


func execute(
	action_id: String,
	session: GameSession,
	protagonist: CharacterDefinition,
	target_character: CharacterDefinition = null
) -> Variant:
	var runtime_state := session.get_character_state(session.protagonist_id)
	if runtime_state == null or protagonist == null:
		return ACTION_RESOLUTION_SCRIPT.create(action_id, "行动失败", false, "当前会话未初始化。", "", {}, {}, "当前角色状态不可用。", "行动未执行")

	match action_id:
		"train":
			return _resolve_train(runtime_state)
		"study":
			return _resolve_study(runtime_state)
		"rest":
			return _resolve_rest(runtime_state)
		"inspect":
			return _resolve_inspect(runtime_state)
		"review_memorials":
			return _resolve_review_memorials(runtime_state)
		"inspect_subordinates":
			return _resolve_inspect_subordinates(session, runtime_state, protagonist, target_character)
		"visit":
			return _resolve_visit(session, runtime_state, protagonist, target_character)
		_:
			return ACTION_RESOLUTION_SCRIPT.create(action_id, "行动失败", false, "未知行动。", "", {}, {}, "没有找到对应的行动规则。", "行动未执行")


func _resolve_train(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 10
	runtime_state.stress += 3
	runtime_state.merit += 1
	runtime_state.martial_exp += 6
	return ACTION_RESOLUTION_SCRIPT.create(
		"train",
		"训练",
		true,
		"训练完成。",
		"",
		{"ap": -1, "energy": -10, "stress": 3, "merit": 1, "martial_exp": 6},
		{},
		"",
		"训练完成，武艺历练有所提升。"
	)


func _resolve_study(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 8
	runtime_state.stress += 2
	runtime_state.fame += 1
	runtime_state.strategy_exp += 6
	return ACTION_RESOLUTION_SCRIPT.create(
		"study",
		"读书",
		true,
		"读书完成。",
		"",
		{"ap": -1, "energy": -8, "stress": 2, "fame": 1, "strategy_exp": 6},
		{},
		"",
		"读书完成，智略历练有所提升。"
	)


func _resolve_rest(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy += 20
	runtime_state.stress -= 12
	return ACTION_RESOLUTION_SCRIPT.create(
		"rest",
		"休整",
		true,
		"休整完成。",
		"",
		{"ap": -1, "energy": 20, "stress": -12},
		{},
		"",
		"休整完成，精力得到恢复。"
	)


func _resolve_inspect(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 10
	runtime_state.stress += 4
	runtime_state.merit += 5
	runtime_state.governance_exp += 4
	return ACTION_RESOLUTION_SCRIPT.create(
		"inspect",
		"巡察",
		true,
		"巡察完成。",
		"",
		{"ap": -1, "energy": -10, "stress": 4, "merit": 5, "governance_exp": 4},
		{},
		"",
		"巡察完成，政务历练与功绩提升。"
	)


func _resolve_review_memorials(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 6
	runtime_state.governance_exp += 5
	runtime_state.merit += 2
	return ACTION_RESOLUTION_SCRIPT.create(
		"review_memorials",
		"审阅奏牍",
		true,
		"审阅完成。",
		"",
		{"ap": -1, "energy": -6, "governance_exp": 5, "merit": 2},
		{},
		"中枢案牍得到梳理，你对幕府政务脉络掌握更清楚。",
		"审阅奏牍完成，中枢事务可见度提高。"
	)


func _resolve_inspect_subordinates(
	session: GameSession,
	runtime_state: RuntimeCharacterState,
	protagonist: CharacterDefinition,
	target_character: CharacterDefinition
) -> Variant:
	if target_character == null or target_character.id == protagonist.id or target_character.city_id != runtime_state.current_city_id:
		return ACTION_RESOLUTION_SCRIPT.create(
			"inspect_subordinates",
			"行动失败",
			false,
			"暂无可监察属员。",
			target_character.id if target_character != null else "",
			{},
			{},
			"需先在同地找到可监察的属员对象。",
			"察看属员未能执行。"
		)
	runtime_state.ap -= 1
	runtime_state.energy -= 5
	runtime_state.strategy_exp += 2
	var relation_key := "%s->%s" % [protagonist.id, target_character.id]
	var relation = session.get_relation_state(relation_key)
	if relation != null:
		relation.trust += 2
		relation.vigilance -= 1
	return ACTION_RESOLUTION_SCRIPT.create(
		"inspect_subordinates",
		"察看属员",
		true,
		"监察完成。",
		target_character.id,
		{"ap": -1, "energy": -5, "strategy_exp": 2},
		{"trust": 2, "vigilance": -1} if relation != null else {},
		"你已掌握属员近况，可为后续人事建议提供依据。",
		"察看属员完成，人事掌控略有提升。"
	)


func _resolve_visit(
	session: GameSession,
	runtime_state: RuntimeCharacterState,
	protagonist: CharacterDefinition,
	target_character: CharacterDefinition
) -> Variant:
	if target_character == null or target_character.id == protagonist.id or target_character.city_id != runtime_state.current_city_id:
		runtime_state.stress += 2
		return ACTION_RESOLUTION_SCRIPT.create(
			"visit",
			"行动失败",
			false,
			"目标已不在当前地点，无法完成拜访。",
			target_character.id if target_character != null else "",
			{"stress": 2},
			{},
			"目标暂不可见，请重新确认所在地与动向。",
			"拜访失败，但你得到了一条关于目标动向的线索。"
		)

	runtime_state.ap -= 1
	runtime_state.energy -= 8
	runtime_state.fame += 1
	var relation_key := "%s->%s" % [protagonist.id, target_character.id]
	var relation = session.get_relation_state(relation_key)
	if relation != null:
		relation.favor += 10
		relation.trust += 6
		relation.respect += 2
		relation.vigilance -= 4
		relation.obligation += 1
	return ACTION_RESOLUTION_SCRIPT.create(
		"visit",
		"拜访",
		true,
		"拜访完成。",
		target_character.id,
		{"ap": -1, "energy": -8, "fame": 1},
		{"favor": 10, "trust": 6, "respect": 2, "vigilance": -4, "obligation": 1},
		"",
		"拜访成功，关系有所推进。"
	)
