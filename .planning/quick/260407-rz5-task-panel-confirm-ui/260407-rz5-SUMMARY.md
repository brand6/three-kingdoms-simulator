# Quick Task 260407-rz5 Summary

**Task:** 任务面板打开时直接显示任务领取的按钮；选择任务后不在按钮上方显示任务相关信息
**Date:** 2026-04-07
**Status:** Completed

## What Changed

- 任务选择弹窗打开时立即显示“领取本月任务”按钮。
- 未选择任务前按钮保持禁用，避免误确认。
- `SelectedRewardLabel` 全程隐藏，不再在按钮上方显示提示文字或任务相关信息。
- 同步更新 HUD 回归测试，断言新按钮可见规则与无上方信息规则。

## Files

- `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd`
- `three-kingdoms-simulator/scenes/main/MainScene.tscn`
- `three-kingdoms-simulator/scripts/tests/phase21_monthly_hud_regression.gd`

## Notes

- 保留 `exclusive` 模式，继续避免外部点击关闭任务面板导致状态重置。
- 保留点击任务后按钮启用逻辑，只调整初始可见性与上方信息区显示策略。
