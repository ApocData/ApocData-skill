#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034  # VERSION is script metadata, not used in logic
VERSION="0.1.0"

# ---------------- 参数解析 ----------------
ARG_API_KEY=""
ARG_ONLY=""
ARG_SKIP=""
ARG_DRY_RUN=0
ARG_UNINSTALL=0
ARG_PRINT_KEY=0    # 测试辅助,不出现在 --help 里
ARG_PRINT_PATHS=0  # 测试辅助,不出现在 --help 里

usage() {
  cat <<'EOF'
Usage: install.sh [options]

天启至数一键安装:把 MCP 配置写入本机 AI 客户端。

Options:
  --api-key <KEY>      直接指定 API Key(也可用 TIANQI_API_KEY 环境变量)
  --only <a,b>         只安装指定客户端(claude,cursor,cline,continue)
  --skip <a,b>         跳过指定客户端
  --dry-run            打印将执行的操作,不写盘
  --uninstall          从所有配置中移除 tianqi 条目
  -h, --help           显示帮助

环境变量:
  TIANQI_API_KEY       预先提供 API Key,跳过交互提示
  TIANQI_NONINTERACTIVE  设为 1 跳过 /dev/tty 交互(用于 CI/脚本)
EOF
}

# 取下一个 arg 的 value,并检查它存在且不是另一个 flag
require_value() {
  local flag="$1" next="${2-}"
  if [[ -z "$next" || "${next:0:1}" == "-" ]]; then
    echo "$flag 需要一个非 flag 参数值" >&2
    exit 4
  fi
  printf '%s' "$next"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-key) ARG_API_KEY="$(require_value "$1" "${2-}")"; shift 2 ;;
    --only) ARG_ONLY="$(require_value "$1" "${2-}")"; shift 2 ;;
    --skip) ARG_SKIP="$(require_value "$1" "${2-}")"; shift 2 ;;
    --dry-run) ARG_DRY_RUN=1; shift ;;
    --uninstall) ARG_UNINSTALL=1; shift ;;
    --print-key) ARG_PRINT_KEY=1; shift ;;
    --print-paths) ARG_PRINT_PATHS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage; exit 4 ;;
  esac
done

# ---------------- JSON 引擎检测(spec §6 -> 退出码 3)----------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "需要 python3 来解析/合并 JSON 配置。请先安装 python3(macOS 自带,Ubuntu/Debian 用 apt install python3)。" >&2
  exit 3
fi

# ---------------- API Key ----------------
get_api_key() {
  # 优先级:--api-key > TIANQI_API_KEY > /dev/tty
  if [[ -n "$ARG_API_KEY" ]]; then
    printf '%s' "$ARG_API_KEY"
    return 0
  fi
  if [[ -n "${TIANQI_API_KEY:-}" ]]; then
    printf '%s' "$TIANQI_API_KEY"
    return 0
  fi
  # 非交互逃生舱:测试或非 TTY 环境(同时无 /dev/tty)时直接退出
  if [[ "${TIANQI_NONINTERACTIVE:-0}" == "1" || ( ! -t 0 && ! -e /dev/tty ) ]]; then
    echo "未提供 API Key。请用 --api-key 或 TIANQI_API_KEY 环境变量。" >&2
    return 2
  fi
  # 交互式:从 /dev/tty 读取(兼容 curl|bash 管道安装)
  local key
  if [[ -e /dev/tty ]]; then
    printf "请输入 API Key (https://tianqis.com/signup): " > /dev/tty
    IFS= read -rs key < /dev/tty
    printf "\n" > /dev/tty
  else
    IFS= read -rs key
  fi
  if [[ -z "$key" ]]; then
    echo "API Key 为空" >&2
    return 2
  fi
  printf '%s' "$key"
}

# ---------------- 加载客户端注册表 ----------------
# 探测 lib/ 位置:本地优先,curl|bash 场景下从 GitHub Raw 拉
TIANQI_BASE_URL="${TIANQI_BASE_URL:-https://raw.githubusercontent.com/ApocData/ApocData-skill/main}"
SCRIPT_DIR_ABS="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || SCRIPT_DIR_ABS=""

if [[ -n "$SCRIPT_DIR_ABS" && -f "$SCRIPT_DIR_ABS/lib/clients.sh" ]]; then
  # 本地运行
  LIB_DIR="$SCRIPT_DIR_ABS/lib"
else
  # curl | bash 场景:lib/ 不在本地,从远端下载到临时目录
  LIB_DIR="$(mktemp -d)"
  trap 'rm -rf "$LIB_DIR"' EXIT
  for f in clients.sh json_merge.py; do
    if ! curl -fsSL "$TIANQI_BASE_URL/lib/$f" -o "$LIB_DIR/$f"; then
      echo "无法下载 $TIANQI_BASE_URL/lib/$f,请检查网络或手动下载完整安装包。" >&2
      exit 1
    fi
  done
fi

# shellcheck source=tianqi-installer/lib/clients.sh
source "$LIB_DIR/clients.sh"

# ---------------- 输出格式化 ----------------
print_banner() {
  cat <<'EOF'

╭──────────────────────────────────────────╮
│  天启至数 · 一键安装                      │
╰──────────────────────────────────────────╯
EOF
}

