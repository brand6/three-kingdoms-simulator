extends RefCounted
class_name PoliticalSupportSnapshot

# 政治支持快照：HUD、人物页、任命输入共读的月内政治状态

## 月份标识
var month_key: String = ""
## 角色 ID
var character_id: String = ""
## 主要推荐人角色 ID 列表
var primary_recommender_ids: Array[String] = []
## 主要反对者角色 ID 列表
var primary_opposer_ids: Array[String] = []
## 派系块态度映射：bloc_id → "support" / "neutral" / "oppose"
var bloc_attitudes: Dictionary = {}
## 支持总分
var support_score_total: int = 0
## 反对总分
var opposition_score_total: int = 0
## 资格标签列表
var qualification_tags: Array[String] = []
## 阻断标签列表
var blocker_tags: Array[String] = []
## 候选职位 ID 列表
var candidate_office_ids: Array[String] = []
## 机会标签列表
var opportunity_tags: Array[String] = []


static func create(
	month_key_value: String,
	character_id_value: String,
	primary_recommender_ids_value: Array[String],
	primary_opposer_ids_value: Array[String],
	bloc_attitudes_value: Dictionary,
	support_score_total_value: int,
	opposition_score_total_value: int,
	qualification_tags_value: Array[String],
	blocker_tags_value: Array[String],
	candidate_office_ids_value: Array[String],
	opportunity_tags_value: Array[String]
) -> PoliticalSupportSnapshot:
	var snapshot := PoliticalSupportSnapshot.new()
	snapshot.month_key = month_key_value
	snapshot.character_id = character_id_value
	snapshot.primary_recommender_ids = primary_recommender_ids_value.duplicate()
	snapshot.primary_opposer_ids = primary_opposer_ids_value.duplicate()
	snapshot.bloc_attitudes = bloc_attitudes_value.duplicate(true)
	snapshot.support_score_total = support_score_total_value
	snapshot.opposition_score_total = opposition_score_total_value
	snapshot.qualification_tags = qualification_tags_value.duplicate()
	snapshot.blocker_tags = blocker_tags_value.duplicate()
	snapshot.candidate_office_ids = candidate_office_ids_value.duplicate()
	snapshot.opportunity_tags = opportunity_tags_value.duplicate()
	return snapshot


func to_save_dict() -> Dictionary:
	return {
		"month_key": month_key,
		"character_id": character_id,
		"primary_recommender_ids": Array(primary_recommender_ids),
		"primary_opposer_ids": Array(primary_opposer_ids),
		"bloc_attitudes": bloc_attitudes,
		"support_score_total": support_score_total,
		"opposition_score_total": opposition_score_total,
		"qualification_tags": Array(qualification_tags),
		"blocker_tags": Array(blocker_tags),
		"candidate_office_ids": Array(candidate_office_ids),
		"opportunity_tags": Array(opportunity_tags),
	}
