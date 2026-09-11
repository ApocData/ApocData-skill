#!/usr/bin/env python3
"""JSON 合并器。

环境变量:
  TIANQI_API_KEY      Bearer key
  TIANQI_MERGE_MODE   dict | array | dict-remove | array-remove
  TIANQI_MCP_URL      可选,默认 https://mcp.tianqis.com/sse

stdin: 旧 JSON(允许空字符串 → 视为 {})
stdout: 新 JSON,2 空格缩进,UTF-8 无 BOM,文末单换行
退出码: 0=成功,1=旧 JSON 解析失败,2=参数错误
"""
import json
import os
import sys


def main() -> int:
    mode = os.environ.get("TIANQI_MERGE_MODE", "")
    api_key = os.environ.get("TIANQI_API_KEY", "")
    mcp_url = os.environ.get("TIANQI_MCP_URL", "https://mcp.tianqis.com/sse")

    if mode not in {"dict", "array", "dict-remove", "array-remove"}:
        print(f"unknown merge mode: {mode}", file=sys.stderr)
        return 2

    if mode in {"dict", "array"} and not api_key:
        print("TIANQI_API_KEY required for install mode", file=sys.stderr)
        return 2

    raw = sys.stdin.read().strip()
    try:
        data = json.loads(raw) if raw else {}
    except json.JSONDecodeError as e:
        print(f"invalid JSON in input: {e}", file=sys.stderr)
        return 1

    if not isinstance(data, dict):
        print("top-level JSON must be an object", file=sys.stderr)
        return 1

    if mode == "dict":
        servers = data.get("mcpServers") or {}
        data["mcpServers"] = servers
        servers["tianqi"] = {
            "url": mcp_url,
            "headers": {"Authorization": f"Bearer {api_key}"},
        }
    elif mode == "dict-remove":
        servers = data.get("mcpServers") or {}
        servers.pop("tianqi", None)
        if not servers and "mcpServers" in data:
            data.pop("mcpServers")
    elif mode == "array":
        exp = data.get("experimental") or {}
        data["experimental"] = exp
        arr = exp.get("modelContextProtocolServers") or []
        entry = {
            "name": "tianqi",
            "transport": {
                "type": "sse",
                "url": mcp_url,
                "headers": {"Authorization": f"Bearer {api_key}"},
            },
        }
        arr = [x for x in arr if not (isinstance(x, dict) and x.get("name") == "tianqi")]
        arr.append(entry)
        exp["modelContextProtocolServers"] = arr
    elif mode == "array-remove":
        exp = data.get("experimental") or {}
        arr = exp.get("modelContextProtocolServers") or []
        exp["modelContextProtocolServers"] = [
            x for x in arr if not (isinstance(x, dict) and x.get("name") == "tianqi")
        ]
        if not exp["modelContextProtocolServers"]:
            exp.pop("modelContextProtocolServers")
        if not exp and "experimental" in data:
            data.pop("experimental")

    sys.stdout.write(json.dumps(data, indent=2, ensure_ascii=False))
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
