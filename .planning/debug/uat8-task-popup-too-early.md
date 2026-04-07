---
status: diagnosed
trigger: "Diagnose a Phase 2.1 UAT gap in a Godot project. Issue from .planning/phases/02.1-/02.1-UAT.md test 8: 在月末进入新月时，若上一月的任命/升官结果弹窗仍未确认，新一月的任务领取弹窗不应提前叠在其上方；只有玩家点击任命结果的确认后，新的领任务界面才可以出现。User reported: not pass 目前任务领取弹窗出现太早"
created: 2026-04-07T00:00:00Z
updated: 2026-04-07T00:14:00Z
---

## Current Focus

hypothesis: 月末结算时 `GameRoot.end_current_xun()` 已先把 session 推进到新月并重新上锁，`MainHUD._on_end_xun_confirmed()` 随后立即 `show_success_state()`，导致任务领取弹窗在月报/任命结果流程之前就被打开；而 `_sync_month_task_ui_state()` 又会持续维持这个错误状态
test: 对照 end_current_xun、show_success_state、month_report/promotion confirm 流程，确认是否存在任何“等待任命结果确认”的 gate
expecting: 若问题存在，应能看到 month_action_locked 被当成唯一条件，而 month_report/promotion 可见性完全未参与 gating
next_action: finalize diagnosis output

## Symptoms

expected: 在月末进入新月时，如果上一月任命/升官结果弹窗尚未确认，则新一月任务领取弹窗必须等待；只有确认任命结果后才出现
actual: 任务领取弹窗出现太早，叠在任命/升官结果弹窗上方
errors: 无显式报错；UAT test 8 fail
reproduction: 触发月末进入新月，并让上一月任命/升官结果弹窗保持未确认，观察新月任务领取弹窗是否提前出现
started: Phase 2.1 UAT test 8

## Eliminated

## Evidence

- timestamp: 2026-04-07T00:03:00Z
  checked: .planning/phases/02.1-/02.1-UAT.md test 8
  found: UAT 明确要求新月任务领取弹窗必须等待上一月任命/升官结果确认后再出现；当前用户报告为“任务领取弹窗出现太早”。
  implication: 需要检查月末结算后 UI 弹窗显示顺序与 gating 逻辑，而不是任务数据本身。

- timestamp: 2026-04-07T00:04:00Z
  checked: .planning/debug/knowledge-base.md
  found: knowledge base 文件不存在。
  implication: 无已知模式可优先复用，继续常规调查。

- timestamp: 2026-04-07T00:07:00Z
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd
  found: `show_success_state()` 每次刷新 HUD 都会无条件调用 `_open_month_task_picker_if_needed(session)`；而 `_process()` 中的 `_sync_month_task_ui_state()` 也会在 `session.month_action_locked` 时自动 reopen 任务面板。
  implication: 只要月末结算把 session 置为“新月待领任务”状态，任务面板就会被主动打开，除非另有额外 gating。

- timestamp: 2026-04-07T00:08:00Z
  checked: three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd
  found: 现有回归测试只校验“月报确认前 promotion 不出现”和“promotion 确认后两个月末弹窗都关闭”，没有断言 promotion 未确认期间任务领取面板必须保持隐藏。
  implication: 自动弹出新月任务面板的回归缺口未被测试覆盖，导致该 UI 竞态可漏过。

- timestamp: 2026-04-07T00:12:00Z
  checked: three-kingdoms-simulator/scripts/autoload/GameRoot.gd
  found: `end_current_xun()` 在月末先执行 `_process_month_end_evaluation()`，再 `advance_xun()`，进入新月后若 `current_xun == 1` 会立即 `_initialize_month_start_state()`，把 `month_action_locked = true` 并生成新月待选任务。
  implication: 在月报/任命结果 UI 还未走完之前，session 已经处于“新月待领任务”状态。

- timestamp: 2026-04-07T00:13:00Z
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd + MonthReportPanel.gd + PromotionPopup.gd
  found: `_on_end_xun_confirmed()` 先 `show_success_state(_game_root().current_session)`，而 `show_success_state()` 会调用 `_open_month_task_picker_if_needed(session)`；`_sync_month_task_ui_state()` 也仅依据 `month_action_locked` 自动 reopen。月报确认仅触发 `_on_month_report_confirmed()` -> `show_promotion()`，PromotionPopup.confirm 只 `hide()`，整个链路都没有“月报/任命结果未确认时禁止打开任务领取面板”的 gating。
  implication: 根因是 UI 流程顺序和 gating 缺失，不是任务数据错误。

## Resolution

root_cause: 月末推进到新月后，GameRoot 会立即把 session 重置为 `month_action_locked = true` 的“新月待领任务”状态；MainHUD 在 `_on_end_xun_confirmed()` 中先刷新 HUD，再显示月报/任命结果，因此 `show_success_state()` 和 `_process()` 里的 `_sync_month_task_ui_state()` 会只根据 `month_action_locked` 立刻打开 TaskSelectPanel。代码没有任何条件去等待 MonthReportPanel/PromotionPopup 确认完成，所以新月任务领取弹窗会抢在任命结果确认前出现。
fix: 在 MainHUD 为月末反馈流程增加显式 gating：当月报或任命结果流程未结束时禁止 `_open_month_task_picker_if_needed()` / `_sync_month_task_ui_state()` 打开任务领取面板；仅在 PromotionPopup 确认后再允许新月任务弹窗显示。
verification: 诊断模式，未修改代码。
files_changed: []
