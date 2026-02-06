#!/bin/bash
# 播客/音频内容自动总结工具
# 使用 Whisper 转录 + summarize 总结

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../memory/podcast-summaries"
LOG_DIR="$SCRIPT_DIR/../memory/podcast-logs"

# 确保目录存在
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

# 显示用法
show_usage() {
    cat << 'EOF'
播客/音频内容自动总结工具

用法:
    podcast-summarizer.sh <action> [options]

动作:
    transcribe       转录音频文件
    summarize        总结文本内容
    process          完整流程（转录+总结）
    list             列出所有摘要
    show             显示摘要详情

转录选项:
    -i, --input <file>         音频文件路径
    -o, --output <name>        输出名称（默认：时间戳）

总结选项:
    -i, --input <text>         文本内容或文件路径
    -o, --output <name>        输出名称

完整流程选项:
    -i, --input <file>         音频文件路径
    -o, --output <name>        输出名称

示例:
    podcast-summarizer.sh transcribe -i podcast.mp3 -o episode1
    podcast-summarizer.sh summarize -i transcript.txt -o episode1
    podcast-summarizer.sh process -i podcast.mp3 -o episode1
    podcast-summarizer.sh list
EOF
}

# 获取输出文件路径
get_output_file() {
    local name="$1"
    echo "$OUTPUT_DIR/${name}.md"
}

# 获取日志文件路径
get_log_file() {
    local name="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    echo "$LOG_DIR/${name}_${timestamp}.log"
}

# 转录音频
transcribe_audio() {
    local input=""
    local output=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                input="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$input" ]; then
        echo "❌ 错误: 请指定输入音频文件"
        exit 1
    fi

    if [ ! -f "$input" ]; then
        echo "❌ 错误: 文件不存在: $input"
        exit 1
    fi

    if [ -z "$output" ]; then
        output="transcript_$(date '+%Y%m%d_%H%M%S')"
    fi

    local output_file="$OUTPUT_DIR/${output}_transcript.txt"
    local log_file=$(get_log_file "$output")

    echo "🎧 转录音频: $input"
    echo "📝 输出文件: $output_file"
    echo "📋 日志文件: $log_file"
    echo ""

    # 检查 Whisper 技能
    if [ ! -d "/opt/homebrew/lib/node_modules/@qingchencloud/openclaw-zh/skills/openai-whisper" ]; then
        echo "❌ 错误: Whisper 技能未安装"
        exit 1
    fi

    # 读取 Whisper SKILL.md
    local skill_file="/opt/homebrew/lib/node_modules/@qingchencloud/openclaw-zh/skills/openai-whisper/SKILL.md"
    if [ -f "$skill_file" ]; then
        echo "📖 Whisper 技能路径: $skill_file"
    fi

    # 执行转录（占位符 - 实际需要根据 Whisper 技能的具体使用方式）
    echo "⚠️  转录功能需要 Whisper CLI 配置"
    echo "🔧 请参考 Whisper SKILL.md 进行配置"

    # 创建转录文件占位符
    cat > "$output_file" << EOF
# 转录文件: ${output}
# 源文件: ${input}
# 创建时间: $(date '+%Y-%m-%d %H:%M:%S')

转录内容待生成...

（此处将放置 Whisper 转录的文本）
EOF

    echo ""
    echo "✅ 转录文件已创建: $output_file"
    echo "⚠️  实际转录内容需要手动配置 Whisper"
}

# 总结文本
summarize_text() {
    local input=""
    local output=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                input="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$input" ]; then
        echo "❌ 错误: 请指定输入文本或文件"
        exit 1
    fi

    # 判断是文件还是直接文本
    local text=""
    if [ -f "$input" ]; then
        text=$(cat "$input")
    else
        text="$input"
    fi

    if [ -z "$output" ]; then
        output="summary_$(date '+%Y%m%d_%H%M%S')"
    fi

    local output_file=$(get_output_file "$output")

    echo "📝 总结内容"
    echo "📄 输出文件: $output_file"
    echo ""

    # 检查 summarize 技能
    if [ ! -d "/opt/homebrew/lib/node_modules/@qingchencloud/openclaw-zh/skills/summarize" ]; then
        echo "❌ 错误: Summarize 技能未安装"
        exit 1
    fi

    # 创建摘要（占位符 - 实际需要根据 summarize 技能的具体使用方式）
    cat > "$output_file" << EOF
# 摘要: ${output}
# 创建时间: $(date '+%Y-%m-%d %H:%M:%S')

## 内容概述
（此处将放置总结内容）

## 原文长度
$(echo "$text" | wc -c) 字符

## 关键点
- 关键点1
- 关键点2
- 关键点3

## 原文（部分）
\`\`\`
$(echo "$text" | head -c 500)...
\`\`\`
EOF

    echo ""
    echo "✅ 摘要已创建: $output_file"
    echo "⚠️  实际总结需要手动配置 Summarize 技能"
}

# 完整流程
process_audio() {
    local input=""
    local output=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                input="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -z "$input" ]; then
        echo "❌ 错误: 请指定输入音频文件"
        exit 1
    fi

    if [ -z "$output" ]; then
        output="podcast_$(date '+%Y%m%d_%H%M%S')"
    fi

    echo "🎙️  完整流程：转录 + 总结"
    echo "============================"

    # 步骤1：转录
    echo ""
    echo "步骤 1/2: 转录音频"
    transcribe_audio -i "$input" -o "${output}"

    # 步骤2：总结
    echo ""
    echo "步骤 2/2: 总结内容"
    local transcript_file="$OUTPUT_DIR/${output}_transcript.txt"
    if [ -f "$transcript_file" ]; then
        summarize_text -i "$transcript_file" -o "$output"
    else
        echo "⚠️  转录文件不存在，跳过总结"
    fi

    echo ""
    echo "✅ 完整流程完成"
}

# 列出所有摘要
list_summaries() {
    echo "📋 播客摘要列表"
    echo "================"

    if [ -z "$(ls -A "$OUTPUT_DIR" 2>/dev/null)" ]; then
        echo "还没有摘要"
        return
    fi

    for file in "$OUTPUT_DIR"/*.md; do
        if [ -f "$file" ]; then
            basename=$(basename "$file" .md)
            created=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file")
            size=$(wc -c < "$file")
            printf "  %-30s %s  (%d bytes)\n" "$basename" "$created" "$size"
        fi
    done
}

# 显示摘要详情
show_summary() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ 错误: 请指定摘要名称"
        exit 1
    fi

    local file=$(get_output_file "$name")

    if [ ! -f "$file" ]; then
        echo "❌ 错误: 摘要不存在"
        exit 1
    fi

    cat "$file"
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
        transcribe)
            transcribe_audio "$@"
            ;;
        summarize)
            summarize_text "$@"
            ;;
        process)
            process_audio "$@"
            ;;
        list)
            list_summaries
            ;;
        show)
            if [ $# -eq 0 ]; then
                echo "❌ 错误: 请指定摘要名称"
                exit 1
            fi
            show_summary "$@"
            ;;
        *)
            echo "❌ 错误: 未知动作 '$action'"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
