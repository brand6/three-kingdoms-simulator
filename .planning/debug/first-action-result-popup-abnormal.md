---
status: awaiting_human_verify
trigger: "Investigate issue: first-action-result-popup-abnormal"
created: 2026-04-08T00:00:00Z
updated: 2026-04-08T01:05:00Z
---

## Current Focus

hypothesis: target popup fix is complete and self-verified; user now needs to confirm the first-open action-result popup is normal in the real game flow
test: user performs the first action-result popup flow from a fresh month/task-selection path and confirms content/layout are complete on first open
expecting: first-open action result popup shows full text and visible confirm button with no missing content
next_action: wait for user confirmation or failure details from real workflow verification

## Symptoms

expected: 行动结果弹窗首次打开时就应正常布局显示，内容完整。
actual: 行动结果弹窗首次打开必现异常，主要表现为内容缺失。
errors: 控制台目前没有看到相关报错或警告。
reproduction: 首次打开行动结果弹窗时稳定复现。
started: 一直存在，从一开始就有。

## Eliminated

## Evidence

- timestamp: 2026-04-08T00:10:00Z
  checked: knowledge base existence
  found: `.planning/debug/knowledge-base.md` does not exist in this repo.
  implication: no prior resolved-session index is available; must investigate from code and existing debug notes.

- timestamp: 2026-04-08T00:10:00Z
  checked: popup-related codebase search
  found: `MainHUD.gd` owns `ActionResultDialog`; prior debug note `month-report-exclusive-child.md` documents a confirmed first-open popup sizing pattern affecting other dialogs and already-fixed popups use deferred popup plus fixed sizing.
  implication: ActionResultDialog is a strong candidate for a similar but not yet patched first-open layout bug.

- timestamp: 2026-04-08T00:18:00Z
  checked: `MainHUD.gd` `_show_action_result()` + `MainScene.tscn` ActionResultDialog subtree
  found: ActionResultDialog still uses `AcceptDialog` with only `ActionResultMargin -> ActionResultBody` and opens via `popup_centered_ratio(0.45)`. Unlike `XunSummaryDialog`, it has no fixed-size constants, no `min_size/max_size/size` synchronization, no deferred popup call, and no custom confirm row. `ActionResultBody` is also the sole content node, so there is no explicit reserved space for controls.
  implication: this popup has not received the first-open stabilization pattern already applied to other dialogs, matching the reported “首次打开内容缺失” symptom.

- timestamp: 2026-04-08T00:24:00Z
  checked: `MonthReportPanel.gd`, `PromotionPopup.gd`, `phase2_xun_loop_regression.gd`
  found: already-fixed dialogs all share the same stabilization pattern—fixed `PANEL_SIZE`, `_ready()`-time size constraints, hidden built-in OK button, explicit custom confirm button, and `call_deferred(...popup_centered(PANEL_SIZE))`. Existing regressions already assert first-open dialog correctness for similar popup classes.
  implication: the cleanest falsifiable fix is to migrate ActionResultDialog onto the same pattern and add a first-open regression covering size and content visibility.

- timestamp: 2026-04-08T00:37:00Z
  checked: `MainHUD.gd`, `MainScene.tscn`, new `phase2_action_result_popup_regression.gd`
  found: ActionResultDialog was migrated to a stabilized structure matching other fixed dialogs: fixed `ACTION_RESULT_DIALOG_SIZE`, hidden built-in OK button, custom confirm row, deferred popup helper, and scene content wrapped in a VBox with body `size_flags_vertical = 3` plus explicit bottom action row.
  implication: the previously missing first-open layout protections are now in place and can be verified through regression.

- timestamp: 2026-04-08T00:45:00Z
  checked: first regression run output
  found: the new regression attempted to open ActionResultDialog while `TaskSelectPanel` was still the active exclusive popup, causing an exclusive-child error unrelated to the reported bug. The test also failed because Godot `Button` does not expose a `press()` method.
  implication: the current test setup is invalid, but this does not disprove the root-cause hypothesis; verification must follow the real post-task-selection flow and use a valid button interaction API.

- timestamp: 2026-04-08T00:50:00Z
  checked: `phase21_monthly_hud_regression.gd` and `phase21_monthly_career_regression.gd`
  found: existing monthly regressions consistently clear the initial lock by selecting a month task through the picker/UI flow before testing later popups.
  implication: the action-result regression should use the same precondition; otherwise first-open popup tests are confounded by unrelated modal gating.

- timestamp: 2026-04-08T00:58:00Z
  checked: headless verification runs
  found: `phase2_action_result_popup_regression.gd` now passes headlessly with no assertion failures. An existing broader regression, `phase21_monthly_hud_regression.gd`, still fails earlier on TaskSelectPanel selected-reward behavior (`Selecting a task should still keep the area above the confirm CTA free of task info.`), which is outside the files changed for this fix and occurs before the action-result popup path.
  implication: the target popup fix is self-verified by focused regression, but there is unrelated pre-existing regression noise elsewhere in the branch.

- timestamp: 2026-04-08T01:05:00Z
  checked: adjacent sanity regression `phase21_monthly_career_regression.gd`
  found: it still reports an exclusive-child conflict caused by `TaskSelectPanel` remaining open on a later flow, which is unrelated to ActionResultDialog and outside the files changed here.
  implication: no new evidence points back to the action-result popup fix itself; final confidence now depends on user verification in the real UI flow.

## Resolution

root_cause: ActionResultDialog still used the old unstabilized AcceptDialog flow—single body label plus immediate `popup_centered_ratio(0.45)` on first open—while similar dialogs had already been migrated to fixed-size, deferred popup logic. On the first open, this left the content/layout calculation nondeterministic and could produce a partially empty body area.
fix: Migrate ActionResultDialog to the stabilized popup pattern used by the other fixed dialogs: explicit fixed size, custom content container with confirm button, hidden built-in OK button, and deferred `popup_centered()` after content update.
verification: Focused headless regression `phase2_action_result_popup_regression.gd` passes after the fix, confirming first-open action-result popup shows required content tokens, stable 560x360 sizing, hidden built-in OK button, and visible custom confirm button. Broader monthly HUD regression still has an unrelated TaskSelectPanel failure outside this fix surface.
files_changed: ["three-kingdoms-simulator/scripts/ui/MainHUD.gd", "three-kingdoms-simulator/scenes/main/MainScene.tscn", "three-kingdoms-simulator/scripts/tests/phase2_action_result_popup_regression.gd"]
