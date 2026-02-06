#!/bin/bash
# 自动化任务调度器
# 用于管理和执行周期性或一次性任务

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASKS_DIR="$SCRIPT_DIR/../memory/tasks"
LOGS_DIR="$SCRIPT_DIR/../memory/task-logs"

# 确保目录存在
mkdir -p "$TASKS_DIR"
mkdir -p "$LOGS_DIR"

# 显示用法
show_usage() {
    cat << 'EOF'
自动化任务调度器

用法:
    task-scheduler.sh <action> [options]

动作:
    list           列出所有任务
    add            添加新任务
    remove         删除任务
    run            执行任务
    schedule       调度任务（周期性执行）
    show           显示任务详情
    logs           查看任务日志

添加选项:
    -n, --name <name>          任务名称
    -c, --command <command>    命令或脚本路径
    -d, --description <desc>    描述
    -s, --schedule <schedule>  调度（cron表达式或间隔秒数）
    -e, --enabled <true|false> 是否启用（默认true）

示例:
    task-scheduler.sh list
    task-scheduler.sh add -n "每日备份" -c "/path/to/backup.sh" -s "0 2 * * *"
    task-scheduler.sh add -n "每小时检查" -c "./scripts/check.sh" -s "3600"
    task-scheduler.sh run "每日备份"
    task-scheduler.sh schedule "每日备份"
EOF
}

# 生成任务文件名
get_task_file() {
    local name="$1"
    echo "$TASKS_DIR/$(echo "$name" | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-').json"
}

# 生成日志文件名
get_log_file() {
    local name="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    echo "$LOGS_DIR/${name}_${timestamp}.log"
}

