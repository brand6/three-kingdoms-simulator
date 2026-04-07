---
status: diagnosed
trigger: "Diagnose a Phase 2.1 UAT gap in a Godot project. Issue from .planning/phases/02.1-/02.1-UAT.md test 4: 领取主任务后，继续使用现有的训练、读书、休整、拜访、巡察等基础行动时，月任务应能被推进；至少在执行相关行动后，任务进度或结果反馈中能看出任务确实发生了变化，而不是需要额外新增专属行动。User reported: 无法完成任务，政务里只有巡查，而且是置灰的状态，无法点击。建议修复巡查按钮灰色的问题，然后月初只出现巡查的任务"
created: 2026-04-07T16:10:00+08:00
updated: 2026-04-07T16:28:00+08:00
---

## Current Focus

hypothesis: 已确认：月任务系统允许/鼓励使用 inspect 推进，但 UI 菜单把默认主角荀彧的 inspect 硬性禁用，形成任务-行动契约不一致。
test: 汇总结论并给出最小缺失修复。
expecting: 输出明确 root cause、受影响工件和最小修复点。
next_action: return diagnosis only

## Symptoms

expected: 领取主任务后，继续使用现有的训练、读书、休整、拜访、巡察等基础行动时，月任务应能被推进；至少在执行相关行动后，任务进度或结果反馈中能看出任务确实发生了变化，而不是需要额外新增专属行动。
actual: 无法完成任务；政务里只有巡查，而且是置灰状态，无法点击。
errors: 无显式报错；UAT 现象为“政务里只有巡查且置灰，无法点击”。
reproduction: 月初领取主任务后，打开行动/政务菜单，看到只有巡查选项且按钮灰色不可点击，任务无法推进。
started: Phase 2.1 UAT test 4

## Eliminated

## Evidence

- timestamp: 2026-04-07T16:14:00+08:00
  checked: .planning/debug/knowledge-base.md
  found: 文件不存在，无可复用已知模式。
  implication: 需要直接检查代码路径，不能依赖历史案例。

- timestamp: 2026-04-07T16:18:00+08:00
  checked: scripts/systems/TaskSystem.gd + scripts/autoload/GameRoot.gd + scripts/ui/MainHUD.gd + scripts/systems/Phase2ActionCatalog.gd + scripts/systems/Phase2ActionResolver.gd
  found: 月任务进度确实只靠现有五个 action_id（train/study/rest/visit/inspect）推进；UI 会显示 disabled action；巡查按钮是否发灰完全由 Phase2ActionCatalog._get_disabled_reason 决定，而成功执行后 GameRoot.execute_phase2_action 会正常把 inspect 进度写回 TaskSystem。
  implication: 根因更可能在“任务候选生成”和“action 可用性判定”不一致，而不是进度写回链路缺失。

- timestamp: 2026-04-07T16:21:00+08:00
  checked: data/config/phase2_action_menu_config.tres + grep hits in scripts/tests/phase2_action_resolver_test.gd
  found: inspect 的 allowed_identity_types 只包含 ruler/military_officer，不包含 civil_official；并且测试显式断言荀彧的 inspect.disabled_reason == "当前身份不可执行"。
  implication: 巡查置灰不是偶发现象，而是配置与测试共同定义出的现有行为；若 UAT 期望文官荀彧可用巡查，则这是具体的错误实现点。

- timestamp: 2026-04-07T16:28:00+08:00
  checked: data/task_rules/task_pool_xunyu_early_career.tres + data/scenario_patches/xunyu_default_start_patch.tres + data/tasks/task_document_cleanup.tres + data/tasks/task_grain_audit.tres + scripts/tests/phase21_monthly_career_regression.gd
  found: 荀彧首月稳定任务被固定为 task_document_cleanup，首月任务池也允许 logistics/admin 任务；这些任务的进度规则都把 inspect 作为有效甚至高权重输入，而回归测试只验证 study 能推进任务，没有覆盖“inspect 对默认主角必须可点”。
  implication: 后端任务设计把 inspect 当成 Phase 2.1 的基础动作之一，但前端/菜单层没有与之对齐，最终在 UAT 中表现为“任务看起来需要巡查，但巡查按钮是灰的”。

## Resolution

root_cause: inspect/巡查 在月任务系统中被设计为默认五基础行动之一，并被首月任务模板与任务池直接使用；但 phase2_action_menu_config.tres 把该动作限制为 ruler/military_officer，导致默认主角荀彧（civil_official）在 MainHUD 行动菜单中永远看到一个置灰的巡查按钮。任务生成与行动可用性规则因此不一致。
fix: diagnose only
verification: 通过读取 TaskSystem、任务池/模板、行动菜单配置和现有回归测试，已定位到配置与测试共同固化的错误实现点。
files_changed: []
