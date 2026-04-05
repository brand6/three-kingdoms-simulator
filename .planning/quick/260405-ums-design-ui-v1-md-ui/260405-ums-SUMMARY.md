---
phase: quick-260405-ums
plan: 260405-ums
subsystem: ui
tags: [godot, hud, ui, theme, gdscript]
requires:
  - phase: 01-190
    provides: MainScene HUD skeleton, PrototypeTheme baseline, autoload-driven MainHUD binding
provides:
  - 主 HUD 决策区、摘要卡与结束本旬入口
  - PrototypeTheme 主按钮与结束本旬按钮变体
  - 中文化推荐行动与关系/派系/家族摘要文案
affects: [phase-02-ui, main-hud, quick-tasks]
tech-stack:
  added: []
  patterns: [Godot Theme type variation for CTA hierarchy, MainHUD copy-only guidance over autoload session data]
key-files:
  created: []
  modified:
    - three-kingdoms-simulator/scenes/main/MainScene.tscn
    - three-kingdoms-simulator/themes/PrototypeTheme.tres
    - three-kingdoms-simulator/scripts/ui/MainHUD.gd
key-decisions:
  - "保持 MainScene + MainHUD 骨架不变，只在现有 HUD 中扩展决策区和三张摘要卡。"
  - "通过 PrototypeTheme 的 PrimaryButton 与 DangerButton 统一管理行动/结束本旬层级。"
  - "在真实系统未接通前，用中文可读的推荐行动和政治摘要文案承担主循环引导。"
patterns-established:
  - "HUD 主操作优先级通过 theme_type_variation 落地，而不是节点级临时 override。"
  - "空状态也要提供推荐行动与政治上下文，避免主界面退回占位说明页。"
requirements-completed: [CORE-04, ACTN-01, UI-01, UI-02, UI-04]
duration: 29min
completed: 2026-04-05
---

# Quick Task 260405-ums Summary

**Godot 主界面已升级为带决策区、政治摘要卡与双层主操作按钮的旬内主循环 HUD。**

## Performance

- **Duration:** 29 min
- **Started:** 2026-04-05T13:46:00Z
- **Completed:** 2026-04-05T14:14:59Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments

- 将 MainScene 从 Phase 1 说明页重构为“人物总览 + 当前决策区 + 任务反馈 + 三张摘要卡 + 结束本旬”结构。
- 为 `行动` 与 `结束本旬` 建立共享 Theme 按钮变体，明确主循环操作层级。
- 更新 MainHUD 文案绑定，使加载态、成功态、错误态都能直接提示推荐行动、关系关注点与旬推进方式。

## Task Commits

1. **Task 1: 重构主 HUD 布局为“决策区 + 摘要卡 + 旬推进”结构** - `c22b8c9` (feat)
2. **Task 2: 用主题和按钮变体突出主操作层级** - `4fd9742` (feat)
3. **Task 3: 更新 MainHUD 绑定与占位文案，让主界面直接指导下一步** - `bcbd4f7` (feat)

**Plan metadata:** pending final docs commit

## Files Created/Modified

- `three-kingdoms-simulator/scenes/main/MainScene.tscn` - 重排主 HUD 结构，新增当前决策区、三张政治摘要卡与 `结束本旬` 按钮。
- `three-kingdoms-simulator/themes/PrototypeTheme.tres` - 新增 `PrimaryButton` / `DangerButton` 变体，统一主操作与结束本旬按钮的强调样式。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` - 绑定新版节点路径，输出中文化推荐行动、任务引导与关系/派系/家族摘要文案。

## Decisions Made

- 保留 HUD + 面板主循环结构，不新增场景切换或独立 UI 控制器，避免偏离 D-03。
- 使用 Theme type variation 管理 CTA 层级，确保后续 Godot UI 扩展继续复用统一主题资源。
- 将“暂无任务”替换为推荐行动列表，并在成功态根据当前人物/城市/势力拼接可读提示，优先验证主循环认知而非真实 Phase 3/4 系统。

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Task 2 初始自动校验命令因 PowerShell 内联 Python 引号转义失败，已改用 PowerShell 原生命令验证 `PrimaryButton` / `DangerButton` 场景绑定；实现本身无需返工。

## Verification

- 通过计划内 3 条自动校验，确认场景关键文案、主题变体与 HUD 脚本关键词均存在。
- 使用 Godot 4.6.1 启动 `three-kingdoms-simulator` 项目并检查调试输出，无运行时错误。

## Known Stubs

- `three-kingdoms-simulator/scenes/main/MainScene.tscn:108` - `人物立绘 / 状态标签` 仍为静态立绘区域占位，当前任务只要求 HUD 信息架构升级，真实头像与状态标签数据待后续系统接入。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd:8` - `正在整理本旬建议…` 为加载态提示，表示 autoload 尚未回填成功态数据，是可接受的瞬时占位。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd:70` - 关键关系摘要在加载态使用整理中文案，等待真实关系系统接入后替换为动态人物名单。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd:72` - 家族/士族摘要在加载态使用读取中文案，等待真实家族/士族系统接入后替换为动态摘要。

## Next Phase Readiness

- Main HUD 已具备清晰的主循环视觉结构，后续可在不改场景骨架的前提下接入行动浮层、结果弹窗与旬末结算。
- 关系、派系、家族摘要卡已有稳定挂点，后续系统只需替换文案来源即可。

## Self-Check: PASSED

- FOUND: `.planning/quick/260405-ums-design-ui-v1-md-ui/260405-ums-SUMMARY.md`
- FOUND: `three-kingdoms-simulator/scenes/main/MainScene.tscn`
- FOUND: `three-kingdoms-simulator/themes/PrototypeTheme.tres`
- FOUND: `three-kingdoms-simulator/scripts/ui/MainHUD.gd`
- FOUND commit: `c22b8c9`
- FOUND commit: `4fd9742`
- FOUND commit: `bcbd4f7`
