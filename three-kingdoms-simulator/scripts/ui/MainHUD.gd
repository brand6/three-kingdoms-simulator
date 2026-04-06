extends Control
class_name MainHUD

const LOADING_DECISION_TITLE := "推荐行动：先查看城中局势"
const LOADING_DECISION_BODY := "阶段目标：先确认本旬可投入的 AP 与关键人物，再决定是巡察、拜访还是休整。"
const LOADING_GOAL_BODY := "可接任务：巡察陈留、拜访重臣、回府安抚家族。"
const LOADING_FOCUS_BODY := "本旬重点：找出最值得争取的支持者，并为结束本旬保留推进空间。"
const LOADING_HINT := "正在整理本旬建议…"
const ERROR_TEXT := "190 样本加载失败。请检查 Luban JSON 导出文件、默认主角 ID 与数据路径配置，然后重新启动项目。"
const EMPTY_TASK_BODY := "暂无硬性任务时，请优先选择一项能带来关系、功绩或压力缓解的行动。"
const EMPTY_EVENT_BODY := "若暂未触发事件，系统会继续根据你的所在地、势力位置与关键人物关系给出方向。"
const EMPTY_NOTICE_BODY := "结束本旬前请确认 AP 是否用尽，并留意是否还有值得拜访的对象。"
const EXPLANATION_TEXT := "先点行动安排本旬事务；准备完毕后可直接结束本旬。"
const END_TURN_TEXT := "结束本旬：确认后将立即结算本旬变化并推进到下一旬。"
const PHASE2_CATEGORIES := ["成长", "关系", "政务", "军事", "家族"]
const ACTION_MENU_EMPTY_HEADING := "当前分类暂无可执行行动"
const ACTION_MENU_EMPTY_BODY := "请切换其他分类，或等待 AP、精力、地点与目标条件满足后再试。"
const ACTION_LABEL_NAME := "动作名称"
const ACTION_LABEL_AP := "AP"
const ACTION_LABEL_ENERGY := "精力"
const ACTION_LABEL_TARGET := "目标类型"
const ACTION_LABEL_EFFECT := "效果摘要"
const REASON_NO_AP := "AP 不足"
const REASON_NO_ENERGY := "精力不足"
const REASON_WRONG_LOCATION := "当前地点不可执行"
const REASON_NO_VISIT_TARGET := "暂无可拜访对象"
const RELATION_COLUMNS := "人物名 / 关系标签 / 好感 / 信任 / 敬重 / 戒备 / 所属势力 / 可互动状态"
const RESULT_LABEL_OUTCOME := "成败结论"
const RESULT_LABEL_REASON := "原因说明"
const RESULT_LABEL_STATS := "数值变化"
const RESULT_LABEL_RELATIONS := "关系变化"
const RESULT_LABEL_CLUE := "新线索"

