extends Control
class_name MainHUD

const LOADING_TEXT := "正在加载 190 样本…"
const SUCCESS_TEXT := "已进入 190 样本"
const ERROR_TEXT := "190 样本加载失败。请检查 Luban JSON 导出文件、默认主角 ID 与数据路径配置，然后重新启动项目。"
const EMPTY_TASK_HEADING := "暂无当前任务"
const EMPTY_TASK_BODY := "当前阶段只验证入口与状态总览。请先查看人物、时间与基础数值，后续阶段将开放行动与任务。"

@onready var _time_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/TimeLabel")
@onready var _city_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/CityLabel")
@onready var _identity_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/IdentityLabel")
@onready var _faction_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/FactionLabel")
@onready var _office_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/OfficeLabel")
@onready var _name_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/LeftOverview/LeftOverviewContent/NameLabel")
@onready var _ap_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/LeftOverview/LeftOverviewContent/APLabel")
@onready var _energy_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/LeftOverview/LeftOverviewContent/EnergyLabel")
@onready var _stress_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/LeftOverview/LeftOverviewContent/StressLabel")
@onready var _fame_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/LeftOverview/LeftOverviewContent/FameLabel")
@onready var _merit_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/LeftOverview/LeftOverviewContent/MeritLabel")
@onready var _summary_label: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/SummaryLabel")
@onready var _summary_body: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/CenterSummary/CenterSummaryContent/CenterCard/CenterCardContent/SummaryBody")
@onready var _task_body: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/RightContext/RightContextContent/TaskBody")
@onready var _event_body: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/RightContext/RightContextContent/EventBody")
@onready var _notice_body: Label = get_node("MarginContainer/VBoxContainer/MiddleBody/RightContext/RightContextContent/NoticeBody")


func _game_root() -> Node:
	return get_node("/root/GameRoot")


func _data_repository() -> Node:
	return get_node("/root/DataRepository")


func _time_manager() -> Node:
	return get_node("/root/TimeManager")


func _ready() -> void:
	show_loading_state()
	if Engine.is_editor_hint():
		return
	call_deferred("_bootstrap_default_entry")


func _bootstrap_default_entry() -> void:
	_game_root().call("register_hud", self)
	_game_root().call("bootstrap_default_entry")


func show_loading_state() -> void:
	_summary_label.text = SUCCESS_TEXT
	_summary_body.text = LOADING_TEXT
	_task_body.text = EMPTY_TASK_HEADING
	_event_body.text = EMPTY_TASK_BODY
	_notice_body.text = "后续阶段开放"
	_render_empty_fields()


func show_success_state(session: GameSession) -> void:
	var protagonist := _data_repository().call("get_character", session.protagonist_id) as CharacterDefinition
	var runtime_state := session.get_character_state(session.protagonist_id)
	var city := _data_repository().call("get_city", runtime_state.current_city_id if runtime_state != null else "") as CityDefinition
	var faction := _data_repository().call("get_faction", protagonist.faction_id if protagonist != null else "") as FactionDefinition

	_summary_label.text = SUCCESS_TEXT
	_summary_body.text = "当前阶段已完成默认主角载入，可直接验证时间、身份、势力与基础状态展示。"
	_task_body.text = EMPTY_TASK_HEADING
	_event_body.text = EMPTY_TASK_BODY
	_notice_body.text = "重要提示：灰色入口将在后续阶段开放"

	_time_label.text = _time_manager().call("get_current_label")
	_city_label.text = _pair_text("当前城市", city.name if city != null else "")
	_identity_label.text = _pair_text("当前身份", protagonist.identity_type if protagonist != null else "")
	_faction_label.text = _pair_text("所属势力", faction.name if faction != null else "")
	_office_label.text = _pair_text("当前官职", protagonist.office_id if protagonist != null else "")
	_name_label.text = _pair_text("姓名", protagonist.name if protagonist != null else "")
	_ap_label.text = _metric_text("AP", runtime_state, &"ap")
	_energy_label.text = _metric_text("精力", runtime_state, &"energy")
	_stress_label.text = _metric_text("压力", runtime_state, &"stress")
	_fame_label.text = _metric_text("名望", runtime_state, &"fame")
	_merit_label.text = _metric_text("功绩", runtime_state, &"merit")


func show_error_state(message: String) -> void:
	_summary_label.text = SUCCESS_TEXT
	_summary_body.text = "%s\n%s" % [ERROR_TEXT, _display_value(message)]
	_task_body.text = EMPTY_TASK_HEADING
	_event_body.text = EMPTY_TASK_BODY
	_notice_body.text = "重要提示：请修复数据后重新启动"
	_render_empty_fields()


func _render_empty_fields() -> void:
	_time_label.text = _display_value(null)
	_city_label.text = _pair_text("当前城市", "")
	_identity_label.text = _pair_text("当前身份", "")
	_faction_label.text = _pair_text("所属势力", "")
	_office_label.text = _pair_text("当前官职", "")
	_name_label.text = _pair_text("姓名", "")
	_ap_label.text = _pair_text("AP", null)
	_energy_label.text = _pair_text("精力", null)
	_stress_label.text = _pair_text("压力", null)
	_fame_label.text = _pair_text("名望", null)
	_merit_label.text = _pair_text("功绩", null)


func _pair_text(label_text: String, value: Variant) -> String:
	return "%s：%s" % [label_text, _display_value(value)]


func _metric_text(label_text: String, runtime_state: RuntimeCharacterState, property_name: StringName) -> String:
	if runtime_state == null:
		return _pair_text(label_text, null)
	return _pair_text(label_text, runtime_state.get(property_name))


func _display_value(value: Variant) -> String:
	if value == null:
		return "—"
	var text := str(value).strip_edges()
	if text.is_empty() or text == "null" or text == "N/A":
		return "—"
	return text
