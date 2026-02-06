#!/bin/bash

# 自动化快速回复生成器
# 用于快速生成常见场景的回复模板

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../memory/auto-replies"

# 确保数据目录存在
mkdir -p "$DATA_DIR"

# 显示用法
show_usage() {
    cat << 'EOF'
快速回复生成器

用法:
    auto-reply.sh <action> [options]

动作:
    list          列出所有快速回复
    create        创建新的快速回复
    show <name>   显示特定回复
    delete <name> 删除回复
    search <query> 搜索回复

创建选项:
    -t, --title <title>      回复标题
    -k, --keywords <keywords> 关键词（逗号分隔）
    -c, --content <content>  回复内容
    -f, --file <file>       从文件读取内容

示例:
    auto-reply.sh create -t "项目完成" -k "完成,done" -c "项目已成功完成！"
    auto-reply.sh list
    auto-reply.sh show "项目完成"
    auto-reply.sh search "完成"
EOF
}

# 列出所有回复
list_replies() {
    echo "📋 快速回复列表"
    echo "=================="
    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            title=$(head -1 "$file" | sed 's/^# //')
            keywords=$(grep -E "^关键词:" "$file" | cut -d':' -f2- | xargs)
            printf "  %-30s %s\n" "$title" "[$keywords]"
        fi
    done
}

# 创建新回复
create_reply() {
    local title=""
    local keywords=""
    local content=""
    local content_file=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--title)
                title="$2"
                shift 2
                ;;
            -k|--keywords)
                keywords="$2"
                shift 2
                ;;
            -c|--content)
                content="$2"
                shift 2
                ;;
            -f|--file)
                content_file="$2"
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$title" ]; then
        echo "❌ 错误: 标题不能为空"
        exit 1
    fi

    if [ -z "$keywords" ]; then
        echo "❌ 错误: 关键词不能为空"
        exit 1
    fi

    if [ -z "$content" ] && [ -z "$content_file" ]; then
        echo "❌ 错误: 必须提供内容或内容文件"
        exit 1
    fi

    # 如果指定了文件，读取内容
    if [ -n "$content_file" ]; then
        if [ ! -f "$content_file" ]; then
            echo "❌ 错误: 文件不存在: $content_file"
            exit 1
        fi
        content=$(cat "$content_file")
    fi

    # 创建安全文件名
    safe_name=$(echo "$title" | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-')
    output_file="$DATA_DIR/${safe_name}.md"

    # 检查是否已存在
    if [ -f "$output_file" ]; then
        read -p "⚠️  回复已存在，是否覆盖？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "已取消"
            exit 0
        fi
    fi

    # 创建回复文件
    cat > "$output_file" << EOF
# ${title}
关键词: ${keywords}
创建时间: $(date '+%Y-%m-%d %H:%M:%S')

${content}
EOF

    echo "✅ 快速回复已创建: $output_file"
}

# 显示特定回复
show_reply() {
    local name="$1"
    local safe_name=$(echo "$name" | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-')
    local file="$DATA_DIR/${safe_name}.md"

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 未找到回复: $name"
        exit 1
    fi

    cat "$file"
}

# 删除回复
delete_reply() {
    local name="$1"
    local safe_name=$(echo "$name" | tr ' ' '_' | tr -cd 'a-zA-Z0-9_-')
    local file="$DATA_DIR/${safe_name}.md"

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 未找到回复: $name"
        exit 1
    fi

    read -p "⚠️  确定要删除回复 '$name'？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$file"
        echo "✅ 回复已删除"
    else
        echo "已取消"
    fi
}

# 搜索回复
search_replies() {
    local query="$1"
    echo "🔍 搜索 '$query'"
    echo "================="

    found=0
    for file in "$DATA_DIR"/*.md; do
        if [ -f "$file" ]; then
            # 搜索标题、关键词和内容
            if grep -qi "$query" "$file"; then
                title=$(head -1 "$file" | sed 's/^# //')
                keywords=$(grep -E "^关键词:" "$file" | cut -d':' -f2- | xargs)
                printf "✅ %-30s %s\n" "$title" "[$keywords]"
                ((found++))
            fi
        fi
    done

    if [ $found -eq 0 ]; then
        echo "未找到匹配的回复"
    else
        echo ""
        echo "找到 $found 个匹配的回复"
    fi
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
            list_replies
            ;;
        create)
            create_reply "$@"
            ;;
        show)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定回复名称"
                exit 1
            fi
            show_reply "$@"
            ;;
        delete)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定回复名称"
                exit 1
            fi
            delete_reply "$@"
            ;;
        search)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定搜索关键词"
                exit 1
            fi
            search_replies "$@"
            ;;
        *)
            echo "❌ 错误: 未知动作 '$action'"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
