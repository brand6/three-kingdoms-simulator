extends SceneTree

# Phase 3 合同回归测试
# 验证政治 DTO 可实例化、字段可安全复制、候选评估可产出决定和原因行


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_political_reason_line()
	_test_political_support_snapshot()
	_test_appointment_candidate_evaluation()
	_test_evaluation_with_reason_lines()
	_test_snapshot_duplicate_safety()

	print("[phase3_contract_regression] All tests passed.")
	quit()


func _test_political_reason_line() -> void:
	var line := PoliticalReasonLine.create(
		"recommendation",
		"recommendation_stage",
		"superior",
		"xun_yu",
		"bloc_颍川",
		"support",
		"major",
		"荀彧举荐：信任深厚，功绩显著",
		"月报推荐",
		1,
		true
	)
	_assert_equal(line.reason_type, "recommendation", "reason_line.reason_type")
	_assert_equal(line.stage, "recommendation_stage", "reason_line.stage")
	_assert_equal(line.source_type, "superior", "reason_line.source_type")
	_assert_equal(line.source_character_id, "xun_yu", "reason_line.source_character_id")
	_assert_equal(line.source_bloc_id, "bloc_颍川", "reason_line.source_bloc_id")
	_assert_equal(line.direction, "support", "reason_line.direction")
	_assert_equal(line.weight_tier, "major", "reason_line.weight_tier")
	_assert_equal(line.is_major, true, "reason_line.is_major")
	_assert_equal(line.sort_order, 1, "reason_line.sort_order")

	# 验证 to_save_dict 可序列化
	var dict := line.to_save_dict()
	_assert_equal(dict["reason_type"], "recommendation", "reason_line dict.reason_type")
	_assert_equal(dict["is_major"], true, "reason_line dict.is_major")


func _test_political_support_snapshot() -> void:
	var recommenders: Array[String] = ["xun_yu", "cao_ren"]
	var opposers: Array[String] = ["chen_gong"]
	var blocs: Dictionary = {"bloc_颍川": "support", "bloc_旧吏": "oppose"}
	var qual_tags: Array[String] = ["merit_sufficient"]
	var blocker_tags: Array[String] = []
	var candidate_offices: Array[String] = ["office_zhubu"]
	var opportunity_tags: Array[String] = ["vacancy_open"]

	var snapshot := PoliticalSupportSnapshot.create(
		"190-01",
		"player_char",
		recommenders,
		opposers,
		blocs,
		25,
		10,
		qual_tags,
		blocker_tags,
		candidate_offices,
		opportunity_tags
	)

	_assert_equal(snapshot.month_key, "190-01", "snapshot.month_key")
	_assert_equal(snapshot.character_id, "player_char", "snapshot.character_id")
	_assert_equal(snapshot.primary_recommender_ids.size(), 2, "snapshot.recommender count")
	_assert_equal(snapshot.primary_opposer_ids.size(), 1, "snapshot.opposer count")
	_assert_equal(snapshot.bloc_attitudes["bloc_颍川"], "support", "snapshot.bloc attitude 颍川")
	_assert_equal(snapshot.bloc_attitudes["bloc_旧吏"], "oppose", "snapshot.bloc attitude 旧吏")
	_assert_equal(snapshot.support_score_total, 25, "snapshot.support_total")
	_assert_equal(snapshot.opposition_score_total, 10, "snapshot.opposition_total")
	_assert_equal(snapshot.candidate_office_ids.size(), 1, "snapshot.candidate_offices count")
	_assert_equal(snapshot.opportunity_tags[0], "vacancy_open", "snapshot.opportunity_tags[0]")

	# 验证 to_save_dict
	var dict := snapshot.to_save_dict()
	_assert_equal(dict["month_key"], "190-01", "snapshot dict.month_key")
	_assert_equal(dict["support_score_total"], 25, "snapshot dict.support_total")


