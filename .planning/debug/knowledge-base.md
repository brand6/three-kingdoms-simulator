# GSD Debug Knowledge Base

Resolved debug sessions. Used by `gsd-debugger` to surface known-pattern hypotheses at the start of new investigations.

---

## godot-runtime-warnings — Godot 运行时静态脚本 warning 清零
- **Date:** 2026-04-09
- **Error patterns:** Godot warning, runtime warning, parameter never used, local variable never used, integer division, shadowing, Window.position, AppointmentResolver.gd, GameRoot.gd, TaskSelectPanel.gd, FactionPanel.gd
- **Root cause:** 多个脚本存在可静态判定的 GDScript warning：未使用参数/变量未以下划线标记、整数除法未显式说明取整意图、FactionPanel 局部变量名与 Window.position 属性冲突。
- **Fix:** 已对 4 个脚本做最小修复：AppointmentResolver 中未使用参数改为下划线命名并将整数除法改为显式 int(merit_score / 4.0)；GameRoot 中删除未使用局部变量；TaskSelectPanel 中将未使用参数改为 _repository；FactionPanel 中将局部变量 position 改名为 player_position。
- **Files changed:** three-kingdoms-simulator/scripts/systems/AppointmentResolver.gd, three-kingdoms-simulator/scripts/autoload/GameRoot.gd, three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd, three-kingdoms-simulator/scripts/ui/FactionPanel.gd
---

## mainscene-container-label-autowrap-warning — MainScene 容器内自动换行 Label 编辑器警告
- **Date:** 2026-04-09
- **Error patterns:** MainScene, Label, autowrap, container, custom minimum size, 黄色警告三角, 位于容器中的Label如果启用了自动换行,则必须配置自定义最小尺寸才能正常工作
- **Root cause:** Godot 4.2+ 会对处于 Container 内且启用了 autowrap 的 Label 发出编辑器警告，只要该 Label 自身的 custom_minimum_size 仍为 Vector2(0, 0)。MainScene 中有 21 个这样的节点，祖先容器的尺寸并不能消除该警告条件。
- **Fix:** 为 MainScene 中所有启用自动换行的 Label 逐个补上明确的 custom_minimum_size 宽度，让每个 Label 都有稳定的换行基线并避开引擎的 warning 条件。
- **Files changed:** three-kingdoms-simulator/scenes/main/MainScene.tscn
---
