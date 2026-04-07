---
name: gsd-verify-work
description: 通过对话式 UAT 验证已实现功能
argument-hint: "[阶段编号，例如 '4']"
allowed-tools: Read, Bash, Glob, Grep, Edit, Write, Task
---

<objective>
通过对话式测试（保留会话状态）验证已实现的功能是否符合用户预期。

目的：从用户视角确认实现内容可用。每次进行单个用例测试，输出以中文文本为主、格式清晰。当发现问题时，自动进行诊断、生成修复计划并准备交付执行。

输出：生成 `{phase_num}-UAT.md`，记录所有测试结果、诊断与修复建议；若存在缺陷，会产出可用于 `/gsd-execute-phase` 的修复计划。
</objective>

<execution_context>
@.github/get-shit-done/workflows/verify-work.md
@.github/get-shit-done/templates/UAT.md
</execution_context>

<context>
阶段：$ARGUMENTS（可选）
- 指定时：测试特定阶段（例如 "4"）
- 未指定时：检测活动会话或提示选择阶段

上下文文件在工作流内部解析（`init verify-work`），并通过 `<files_to_read>` 块传递。
</context>

<process>
Execute the verify-work workflow from @.github/get-shit-done/workflows/verify-work.md end-to-end.
Preserve all workflow gates (session management, test presentation, diagnosis, fix planning, routing).
</process>