@onready var _time_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/TimeLabel")
@onready var _city_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/CityLabel")
@onready var _identity_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/IdentityLabel")
@onready var _faction_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/FactionLabel")
@onready var _office_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/OfficeLabel")
@onready var _name_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/LeftOverview/LeftOverviewContent/NameLabel")
@onready var _ap_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/LeftOverview/LeftOverviewContent/APLabel")
@onready var _energy_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/LeftOverview/LeftOverviewContent/EnergyLabel")
@onready var _stress_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/LeftOverview/LeftOverviewContent/StressLabel")
@onready var _fame_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/LeftOverview/LeftOverviewContent/FameLabel")
@onready var _merit_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/LeftOverview/LeftOverviewContent/MeritLabel")
@onready var _summary_label: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/SummaryLabel")
@onready var _summary_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/SummaryBody")
@onready var _goal_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/GoalBody")
@onready var _focus_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/FocusBody")
@onready var _success_hint: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/SuccessHint")
@onready var _task_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/RightContext/RightContextContent/TaskBody")
@onready var _event_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/RightContext/RightContextContent/EventBody")
@onready var _notice_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/PrimaryRow/RightContext/RightContextContent/NoticeBody")
@onready var _relation_summary_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/SummaryRow/RelationSummaryCard/RelationSummaryContent/RelationSummaryBody")
@onready var _faction_summary_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/SummaryRow/FactionSummaryCard/FactionSummaryContent/FactionSummaryBody")
@onready var _clan_summary_body: Label = get_node("MarginContainer/VBoxContainer/MiddleScroll/MiddleBody/SummaryRow/ClanSummaryCard/ClanSummaryContent/ClanSummaryBody")
@onready var _explanation_label: Label = get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/ExplanationLabel")
@onready var _action_button: Button = get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/NavigationRow/ActionButton")
@onready var _relation_button: Button = get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/NavigationRow/RelationButton")
@onready var _action_menu_popup: PopupPanel = get_node("ActionMenuPopup")
@onready var _category_list: VBoxContainer = get_node("ActionMenuPopup/ActionMenuMargin/ActionMenuLayout/CategoryPanel/CategoryContent/CategoryList")
@onready var _action_list: VBoxContainer = get_node("ActionMenuPopup/ActionMenuMargin/ActionMenuLayout/ActionPanel/ActionContent/ActionListScroll/ActionList")
@onready var _action_empty_state: Label = get_node("ActionMenuPopup/ActionMenuMargin/ActionMenuLayout/ActionPanel/ActionContent/ActionEmptyState")
@onready var _target_picker_dialog: ConfirmationDialog = get_node("TargetPickerDialog")
@onready var _target_list: VBoxContainer = get_node("TargetPickerDialog/TargetPickerMargin/TargetPickerContent/TargetListScroll/TargetList")
@onready var _relation_popup: PopupPanel = get_node("RelationPopup")
@onready var _relation_list: VBoxContainer = get_node("RelationPopup/RelationMargin/RelationContent/RelationListScroll/RelationList")
@onready var _action_result_dialog: AcceptDialog = get_node("ActionResultDialog")
@onready var _action_result_body: Label = get_node("ActionResultDialog/ActionResultMargin/ActionResultBody")

var _selected_category: String = "成长"
var _pending_target_action_id: String = ""


func _game_root() -> Node:
	return get_node("/root/GameRoot")


func _data_repository() -> Node:
	return get_node("/root/DataRepository")


func _time_manager() -> Node:
	return get_node("/root/TimeManager")


func _ready() -> void:
	show_loading_state()
	_action_button.pressed.connect(_on_action_button_pressed)
	_relation_button.pressed.connect(_on_relation_button_pressed)
	_target_picker_dialog.confirmed.connect(_on_target_picker_confirmed)
	if Engine.is_editor_hint():
		return
	call_deferred("_bootstrap_default_entry")


func _bootstrap_default_entry() -> void:
	_game_root().call("register_hud", self)
	_game_root().call("bootstrap_default_entry")


func show_loading_state() -> void:
	_render_decision_panel(LOADING_DECISION_TITLE, LOADING_DECISION_BODY, LOADING_GOAL_BODY, LOADING_FOCUS_BODY, LOADING_HINT)
	_task_body.text = _fallback_recommendations_text()
	_event_body.text = EMPTY_EVENT_BODY
	_notice_body.text = "重要提示：%s" % EMPTY_NOTICE_BODY
	_relation_summary_body.text = "关键关系摘要：正在整理主公、亲近者与高戒备对象的名单。"
	_faction_summary_body.text = "派系摘要：正在汇总所属势力的支持态势与当前政治风险。"
	_clan_summary_body.text = "家族/士族摘要：正在读取家族声望、士族背书与当前家务诉求。"
	_explanation_label.text = EXPLANATION_TEXT
	_render_empty_fields()


