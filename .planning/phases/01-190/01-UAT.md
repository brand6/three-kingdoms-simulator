---
status: complete
phase: 01-190
source:
  - .planning/phases/01-190/01-190-01-SUMMARY.md
  - .planning/phases/01-190/01-190-02-SUMMARY.md
  - .planning/phases/01-190/01-190-03-SUMMARY.md
  - .planning/phases/01-190/01-190-04-SUMMARY.md
started: 2026-04-05T05:52:42.0041138Z
updated: 2026-04-05T05:55:30.0000000Z
---

## Current Test

[testing complete]

## Tests

### 1. 冷启动进入主界面
expected: 关闭现有运行实例后重新启动项目，游戏应直接进入 190 样本主界面，不需要选择剧本或角色，也不应先停在空白场景或其他中间页。
result: issue
reported: "符合,但存在一个问题:主界面顶部显示了两个年份"
severity: minor

### 2. 顶栏显示默认开局身份
expected: 进入主界面后，顶栏应显示 190年 / 1月 / 第1旬，并且当前城市、当前身份、所属势力、当前官职分别显示为 陈留、ruler、曹操集团、lord。
result: issue
reported: "不符合,顶栏显示了两遍年份\"190年/月/旬:190年/1月/第1旬\",其他信息没有问题"
severity: minor

### 3. 左侧人物状态显示曹操数值
expected: 左侧人物总览应显示 姓名：曹操，且 AP、精力、压力、名望、功绩 分别显示为 3、88、24、82、75；头像区域仍可显示“头像占位”。
result: pass

### 4. 中部与右侧显示 Phase 1 状态说明
expected: 中部应显示“已进入 190 样本”及当前阶段已完成默认主角载入的说明；右侧应显示“暂无当前任务”、Phase 1 说明文案，以及“重要提示：灰色入口将在后续阶段开放”或等价提示。
result: pass

### 5. 底部入口保持禁用
expected: 底部的 行动、角色、关系、势力、家族/士族、日志 按钮都应为灰色禁用状态，点击不会进入新页面。
result: pass

## Summary

total: 5
passed: 3
issues: 2
pending: 0
skipped: 0
blocked: 0

## Gaps

- truth: "关闭现有运行实例后重新启动项目，游戏应直接进入 190 样本主界面，不需要选择剧本或角色，也不应先停在空白场景或其他中间页。"
  status: failed
  reason: "User reported: 符合,但存在一个问题:主界面顶部显示了两个年份"
  severity: minor
  test: 1
  root_cause: "MainHUD.gd 把 TimeLabel 按‘字段名：值’格式渲染时，前缀硬编码成了时间模板，而 TimeManager.gd 又返回完整时间串，拼接后导致顶部出现两个年份。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "show_success_state() 与 _render_empty_fields() 都把 TimeLabel 错当成键值对字段，使用 _pair_text(\"190年 / 月 / 旬\", ...) 进行重复拼接。"
    - path: "three-kingdoms-simulator/scenes/main/MainScene.tscn"
      issue: "TimeLabel 默认文案沿用了时间模板，强化了错误的显示语义。"
  missing:
    - "将 TimeLabel 改为直接显示完整时间值，不再通过 _pair_text() 追加前缀。"
    - "同步修正空状态与场景默认文本，确保时间栏只显示一次时间。"
    - "回归验证冷启动与顶栏显示测试，确认顶部只显示一次 190年 / 1月 / 第1旬。"
  debug_session: ".planning/debug/uat2-topbar-double-year.md"
- truth: "进入主界面后，顶栏应显示 190年 / 1月 / 第1旬，并且当前城市、当前身份、所属势力、当前官职分别显示为 陈留、ruler、曹操集团、lord。"
  status: failed
  reason: "User reported: 不符合,顶栏显示了两遍年份\"190年/月/旬:190年/1月/第1旬\",其他信息没有问题"
  severity: minor
  test: 2
  root_cause: "MainHUD.gd 将已完整格式化的时间文本再次包成‘190年 / 月 / 旬：值’，导致顶栏时间重复；该问题与测试 1 属于同一根因。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/MainHUD.gd"
      issue: "show_success_state() 中 TimeLabel 运行时赋值错误地使用 _pair_text()。"
    - path: "three-kingdoms-simulator/scripts/autoload/TimeManager.gd"
      issue: "get_current_label() 已返回完整时间字符串，本身无错，但被上层重复拼接后放大了问题。"
  missing:
    - "将时间栏的运行时赋值改为直接使用 TimeManager.get_current_label() 的返回值。"
    - "统一 HUD 中时间栏与其他键值对栏位的渲染约定，避免再次混用。"
    - "补一条回归验证：顶栏精确显示 190年 / 1月 / 第1旬，其他顶栏字段保持不变。"
  debug_session: ".planning/debug/uat2-topbar-double-year.md"
