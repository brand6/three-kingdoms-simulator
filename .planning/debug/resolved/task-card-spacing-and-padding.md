---
status: resolved
trigger: "Investigate issue: task-card-spacing-and-padding"
created: 2026-04-09T00:00:00Z
updated: 2026-04-09T01:20:00Z
---

## Current Focus

hypothesis: confirmed; deferred post-layout card minimum-height recomputation fixed the stale one-line sizing by letting the wrapped RichTextLabel contribute after popup width is known
test: archive the resolved session, commit the verified fix, and record the pattern in the debug knowledge base
expecting: resolved session is archived cleanly and future similar UI sizing bugs can be matched from the knowledge base
next_action: move this debug note to resolved/, commit the code fix, and append a knowledge-base entry

## Symptoms

expected: 月初任务领取界面的任务卡标题行中，任务名/来源/请求方三块等宽均匀分布；单条任务正文下方没有多余空行；文字内容与左右边缘之间有统一边距，并尽量形成可复用的 UI 规范。
actual: 当前标题三块分布不均，表现为左边1块、右边2块；单条任务信息下方仍有空行；任务文字贴近左右边缘。
errors: 无报错，纯 UI 表现问题。
reproduction: 打开月初任务弹窗即可稳定复现。
started: 之前也有，不是本次 quick task 才出现。

## Eliminated

## Evidence

- timestamp: 2026-04-09T00:05:00Z
  checked: .planning/debug/knowledge-base.md and prior debug notes
  found: No resolved knowledge-base match exists, but two active debug notes overlap strongly. political-task-card-layout identified TaskSelectPanel task cards as a single plain-text Button renderer, and task-card-source-requester-layout noted remaining spacing/readability concerns were not yet fixed.
  implication: Highest-probability starting point is TaskSelectPanel card layout/formatting rather than data or engine behavior.

- timestamp: 2026-04-09T00:10:00Z
  checked: three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd
  found: _card_header_segments gives SIZE_EXPAND_FILL only to the task title; 来源 and 请求方 labels have no horizontal expand flag, while the header row itself is an HBoxContainer.
  implication: The title consumes the flexible left column and the other two labels collapse together on the right, matching the reported “左边1块、右边2块” layout defect.

- timestamp: 2026-04-09T00:10:00Z
  checked: three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd
  found: CardContent is added as a manual child of Button and forced to PRESET_FULL_RECT with zero offsets. The button stylebox defines content_margin_left/right = 20, but those margins only affect Button-owned text/icon layout, not arbitrary child controls.
  implication: The visible text padding is effectively zero despite the stylebox margins, which explains why card text still hugs the left/right edges.

- timestamp: 2026-04-09T00:11:00Z
  checked: three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd and scripts/tests/phase21_monthly_hud_regression.gd
  found: Each task card enforces custom_minimum_size.y = 152, while the regression only checks for a tall minimum height and stylebox margins, not the actual inner content box.
  implication: The remaining blank band under short task bodies is structural, and the existing regression protects the wrong readability proxy instead of the real spacing contract.

- timestamp: 2026-04-09T00:17:00Z
  checked: headless run of res://scripts/tests/phase21_monthly_hud_regression.gd
  found: The regression failed on every text-content assertion immediately after the layout patch. The failures cluster around _first_task_card_text no longer finding header/body text because the card root now wraps content in CardPadding before CardContent.
  implication: This is a test harness mismatch caused by the intentional structure change, not evidence that the rendered task card semantics regressed.

- timestamp: 2026-04-09T00:30:00Z
  checked: human verification checkpoint response
  found: In the real month-start popup, task cards still render at roughly one line tall instead of expanding with task content.
  implication: The previous self-verification missed a runtime sizing defect; the remaining issue is now specifically card height / multiline growth rather than header spacing or side padding.

- timestamp: 2026-04-09T00:34:00Z
  checked: three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd
  found: Each card button sets `custom_minimum_size = card_content.get_combined_minimum_size()` immediately after adding a `CardPadding` child built from a full-rect MarginContainer + fit_content RichTextLabel. That minimum size is captured before the button has its final popup width.
  implication: The card height is being frozen from an unconstrained pre-layout measurement, which is consistent with a body that later wraps to multiple lines visually but still only reserves one-line height in the real popup.

- timestamp: 2026-04-09T00:48:00Z
  checked: remote Godot inspection snippet against the live editor
  found: The first inspection attempt failed to compile because snippet-mode GDScript could not infer the type of `main_scene` from `instantiate()` without an explicit annotation.
  implication: The runtime inspection path is still viable; the next step is to rerun the measurement with explicit variable types rather than changing the hypothesis.

- timestamp: 2026-04-09T00:52:00Z
  checked: rerun of the typed remote Godot inspection snippet
  found: The snippet compiled and ran but returned no structured outputs, so it did not provide the expected first-card size metrics.
  implication: Direct runtime instrumentation through the broker is inconclusive for this measurement; proceed by tracing the deterministic popup layout code and fixing the stale sizing path directly.

- timestamp: 2026-04-09T00:58:00Z
  checked: three-kingdoms-simulator/scenes/main/MainScene.tscn and scripts/ui/MainHUD.gd
  found: The month-start task picker always opens through `show_task_picker()` into a fixed 720x520 PopupPanel, and the card list lives in a width-constrained ScrollContainer/VBox within that popup.
  implication: Final card width is deterministic after `popup_centered()`, so a deferred post-layout minimum-height recomputation is a targeted fix for the stale one-line card sizing.

- timestamp: 2026-04-09T01:03:00Z
  checked: headless regression invocation
  found: The expected console binary path `D:/Apps/Godot/Godot_v4.6.1-stable_mono_win64_console.exe` does not exist in this environment, so verification failed before the test could run.
  implication: The code patch is in place, but verification must continue by locating the actual installed Godot executable rather than assuming the prior path.

- timestamp: 2026-04-09T01:06:00Z
  checked: three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd
  found: Added deferred `_refresh_card_minimum_heights()` logic that runs after popup relayout and on card resize, recomputing each Button's minimum height from header height, content separation, vertical padding, and `BodyLabel.get_content_height()`.
  implication: Card height is now derived from the final wrapped content instead of the stale pre-layout one-line minimum.

- timestamp: 2026-04-09T01:07:00Z
  checked: headless run of `res://scripts/tests/phase21_monthly_hud_regression.gd` with `D:/Godot/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64_console.exe`
  found: The regression exited cleanly after the new multiline-height assertion was added, so the updated card contract passed in runtime.
  implication: Self-verification now covers the previously missed failure mode where wrapped task content was taller than the rendered card.

## Resolution

root_cause: TaskSelectPanel fixed the header spacing/padding issues, but it still set each task card Button's `custom_minimum_size` before the fixed-width popup assigned the RichTextLabel its real wrapping width. Because BaseButton did not later recompute its height from that child content automatically, the card kept a stale one-line minimum height in the real month-start popup.
fix: Added deferred post-layout card-height recomputation so each task card recalculates its minimum height from actual wrapped body content after popup sizing settles, and extended the monthly HUD regression to fail if card height is shorter than header + padding + wrapped body content.
verification: Headless regression passed via `D:/Godot/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64_console.exe --headless --path D:/Projects/Godot/三国模拟器/three-kingdoms-simulator --script res://scripts/tests/phase21_monthly_hud_regression.gd`, and the user confirmed the real month-start popup is fixed.
files_changed: ["three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd", "three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd"]
