---
status: diagnosed
phase: 02-旬内行动—关系闭环
source:
  - .planning/phases/02-旬内行动—关系闭环/02-01-SUMMARY.md
  - .planning/phases/02-旬内行动—关系闭环/02-02-SUMMARY.md
  - .planning/phases/02-旬内行动—关系闭环/02-03-SUMMARY.md
  - .planning/phases/02-旬内行动—关系闭环/02-04-SUMMARY.md
started: 2026-04-06T09:05:44.5425233+08:00
updated: 2026-04-06T10:21:01.1051102+08:00
---

## Current Test

[testing complete]

## Tests

### 1. 打开行动菜单并看到五类行动
expected: 进入主界面后，底部“行动”按钮应可点击。点击后会在主界面内弹出行动菜单，而不是切场景；菜单中应能看到固定的五个行动：训练、读书、休整、拜访、巡察，并显示各自动作说明或消耗信息。
result: issue
reported: "不符合，预期是点按钮后出现上浮菜单，类似我发的图片。点击大类后向右侧展开里面的小类，点击小类后如果有选目标流程才在主界面弹出目标选择界面"
severity: major

### 2. 行动菜单展示禁用原因
expected: 当某个行动当前不可执行时，它应仍显示在行动菜单中，但会以禁用状态呈现，并明确说明原因，例如 AP 不足、精力不足、缺少目标或当前条件不满足；可执行的行动应保持可点。
result: issue
reported: "部分符合，这里还需要加另一种情况，因为身份不满足而不可执行的行动不显示在菜单中，这个开放到配置表，玩家可以配置哪些身份可以执行哪些行动。"
severity: major

### 3. 执行训练或读书后立即看到结果反馈
expected: 执行一次“训练”或“读书”后，应立即弹出结果反馈，不离开主界面；结果里应能看出本次行动成功结算，并且人物相关数值发生变化，例如 AP 消耗、精力/压力变化，且主界面对应状态同步刷新。
result: pass

### 4. 拜访流程支持选目标并反馈关系变化
expected: 选择“拜访”后，应先出现目标选择，而不是直接结算；选定可拜访角色后，会得到一次明确结果反馈。若成功，结果或关系区域应体现与该角色关系的变化；若失败，也应给出非静默提示说明原因或线索。
result: issue
reported: "流程符合，但界面要修改。目标选择界面需要修改成表格的形式，玩家可以点击不同的属性来排序，类似我发的图片。另外这个目标选择要做成通用的组件，可以在其他地方调用。"
severity: major

### 5. 关系面板可查看当前关系上下文
expected: 点击“关系”按钮后，应在主界面内打开关系查看面板；面板中应能看到至少一部分当前人物关系信息或摘要，例如对象、好感/信任/戒备等上下文，而不是空白占位。
result: issue
reported: "不符合，点击“关系”按钮后，应该打开通用的目标选择界面（上面说的表格），点击对应角色后打开他的角色信息面板"
severity: major

### 6. 行动后的主界面文案会同步更新
expected: 执行行动后，主界面中的任务/事件/关系相关说明区域应立即刷新，能反映最近一次行动的结果或影响，而不是仍停留在旧的初始文案。
result: pass

### 7. 结束本旬前会先要求确认
expected: 在 AP 消耗完成或你主动结束本旬时，界面应先弹出“结束本旬”确认，而不是直接跳到下一旬；你可以明确看到这是一次确认步骤。
result: issue
reported: "不符合，有弹出确认界面，但界面有问题：1、界面太大了，确认弹窗没必要那么大；2、界面上没看到确认和取消按钮。再次点击结束本旬时界面显示正常了，应该是首次打开界面有bug。"
severity: major

### 8. 结束本旬后显示旬总结并推进时间
expected: 确认结束本旬后，应先看到本旬总结弹窗，内容顺序应包含“本旬行动摘要 → 主要数值变化 → 关系变化摘要 → 新提示”或等价结构。关闭总结后，时间推进到下一旬；若跨过三旬，则月份进位，且 AP 被重置，但名望、功绩、关系等长期变化保留。
result: pass

## Summary

