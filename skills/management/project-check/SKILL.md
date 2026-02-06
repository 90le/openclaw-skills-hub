---
name: project-check
description: 项目状态管理系统 - 快速检查所有项目的状态、进度、待办事项
metadata:
  {
    "openclaw":
      {
        "emoji": "📋",
        "requires": {
          "bins": ["bash", "python3"]
        }
      }
  }
---

# Project Check 📋

项目状态检查工具，快速检查所有项目的状态、进度、待办事项。

## 概述

`project-check` 让你可以：
- 列出所有项目
- 添加新项目
- 更新项目状态
- 搜索项目
- 生成项目报告

## 设置

### 前置要求
- Bash + Python 3

### 安装
```bash
cd ~/clawd
mkdir -p scripts
cp [path/to]/project-check.sh scripts/
chmod +x scripts/project-check.sh
mkdir -p memory/projects
```

## 使用方法

### 列出所有项目
```bash
./scripts/project-check.sh list
```

### 添加新项目
```bash
./scripts/project-check.sh add \
  -n "项目名称" \
  -d "项目描述" \
  -s "active" \
  -p "high" \
  -t "tag1,tag2" \
  -r 10
```

### 更新项目状态
```bash
./scripts/project-check.sh update \
  -n "项目名称" \
  -s "completed" \
  -r 100
```

### 查看项目详情
```bash
./scripts/project-check.sh show "项目名称"
```

### 生成项目报告
```bash
./scripts/project-check.sh report
```

## 项目状态
- planning: 筹备中
- active: 活跃
- paused: 暂停
- completed: 已完成
- archived: 已归档

## 优先级
- high: 高优先级
- medium: 中优先级
- low: 低优先级

## 仓库

https://github.com/90le/openclaw-skills-hub

---

**管理你的项目！** 📋
