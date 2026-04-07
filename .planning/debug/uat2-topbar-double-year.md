---
status: investigating
trigger: "请诊断第1阶段 UAT 问题 2 的根因。用户反馈顶栏时间显示为“两遍年份”，具体为“190年/月/旬:190年/1月/第1旬”，而当前城市、身份、势力、官职都正确。请只做诊断，不要修改代码。"
created: 2026-04-05T14:06:32.8366311+08:00
updated: 2026-04-05T14:06:32.8366311+08:00
---

## Current Focus

hypothesis: MainHUD 把时间字段的静态标题与 TimeManager 返回的完整时间字符串再次拼接，导致时间信息重复显示。
test: 对比 MainHUD 的 TimeLabel 赋值逻辑、TimeManager.get_current_label() 返回值，以及 MainScene 中 TimeLabel 的设计意图。
expecting: 如果假设成立，TimeManager 会返回完整的“190年 / 1月 / 第1旬”，而 MainHUD 仍用 _pair_text("190年 / 月 / 旬", ...) 再包一层前缀。
next_action: 记录证据并确认该缺陷是否与 UAT 问题 1 为同一显示问题。

## Symptoms

expected: 顶栏应显示“190年 / 1月 / 第1旬”，且当前城市、身份、所属势力、当前官职正确。
actual: 顶栏时间显示为“190年/月/旬:190年/1月/第1旬”，其他顶栏字段正确。
errors: 无运行时报错；表现为时间文案重复。
reproduction: 启动项目进入 190 样本主界面，观察顶栏时间文本。
started: 第1阶段 UAT 首次进入主界面时即出现。

## Eliminated

## Evidence

- timestamp: 2026-04-05T14:06:32.8366311+08:00
  checked: .planning/phases/01-190/01-UAT.md
  found: UAT 问题 1 和问题 2 都报告同一现象——顶栏出现两遍年份，而城市、身份、势力、官职显示正常。
  implication: 这是单一的时间标签渲染缺陷，并且同时影响测试 1 与测试 2。

- timestamp: 2026-04-05T14:06:32.8366311+08:00
  checked: three-kingdoms-simulator/scripts/autoload/TimeManager.gd
  found: get_current_label() 已返回完整格式字符串“%d年 / %d月 / 第%d旬”。
  implication: 时间管理器本身已经生成完整时间文本，不需要 UI 再附加“年/月/旬”前缀。

- timestamp: 2026-04-05T14:06:32.8366311+08:00
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd
  found: show_success_state() 和 _render_empty_fields() 都使用 _pair_text("190年 / 月 / 旬", ...) 给 _time_label 赋值；_pair_text 会输出“标签：值”。
  implication: TimeLabel 被当成键值对字段处理，导致静态标题和完整时间值被拼成同一串文本，从而出现重复时间信息。

- timestamp: 2026-04-05T14:06:32.8366311+08:00
  checked: three-kingdoms-simulator/scenes/main/MainScene.tscn
  found: TimeLabel 初始文本是“190年 / 月 / 旬”，而其他顶栏字段初始文本都采用“字段名：—”样式。
  implication: 场景把 TimeLabel 设计成独立显示值而非“标签：值”字段，但 MainHUD 运行时更新逻辑没有遵守这个约定。

## Resolution

root_cause: MainHUD 将 TimeLabel 错误地按“标签：值”字段渲染，给已经由 TimeManager 格式化好的完整时间字符串又拼接了一次静态时间标题，导致显示成“两遍年份”。
fix: ""
verification: ""
files_changed: []
