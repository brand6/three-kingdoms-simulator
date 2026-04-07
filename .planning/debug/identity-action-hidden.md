---
status: investigating
trigger: "当某个行动当前不可执行时，它应仍显示在行动菜单中，但会以禁用状态呈现，并明确说明原因，例如 AP 不足、精力不足、缺少目标或当前条件不满足；可执行的行动应保持可点。实际：因为身份不满足而不可执行的行动不显示在菜单中，这个开放到配置表，玩家可以配置哪些身份可以执行哪些行动。"
created: 2026-04-06T00:00:00Z
updated: 2026-04-06T00:20:00Z
---

## Current Focus

hypothesis: 根因已确认：Phase 2 当前把“身份/权限不满足”定义为隐藏规则，并在 catalog 层直接过滤；同时动作目录是硬编码脚本而非配置表，所以既不会显示为禁用，也无法由玩家配置身份-动作映射
test: 用代码证据交叉验证 catalog 过滤、HUD 渲染、测试断言与 Phase 2 设计约束是否一致
expecting: catalog 使用 _is_permission_locked + continue；HUD 仅禁用已返回项；测试明确要求 inspect 对某些身份隐藏；动作定义写死在 _build_base_specs
next_action: 汇总根因与证据，准备诊断结论

## Symptoms

expected: 当某个行动当前不可执行时，它应仍显示在行动菜单中，但会以禁用状态呈现，并明确说明原因，例如 AP 不足、精力不足、缺少目标或当前条件不满足；可执行的行动应保持可点。
actual: 部分符合，但因为身份不满足而不可执行的行动不显示在菜单中；该约束还需开放到配置表，让玩家可配置哪些身份可以执行哪些行动。
errors: 无显式报错；表现为身份不满足的行动缺失而非禁用显示。
reproduction: Phase 02 UAT test 2：打开行动菜单，观察某些身份不满足的行动未显示。
started: Phase 02 UAT test 2

## Eliminated

## Evidence

- timestamp: 2026-04-06T00:05:00Z
  checked: .planning/debug/knowledge-base.md
  found: 知识库文件不存在，无可复用已知模式。
  implication: 需要从当前实现直接追踪根因。

- timestamp: 2026-04-06T00:06:00Z
  checked: 仓库全文检索（行动菜单 / disabled_reason / 身份 / get_available_actions）
  found: 行动菜单核心路径集中在 three-kingdoms-simulator/scripts/autoload/GameRoot.gd、systems/Phase2ActionCatalog.gd、ui/MainHUD.gd；设计文档与 Phase 2 上下文多处写明“身份权限动作隐藏，其他条件不足动作灰显并说明原因”。
  implication: 高概率不是实现偶发 bug，而是当前代码遵循了先前设计：身份限制直接隐藏。

- timestamp: 2026-04-06T00:12:00Z
  checked: three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd
  found: get_available_actions() 在遍历 _build_base_specs() 时先调用 _is_permission_locked(base_spec, protagonist)；若返回 true 则直接 continue，不创建 spec、不设置 disabled_reason、不加入 actions。inspect 还被硬编码为 required_permission_tags=["inspect", "lead"] 且 hidden_when_locked=true。
  implication: 身份/权限不满足的动作在数据生成阶段就被移除，因此 UI 根本拿不到这些动作，自然不可能显示为禁用态。

- timestamp: 2026-04-06T00:14:00Z
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd
  found: _refresh_action_menu() 只遍历 GameRoot.get_available_phase2_actions() 返回的 actions；按钮禁用条件仅为 disabled_reason 非空。被 catalog 过滤掉的动作不会进入列表，也不会有禁用原因文案。
  implication: UI 层没有身份锁定动作的占位或解释逻辑，只会渲染 catalog 已保留下来的动作。

- timestamp: 2026-04-06T00:16:00Z
  checked: three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd
  found: 测试 _test_hidden_and_disabled_rules() 明确断言 xun_yu 看不到 inspect（“Inspect should be hidden...”），而 AP/精力/地点/无目标等情况则要求动作继续 visible 并返回 disabled_reason。
  implication: “身份限制隐藏、条件不足灰显”不是遗漏，而是当前测试与预期实现的一部分。

- timestamp: 2026-04-06T00:18:00Z
  checked: .planning/phases/02-旬内行动—关系闭环/02-CONTEXT.md、02-UI-SPEC.md、design/行动菜单结构设计 v1.md
  found: 02-CONTEXT D-11 与 UI-SPEC 第 59 行明确写“身份权限导致不可用的动作直接隐藏”；同时 Phase2ActionCatalog._build_base_specs() 直接在脚本中硬编码五个动作及权限标签，没有从任何可编辑配置表读取身份-动作映射。
  implication: 当前缺口的根因包含两层：一是 Phase 2 设计本身要求隐藏身份锁；二是实现把动作权限写死在代码里，未做成可配置数据，因此无法满足新的“显示禁用 + 开放到配置表”要求。

## Resolution

root_cause: 
fix: 
verification: 
files_changed: []
