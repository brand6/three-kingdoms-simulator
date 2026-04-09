---
status: investigating
trigger: "月初任务卡中的来源应显示权力机构（如 尚书台 / 军功集团 / 宗族长老会），请求方应显示具体下达任务的人，且整体文字排版需要进一步优化边距与可读性。"
created: 2026-04-09T09:23:34.9959001+08:00
updated: 2026-04-09T09:29:15+08:00
---

## Current Focus

hypothesis: root cause is now narrowed to two concrete defects from the 03-08 contract: (1) semantic mapping defect—request_character_id is incorrectly used as both 来源 target and 请求方 while no institution field exists; (2) regression coverage defect—tests only assert label presence, not institution/requester correctness or spacing
test: inspect whether faction/bloc/clan data contains institution labels that could have been mapped, and confirm current regression lacks semantic assertions
expecting: finalize root-cause statement with precise files involved
next_action: read faction/bloc data and summarize diagnosis

## Symptoms

expected: 来源显示权力机构名，请求方显示具体下达任务的人，任务卡边距与排版更易读
actual: 来源仍显示当前来源对象拼接逻辑，请求方不是具体下达人，整体文字排版仍需优化
errors: None reported
reproduction: Follow-up UAT after 03-08
started: Discovered after executing gap closure plan 03-08

## Eliminated

## Evidence

- timestamp: 2026-04-09T09:24:30+08:00
  checked: .planning/debug/knowledge-base.md
  found: Knowledge base file does not exist yet.
  implication: No prior resolved pattern is available; investigation proceeds from code evidence only.

- timestamp: 2026-04-09T09:24:30+08:00
  checked: grep across three-kingdoms-simulator for task source/request fields
  found: TaskSelectPanel.gd header builds 来源 from _localized_source_type(task_source_type) + _source_target_text(candidate), while _source_target_text prefers request_character_id and only then source_summary.
  implication: Current implementation likely conflates 来源 with requester/summary rather than a dedicated institution field.

- timestamp: 2026-04-09T09:24:55+08:00
  checked: three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd and scripts/systems/TaskSystem.gd
  found: Candidate payload only exposes task_source_type, request_character_id, related_bloc_id, source_summary, issuer_character_id, and tag arrays; header text renders 请求方 directly from request_character_id, while 来源 also derives from request_character_id via _source_target_text before falling back.
  implication: The wrong display is already encoded before rendering completes; even a correct layout cannot show institution/requester separation without different fields or mapping rules.

- timestamp: 2026-04-09T09:26:40+08:00
  checked: scripts/runtime/MonthlyTaskState.gd, scripts/data/resources/TaskTemplateData.gd, scripts/autoload/DataRepository.gd, and data/generated/190/task_templates.json
  found: The persistent schema only defines task_source_type, request_character_id, related_bloc_id, and source_summary for source metadata; generated task JSON contains person-centric summaries like “曹操直接下令” / “陈宫建议...” and no authority-institution field at all.
  implication: The requested institution names are not merely hidden by UI; current content/schema cannot supply them, so the renderer has no correct institution value to display.

- timestamp: 2026-04-09T09:28:20+08:00
  checked: three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd and 03-08 planning docs
  found: The 03-08 plan/summary explicitly chose “来源类型内联到首行的 来源：{来源类型} · {来源对象}”, and the regression only checks that 来源/请求方 labels exist, not that 来源 is an authority institution or that 请求方 is the actual issuer.
  implication: The incorrect semantics were intentionally baked into the accepted contract and then left unguarded by tests, allowing UAT to surface the mismatch only afterward.

## Resolution

root_cause: 
fix: 
verification: 
files_changed: []
