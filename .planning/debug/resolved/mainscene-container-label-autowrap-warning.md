---
status: resolved
trigger: "Investigate issue: mainscene-container-label-autowrap-warning"
created: 2026-04-09T00:00:00Z
updated: 2026-04-09T00:35:00Z
---

## Current Focus

hypothesis: resolved; user confirmed the editor warnings disappeared after reloading MainScene
test: archive the resolved session, commit the code fix, and append the knowledge-base entry
expecting: debug record moves to resolved, code fix is committed, and the pattern is captured for future sessions
next_action: archive session and write knowledge-base entry

## Symptoms

expected: MainScene 中这些 Label 不应再出现该编辑器警告，并且容器内文本布局行为正确、稳定。
actual: 用户在 Godot 编辑器中、无需运行游戏即可在 MainScene 的多个节点上看到黄色警告三角；未额外观察到明确运行时异常。
errors: 警告内容为“位于容器中的Label如果启用了自动换行,则必须配置自定义最小尺寸才能正常工作。”；存在多处。
reproduction: 直接在 Godot 编辑器中打开 MainScene，即可看到多个相关节点上的黄色警告三角。
started: 一直存在，不是最近某次修改后才出现。

## Eliminated

## Evidence

- timestamp: 2026-04-09T00:04:00Z
  checked: project debug knowledge base file presence
  found: .planning/debug/knowledge-base.md exists
  implication: known resolved patterns may provide a candidate hypothesis and should be checked first

- timestamp: 2026-04-09T00:04:00Z
  checked: MainScene scene file lookup
  found: MainScene is located at three-kingdoms-simulator/scenes/main/MainScene.tscn
  implication: the warning source is likely in this scene definition rather than a generated runtime scene

- timestamp: 2026-04-09T00:04:00Z
  checked: scene text search for autowrap_mode and custom_minimum_size
  found: MainScene contains many Label nodes with autowrap enabled and mixed custom_minimum_size settings
  implication: some warning nodes may already have a size override, so the issue may depend on which axis is configured or whether the control is inside a Container

- timestamp: 2026-04-09T00:07:00Z
  checked: knowledge base contents against current symptom keywords
  found: existing knowledge base only contains a Godot runtime script warning cleanup entry; no 2-keyword overlap with Label/autowrap/container warning symptoms
  implication: there is no strong known-pattern match, so this issue needs fresh investigation rather than reusing a prior diagnosis

- timestamp: 2026-04-09T00:10:00Z
  checked: Godot docs for Label and container layout behavior
  found: Label docs state autowrap wraps within the node's bounding rectangle, while container docs state children of Container give up their own positioning and sizing is controlled by the parent container
  implication: an autowrapped Label inside a Container needs an explicit minimum width signal for layout negotiation; ancestor panel sizes alone may not satisfy the Label warning condition

- timestamp: 2026-04-09T00:12:00Z
  checked: live editor warning inspection via Hastur
  found: first inspection attempt failed at compile time with "Standalone lambdas cannot be accessed" because the snippet used a nested function declaration unsupported in that context
  implication: the investigation path is still valid; only the probe implementation needs adjustment

- timestamp: 2026-04-09T00:14:00Z
  checked: revised live editor warning inspection via Hastur
  found: second inspection attempt failed because get_configuration_warnings() result type was left implicit and the editor treated Variant inference warnings as errors
  implication: the editor is enforcing strict typed GDScript in this execution path, so the probe must use explicit variable types before the real hypothesis can be tested

- timestamp: 2026-04-09T00:15:00Z
  checked: third Hastur request transport formatting
  found: the broker rejected the request JSON with "Bad control character in string literal", meaning the shell command escaped the embedded multiline GDScript incorrectly
  implication: future Hastur calls must be sent with safer JSON construction rather than inline raw string escaping

- timestamp: 2026-04-09T00:23:00Z
  checked: MainScene.tscn fix implementation
  found: added explicit custom_minimum_size entries to all 21 autowrapped Label nodes across summary cards, side panels, and popup/dialog content areas
  implication: the direct trigger used by Label::get_configuration_warnings() should now be removed for these nodes because their custom minimum size is no longer Vector2(0, 0)

- timestamp: 2026-04-09T00:28:00Z
  checked: MainScene.tscn post-fix pattern counts
  found: scene still contains 21 autowrap_mode = 3 entries, and the file now includes matching per-label custom_minimum_size entries for those nodes with non-zero widths added before each autowrap Label block
  implication: the warning precondition visible in Godot's Label::get_configuration_warnings() is removed from the scene file even before editor reload

- timestamp: 2026-04-09T00:29:00Z
  checked: live post-fix scene validation via Hastur
  found: the remote verification snippet failed with a mixed tabs/spaces indentation parse error
  implication: live editor confirmation is still pending, but this failure does not contradict the file-based verification or root cause

- timestamp: 2026-04-09T00:35:00Z
  checked: human verification checkpoint response
  found: user confirmed fixed in the real Godot editor workflow
  implication: the fix is verified end-to-end and the session can be archived as resolved

## Resolution

root_cause: Godot 4.2+ intentionally warns on any Label inside a Container when autowrap is enabled and the Label's own custom_minimum_size is Vector2(0, 0). MainScene has 21 such Label nodes. The warning is emitted by Label::get_configuration_warnings() regardless of ancestor container sizing, because autowrapped Label minimum-size computation is otherwise ambiguous in container layouts.
fix: Add explicit custom_minimum_size values to every autowrapped Label in MainScene, using per-panel widths so each Label reports a non-zero minimum size and wraps against a stable width baseline.
verification: File-based verification confirmed all 21 autowrapped Labels in MainScene now have explicit non-zero custom minimum widths, removing the engine warning precondition. User then confirmed in the actual Godot editor that the warning triangles are gone.
files_changed: ["three-kingdoms-simulator/scenes/main/MainScene.tscn"]
