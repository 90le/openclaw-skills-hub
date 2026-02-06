#!/bin/bash
# 生成进化报告

echo "=== 🧬 进化报告 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 统计技能数
SKILL_COUNT=$(ls /opt/homebrew/lib/node_modules/@qingchencloud/openclaw-zh/skills/ | wc -l | tr -d ' ')
echo "技能总数: $SKILL_COUNT"

# 统计自定义工具
SCRIPT_TOOLS=$(find /Users/binbin/clawd/scripts -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) 2>/dev/null | wc -l | tr -d ' ')
OTHER_TOOLS=$(find /Users/binbin/clawd/tools -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) 2>/dev/null | wc -l | tr -d ' ')
TOOL_COUNT=$((SCRIPT_TOOLS + OTHER_TOOLS))
echo "自定义工具: $TOOL_COUNT"

# 检查文件存在
FILES="MEMORY.md memory/issues.md memory/evolution.md"
for f in $FILES; do
  if [ -f "/Users/binbin/clawd/$f" ]; then
    echo "✓ $f"
  else
    echo "✗ $f (缺失)"
  fi
done

echo ""
echo "下次进化检查: 1小时内"