# 列出所有任务
list_tasks() {
    echo "📋 任务列表"
    echo "==========="

    if [ -z "$(ls -A "$TASKS_DIR" 2>/dev/null)" ]; then
        echo "还没有任务"
        return
    fi

    for file in "$TASKS_DIR"/*.json; do
        if [ -f "$file" ]; then
            name=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('name','Unknown'))" 2>/dev/null || echo "Unknown")
            enabled=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('enabled','false'))" 2>/dev/null || echo "false")
            schedule=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('schedule','-'))" 2>/dev/null || echo "-")
            status="❌"
            [ "$enabled" = "true" ] && status="✅"
            printf "  %-2s %-30s %s\n" "$status" "$name" "$schedule"
        fi
    done
}

# 添加新任务
add_task() {
    local name=""
    local command=""
    local description=""
    local schedule=""
    local enabled="true"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -c|--command)
                command="$2"
                shift 2
                ;;
            -d|--description)
                description="$2"
                shift 2
                ;;
            -s|--schedule)
                schedule="$2"
                shift 2
                ;;
            -e|--enabled)
                enabled="$2"
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$name" ]; then
        echo "❌ 错误: 任务名称不能为空"
        exit 1
    fi

    if [ -z "$command" ]; then
        echo "❌ 错误: 命令不能为空"
        exit 1
    fi

    local file=$(get_task_file "$name")

    if [ -f "$file" ]; then
        echo "❌ 错误: 任务已存在"
        exit 1
    fi

    # 创建任务文件
    cat > "$file" << EOF
{
  "name": "${name}",
  "command": "${command}",
  "description": "${description}",
  "schedule": "${schedule}",
  "enabled": ${enabled},
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_run": null,
  "run_count": 0,
  "success_count": 0,
  "failure_count": 0
}
EOF

    echo "✅ 任务已创建: $name"
}

# 删除任务
remove_task() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ 错误: 请指定任务名称"
        exit 1
    fi

    local file=$(get_task_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 任务不存在"
        exit 1
    fi

    read -p "⚠️  确定要删除任务 '$name'？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$file"
        echo "✅ 任务已删除"
    else
        echo "已取消"
    fi
}

# 执行任务
run_task() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ 错误: 请指定任务名称"
        exit 1
    fi

    local file=$(get_task_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 任务不存在"
        exit 1
    fi

    # 检查任务是否启用
    local enabled=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('enabled','false'))" 2>/dev/null || echo "false")
    if [ "$enabled" != "true" ]; then
        echo "⚠️  任务已禁用"
        return 0
    fi

    local command=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('command',''))" 2>/dev/null)
    local log_file=$(get_log_file "$name")

    echo "🚀 执行任务: $name"
    echo "📝 日志文件: $log_file"
    echo ""

    # 更新任务统计
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local run_count=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('run_count',0)+1)" 2>/dev/null || echo "1")
    local success_count=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('success_count',0))" 2>/dev/null || echo "0")
    local failure_count=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('failure_count',0))" 2>/dev/null || echo "0")

    # 执行命令
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
    echo "命令: $command" >> "$log_file"
    echo "---" >> "$log_file"

    if eval "$command" >> "$log_file" 2>&1; then
        echo "✅ 任务执行成功"
        ((success_count++))
    else
        echo "❌ 任务执行失败"
        ((failure_count++))
    fi

    # 更新任务文件
    python3 << EOF
import json
with open('$file', 'r') as f:
    data = json.load(f)
data['last_run'] = '$current_time'
data['run_count'] = $run_count
data['success_count'] = $success_count
data['failure_count'] = $failure_count
data['updated_at'] = '$current_time'
with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
EOF

    echo "📋 日志: $log_file"
    echo "📊 统计: 运行 $run_count 次，成功 $success_count 次，失败 $failure_count 次"
}

# 调度任务（显示如何调度）
schedule_task() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ 错误: 请指定任务名称"
        exit 1
    fi

    local file=$(get_task_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 任务不存在"
        exit 1
    fi

    local schedule=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('schedule','-'))" 2>/dev/null || echo "-")
    local command=$(python3 -c "import json, sys; data=json.load(open('$file')); print(data.get('command',''))" 2>/dev/null)

    echo "📅 调度任务: $name"
    echo "=================="
    echo "调度: $schedule"
    echo ""
    echo "如果 $schedule 是 cron 表达式，你可以添加到系统的 crontab："
    echo ""
    echo "  crontab -e"
    echo "  # 添加以下行："
    echo "  $schedule $command"
    echo ""
    echo "如果 $schedule 是间隔秒数，可以使用以下方式："
    echo ""
    echo "  while true; do $command; sleep $schedule; done"
    echo ""
    echo "或者使用 OpenClaw 的 cron 工具（如果可用）："
    echo ""
    echo "  cron add --job ..."
}

# 显示任务详情
show_task() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ 错误: 请指定任务名称"
        exit 1
    fi

    local file=$(get_task_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 任务不存在"
        exit 1
    fi

    echo "📋 任务详情: $name"
    echo "================"
    cat "$file"
}

# 查看任务日志
show_logs() {
    local name="$1"
    local count=5

    if [ -n "$2" ] && [ "$2" = "-n" ]; then
        count="$3"
    fi

    echo "📋 任务日志: $name (最近 $count 条)"
    echo "================================"

    if [ ! -d "$LOGS_DIR" ]; then
        echo "还没有日志"
        return
    fi

    local logs=$(ls -t "$LOGS_DIR"/${name}_*.log 2>/dev/null | head -n "$count")

    if [ -z "$logs" ]; then
        echo "没有找到日志"
        return
    fi

    for log_file in $logs; do
        local basename=$(basename "$log_file")
        local date=$(echo "$basename" | sed "s/${name}_//" | sed 's/.log//')
        echo ""
        echo "📅 $date"
        echo "-------------------"
        tail -n 10 "$log_file"
        echo ""
    done
}

# 主程序
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi

    local action="$1"
    shift

    case "$action" in
        list)
            list_tasks
            ;;
        add)
            add_task "$@"
            ;;
        remove)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定任务名称"
                exit 1
            fi
            remove_task "$@"
            ;;
        run)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定任务名称"
                exit 1
            fi
            run_task "$@"
            ;;
        schedule)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定任务名称"
                exit 1
            fi
            schedule_task "$@"
            ;;
        show)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定任务名称"
                exit 1
            fi
            show_task "$@"
            ;;
        logs)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定任务名称"
                exit 1
            fi
            show_logs "$@"
            ;;
        *)
            echo "❌ 错误: 未知动作 '$action'"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
