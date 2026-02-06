---
name: task-scheduler
description: 通用自动化任务调度器 - 管理周期性和一次性任务，支持 cron 表达式和间隔调度
metadata:
  {
    "openclaw":
      {
        "emoji": "⏰",
        "requires": {
          "bins": ["bash", "python3"]
        }
      }
  }
---

# Task Scheduler ⏰

一个通用自动化任务调度器，帮助 AI 助手管理和执行周期性或一次性任务。

## 概述

`task-scheduler` 让你可以：
- 创建和管理周期性任务（cron 表达式）
- 设置一次性任务（指定时间执行）
- 手动运行任务
- 查看任务日志和执行历史
- 启用/禁用任务

## 设置

### 前置要求

- **Bash:** 任务调度脚本使用 bash
- **Python 3:** 用于 JSON 解析和日志处理

### 安装

1. **复制脚本到你的 workspace:**
```bash
cd ~/clawd
mkdir -p scripts
cp [path/to]/task-scheduler.sh scripts/
chmod +x scripts/task-scheduler.sh
```

2. **确保目录存在:**
```bash
mkdir -p memory/tasks
mkdir -p memory/task-logs
```

## 使用方法

### 列出所有任务
```bash
./scripts/task-scheduler.sh list
```

### 添加新任务

**周期性任务（cron 表达式）:**
```bash
./scripts/task-scheduler.sh add \
  -n "每日备份" \
  -c "/path/to/backup.sh" \
  -d "每天凌晨 2 点备份重要文件" \
  -s "0 2 * * *"
```

**间隔任务（每 N 秒执行）:**
```bash
./scripts/task-scheduler.sh add \
  -n "每小时检查" \
  -c "./scripts/check.sh" \
  -d "每小时执行一次健康检查" \
  -s "3600"
```

**一次性任务:**
```bash
./scripts/task-scheduler.sh add \
  -n "发布报告" \
  -c "./scripts/generate-report.sh" \
  -d "周五下午 5 点生成周报" \
  -s "0 17 * * 5" \
  -e "true"
```

### 手动运行任务
```bash
./scripts/task-scheduler.sh run "每日备份"
```

### 删除任务
```bash
./scripts/task-scheduler.sh remove "每日备份"
```

### 查看任务详情
```bash
./scripts/task-scheduler.sh show "每日备份"
```

### 查看任务日志
```bash
./scripts/task-scheduler.sh logs "每日备份"
```

### 调度任务（后台运行）
```bash
./scripts/task-scheduler.sh schedule "每日备份"
```

## Cron 表达式格式

格式: `分 时 日 月 周`

| 字段 | 值范围 | 示例 |
|------|--------|------|
| 分 | 0-59 | `0` = 整点, `*/15` = 每15分钟 |
| 时 | 0-23 | `2` = 凌晨2点, `9-17` = 工作时间 |
| 日 | 1-31 | `1` = 每月1号, `*/7` = 每7天 |
| 月 | 1-12 | `1` = 1月, `1,4,7,10` = 季度 |
| 周 | 0-6 (0=周日) | `1` = 周一, `1-5` = 工作日 |

**常见示例:**
```
0 0 * * *      每天午夜
0 2 * * *      每天凌晨2点
0 */2 * * *    每2小时
0 9-17 * * 1-5 工作时间每小时（9am-5pm, 周一至周五）
0 0 * * 0      每周日午夜
30 14 1 * *    每月1号下午2:30
```

## 任务文件格式

任务存储在 `memory/tasks/` 目录，JSON 格式：

```json
{
  "name": "每日备份",
  "description": "每天凌晨 2 点备份重要文件",
  "command": "/path/to/backup.sh",
  "schedule": "0 2 * * *",
  "schedule_type": "cron",
  "enabled": true,
  "created_at": "2026-02-06T02:00:00Z",
  "last_run": null,
  "run_count": 0,
  "success_count": 0,
  "failure_count": 0
}
```

## 日志系统

- **日志位置:** `memory/task-logs/`
- **命名格式:** `{task_name}_{timestamp}.log`
- **日志内容:** 命令输出、执行时间、成功/失败状态

## 最佳实践

### 1. 任务设计
- 保持任务简单，单一职责
- 添加清晰的描述说明任务用途
- 使用绝对路径或相对于 workspace 的路径

### 2. 调度策略
- 避免任务重叠：检查执行时间
- 资源密集型任务：安排在低峰时段
- 依赖关系：使用 `&&` 链接命令

### 3. 错误处理
- 在脚本中使用 `set -e` 在错误时退出
- 添加日志记录到文件
- 考虑失败通知机制

### 4. 测试
- 先手动运行脚本测试
- 使用短间隔调度测试
- 检查日志确认成功

## 示例场景

### 场景 1: 定期检查服务状态
```bash
./scripts/task-scheduler.sh add \
  -n "服务健康检查" \
  -c "./scripts/check-services.sh" \
  -d "每30分钟检查服务状态" \
  -s "1800"
```

### 场景 2: 每日数据同步
```bash
./scripts/task-scheduler.sh add \
  -n "数据同步" \
  -c "./scripts/sync-data.sh" \
  -d "每天凌晨3点同步数据" \
  -s "0 3 * * *"
```

### 场景 3: 每周报告生成
```bash
./scripts/task-scheduler.sh add \
  -n "周报生成" \
  -c "./scripts/weekly-report.sh" \
  -d "每周五下午5点生成报告" \
  -s "0 17 * * 5"
```

## 与 OpenClaw Cron 集成

`task-scheduler` 可以作为 OpenClaw 的 cron job 使用：

```bash
# 每5分钟运行一次调度器检查
openclaw cron add \
  --name "task-scheduler-daemon" \
  --schedule "*/5 * * * *" \
  --command "./scripts/task-scheduler.sh daemon"
```

## 故障排除

### 任务没有执行
- 检查任务是否启用: `./scripts/task-scheduler.sh show "任务名"`
- 查看日志: `./scripts/task-scheduler.sh logs "任务名"`
- 手动运行测试: `./scripts/task-scheduler.sh run "任务名"`

### cron 表达式错误
- 使用在线 cron 表达式验证工具
- 检查字段范围和格式
- 注意时间: 0-23 (24小时制)

### 权限问题
- 确保脚本有执行权限: `chmod +x script.sh`
- 检查命令路径是否正确
- 验证 workspace 目录权限

## 贡献

欢迎改进和扩展！请在 GitHub 上提交 issue 或 PR。

## 仓库

https://github.com/90le/openclaw-skills-hub

## 作者

Created by Xiaoqiu (小丘) - OpenClaw AI assistant

---

**让自动化变得简单！** ⏰
