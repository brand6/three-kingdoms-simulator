---
status: investigating
trigger: "在 AP 消耗完成或你主动结束本旬时，界面应先弹出“结束本旬”确认，而不是直接跳到下一旬；首次打开确认界面过大且看不到确认/取消按钮，再次点击结束本旬后显示正常。"
created: 2026-04-06T00:00:00Z
updated: 2026-04-06T00:02:00Z
---

## Current Focus

hypothesis: 结束本旬确认弹窗首次打开时错误地使用 viewport 比例弹出，且未在首次显示前重算对话框内容尺寸，导致首次布局过大并把内置按钮行挤出可视区域
test: 对照 MainHUD 打开逻辑、MainScene 对话框定义和 Godot 4.6 ConfirmationDialog/Window 文档，验证是否存在“只调用 popup_centered_ratio、不做 reset_size/内容最小尺寸约束”的路径
expecting: 若代码仅用 popup_centered_ratio(0.35) 打开 ConfirmationDialog，而文档表明该类依赖 Window popup_* 与内容最小尺寸/内置按钮布局，则可解释首次按比例放大、布局未稳定时按钮不可见、二次打开恢复正常
next_action: 汇总证据并写入根因结论

## Symptoms

expected: 在 AP 消耗完成或你主动结束本旬时，界面应先弹出“结束本旬”确认，而不是直接跳到下一旬；你可以明确看到这是一次确认步骤。
actual: 有弹出确认界面，但首次打开时界面太大，且看不到确认和取消按钮；再次点击结束本旬时界面显示正常。
errors: 无明确报错；首次打开确认界面过大且按钮缺失
reproduction: Phase 02 UAT test 7；在 AP 消耗完成或主动点击结束本旬时首次打开确认界面
started: Phase 02 UAT

## Eliminated

## Evidence

- timestamp: 2026-04-06T00:01:20Z
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd
  found: 结束本旬按钮唯一打开路径是 `_on_end_turn_button_pressed()`，其中只调用 `_end_xun_dialog.popup_centered_ratio(0.35)`；没有 `reset_size()`、没有基于内容最小尺寸的 popup 方法，也没有首次显示前的布局修正。
  implication: 首次打开完全依赖 Window 的比例弹窗行为，而不是按确认弹窗实际内容收缩到合适尺寸。

- timestamp: 2026-04-06T00:01:35Z
  checked: three-kingdoms-simulator/scenes/main/MainScene.tscn
  found: `EndXunDialog` 是 `ConfirmationDialog`，场景内只有一段短文案（`EndXunBody`），固定 size 为 `Vector2i(480, 220)`，内容本身很轻；但脚本打开时又强制使用 `popup_centered_ratio(0.35)`，覆盖了这个小对话框的意图尺寸。
  implication: “界面太大”来自代码层按屏幕比例放大，而不是内容真的需要那么大。

- timestamp: 2026-04-06T00:01:50Z
  checked: Godot 4.6 docs for ConfirmationDialog / AcceptDialog / Window
  found: `ConfirmationDialog`/`AcceptDialog` 继承 `Window`，通过 `popup_*` 方法显示；`AcceptDialog` 自带内部 OK/Cancel 按钮区，`wrap_controls = true`，并提供 `reset_size()` / 内容最小尺寸相关机制。
  implication: 这类对话框的按钮区是内部布局的一部分；若首次显示前不重算尺寸、而直接按比例弹出，内容区和按钮区的首次布局容易失衡，出现首次显示异常、再次打开正常的典型现象。

- timestamp: 2026-04-06T00:02:00Z
  checked: three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd
  found: 回归测试只断言“确认框 visible” 和确认后能推进到总结，没有验证首次打开时的窗口尺寸或 OK/Cancel 按钮是否可见。
  implication: 当前自动测试覆盖了流程存在性，但没有覆盖这次 UAT 暴露的首次布局 bug，因此问题能存活到 UAT。

## Resolution

root_cause: 
fix: 
verification: 
files_changed: []
