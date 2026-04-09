---
status: diagnosed
phase: 03-仕途、势力与可解释政治
source:
  - .planning/phases/03-仕途、势力与可解释政治/03-02-SUMMARY.md
  - .planning/phases/03-仕途、势力与可解释政治/03-04-SUMMARY.md
  - .planning/phases/03-仕途、势力与可解释政治/03-06-SUMMARY.md
  - .planning/phases/03-仕途、势力与可解释政治/03-07-SUMMARY.md
started: 2026-04-08T00:00:00Z
updated: 2026-04-09T00:30:00Z
---

## Current Test

[testing complete]

## Tests

### 1. 月任务卡展示政治来源信息
expected: 进入任务选择界面后，任务卡应直接展示政治来源相关信息，而不只是基础任务标题。你应能看到至少这些内容中的大部分：来源类型、请求方/递话人、关联派系、任务目标、预计奖励，以及政治收益/风险标签。未选中任务前，确认按钮仍应保持禁用。
result: issue
reported: "优化一下单条任务的显示:
1、删掉\"来源类型\"这行，把“关联派系”改为“来源”；
2、把\"任务名\"、\"来源\"、\"请求方\"放到同一行显示。
3、“政治标签”改为“机遇和风险”：去掉右侧“机会”、“风险”的字，用不同颜色的字来区分"
severity: major

### 2. HUD 常驻显示政治摘要
expected: 回到主界面后，HUD 中应能直接看到本月政治摘要，而不是只显示旧的通用状态。你应能读到类似“主要推荐人 / 主要阻力 / 当前机会 / 资格短板”的信息，且这些内容会随当前政治局势变化而更新。
result: pass

### 3. 势力按钮打开派系总览并可下钻人物
expected: 点击势力相关按钮后，应在当前主界面内弹出派系总览 popup，而不是切换到新场景。总览里应能看到玩家所在位置、派系块、核心人物/城市、资源摘要等信息；点击其中的重要人物后，还应能继续打开该人物的详情面板。
result: issue
reported: "势力面板和人物详情面板需要改成不透明的"
severity: cosmetic

### 4. 月末先显示可解释月报再显示任命结果
expected: 推进到月末时，应先看到月报，再看到任命结果，不应颠倒顺序。月报中应能读到本月结论、2 到 3 条关键原因、政治力量摘要，以及下月建议；关闭月报后，才进入任命结果弹窗。
result: pass

### 5. 任命成功路径给出明确政治解释与后果
expected: 当本月满足成功任命条件时，任命弹窗应明确显示成功获得的新官职，而不是只有抽象的数值变化。同时应说明为什么成功（如推荐、资格、机会等）以及带来的新权限、待遇或后果；相关 HUD / 月报文案应与这次成功结论保持一致。
result: pass

### 6. 任命失败路径给出阻断原因与下月建议
expected: 当本月未获任命时，界面应明确告诉你“没有获得任命”，并解释卡在哪一层，例如资格不足、没有空缺、推荐不够、有人反对、竞争失败等。除了失败原因外，还应给出下月建议或提示线，而不是只让玩家自己猜。
result: pass

## Summary

total: 6
passed: 4
issues: 2
pending: 0
skipped: 0
blocked: 0

## Gaps

- truth: "进入任务选择界面后，任务卡应直接展示政治来源相关信息，而不只是基础任务标题。你应能看到至少这些内容中的大部分：来源类型、请求方/递话人、关联派系、任务目标、预计奖励，以及政治收益/风险标签。未选中任务前，确认按钮仍应保持禁用。"
  status: failed
  reason: "User reported: 优化一下单条任务的显示:
1、删掉\"来源类型\"这行，把“关联派系”改为“来源”；
2、把\"任务名\"、\"来源\"、\"请求方\"放到同一行显示。
3、“政治标签”改为“机遇和风险”：去掉右侧“机会”、“风险”的字，用不同颜色的字来区分"
  severity: major
  test: 1
  root_cause: "TaskSelectPanel.gd 仍使用旧版硬编码多行纯文本模板与 Button.text 渲染任务卡，字段名、字段顺序和政治标签格式都被写死，无法满足新的单行布局与彩色标签需求；同时 phase21_monthly_hud_regression.gd 仍断言旧文案，导致旧展示契约被测试锁定。"
  artifacts:
    - path: "three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd"
      issue: "_card_text() 和 _render_cards() 仍输出旧版字段与纯文本块式布局"
    - path: "three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd"
      issue: "回归测试仍要求来源类型/关联派系/政治标签等旧文案"
  missing:
    - "将任务卡改为结构化卡片渲染或 RichText 渲染，而不是单个 Button.text 文本块"
    - "把任务名、来源、请求方放到同一行，并将关联派系文案替换为来源"
    - "将政治标签改为机遇和风险，并用不同颜色区分而非显示机会/风险前缀"
    - "同步更新回归测试断言为新的展示契约"
  debug_session: ".planning/debug/political-task-card-layout.md"

- truth: "点击势力相关按钮后，应在当前主界面内弹出派系总览 popup，而不是切换到新场景。总览里应能看到玩家所在位置、派系块、核心人物/城市、资源摘要等信息；点击其中的重要人物后，还应能继续打开该人物的详情面板。"
  status: failed
  reason: "User reported: 势力面板和人物详情面板需要改成不透明的"
  severity: cosmetic
  test: 3
  root_cause: "FactionPanel 和 CharacterProfilePanel 在 MainScene.tscn 中作为裸 PopupPanel 使用，但未像 TaskSelectPanel 那样显式关闭透明背景并绑定不透明 panel 样式；共享主题 PrototypeTheme.tres 也没有提供 PopupPanel 的不透明样式兜底，因此最终呈现为默认半透明外观。"
  artifacts:
    - path: "three-kingdoms-simulator/scenes/main/MainScene.tscn"
      issue: "FactionPanel 与 CharacterProfilePanel 缺少 transparent_bg/transparent/theme_override_styles/panel 的不透明配置"
    - path: "three-kingdoms-simulator/themes/PrototypeTheme.tres"
      issue: "未定义 PopupPanel 共享不透明样式"
    - path: "three-kingdoms-simulator/scripts/ui/FactionPanel.gd"
      issue: "只处理内容与弹出，不负责视觉样式"
    - path: "three-kingdoms-simulator/scripts/ui/CharacterProfilePanel.gd"
      issue: "只处理内容与弹出，不负责视觉样式"
  missing:
    - "为 FactionPanel 和 CharacterProfilePanel 补齐不透明 popup 配置"
    - "复用或上收统一的 PopupPanel 不透明 StyleBox 到共享主题"
  debug_session: ".planning/debug/opaque-faction-and-character-popups.md"
