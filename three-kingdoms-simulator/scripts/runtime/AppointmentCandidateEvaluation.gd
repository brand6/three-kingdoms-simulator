extends RefCounted
class_name AppointmentCandidateEvaluation

# 候选评估 DTO：统一月末候选比较与五层解释

## 目标职位 ID
var office_id: String = ""
## 候选角色 ID
var candidate_character_id: String = ""
## 评估状态：pending / evaluated / skipped
var evaluation_status: String = "pending"
## 资格是否通过
var qualification_passed: bool = false
## 是否有空缺
var vacancy_available: bool = false
## 推荐得分
var recommendation_score: int = 0
## 反对得分
var opposition_score: int = 0
## 派系支持得分
var bloc_score: int = 0
## 功绩得分
var merit_score: int = 0
## 信任得分
var trust_score: int = 0
## 竞争排名（1 = 最优）
var competition_rank: int = 0
## 原因行列表
var reason_lines: Array = []
## 最终决定：appointed / rejected / deferred / lost_to_rival
var final_decision: String = ""
## 下月建议
var next_goal_hint: String = ""


static func create(
	office_id_value: String,
	candidate_character_id_value: String,
	evaluation_status_value: String,
	qualification_passed_value: bool,
	vacancy_available_value: bool,
	recommendation_score_value: int,
	opposition_score_value: int,
	bloc_score_value: int,
	merit_score_value: int,
	trust_score_value: int,
	competition_rank_value: int,
	reason_lines_value: Array,
	final_decision_value: String,
	next_goal_hint_value: String
) -> AppointmentCandidateEvaluation:
	var evaluation := AppointmentCandidateEvaluation.new()
	evaluation.office_id = office_id_value
	evaluation.candidate_character_id = candidate_character_id_value
	evaluation.evaluation_status = evaluation_status_value
	evaluation.qualification_passed = qualification_passed_value
	evaluation.vacancy_available = vacancy_available_value
	evaluation.recommendation_score = recommendation_score_value
	evaluation.opposition_score = opposition_score_value
	evaluation.bloc_score = bloc_score_value
	evaluation.merit_score = merit_score_value
	evaluation.trust_score = trust_score_value
	evaluation.competition_rank = competition_rank_value
	evaluation.reason_lines = reason_lines_value.duplicate()
	evaluation.final_decision = final_decision_value
	evaluation.next_goal_hint = next_goal_hint_value
	return evaluation


## 获取可见的主要原因行（用于月报/任命弹窗）
func get_visible_reason_lines(max_count: int = 3) -> Array:
	var visible: Array = []
	var sorted_lines := reason_lines.duplicate()
	sorted_lines.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(a.sort_order) < int(b.sort_order)
	)
	for line in sorted_lines:
		if visible.size() >= max_count:
			break
		visible.append(line)
	return visible


## 获取顶层决定标签（最早阻断层）
func get_top_line_decision() -> String:
	if final_decision.is_empty():
		return "pending"
	return final_decision


func to_save_dict() -> Dictionary:
	var reason_dicts: Array = []
	for line in reason_lines:
		if line is PoliticalReasonLine:
			reason_dicts.append(line.to_save_dict())
	return {
		"office_id": office_id,
		"candidate_character_id": candidate_character_id,
		"evaluation_status": evaluation_status,
		"qualification_passed": qualification_passed,
		"vacancy_available": vacancy_available,
		"recommendation_score": recommendation_score,
		"opposition_score": opposition_score,
		"bloc_score": bloc_score,
		"merit_score": merit_score,
		"trust_score": trust_score,
		"competition_rank": competition_rank,
		"reason_lines": reason_dicts,
		"final_decision": final_decision,
		"next_goal_hint": next_goal_hint,
	}
