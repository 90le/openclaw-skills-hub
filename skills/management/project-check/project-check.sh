#!/bin/bash
# 项目状态检查工具
# 快速检查所有项目的状态、进度、待办事项

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../memory/projects"

# 确保数据目录存在
mkdir -p "$DATA_DIR"

# 显示用法
show_usage() {
    cat << 'EOF'
项目状态检查工具

用法:
    project-check.sh <action> [options]

动作:
    list          列出所有项目
    add           添加新项目
    update         更新项目状态
    status        显示项目详情
    search        搜索项目
    report        生成项目报告

添加/更新选项:
    -n, --name <name>          项目名称
    -d, --desc <description>   项目描述
    -s, --status <status>      项目状态（planning, active, paused, completed, archived）
    -p, --priority <priority>   优先级（high, medium, low）
    -t, --tags <tags>         标签（逗号分隔）
    -r, --progress <progress>  进度（0-100）
    --notes <notes>            备注

示例:
    project-check.sh list
    project-check.sh add -n "网站开发" -s "active" -p "high"
    project-check.sh update -n "网站开发" -s "completed"
    project-check.sh status "网站开发"
    project-check.sh report
EOF
}

# 项目文件名生成
get_project_file() {
    local name="$1"
    echo "$DATA_DIR/$(echo "$name" | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-').md"
}

# 列出所有项目
list_projects() {
    echo "📋 项目列表"
    echo "==========="

    if [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
        echo "还没有项目"
        return
    fi

    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            name=$(grep -E "^项目名称:" "$file" | cut -d':' -f2- | xargs)
            status=$(grep -E "^状态:" "$file" | cut -d':' -f2- | xargs)
            priority=$(grep -E "^优先级:" "$file" | cut -d':' -f2- | xargs)
            progress=$(grep -E "^进度:" "$file" | cut -d':' -f2- | xargs | tr -d '%')
            printf "  %-30s %-12s %-10s %s%%\n" "$name" "$status" "$priority" "$progress"
        fi
    done
}

# 添加新项目
add_project() {
    local name=""
    local desc=""
    local status="planning"
    local priority="medium"
    local tags=""
    local progress=0
    local notes=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -d|--desc)
                desc="$2"
                shift 2
                ;;
            -s|--status)
                status="$2"
                shift 2
                ;;
            -p|--priority)
                if [ "$1" = "--priority" ]; then
                    priority="$2"
                else
                    priority="$2"
                fi
                shift 2
                ;;
            -t|--tags)
                tags="$2"
                shift 2
                ;;
            -r|--progress)
                progress="$2"
                shift 2
                ;;
            --notes)
                notes="$2"
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$name" ]; then
        echo "❌ 错误: 项目名称不能为空"
        exit 1
    fi

    local file=$(get_project_file "$name")

    if [ -f "$file" ]; then
        echo "❌ 错误: 项目已存在"
        exit 1
    fi

    cat > "$file" << EOF
# 项目: ${name}
创建时间: $(date '+%Y-%m-%d %H:%M:%S')

项目名称: ${name}
描述: ${desc}
状态: ${status}
优先级: ${priority}
标签: ${tags}
进度: ${progress}%

最后更新: $(date '+%Y-%m-%d %H:%M:%S')

备注:
${notes}

## 待办事项
- [ ] 待办事项1
- [ ] 待办事项2

## 进度日志
EOF

    echo "✅ 项目已创建: $name"
}