total: 8
passed: 3
issues: 5
pending: 0
skipped: 0
blocked: 0

## Gaps

- truth: "进入主界面后，底部“行动”按钮应可点击。点击后会在主界面内弹出行动菜单，而不是切场景；菜单中应能看到固定的五个行动：训练、读书、休整、拜访、巡察，并显示各自动作说明或消耗信息。"
  status: failed
  reason: "User reported: 不符合，预期是点按钮后出现上浮菜单，类似我发的图片。点击大类后向右侧展开里面的小类，点击小类后如果有选目标流程才在主界面弹出目标选择界面"
  severity: major
  test: 1
  root_cause: "Phase 2 将行动入口实现为先选分类再看分类内动作的弹窗，并且权限锁定动作会被直接隐藏；因此首屏不会稳定显示固定五个行动，信息架构与 UAT 期望的上浮菜单/直接行动列表不一致。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "打开行动菜单时强制选中首个分类，只渲染当前分类动作。"
    - path: "three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd"
      issue: "五个动作被拆到不同分类，且部分权限锁定动作会被直接隐藏。"
    - path: "three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd"
      issue: "测试固化了分类式菜单实现，没有覆盖 UAT 所需的固定五行动首屏展示。"
  missing:
    - "将行动菜单首屏改为固定五个基础行动直接可见，而不是先按分类过滤。"
    - "若保留大类/小类结构，应将其作为二级展开交互，而非一级入口。"
    - "补回归测试，验证打开菜单后能直接看到五个基础行动及说明/消耗。"
  debug_session: ".planning/debug/action-menu-popup-gap.md"
- truth: "当某个行动当前不可执行时，它应仍显示在行动菜单中，但会以禁用状态呈现，并明确说明原因，例如 AP 不足、精力不足、缺少目标或当前条件不满足；可执行的行动应保持可点。"
  status: failed
  reason: "User reported: 部分符合，这里还需要加另一种情况，因为身份不满足而不可执行的行动不显示在菜单中，这个开放到配置表，玩家可以配置哪些身份可以执行哪些行动。"
  severity: major
  test: 2
  root_cause: "当前 catalog 在身份/权限不满足时直接过滤动作，而不是返回禁用态；同时身份-行动映射被硬编码在脚本与文档规则中，没有抽到可配置数据表，所以既不能显示锁定原因，也无法由配置驱动调整。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/systems/Phase2ActionCatalog.gd"
      issue: "权限锁定动作直接 continue 过滤，无法生成禁用原因。"
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "HUD 只渲染 catalog 返回结果，被过滤动作完全不可见。"
    - path: "three-kingdoms-simulator/scripts/tests/phase2_action_resolver_test.gd"
      issue: "测试将身份锁定动作隐藏视为正确行为。"
    - path: ".planning/phases/02-旬内行动—关系闭环/02-CONTEXT.md"
      issue: "阶段决策把身份限制定义为隐藏而不是显示禁用。"
  missing:
    - "将身份/权限限制从直接隐藏改为显示禁用态并提供锁定原因。"
    - "把动作与身份/权限映射迁移到可编辑配置表或数据资源。"
    - "更新测试与 UI 合同，覆盖身份不满足时仍显示但不可执行的情形。"
  debug_session: ".planning/debug/identity-action-hidden.md"
- truth: "选择“拜访”后，应先出现目标选择，而不是直接结算；选定可拜访角色后，会得到一次明确结果反馈。若成功，结果或关系区域应体现与该角色关系的变化；若失败，也应给出非静默提示说明原因或线索。"
  status: failed
  reason: "User reported: 流程符合，但界面要修改。目标选择界面需要修改成表格的形式，玩家可以点击不同的属性来排序，类似我发的图片。另外这个目标选择要做成通用的组件，可以在其他地方调用。"
  severity: major
  test: 4
  root_cause: "目标选择目前被实现为拜访专用的最小弹窗列表，内部仅动态生成按钮项；场景中也将目标选择与关系查看拆成两套独立 UI，缺少通用角色选择组件，因此天然不支持表格列头、点击排序和跨入口复用。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "visit 分支硬编码打开 TargetPickerDialog，并用 VBoxContainer + Button 渲染目标列表。"
    - path: "three-kingdoms-simulator/scenes/main/MainScene.tscn"
      issue: "只定义了专用 TargetPickerDialog 与独立 RelationPopup，没有通用目标选择组件。"
    - path: "three-kingdoms-simulator/scripts/autoload/GameRoot.gd"
      issue: "仅提供 visit 目标数组与关系总览，没有面向通用角色选择/排序的契约。"
  missing:
    - "抽象通用角色/目标选择组件，统一供拜访、关系等入口复用。"
    - "将目标选择界面改为可排序表格，并暴露列定义与排序能力。"
    - "补 UI/回归测试，覆盖通用选择器的复用与排序交互。"
  debug_session: ".planning/debug/visit-target-selector-ui.md"
