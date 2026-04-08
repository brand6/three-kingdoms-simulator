extends RefCounted
class_name PoliticalReasonLine

# 政治原因行：explainable-politics 的唯一原因单位
# 被月报、HUD、任命反馈共用

## 原因类型：qualification / vacancy / recommendation / opposition / competition
var reason_type: String = ""
## 所属阶段：对应五层原因树的层级
var stage: String = ""
## 来源类型：上级、同僚、派系、门阀等
var source_type: String = ""
## 来源角色 ID（推荐人/反对者）
var source_character_id: String = ""
## 来源派系块 ID
var source_bloc_id: String = ""
## 方向：support / oppose / neutral
var direction: String = ""
## 权重层级：major / minor / trivial
var weight_tier: String = "minor"
## 摘要文本，UI 直接展示
var summary_text: String = ""
## UI 分组标签，用于面板中归类展示
var ui_group: String = ""
## 排序序号
var sort_order: int = 0
## 是否为主要原因（月报主标题候选）
var is_major: bool = false


static func create(
	reason_type_value: String,
	stage_value: String,
	source_type_value: String,
	source_character_id_value: String,
	source_bloc_id_value: String,
	direction_value: String,
	weight_tier_value: String,
	summary_text_value: String,
	ui_group_value: String,
	sort_order_value: int,
	is_major_value: bool
) -> PoliticalReasonLine:
	var line := PoliticalReasonLine.new()
	line.reason_type = reason_type_value
	line.stage = stage_value
	line.source_type = source_type_value
	line.source_character_id = source_character_id_value
	line.source_bloc_id = source_bloc_id_value
	line.direction = direction_value
	line.weight_tier = weight_tier_value
	line.summary_text = summary_text_value
	line.ui_group = ui_group_value
	line.sort_order = sort_order_value
	line.is_major = is_major_value
	return line


func to_save_dict() -> Dictionary:
	return {
		"reason_type": reason_type,
		"stage": stage,
		"source_type": source_type,
		"source_character_id": source_character_id,
		"source_bloc_id": source_bloc_id,
		"direction": direction,
		"weight_tier": weight_tier,
		"summary_text": summary_text,
		"ui_group": ui_group,
		"sort_order": sort_order,
		"is_major": is_major,
	}
