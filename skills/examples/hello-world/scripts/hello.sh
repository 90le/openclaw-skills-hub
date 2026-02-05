#!/bin/bash
#
# Hello World 示例脚本
#
# 这是一个简单的示例，展示 OpenClaw 技能脚本的基本结构

set -e  # 遇到错误立即退出

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[32m'
COLOR_BLUE='\033[34m'
COLOR_YELLOW='\033[33m'

# 日志函数
log_info() {
    echo -e "${COLOR_BLUE}ℹ${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}✅${COLOR_RESET} $*"
}

# 打印使用说明
usage() {
    cat << EOF
使用方法: $(basename "$0") [消息]

参数:
    消息    要打印的消息（可选，默认：Hello World!）

示例:
    $(basename "$0")
    $(basename "$0") "你好，世界！"

EOF
}

# 主函数
main() {
    local message="${1:-Hello World!}"

    # 打印 Hello World 消息
    echo ""
    log_success "$message"
    echo ""
}

# 解析参数
case "${1:-}" in
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
