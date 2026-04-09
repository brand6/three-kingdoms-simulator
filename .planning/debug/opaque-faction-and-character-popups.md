---
status: investigating
trigger: "点击势力相关按钮后，应在当前主界面内弹出派系总览 popup；当前 UAT 反馈为势力面板和人物详情面板需要改成不透明的"
created: 2026-04-09T00:00:00Z
updated: 2026-04-09T00:12:00Z
---

## Current Focus

hypothesis: confirmed — FactionPanel and CharacterProfilePanel were instantiated as bare PopupPanel nodes with no opaque style override, unlike TaskSelectPanel which explicitly disables transparency and assigns an opaque StyleBox
test: compare MainScene popup node properties and shared theme resource
expecting: mismatch between styled TaskSelectPanel and unstyled faction/character popups explains why only these panels look transparent
next_action: record root cause and return diagnosis

## Symptoms

expected: 势力面板和人物详情面板以不透明 popup 呈现，可正常下钻人物。
actual: 用户报告势力面板和人物详情面板需要改成不透明的，说明当前 popup 可见但背景/内容存在透明表现。
errors: None reported
reproduction: Test 3 in UAT；点击势力相关按钮打开派系总览，再点击重要人物进入人物详情。
started: Discovered during UAT

## Eliminated

## Evidence

- timestamp: 2026-04-09T00:03:00Z
  checked: .planning/debug/knowledge-base.md
  found: knowledge base file does not exist yet
  implication: no prior resolved pattern is available; investigation must proceed from current implementation

- timestamp: 2026-04-09T00:04:00Z
  checked: codebase search for faction/character popup implementation
  found: MainHUD owns FactionPanel and CharacterProfilePanel, both implemented as PopupPanel-based overlays inside MainScene rather than scene changes
  implication: the UAT complaint is about popup styling/contents, not wrong navigation architecture

- timestamp: 2026-04-09T00:07:00Z
  checked: scripts/ui/MainHUD.gd, scripts/ui/FactionPanel.gd, scripts/ui/CharacterProfilePanel.gd
  found: faction button opens FactionPanel.show_faction(), officer click opens CharacterProfilePanel.show_profile(); both scripts only populate text and call popup_centered, with no code that sets opaque backgrounds or theme/style overrides
  implication: if the popups are transparent, the cause must come from scene/theme configuration rather than runtime navigation logic

- timestamp: 2026-04-09T00:10:00Z
  checked: scenes/main/MainScene.tscn
  found: TaskSelectPanel explicitly sets transparent_bg=false, transparent=false, and theme_override_styles/panel=StyleBoxFlat_hi3im, while CharacterProfilePanel and FactionPanel are plain PopupPanel nodes with no corresponding transparency flags or panel style override
  implication: faction and character popups inherit default PopupPanel visuals instead of the intended opaque card style

- timestamp: 2026-04-09T00:11:00Z
  checked: themes/PrototypeTheme.tres
  found: shared theme only defines default_base_scale and default_font_size; it does not provide PopupPanel panel styles that could make these overlays opaque globally
  implication: there is no theme fallback that would correct the missing style on FactionPanel or CharacterProfilePanel

## Resolution

root_cause: 
root_cause: FactionPanel and CharacterProfilePanel were added to MainScene as unstyled PopupPanel nodes. Unlike TaskSelectPanel, they do not disable transparency or override the panel StyleBox, and the shared PrototypeTheme provides no PopupPanel styling. As a result, these two overlays render with default translucent PopupPanel visuals.
fix: 
verification: 
files_changed: []
