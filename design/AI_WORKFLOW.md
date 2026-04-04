# design AI 工作流

供开发 AI 在 `design/` 目录下新增、修改、移动文档时快速执行。

## 1. 先判断文档放哪

- 总体设计 / GDD / 项目方向 → `design/总纲/`
- 系统规则 / 机制专项 → `design/系统设计/`
- 数值 / 公式 / 资源循环 → `design/数值/`
- 数据结构 / 字段 / 配表 / 存档 → `design/数据/`
- Godot 原型 / 模块拆分 / 任务清单 / 验收 → `design/原型与实现/`
- UI / 交互 / 面板流程 → `design/UIUX/`
- 剧本 / 人物样本 / 事件样本 → `design/剧情与样本/`

## 2. 命名规则

- 格式：`主题名 v版本号.md`
- 例：`行动系统专项设计 v1.md`
- 不要使用：`最终版`、`新版`、`临时`、`杂项`

## 3. 创建或修改后必须同步更新

- `design/Agent.md`
  - 补充文件说明
  - 必要时更新推荐检索路径
- `design/machine_index.json`
  - 增加或更新对应文件索引
- `design/CHANGELOG.md`
  - 记录新增、移动、重命名、版本升级

## 4. machine_index.json 最少应填写

- `path`
- `title`
- `category`
- `summary`
- `keywords`
- `recommended_for`
- `priority`
- `legacy_path`（若有移动或重命名）

## 5. 不要做的事

- 不要新建无意义一级目录
- 不要把同类内容放到多个地方重复保存
- 不要只改正文，不更新索引
- 不要创建看不出用途的文件名

## 6. 最短执行流程

1. 先看 `design/Agent.md`
2. 判断目标目录
3. 创建 / 修改文档
4. 更新 `design/machine_index.json`
5. 更新 `design/Agent.md`
6. 更新 `design/CHANGELOG.md`
