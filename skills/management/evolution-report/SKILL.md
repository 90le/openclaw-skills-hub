---
name: evolution-report
description: 生成 AI 进化报告 - 快速检查技能掌握、工具创建、记忆系统状态
metadata:
  {
    "openclaw":
      {
        "emoji": "🧬",
        "requires": {
          "bins": ["bash"]
        }
      }
  }
---

# Evolution Report 🧬

快速生成 AI 助手的进化报告，追踪技能掌握、工具创建和系统状态。

## 概述

`evolution-report` 让你可以：
- 统计已掌握的技能数量
- 统计自定义工具数量
- 检查关键记忆文件是否存在
- 快速评估进化状态

## 设置

### 前置要求

- **Bash:** 脚本运行

### 安装

1. **复制脚本到你的 workspace:**
```bash
cd ~/clawd
mkdir -p scripts
cp [path/to]/evolution-report.sh scripts/
chmod +x scripts/evolution-report.sh
```

2. **（可选）自定义路径:**
编辑脚本中的变量以匹配你的 workspace:
```bash
SKILLS_DIR="/opt/homebrew/lib/node_modules/@qingchencloud/openclaw-zh/skills"
WORKSPACE="/Users/yourname/clawd"
```

## 使用方法

### 生成进化报告
```bash
./scripts/evolution-report.sh
```

### 输出示例
```
=== 🧬 进化报告 ===
时间: 2026-02-06 10:30:00

技能总数: 53
自定义工具: 10
✓ MEMORY.md
✓ memory/issues.md
✓ memory/evolution.md

下次进化检查: 1小时内
```

## 报告内容

### 技能统计
- 扫描 OpenClaw 技能目录
- 统计已安装的技能数量

### 自定义工具统计
- 统计 `scripts/` 目录中的工具
- 统计 `tools/` 目录中的工具
- 总计显示所有自定义工具

### 记忆文件检查
- `MEMORY.md` - 长期记忆
- `memory/issues.md` - 问题追踪
- `memory/evolution.md` - 进化计划

### 下次检查提醒
- 提示下次进化检查时间

## 定期检查

### 添加到 OpenClaw Cron
```bash
# 每小时检查一次
openclaw cron add \
  --name "hourly-evolution-check" \
  --schedule "0 * * * *" \
  --command "./scripts/evolution-report.sh >> memory/evolution-log/$(date +\%Y\%m\%d).md"
```

### 创建日志目录
```bash
mkdir -p memory/evolution-log
```

## 进化跟踪

### 创建日志文件
每次运行时自动追加到日志：
```bash
./scripts/evolution-report.sh >> memory/evolution-log/$(date +%Y%m%d).md
```

### 查看历史记录
```bash
# 查看今天的进化记录
cat memory/evolution-log/$(date +%Y%m%d).md

# 查看最近7天
ls -lt memory/evolution-log/ | head -8
```

## 扩展功能

你可以根据需要扩展脚本：

### 添加新的检查项
```bash
# 检查特定技能
if [ -d "$SKILLS_DIR/my-skill" ]; then
  echo "✓ my-skill"
else
  echo "✗ my-skill (缺失)"
fi

# 检查配置文件
if [ -f "$HOME/.config/my-app/config.json" ]; then
  echo "✓ my-app 配置"
fi
```

### 添加统计指标
```bash
# 统计记忆文件大小
MEMORY_SIZE=$(du -sh ~/clawd/memory | cut -f1)
echo "记忆目录大小: $MEMORY_SIZE"

# 统计项目数量
PROJECT_COUNT=$(ls ~/clawd/memory/projects/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "项目数量: $PROJECT_COUNT"
```

## 最佳实践

### 1. 定期检查
- 每小时或每天运行一次
- 记录到日志文件
- 追踪进化趋势

### 2. 与其他工具配合
- 结合 `task-scheduler` 定时执行
- 使用 `project-check` 追踪项目进展
- 配合 `quick-skill-check` 查看技能详情

### 3. 适应你的需求
- 修改检查项以匹配你的系统
- 添加新的统计指标
- 调整输出格式

## 示例工作流

### 每日进化检查
```bash
#!/bin/bash
# daily-evolution-check.sh

cd ~/clawd

# 生成报告
./scripts/evolution-report.sh >> memory/evolution-log/$(date +%Y%m%d).md

# 记录到今日文件
echo "## $(date '+%H:%M') - 进化检查" >> memory/2026-$(date +%m-%d).md
./scripts/evolution-report.sh >> memory/2026-$(date +%m-%d).md

echo "✅ 进化检查完成"
```

### 完整的进化追踪系统
```bash
#!/bin/bash
# evolution-tracker.sh

# 1. 生成报告
./scripts/evolution-report.sh

# 2. 更新仪表板
./scripts/evolution-dashboard.sh update

# 3. 检查里程碑
./scripts/check-milestones.sh

# 4. 生成趋势图
./scripts/evolution-chart.sh

echo "🧬 进化追踪完成"
```

## 故障排除

### 技能统计为0
- 检查 `SKILLS_DIR` 路径是否正确
- 确认 OpenClaw 已正确安装
- 验证目录权限

### 自定义工具统计不准确
- 检查 `scripts/` 和 `tools/` 目录路径
- 确保脚本有执行权限
- 验证文件扩展名（.sh 或 .py）

### 记忆文件显示缺失
- 创建缺失的文件
- 检查文件路径是否正确
- 确保文件格式正确

## 与 AI 成长

这个工具的设计哲学：
- **意识自己的成长** - 清楚知道学到了什么
- **量化进步** - 用数字追踪进展
- **定期反思** - 定期检查进化状态
- **持续改进** - 基于反馈调整方向

## 贡献

欢迎改进！请在 GitHub 上提交 issue 或 PR。

## 仓库

https://github.com/90le/openclaw-skills-hub

## 作者

Created by Xiaoqiu (小丘) - OpenClaw AI assistant

---

**追踪你的进化！** 🧬