func _test_appointment_candidate_evaluation() -> void:
	var evaluation := AppointmentCandidateEvaluation.create(
		"office_zhubu",
		"player_char",
		"evaluated",
		true,
		true,
		20,
		8,
		5,
		18,
		14,
		1,
		[],
		"appointed",
		"继续积累功绩以谋求更高职位"
	)

	_assert_equal(evaluation.office_id, "office_zhubu", "eval.office_id")
	_assert_equal(evaluation.candidate_character_id, "player_char", "eval.candidate")
	_assert_equal(evaluation.evaluation_status, "evaluated", "eval.status")
	_assert_equal(evaluation.qualification_passed, true, "eval.qualification_passed")
	_assert_equal(evaluation.vacancy_available, true, "eval.vacancy")
	_assert_equal(evaluation.recommendation_score, 20, "eval.recommendation_score")
	_assert_equal(evaluation.opposition_score, 8, "eval.opposition_score")
	_assert_equal(evaluation.bloc_score, 5, "eval.bloc_score")
	_assert_equal(evaluation.merit_score, 18, "eval.merit_score")
	_assert_equal(evaluation.trust_score, 14, "eval.trust_score")
	_assert_equal(evaluation.competition_rank, 1, "eval.competition_rank")
	_assert_equal(evaluation.final_decision, "appointed", "eval.final_decision")
	_assert_equal(evaluation.get_top_line_decision(), "appointed", "eval.top_line_decision")
	_assert_equal(evaluation.next_goal_hint, "继续积累功绩以谋求更高职位", "eval.next_goal_hint")


func _test_evaluation_with_reason_lines() -> void:
	# 构造一个带 3 条原因行的候选评估（模拟失败案例）
	var line1 := PoliticalReasonLine.create(
		"qualification", "qualification_stage", "system", "", "",
		"support", "major", "资格审查通过", "资格", 1, false
	)
	var line2 := PoliticalReasonLine.create(
		"opposition", "opposition_stage", "rival", "chen_gong", "",
		"oppose", "major", "陈宫强烈反对：信任不足", "阻力", 2, true
	)
	var line3 := PoliticalReasonLine.create(
		"competition", "competition_stage", "ai_candidate", "le_jin", "",
		"oppose", "minor", "乐进功绩更高，竞争排名领先", "竞争", 3, false
	)

	var reason_lines: Array = [line1, line2, line3]
	var evaluation := AppointmentCandidateEvaluation.create(
		"office_zhubu",
		"player_char",
		"evaluated",
		true,
		true,
		12,
		18,
		-3,
		15,
		10,
		2,
		reason_lines,
		"lost_to_rival",
		"提升与陈宫的关系，或等待对手调任"
	)

	_assert_equal(evaluation.reason_lines.size(), 3, "eval_fail.reason_lines count")
	_assert_equal(evaluation.final_decision, "lost_to_rival", "eval_fail.final_decision")

	# 验证 get_visible_reason_lines 最多返回 2 条
	var visible := evaluation.get_visible_reason_lines(2)
	_assert_equal(visible.size(), 2, "eval_fail.visible_lines max 2")
	# 按 sort_order 排序，应该是 line1(1) 和 line2(2)
	_assert_equal(visible[0].sort_order, 1, "eval_fail.visible[0].sort_order")
	_assert_equal(visible[1].sort_order, 2, "eval_fail.visible[1].sort_order")

	# 验证 to_save_dict 包含原因行
	var dict := evaluation.to_save_dict()
	_assert_equal(dict["reason_lines"].size(), 3, "eval_fail dict.reason_lines count")
	_assert_equal(dict["next_goal_hint"], "提升与陈宫的关系，或等待对手调任", "eval_fail dict.next_goal_hint")


func _test_snapshot_duplicate_safety() -> void:
	# 验证 create 的 duplicate 行为：修改原数组不影响 snapshot
	var recommenders: Array[String] = ["xun_yu"]
	var opposers: Array[String] = []
	var blocs: Dictionary = {"bloc_颍川": "support"}
	var qual: Array[String] = []
	var block: Array[String] = []
	var offices: Array[String] = []
	var opps: Array[String] = []

	var snapshot := PoliticalSupportSnapshot.create(
		"190-02", "player_char", recommenders, opposers, blocs,
		10, 0, qual, block, offices, opps
	)

	# 修改原数组
	recommenders.append("cao_ren")
	blocs["bloc_旧吏"] = "oppose"

	# snapshot 不应受影响
	_assert_equal(snapshot.primary_recommender_ids.size(), 1, "dup safety: recommenders unchanged")
	_assert_equal(snapshot.bloc_attitudes.size(), 1, "dup safety: blocs unchanged")


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