func show_success_state(session: GameSession) -> void:
	var protagonist := _data_repository().call("get_character", session.protagonist_id) as CharacterDefinition
	var runtime_state := session.get_character_state(session.protagonist_id)
	var city := _data_repository().call("get_city", runtime_state.current_city_id if runtime_state != null else "") as CityDefinition
	var faction := _data_repository().call("get_faction", protagonist.faction_id if protagonist != null else "") as FactionDefinition

	var city_name := _display_value(city.name if city != null else "")
	var faction_name := _display_value(faction.name if faction != null else "")
	var protagonist_name := _display_value(protagonist.name if protagonist != null else "")
	var identity_text := _localized_identity(protagonist.identity_type if protagonist != null else "")
	var office_text := _localized_office(protagonist.office_id if protagonist != null else "")
	var clan_text := _localized_clan(protagonist.clan_id if protagonist != null else "")
	var family_text := _localized_family(protagonist.family_id if protagonist != null else "")
	var ap_value := _metric_value(runtime_state, &"ap")
	var stress_value := _metric_value(runtime_state, &"stress")
	var merit_value := _metric_value(runtime_state, &"merit")

	_render_decision_panel(
		"推荐行动：先以巡察稳住%s，再择机拜访重臣" % city_name,
		"阶段目标：用有限 AP 换取可见政治收益，先稳住城内观感，再为下一旬铺路。",
		"可接任务：巡察%s、拜访关键文臣、回府处理家族来信。" % city_name,
		"本旬重点：观察%s内部支持度，确认谁愿意为%s背书，并决定何时结束本旬。" % [faction_name, protagonist_name],
		"结束本旬前，建议至少完成一次能带来关系或功绩反馈的行动。"
	)

	_task_body.text = "当前任务：先用 %s 点 AP 稳住%s局势，再决定是否转向拜访与休整。\n- 推荐行动 1：巡察，换取可见功绩\n- 推荐行动 2：拜访，争取关键支持\n- 推荐行动 3：休整，避免压力失控" % [ap_value, city_name]
	_event_body.text = "最近事件：%s的官员与宗族都在观察你本旬的第一步。若先巡察，可快速建立秩序；若先拜访，则更利于后续关系推进。" % city_name
	_notice_body.text = "重要提示：%s势力当前仍在整合阶段，若本旬功绩不足，下一旬可用的政治筹码会偏少。" % faction_name
	_relation_summary_body.text = "关键关系摘要：当前最该争取的人物是%s阵营中的核心文臣；亲近者可提供背书，高戒备者会放大你的失误。" % faction_name
	_faction_summary_body.text = "派系摘要：你正处于%s的核心视线中。当前态度偏支持，但仍需用巡察与拜访证明你能稳住地方。" % faction_name
	_clan_summary_body.text = "家族/士族摘要：家族 %s、士族 %s 正在等待你拿出可见成果；若长期忽视家门诉求，后续举荐与联姻机会会减弱。" % [family_text, clan_text]
	_explanation_label.text = "%s 当前主操作：行动 → 反馈 → 结束本旬。" % END_TURN_TEXT

	_time_label.text = _time_text(session)
	_city_label.text = "地点：%s" % city_name
	_identity_label.text = "身份：%s" % identity_text
	_faction_label.text = "势力：%s" % faction_name
	_office_label.text = "官职：%s" % office_text
	_name_label.text = _pair_text("姓名", protagonist_name)
	_ap_label.text = _metric_text("AP", runtime_state, &"ap")
	_energy_label.text = _metric_text("精力", runtime_state, &"energy")
	_stress_label.text = _metric_text("压力", runtime_state, &"stress")
	_fame_label.text = _metric_text("名望", runtime_state, &"fame")
	_merit_label.text = _metric_text("功绩", runtime_state, &"merit")

	if stress_value != "—":
		_notice_body.text += " 当前压力：%s。" % stress_value
	if merit_value != "—":
		_relation_summary_body.text += " 当前功绩：%s。" % merit_value
	_refresh_overlay_data()


