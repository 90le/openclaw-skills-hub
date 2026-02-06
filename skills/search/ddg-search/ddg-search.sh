#!/bin/bash
# DuckDuckGo Instant Answer API - 免费搜索替代方案

if [ -z "$1" ]; then
  echo "Usage: $0 \"search query\" [--json]"
  echo "Example: $0 \"OpenClaw AI assistant\" --json"
  exit 1
fi

QUERY="$1"
FORMAT="json"

if [ "$2" == "--text" ]; then
  FORMAT="text"
fi

# 简单URL编码（替换空格为+，其他字符保持）
ENCODED=$(echo "$QUERY" | sed 's/ /+/g')

# 调用DuckDuckGo Instant Answer API
curl -s "https://api.duckduckgo.com/?q=${ENCODED}&format=${FORMAT}&no_html=1"
