---
status: investigating
trigger: "请诊断第1阶段 UAT 问题 1 的根因。项目根目录：D:/Projects/Godot/三国模拟器 问题：用户确认能够冷启动进入主界面，但反馈‘主界面顶部显示了两个年份’。请只做诊断，不要修改代码。"
created: 2026-04-05T00:00:00Z
updated: 2026-04-05T00:00:00Z
---

## Current Focus

hypothesis: MainHUD 把时间字段的静态标题和 TimeManager 返回的完整日期串再次拼接，导致顶部时间文本重复包含年份。
test: 对照 MainHUD 的 TimeLabel 渲染逻辑、TimeManager 的返回格式、MainScene 的默认文本是否共享同一模板。
expecting: 如果假设成立，会看到 MainHUD 以“190年 / 月 / 旬”作为 label 前缀，而 TimeManager 又返回“190年 / 1月 / 第1旬”，最终形成“190年 / 月 / 旬：190年 / 1月 / 第1旬”。
next_action: 汇总证据并给出根因诊断，不修改代码。

## Symptoms

expected: 冷启动后主界面顶部时间区只显示一次完整时间，格式为“190年 / 1月 / 第1旬”。
actual: 主界面顶部时间区显示了两遍年份，用户看到类似“190年/月/旬:190年/1月/第1旬”。
errors: 无报错；属于 HUD 文案重复显示问题。
reproduction: 关闭现有运行实例后冷启动项目，进入主界面，观察顶部时间标签。
started: 第 1 阶段 UAT 冷启动进入主界面时发现。

## Eliminated

## Evidence

- timestamp: 2026-04-05T00:00:00Z
  checked: .planning/phases/01-190/01-UAT.md
  found: UAT 测试 1 和测试 2 都报告顶部年份显示两遍，且其他顶部字段正常。
  implication: 问题集中在时间标签渲染，不是整条顶栏布局或默认身份数据加载异常。

- timestamp: 2026-04-05T00:00:00Z
  checked: three-kingdoms-simulator/scripts/ui/MainHUD.gd
  found: show_success_state() 与 _render_empty_fields() 都把 TimeLabel 设为 _pair_text("190年 / 月 / 旬", ...)，即用时间模板字符串当作字段名，再追加值。
  implication: 时间标签会始终带一个静态“190年 / 月 / 旬：”前缀，而不是纯字段名或纯值。

- timestamp: 2026-04-05T00:00:00Z
  checked: three-kingdoms-simulator/scripts/autoload/TimeManager.gd
  found: get_current_label() 返回完整格式化时间“%d年 / %d月 / 第%d旬”。
  implication: 当 MainHUD 把这个完整时间再拼到“190年 / 月 / 旬”后面时，会在同一标签中重复出现年份信息。

- timestamp: 2026-04-05T00:00:00Z
  checked: three-kingdoms-simulator/scenes/main/MainScene.tscn
  found: TimeLabel 默认文本也被写成“190年 / 月 / 旬”，不是“时间：—”之类的字段名占位。
  implication: 场景与脚本都沿用了把时间模板当标题的做法，说明这是同一设计错误而非运行时偶发渲染问题。

## Resolution

root_cause: MainHUD 将 TimeLabel 当作“字段名：值”对来渲染，前缀硬编码为“190年 / 月 / 旬”，而 TimeManager.get_current_label() 又返回完整日期“190年 / 1月 / 第1旬”，同一标签被重复拼接后出现两个年份。
fix: 仅诊断，未改代码；后续需把 TimeLabel 改为单一时间值渲染，或将前缀改成真正字段名并避免再拼接完整日期。
verification: 通过读取 UAT 报告、MainHUD.gd、TimeManager.gd、MainScene.tscn 交叉确认字符串构造路径，未进行代码修改。
files_changed: []