func show_error_state(message: String) -> void:
	_render_decision_panel(
		"推荐行动：先修复入口数据",
		"阶段目标：恢复 190 样本载入后，再继续验证 HUD 的推荐行动与旬推进结构。",
		"可接任务：检查数据文件、确认默认主角、重新启动项目。",
		"本旬重点：先解决阻塞问题，再考虑关系、派系与家族摘要。",
		"错误详情已写入主面板，请修复后重新进入。"
	)
	_summary_body.text = "%s\n%s" % [ERROR_TEXT, _display_value(message)]
	_task_body.text = _fallback_recommendations_text()
	_event_body.text = EMPTY_EVENT_BODY
	_notice_body.text = "重要提示：请修复数据后重新启动，再执行行动或结束本旬。"
	_relation_summary_body.text = "关键关系摘要：数据尚未载入，无法生成可信关系提示。"
	_faction_summary_body.text = "派系摘要：数据尚未载入，无法判断当前政治环境。"
	_clan_summary_body.text = "家族/士族摘要：数据尚未载入，无法提供家门与士族背景提示。"
	_explanation_label.text = EXPLANATION_TEXT
	_render_empty_fields()


func _render_empty_fields() -> void:
	_time_label.text = "时间：190年 1月 第1旬"
	_city_label.text = "地点：—"
	_identity_label.text = "身份：—"
	_faction_label.text = "势力：—"
	_office_label.text = "官职：—"
	_name_label.text = _pair_text("姓名", "")
	_ap_label.text = _pair_text("AP", null)
	_energy_label.text = _pair_text("精力", null)
	_stress_label.text = _pair_text("压力", null)
	_fame_label.text = _pair_text("名望", null)
	_merit_label.text = _pair_text("功绩", null)


func _render_decision_panel(title: String, body: String, goal_body: String, focus_body: String, hint: String) -> void:
	_summary_label.text = title
	_summary_body.text = body
	_goal_body.text = goal_body
	_focus_body.text = focus_body
	_success_hint.text = hint


func _fallback_recommendations_text() -> String:
	return "当前任务：%s\n- 推荐行动 1：拜访关键人物，提前铺路\n- 推荐行动 2：巡察当前城市，换取秩序与功绩\n- 推荐行动 3：回府休整，缓解压力后再结束本旬" % EMPTY_TASK_BODY


func _time_text(session: GameSession) -> String:
	if session == null:
		return "时间：190年 1月 第1旬"
	return "时间：%d年 %d月 第%d旬" % [session.current_year, session.current_month, session.current_xun]


func _localized_identity(value: String) -> String:
	match value:
		"ruler":
			return "君主"
		"civil_official":
			return "文官"
		"military_officer":
			return "武官"
		"free_agent":
			return "游士"
		_:
			return _display_value(value)


func _localized_office(value: String) -> String:
	match value:
		"lord":
			return "领主"
		"chief_advisor":
			return "首席谋臣"
		"frontline_commander":
			return "前线统兵"
		"hegemon_claimant":
			return "盟主争衡者"
		"":
			return "无官职"
		_:
			return _display_value(value)


func _localized_family(value: String) -> String:
	match value:
		"cao_family":
			return "曹氏"
		"xun_family":
			return "荀氏"
		"le_family":
			return "乐氏"
		"yuan_family":
			return "袁氏"
		"chen_family":
			return "陈氏"
		_:
			return _display_value(value)


func _localized_clan(value: String) -> String:
	match value:
		"qiao_cao_clan":
			return "谯郡曹氏"
		"yingchuan_xun_clan":
			return "颍川荀氏"
		"new_merit_clan":
			return "新兴军功门第"
		"runan_yuan_clan":
			return "汝南袁氏"
		"chenjun_chen_clan":
			return "陈郡陈氏"
		_:
			return _display_value(value)


func _pair_text(label_text: String, value: Variant) -> String:
	return "%s：%s" % [label_text, _display_value(value)]


func _metric_text(label_text: String, runtime_state: RuntimeCharacterState, property_name: StringName) -> String:
	if runtime_state == null:
		return _pair_text(label_text, null)
	return _pair_text(label_text, runtime_state.get(property_name))


func _metric_value(runtime_state: RuntimeCharacterState, property_name: StringName) -> String:
	if runtime_state == null:
		return "—"
	return _display_value(runtime_state.get(property_name))


