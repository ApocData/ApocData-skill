#!/usr/bin/env bash
# 4 个文件型 AI 客户端的路径与 JSON adapter 类型。
# 被 install.sh source。导出:
#   CLIENT_IDS          空格分隔的客户端 ID 列表
#   client_path <id>    配置文件路径(函数)
#   client_detect <id>  "已安装"判定目录(函数)
#   client_adapter <id> dict | array(函数)
#   client_label <id>   人类可读名(函数)
# 兼容 bash 3.2(macOS 系统 bash),不使用 declare -A。

# OS 检测,允许 TIANQI_TEST_OS 覆盖
_OS="${TIANQI_TEST_OS:-$(uname -s)}"

# shellcheck disable=SC2034  # CLIENT_IDS is exported to callers that source this file
CLIENT_IDS="claude cursor cline continue"

# 标签(静态,不依赖 OS)
client_label() {
  case "$1" in
    claude)   echo "Claude Desktop" ;;
    cursor)   echo "Cursor" ;;
    cline)    echo "Cline (VSCode)" ;;
    continue) echo "Continue" ;;
    *) echo "Unknown" ;;
  esac
}

# Adapter 类型(静态)
client_adapter() {
  case "$1" in
    continue) echo "array" ;;
    *)        echo "dict"  ;;
  esac
}

case "$_OS" in
  Darwin)
    _CLIENT_PATH_claude="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    _CLIENT_DETECT_claude="$HOME/Library/Application Support/Claude"
    _CLIENT_PATH_cursor="$HOME/.cursor/mcp.json"
    _CLIENT_DETECT_cursor="$HOME/.cursor"
    _CLIENT_PATH_cline="$HOME/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
    _CLIENT_DETECT_cline="$HOME/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev"
    _CLIENT_PATH_continue="$HOME/.continue/config.json"
    _CLIENT_DETECT_continue="$HOME/.continue"
    ;;
  Linux)
    _CLIENT_PATH_claude="$HOME/.config/Claude/claude_desktop_config.json"
    _CLIENT_DETECT_claude="$HOME/.config/Claude"
    _CLIENT_PATH_cursor="$HOME/.cursor/mcp.json"
    _CLIENT_DETECT_cursor="$HOME/.cursor"
    _CLIENT_PATH_cline="$HOME/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
    _CLIENT_DETECT_cline="$HOME/.config/Code/User/globalStorage/saoudrizwan.claude-dev"
    _CLIENT_PATH_continue="$HOME/.continue/config.json"
    _CLIENT_DETECT_continue="$HOME/.continue"
    ;;
  *)
    echo "不支持的 OS: $_OS(install.sh 仅支持 Darwin/Linux,Windows 请用 install.ps1)" >&2
    # shellcheck disable=SC2317  # exit 1 is fallback for when the file is run directly (not sourced)
    return 1 2>/dev/null || exit 1
    ;;
esac

# 访问函数:通过变量名间接引用,兼容 bash 3.2
client_path() {
  local _var="_CLIENT_PATH_$1"
  eval "echo \"\${${_var}:-}\""
}

client_detect() {
  local _var="_CLIENT_DETECT_$1"
  eval "echo \"\${${_var}:-}\""
}