mask_key() {
  local k="$1"
  local len=${#k}
  if [[ $len -le 10 ]]; then
    local count_pad=$len
    printf '%s' "$(printf '%*s' "$count_pad" '' | tr ' ' '*')"
  else
    printf '%s…%s' "${k:0:6}" "${k: -4}"
  fi
}

# ---------------- 校验 --only / --skip ----------------
validate_client_list() {
  local flag="$1" list="$2"
  if [[ -z "$list" ]]; then return 0; fi
  local IFS=','
  for _id in $list; do
    case "$_id" in
      claude|cursor|cline|continue) ;;
      *) echo "$flag 含非法值: $_id(合法:claude,cursor,cline,continue)" >&2; exit 4 ;;
    esac
  done
}

validate_client_list "--only" "$ARG_ONLY"
validate_client_list "--skip" "$ARG_SKIP"

if [[ $ARG_PRINT_PATHS -eq 1 ]]; then
  for id in $CLIENT_IDS; do
    echo "$id=$(client_path "$id")"
    echo "$id.detect=$(client_detect "$id")"
    echo "$id.adapter=$(client_adapter "$id")"
  done
  exit 0
fi

print_banner
API_KEY="$(get_api_key)" || exit $?

if [[ $ARG_PRINT_KEY -eq 1 ]]; then
  echo "$API_KEY"
  exit 0
fi

# ---------------- 核心函数 ----------------
JSON_MERGER="$LIB_DIR/json_merge.py"

# install_one_client <id>  ->  打印一行结果,返回 0/非 0/10
install_one_client() {
  local id="$1"
  local label path detect adapter
  label="$(client_label "$id")"
  path="$(client_path "$id")"
  detect="$(client_detect "$id")"
  adapter="$(client_adapter "$id")"

  if [[ ! -d "$detect" ]]; then
    printf '  ⏭️  %s\t未检测到 %s\n' "$label" "$label"
    return 10  # 跳过
  fi

  local mode="$adapter"
  if [[ $ARG_UNINSTALL -eq 1 ]]; then mode="${adapter}-remove"; fi

  local existing="{}"
  local had_file=0
  if [[ -f "$path" ]]; then
    had_file=1
    # 用参数传入,避免 $path 中的空格/引号注入
    if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$path" 2>/dev/null; then
      printf '  ❌ %s\tJSON 损坏: %s\n' "$label" "$path"
      return 1
    fi
    if [[ $ARG_DRY_RUN -ne 1 ]]; then
      cp "$path" "${path}.tianqi.bak.$(date +%Y%m%d-%H%M%S).$$"
    fi
    existing="$(cat "$path")"
  fi

  local merged
  if ! merged="$(printf '%s' "$existing" \
      | TIANQI_API_KEY="$API_KEY" TIANQI_MERGE_MODE="$mode" python3 "$JSON_MERGER")"; then
    printf '  ❌ %s\tJSON 合并失败\n' "$label"
    return 1
  fi

  if [[ $ARG_DRY_RUN -eq 1 ]]; then
    printf '  🟡 %s\t[dry-run] 将写入 %s\n' "$label" "$path"
    return 0
  fi

  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$merged" > "$path"
  if [[ $had_file -eq 1 ]]; then
    printf '  ✅ %s\t已合并\n' "$label"
  else
    printf '  ✅ %s\t已新建\n' "$label"
  fi
}

# ---------------- 客户端筛选 ----------------
should_install_client() {
  local id="$1"
  if [[ -n "$ARG_ONLY" ]]; then
    [[ ",$ARG_ONLY," == *",$id,"* ]] || return 1
  fi
  if [[ -n "$ARG_SKIP" ]]; then
    [[ ",$ARG_SKIP," == *",$id,"* ]] && return 1
  fi
  return 0
}

# ---------------- 主循环 ----------------
echo ""
echo "🔍 正在检测已安装的 AI 客户端..."
echo ""
INSTALLED=0; SKIPPED=0; FAILED=0
for id in $CLIENT_IDS; do
  if ! should_install_client "$id"; then continue; fi
  if install_one_client "$id"; then
    INSTALLED=$((INSTALLED+1))
  else
    rc=$?
    if [[ $rc -eq 10 ]]; then SKIPPED=$((SKIPPED+1)); else FAILED=$((FAILED+1)); fi
  fi
done

echo ""

if [[ $INSTALLED -eq 0 && $SKIPPED -gt 0 && $FAILED -eq 0 ]]; then
  echo "❌ 未检测到任何已安装的 AI 客户端。请先安装 Claude Desktop / Cursor / Cline 或 Continue 后再试。"
  exit 5
fi

echo "🎉 完成!配置 $INSTALLED 个,跳过 $SKIPPED 个,失败 $FAILED 个。"

if [[ $INSTALLED -gt 0 ]]; then
  masked_key="$(mask_key "$API_KEY")"
  echo ""
  echo "💡 以下客户端需要手动添加 MCP 配置:"
  echo ""
  echo "  【Claude Code CLI】"
  echo "  claude mcp add tianqi https://mcp.tianqis.com/sse \\"
  echo "    --header \"Authorization: Bearer $masked_key\""
  echo ""
  echo "  【千问 / Kimi / DeepSeek 等 Web 端】"
  echo "  URL:  https://mcp.tianqis.com/sse"
  echo "  Auth: Bearer $masked_key"
  echo ""
  echo "详细配置:https://data.tianqis.com/ycl/docs"
fi

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