func _display_value(value: Variant) -> String:
	if value == null:
		return "—"
	var text := str(value).strip_edges()
	if text.is_empty() or text == "null" or text == "N/A":
		return "—"
	return text


func _on_action_button_pressed() -> void:
	_selected_category = PHASE2_CATEGORIES[0]
	_refresh_action_menu()
	_action_menu_popup.popup_centered_ratio(0.6)


func _on_relation_button_pressed() -> void:
	_refresh_relation_popup()
	_relation_popup.popup_centered_ratio(0.7)


func _refresh_overlay_data() -> void:
	_refresh_action_menu()
	_refresh_relation_popup()


func _refresh_action_menu() -> void:
	_clear_children(_category_list)
	_clear_children(_action_list)
	for category in PHASE2_CATEGORIES:
		var button := Button.new()
		button.text = category
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.theme_type_variation = &"PrimaryButton" if category == _selected_category else &"Button"
		button.pressed.connect(func() -> void:
			_selected_category = category
			_refresh_action_menu()
		)
		_category_list.add_child(button)

	var actions: Array = _game_root().call("get_available_phase2_actions")
	var shown_count := 0
	for spec in actions:
		if spec.category_id != _selected_category:
			continue
		shown_count += 1
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = not str(spec.disabled_reason).is_empty()
		button.text = _format_action_row(spec)
		button.tooltip_text = _format_action_row(spec)
		button.pressed.connect(func() -> void:
			_handle_action_selected(spec)
		)
		_action_list.add_child(button)
	_action_empty_state.visible = shown_count == 0
	_action_empty_state.text = "%s\n%s" % [ACTION_MENU_EMPTY_HEADING, ACTION_MENU_EMPTY_BODY]


func _format_action_row(spec: Variant) -> String:
	var lines := [
		"%s：%s" % [ACTION_LABEL_NAME, spec.display_name],
		"%s：%d" % [ACTION_LABEL_AP, spec.ap_cost],
		"%s：%s" % [ACTION_LABEL_ENERGY, _signed_value(spec.energy_delta)],
		"%s：%s" % [ACTION_LABEL_TARGET, _localized_target_type(spec.target_type)],
		"%s：%s" % [ACTION_LABEL_EFFECT, spec.effect_summary],
	]
	if not str(spec.disabled_reason).is_empty():
		lines.append(spec.disabled_reason)
	return "\n".join(lines)


func _localized_target_type(target_type: String) -> String:
	match target_type:
		"character":
			return "角色"
		"none":
			return "无"
		_:
			return target_type


