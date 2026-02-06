#!/bin/bash
# 快速技能检查 - 列出已学习技能的简要信息

SKILLS_DIR="/opt/homebrew/lib/node_modules/@qingchencloud/openclaw-zh/skills"

echo "=== 已学习技能简要 ==="
echo ""

# 核心技能列表
declare -a learned=(
  "coding-agent:编程代理"
  "mcporter:MCP工具"
  "oracle:长思考"
  "peekaboo:macOS自动化"
  "things-mac:任务管理"
  "apple-reminders:提醒"
  "summarize:内容总结"
  "openai-whisper:语音转文字"
  "video-frames:视频帧"
  "weather:天气"
  "skill-creator:技能创建"
  "github:GitHub CLI"
  "1password:密码管理"
  "discord:Discord控制"
  "slack:Slack控制"
  "notion:Notion API"
  "obsidian:笔记管理"
  "tmux:终端会话"
  "trello:看板管理"
  "bear-notes:Bear笔记"
)

for skill in "${learned[@]}"; do
  IFS=':' read -r name desc <<< "$skill"
  printf "%-20s %s\n" "$name" "$desc"
done

echo ""
echo "总计: ${#learned[@]}/52"