# 更新项目
update_project() {
    local name=""
    local desc=""
    local status=""
    local priority=""
    local tags=""
    local progress=""
    local notes=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -d|--desc)
                desc="$2"
                shift 2
                ;;
            -s|--status)
                status="$2"
                shift 2
                ;;
            -p|--priority)
                if [ "$1" = "--priority" ]; then
                    priority="$2"
                else
                    priority="$2"
                fi
                shift 2
                ;;
            -t|--tags)
                tags="$2"
                shift 2
                ;;
            -r|--progress)
                progress="$2"
                shift 2
                ;;
            --notes)
                notes="$2"
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$name" ]; then
        echo "❌ 错误: 项目名称不能为空"
        exit 1
    fi

    local file=$(get_project_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 项目不存在"
        exit 1
    fi

    # 更新字段
    if [ -n "$status" ]; then
        sed -i '' "s/^状态:.*/状态: $status/" "$file"
    fi

    if [ -n "$priority" ]; then
        sed -i '' "s/^优先级:.*/优先级: $priority/" "$file"
    fi

    if [ -n "$tags" ]; then
        sed -i '' "s/^标签:.*/标签: $tags/" "$file"
    fi

    if [ -n "$progress" ]; then
        sed -i '' "s/^进度:.*/进度: $progress%/" "$file"
    fi

    if [ -n "$desc" ]; then
        sed -i '' "s/^描述:.*/描述: $desc/" "$file"
    fi

    if [ -n "$notes" ]; then
        sed -i '' "/^备注:$/,/^## 待办事项$/c\
备注:\
$notes\
\
## 待办事项" "$file"
    fi

    # 更新最后更新时间
    sed -i '' "s/^最后更新:.*/最后更新: $(date '+%Y-%m-%d %H:%M:%S')/" "$file"

    echo "✅ 项目已更新: $name"
}

# 显示项目详情
show_project() {
    local name="$1"
    local file=$(get_project_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 项目不存在"
        exit 1
    fi

    cat "$file"
}

# 搜索项目
search_projects() {
    local query="$1"
    echo "🔍 搜索 '$query'"
    echo "================="

    found=0
    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            if grep -qi "$query" "$file"; then
                name=$(grep -E "^项目名称:" "$file" | cut -d':' -f2- | xargs)
                status=$(grep -E "^状态:" "$file" | cut -d':' -f2- | xargs)
                progress=$(grep -E "^进度:" "$file" | cut -d':' -f2- | xargs | tr -d '%')
                printf "✅ %-30s %-12s %s%%\n" "$name" "$status" "$progress"
                ((found++))
            fi
        fi
    done

    if [ $found -eq 0 ]; then
        echo "未找到匹配的项目"
    else
        echo ""
        echo "找到 $found 个匹配的项目"
    fi
}

# 生成项目报告
generate_report() {
    echo "📊 项目报告"
    echo "==========="

    local total=0
    local active=0
    local completed=0
    local total_progress=0

    if [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
        echo "还没有项目"
        return
    fi

    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            ((total++))

            status=$(grep -E "^状态:" "$file" | cut -d':' -f2- | xargs)

            case "$status" in
                "active")
                    ((active++))
                    ;;
                "completed")
                    ((completed++))
                    ;;
            esac

            progress=$(grep -E "^进度:" "$file" | cut -d':' -f2- | xargs | tr -d '%')
            total_progress=$((total_progress + progress))
        fi
    done

    echo ""
    echo "项目总数: $total"
    echo "活跃项目: $active"
    echo "已完成: $completed"
    if [ $total -gt 0 ]; then
        echo "平均进度: $((total_progress / total))%"
    fi
    echo ""

    echo "按优先级分类:"
    echo "============="
    echo "高优先级项目:"
    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            name=$(grep -E "^项目名称:" "$file" | cut -d':' -f2- | xargs)
            priority=$(grep -E "^优先级:" "$file" | cut -d':' -f2- | xargs)
            status=$(grep -E "^状态:" "$file" | cut -d':' -f2- | xargs)
            if [ "$priority" = "high" ]; then
                printf "  - %-30s [%s]\n" "$name" "$status"
            fi
        fi
    done

    echo ""
    echo "中优先级项目:"
    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            name=$(grep -E "^项目名称:" "$file" | cut -d':' -f2- | xargs)
            priority=$(grep -E "^优先级:" "$file" | cut -d':' -f2- | xargs)
            status=$(grep -E "^状态:" "$file" | cut -d':' -f2- | xargs)
            if [ "$priority" = "medium" ]; then
                printf "  - %-30s [%s]\n" "$name" "$status"
            fi
        fi
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
            list_projects
            ;;
        add)
            add_project "$@"
            ;;
        update)
            update_project "$@"
            ;;
        status)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定项目名称"
                exit 1
            fi
            show_project "$@"
            ;;
        search)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定搜索关键词"
                exit 1
            fi
            search_projects "$@"
            ;;
        report)
            generate_report
            ;;
        *)
            echo "❌ 错误: 未知动作 '$action'"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