func _signed_value(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


func _handle_action_selected(spec: Variant) -> void:
	if not str(spec.disabled_reason).is_empty():
		return
	if spec.id == "visit":
		_pending_target_action_id = spec.id
		_refresh_target_picker()
		_target_picker_dialog.popup_centered_ratio(0.5)
		return
	var result = _game_root().call("execute_phase2_action", spec.id, "")
	_show_action_result(result)
	show_success_state(_game_root().current_session)


func _refresh_target_picker() -> void:
	_clear_children(_target_list)
	var relations: Array = _game_root().call("get_relation_overview")
	var protagonist_id: String = _game_root().current_session.protagonist_id if _game_root().current_session != null else ""
	var protagonist_state: RuntimeCharacterState = _game_root().current_session.get_character_state(protagonist_id)
	if protagonist_state == null:
		return
	var targets: Array = _data_repository().call("get_characters_in_city", protagonist_state.current_city_id)
	for target in targets:
		if target.id == protagonist_id:
			continue
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.toggle_mode = true
		button.text = _format_target_row(target, relations)
		button.set_meta("target_id", target.id)
		_target_list.add_child(button)


func _format_target_row(target: CharacterDefinition, relations: Array) -> String:
	var faction := _data_repository().call("get_faction", target.faction_id) as FactionDefinition
	var city := _data_repository().call("get_city", target.city_id) as CityDefinition
	var relation_summary := "关系摘要：尚无重点标记"
	for relation in relations:
		if relation.target_character_id == target.id:
			relation_summary = "关系摘要：好感 %d / 信任 %d / 敬重 %d / 戒备 %d" % [relation.favor, relation.trust, relation.respect, relation.vigilance]
			break
	return "目标名：%s\n所属势力：%s\n所在城市：%s\n%s\n预估效果：好感 +10，信任 +6，敬重 +2，戒备 -4" % [target.name, _display_value(faction.name if faction != null else ""), _display_value(city.name if city != null else ""), relation_summary]


func _on_target_picker_confirmed() -> void:
	var selected_target_id := ""
	for child in _target_list.get_children():
		if child is Button and child.button_pressed:
			selected_target_id = str(child.get_meta("target_id", ""))
			break
	if selected_target_id.is_empty():
		return
	var result = _game_root().call("execute_phase2_action", _pending_target_action_id, selected_target_id)
	_show_action_result(result)
	show_success_state(_game_root().current_session)


func _refresh_relation_popup() -> void:
	_clear_children(_relation_list)
	for relation in _game_root().call("get_relation_overview"):
		var target := _data_repository().call("get_character", relation.target_character_id) as CharacterDefinition
		if target == null:
			continue
		var faction := _data_repository().call("get_faction", target.faction_id) as FactionDefinition
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "人物名：%s\n关系标签：%s\n好感：%d / 信任：%d / 敬重：%d / 戒备：%d\n所属势力：%s\n可互动状态：%s" % [
			target.name,
			_relation_tag(relation),
			relation.favor,
			relation.trust,
			relation.respect,
			relation.vigilance,
			_display_value(faction.name if faction != null else ""),
			_interaction_status(relation)
		]
		_relation_list.add_child(label)


func _relation_tag(relation: Variant) -> String:
	if relation.vigilance >= 60:
		return "高戒备"
	if relation.trust >= 50:
		return "可信赖"
	if relation.favor >= 45:
		return "亲近"
	return "观望"


func _interaction_status(relation: Variant) -> String:
	return "可拜访" if relation.vigilance < 70 else "需谨慎接触"


func _show_action_result(result: Variant) -> void:
	if result == null:
		return
	var relation_text := _format_relation_delta_text(result.relation_deltas)
	var clue_text := str(result.clue_text).strip_edges()
	_action_result_body.text = "行动名：%s\n%s：%s\n%s：%s\n%s：%s\n%s：%s\n%s：%s" % [
		result.title,
		RESULT_LABEL_OUTCOME,
		"成功" if result.success else "失败",
		RESULT_LABEL_REASON,
		result.reason_text,
		RESULT_LABEL_STATS,
		_format_stat_delta_text(result.stat_deltas),
		RESULT_LABEL_RELATIONS,
		relation_text,
		RESULT_LABEL_CLUE,
		clue_text if not clue_text.is_empty() else "无"
	]
	_action_result_dialog.popup_centered_ratio(0.45)
	_task_body.text = "最近行动：%s\n%s：%s" % [result.title, RESULT_LABEL_REASON, result.reason_text]
	_event_body.text = "结果反馈：%s\n%s：%s" % [result.summary_line, RESULT_LABEL_STATS, _format_stat_delta_text(result.stat_deltas)]
	_relation_summary_body.text = "关键关系摘要：%s" % relation_text


func _format_stat_delta_text(stat_deltas: Dictionary) -> String:
	if stat_deltas.is_empty():
		return "无"
	var parts: Array[String] = []
	for key in stat_deltas.keys():
		parts.append("%s %s" % [key, _signed_value(int(stat_deltas[key]))])
	return "，".join(parts)


func _format_relation_delta_text(relation_deltas: Dictionary) -> String:
	if relation_deltas.is_empty():
		return "无"
	var parts: Array[String] = []
	for key in relation_deltas.keys():
		parts.append("%s %s" % [key, _signed_value(int(relation_deltas[key]))])
	return "，".join(parts)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
