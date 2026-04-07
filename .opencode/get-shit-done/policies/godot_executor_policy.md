---
title: Godot 操作首选策略
created: 2026-04-07
author: automated
---

# Godot 操作首选策略

目的：规定在需要以脚本或远程方式操作 Godot 编辑器 / 项目时的优先级与备用流程，使后续自动化 agent 与开发者采用统一、安全的实践。

## 策略

- 优先方法（默认）：使用 `godot-remote-executor` 技能（Hastur broker + Executor 插件）来进行交互式、基于编辑器的检测与修改操作，例如：
  - 查询运行中/编辑器内节点与属性
  - 在编辑器中临时运行 GDScript 片段以验证 UI/行为修复
  - 触发编辑器菜单项（通过 menu id 模拟用户操作）并保存场景
  - 在编辑器环境下做视觉验证后再持久化变更

- 备用方法（仅在下列场景使用）：`godot mcp` 或编辑器外的文件级批量流程（离线/CI）：
  - 大规模、可重复的资源导入/导出或批量生成 `.tres`/`.tscn`
  - 无图形编辑器环境（CI、headless）下的批处理脚本
  - 需要严格、可回滚的批量重写（应通过 VCS/PR/CI 管理）

## 理由（Rationale）

- `godot-remote-executor` 能在编辑器内快速闭环（探索 → 验证 → 保存），减少本地编辑—测试—回退的迭代成本，且可通过 `executeContext.output()` 返回结构化调试信息。
- 文件级/批处理流程在可重复性和 CI 自动化上更稳健，适合大规模无人工干预的场景。

## 示例工作流

- 修复 UI 问题（推荐）：
  1. 用 `godot-remote-executor` 查询目标节点属性（只读）以定位问题
  2. 在编辑器中用 snippet 临时修改并视觉验证（不保存）
  3. 验证通过后触发 Scene → Save（通过编辑器 menu id）持久化更改
  4. 在仓库中创建对应的 PR，包含变更说明与回退方案

- 批量导表/资源生成（备用）：
  1. 在离线脚本中使用 ResourceSaver/导出工具生成资源
  2. 通过 CI 校验结果并在通过后合并到主分支

## 操作注意事项

- 在使用 `godot-remote-executor` 前，确保：
  - Hastur broker-server 可用并已取得 Auth token
  - 目标 Godot 编辑器启用了 Hastur Executor 插件，并处于连接状态（检查 `/api/executors`）
- 所有通过 remote-executor 导致的持久更改应在保存前检查差异并通过 VCS 提交（PR 流程）以便审计与回退。
- 执行有破坏性的操作前请先备份（或确保变更可通过 VCS 回退）。

## 版本记录

- 2026-04-07 — 初版，作者：automated