- truth: "点击“关系”按钮后，应在主界面内打开关系查看面板；面板中应能看到至少一部分当前人物关系信息或摘要，例如对象、好感/信任/戒备等上下文，而不是空白占位。"
  status: failed
  reason: "User reported: 不符合，点击“关系”按钮后，应该打开通用的目标选择界面（上面说的表格），点击对应角色后打开他的角色信息面板"
  severity: major
  test: 5
  root_cause: "Phase 2 将关系按钮规划并实现为专用 RelationPopup 总览入口，而不是‘通用目标选择表格 → 角色信息面板’流程；仓库内也不存在角色详情面板和可复用选择器，所以当前结构无法满足 UAT 期望交互。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "RelationButton 被硬编码为只打开 RelationPopup。"
    - path: "three-kingdoms-simulator/scenes/main/MainScene.tscn"
      issue: "只有 RelationPopup 和 TargetPickerDialog，没有角色详情面板。"
    - path: ".planning/phases/02-旬内行动—关系闭环/02-03-PLAN.md"
      issue: "计划层明确要求关系按钮打开 RelationPopup，错误方向被写入计划。"
    - path: "three-kingdoms-simulator/scripts/autoload/GameRoot.gd"
      issue: "只暴露关系总览接口，没有支撑角色浏览/详情的数据契约。"
  missing:
    - "将关系入口改为复用通用角色选择表格组件。"
    - "补充选中角色后的角色信息/关系详情面板与对应数据接口。"
    - "更新阶段计划与回归口径，防止继续按旧的 RelationPopup 路线实现。"
  debug_session: ".planning/debug/uat5-relation-button-panel.md"
- truth: "在 AP 消耗完成或你主动结束本旬时，界面应先弹出“结束本旬”确认，而不是直接跳到下一旬；你可以明确看到这是一次确认步骤。"
  status: failed
  reason: "User reported: 不符合，有弹出确认界面，但界面有问题：1、界面太大了，确认弹窗没必要那么大；2、界面上没看到确认和取消按钮。再次点击结束本旬时界面显示正常了，应该是首次打开界面有bug。"
  severity: major
  test: 7
  root_cause: "结束本旬确认框使用 popup_centered_ratio(0.35) 按视口比例直接弹出，首次显示前没有 reset_size() 或按内容最小尺寸重算布局，导致首次打开时弹窗被放大并把 ConfirmationDialog 自带按钮区挤出可视区域；第二次打开因布局缓存看起来恢复正常。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "结束本旬确认框通过 popup_centered_ratio(0.35) 打开，缺少首次显示前的尺寸重算。"
    - path: "three-kingdoms-simulator/scenes/main/MainScene.tscn"
      issue: "EndXunDialog 本身是轻量确认框，但运行时打开方式覆盖了其小尺寸意图。"
    - path: "three-kingdoms-simulator/scripts/tests/phase2_xun_loop_regression.gd"
      issue: "测试只验证弹窗出现，不验证首次打开尺寸与按钮可见性。"
  missing:
    - "改为按内容最小尺寸弹出结束本旬确认框，并在显示前显式触发尺寸重算。"
    - "回归验证首次打开时确认/取消按钮可见且弹窗尺寸合理。"
    - "避免继续使用不适合轻量确认框的 popup_centered_ratio 打开方式。"
  debug_session: ".planning/debug/end-xun-confirm-first-open.md"
