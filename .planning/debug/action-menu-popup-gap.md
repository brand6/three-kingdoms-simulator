---
status: investigating
trigger: "你是 Phase 02 UAT 差距诊断代理之一，只做根因诊断，不修复代码。\n\nGap truth: 进入主界面后，底部“行动”按钮应可点击。点击后会在主界面内弹出行动菜单，而不是切场景；菜单中应能看到固定的五个行动：训练、读书、休整、拜访、巡察，并显示各自动作说明或消耗信息。\nExpected: 进入主界面后，底部“行动”按钮应可点击。点击后会在主界面内弹出行动菜单，而不是切场景；菜单中应能看到固定的五个行动：训练、读书、休整、拜访、巡察，并显示各自动作说明或消耗信息。\nActual: 不符合，预期是点按钮后出现上浮菜单，类似我发的图片。点击大类后向右侧展开里面的小类，点击小类后如果有选目标流程才在主界面弹出目标选择界面。\nSeverity: major\nReproduction: Phase 02 UAT test 1\nGoal: find_root_cause_only"
created: 2026-04-06T10:23:00+08:00
updated: 2026-04-06T10:26:00+08:00
---

## Current Focus

hypothesis: Action menu was intentionally implemented as category-first filtering, so opening the popup does not present the five fixed actions required by UAT.
test: Confirm the popup's initial state, catalog structure, and regression tests all encode category-first behavior.
expecting: The menu opens on category 成长, only shows that category's actions, and tests/plans validate categories instead of validating five fixed visible actions on open.
next_action: finalize root cause and return diagnosis-only summary.

## Symptoms

expected: 进入主界面后，底部“行动”按钮应可点击。点击后会在主界面内弹出行动菜单，而不是切场景；菜单中应能看到固定的五个行动：训练、读书、休整、拜访、巡察，并显示各自动作说明或消耗信息。
actual: 不符合，预期是点按钮后出现上浮菜单，类似我发的图片。点击大类后向右侧展开里面的小类，点击小类后如果有选目标流程才在主界面弹出目标选择界面。
errors: 无显式报错；表现为行动菜单结构与内容不符合预期。
reproduction: Phase 02 UAT test 1
started: Phase 02 UAT

## Eliminated

## Evidence

- timestamp: 2026-04-06T10:18:00+08:00
  checked: .planning/phases/02-旬内行动—关系闭环/02-UAT.md
  found: Test 1 failed with report that action button does not open the expected in-HUD floating menu structure.
  implication: This is a UX/behavior mismatch, not a scene-change crash report.

- timestamp: 2026-04-06T10:19:00+08:00
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd
  found: _on_action_button_pressed() hard-resets _selected_category to PHASE2_CATEGORIES[0] and opens ActionMenuPopup; _refresh_action_menu() builds a left category list and filters visible actions by the selected category.
  implication: Opening the menu initially shows only one category's actions instead of all five fixed actions.

- timestamp: 2026-04-06T10:19:30+08:00
  checked: three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
  found: The five base actions are split across categories 成长/关系/政务, and inspect can also be hidden by permission rules.
  implication: The popup architecture is category-driven, so the full fixed action set is not surfaced directly on open.

- timestamp: 2026-04-06T10:20:00+08:00
  checked: .planning/phases/02-旬内行动—关系闭环/02-03-SUMMARY.md and .planning/STATE.md
  found: Phase 2 explicitly recorded the decision to implement grouped category rails and popup overlays inside MainScene.
  implication: The current behavior is the result of an intentional implementation direction, suggesting spec/implementation drift rather than a broken click handler.

- timestamp: 2026-04-06T10:24:00+08:00
  checked: three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd
  found: The regression test asserts EXPECTED_CATEGORIES = ["成长", "关系", "政务", "军事", "家族"] and verifies each action's category_id instead of asserting that opening the HUD action menu shows the five fixed actions together.
  implication: Automated validation reinforced the category-first design, so the mismatch survived Phase 2 completion.

- timestamp: 2026-04-06T10:24:30+08:00
  checked: three-kingdoms-simulator/scripts/autoload/GameRoot.gd and data/generated/190/characters.json
  found: GameRoot returns catalog-filtered actions from Phase2ActionCatalog, and character permission_tags can hide actions like inspect for some protagonists.
  implication: The system is designed to hide or separate actions by role/category, which conflicts with the UAT expectation of a fixed five-action menu with descriptions/consumption info.

## Resolution

root_cause: Phase 2 implemented the action entry as a category-first popup (成长/关系/政务/军事/家族) backed by Phase2ActionCatalog filtering, instead of a fixed five-action menu. On open, MainHUD resets to the first category and only renders that subset, and catalog permission rules can hide actions like 巡察 entirely for some identities. This is an implementation/spec mismatch, not a click-handler failure.
fix: 
verification: 
files_changed: []
