---
status: diagnosed
trigger: "Diagnose a Phase 2.1 UAT gap in a Godot project. Issue from .planning/phases/02.1-/02.1-UAT.md test 6: 进入下一旬后，目前会显示占位/提示文案，而不是继续显示当前主任务名称、进度与剩余旬数。"
created: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:28:00Z
---

## Current Focus

hypothesis: confirmed — _show_xun_summary unconditionally overwrites TaskPanel after end_xun, even when session.current_month_task remains active
test: compare xun advancement state retention with HUD refresh call order
expecting: show_success_state builds correct monthly summary first, then _show_xun_summary replaces it with placeholder copy
next_action: return root cause and minimal missing fix

## Symptoms

expected: 在同一主任务尚未结算的情况下，进入下一旬后，右上角 HUD 继续显示当前主任务名称、进度与剩余旬数。
actual: 进入下一旬后，HUD 显示“本旬已结束，下旬建议……”之类的占位/提示文案，覆盖主任务信息。
errors: 无明确报错；表现为 UI 文案错误。
reproduction: 完成一旬并进入下一旬，在主任务仍未结算时观察右上角 HUD。
started: Phase 2.1 UAT test 6 发现

## Eliminated

## Evidence

- timestamp: 2026-04-07T00:05:00Z
  checked: .planning/phases/02.1-/02.1-UAT.md
  found: Test 6 fails specifically after advancing to next xun while the same main task is still active; issue is HUD placeholder text replacing persistent task summary.
  implication: Investigate HUD refresh timing/state flow around xun advancement, not task assignment itself.

- timestamp: 2026-04-07T00:14:00Z
  checked: grep on HUD/task strings
  found: MainHUD.gd contains both the expected monthly task summary formatter and a separate placeholder assignment `_task_list.text = "- 本旬已结束\n- 下旬建议：..."` at line ~640.
  implication: Root cause likely sits inside MainHUD refresh branch selection rather than missing task data generation.

- timestamp: 2026-04-07T00:24:00Z
  checked: MainHUD.gd, GameRoot.gd, TaskSystem.gd, GameSession.gd
  found: `_on_end_xun_confirmed()` calls `show_success_state(current_session)` immediately after `end_current_xun()`, which rebuilds TaskPanel from `session.current_month_task`; but on non-month-end xun it then calls `_show_xun_summary(summary)`, whose line 640 unconditionally overwrites `_task_list.text` with "本旬已结束 / 下旬建议".
  implication: UI flow overwrites valid active-task HUD text after the correct render, so bug is caused by MainHUD end-xun summary branch, not by task state loss.

- timestamp: 2026-04-07T00:26:00Z
  checked: GameRoot.gd end_current_xun and TaskSystem.gd remaining_xun_count
  found: After finishing xun 1 or 2, `current_month_task` is not cleared; only when rollover reaches a new month (`current_xun == 1`) does `_initialize_month_start_state()` reset monthly task state.
  implication: Cross-xun task persistence exists in runtime state, confirming the HUD placeholder is a presentation-layer overwrite.

- timestamp: 2026-04-07T00:27:00Z
  checked: phase21_monthly_hud_regression.gd
  found: Regression test validates task summary right after task selection and month-end report flow, but does not assert that TaskPanel still shows current monthly task after a normal next-xun rollover.
  implication: Missing regression coverage allowed this HUD overwrite bug to ship.

## Resolution

root_cause: MainHUD non-month-end xun summary flow overwrites the already-correct monthly task HUD. Specifically, `scripts/ui/MainHUD.gd::_on_end_xun_confirmed()` first calls `show_success_state(current_session)` to render the active `current_month_task`, then `_show_xun_summary(summary)` unconditionally replaces `TaskPanel/TaskList` with placeholder copy at line 640. Runtime task state persists across xun, so the failure is a UI overwrite, not data loss.
fix: In `scripts/ui/MainHUD.gd`, stop `_show_xun_summary()` from replacing `_task_list.text` when `current_session.current_month_task` is still active; keep task summary in TaskPanel and place xun-end advice only in the summary dialog/event area. Add a regression assertion for post-rollover TaskPanel text.
verification: Diagnosis only; no fix applied.
files_changed: []
