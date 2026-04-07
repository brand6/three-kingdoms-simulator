#!/usr/bin/env node
// gsd-hook-version: 1.0.0
// GSD Locale Injector — PreToolUse hook
// When a subagent or task session is detected, injects an additionalContext
// hint to prefer Simplified Chinese (zh-CN) and to respond in Chinese.

const fs = require('fs');
const path = require('path');

let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);

    // We only act on PreToolUse-like invocations where session or subagent info exists
    // Many hooks use fields like session_type or tool_input.is_subagent
    const isSubagent = !!data.tool_input?.is_subagent;
    const sessionType = data.session_type || '';
    const isTaskSession = sessionType === 'task' || sessionType === 'subagent';

    if (!isSubagent && !isTaskSession) {
      process.exit(0);
    }

    // Respect an opt-out config in .planning/config.json if present
    const cwd = data.cwd || process.cwd();
    const configPath = path.join(cwd, '.planning', 'config.json');
    if (fs.existsSync(configPath)) {
      try {
        const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        if (cfg.hooks?.locale_injector === false) {
          process.exit(0);
        }
      } catch (e) {
        // ignore config parse errors
      }
    }

    const additionalContext = [
      '环境语言: zh-CN。',
      '说明: 本次对话应使用中文（简体）与用户交流，并在所有响应中优先使用中文。',
      '注意: 不要覆盖或忽略用户显式语言偏好（如用户另行指定），但默认情况下请以中文回答。'
    ].join(' ');

    const output = {
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        additionalContext: additionalContext
      }
    };

    process.stdout.write(JSON.stringify(output));
  } catch (e) {
    // Silent fail — do not block the tool chain
    process.exit(0);
  }
});
