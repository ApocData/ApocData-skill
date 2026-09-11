# 4 个文件型 AI 客户端的路径与适配器类型(Windows)
# 被 install.ps1 dot-source。导出:
#   $ClientIds                客户端 id 列表(顺序固定)
#   $ClientLabel[id]          人类可读名
#   $ClientAdapter[id]        dict | array
#   $ClientPath[id]           配置文件路径
#   $ClientDetect[id]         判定目录(存在 = 客户端已安装)

$ClientIds = @("claude","cursor","cline","continue")

$ClientLabel = @{
    claude   = "Claude Desktop"
    cursor   = "Cursor"
    cline    = "Cline (VSCode)"
    continue = "Continue"
}

$ClientAdapter = @{
    claude   = "dict"
    cursor   = "dict"
    cline    = "dict"
    continue = "array"
}

$appData     = $env:APPDATA
$userProfile = $env:USERPROFILE

# 测试模式覆盖:TIANQI_TEST_OS=Darwin/Linux 用 HOME 替代 Windows 环境
if ($env:TIANQI_TEST_OS -eq "Darwin") {
    $home_ = $env:HOME
    $ClientPath = @{
        claude   = "$home_/Library/Application Support/Claude/claude_desktop_config.json"
        cursor   = "$home_/.cursor/mcp.json"
        cline    = "$home_/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
        continue = "$home_/.continue/config.json"
    }
    $ClientDetect = @{
        claude   = "$home_/Library/Application Support/Claude"
        cursor   = "$home_/.cursor"
        cline    = "$home_/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev"
        continue = "$home_/.continue"
    }
} elseif ($env:TIANQI_TEST_OS -eq "Linux") {
    $home_ = $env:HOME
    $ClientPath = @{
        claude   = "$home_/.config/Claude/claude_desktop_config.json"
        cursor   = "$home_/.cursor/mcp.json"
        cline    = "$home_/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
        continue = "$home_/.continue/config.json"
    }
    $ClientDetect = @{
        claude   = "$home_/.config/Claude"
        cursor   = "$home_/.cursor"
        cline    = "$home_/.config/Code/User/globalStorage/saoudrizwan.claude-dev"
        continue = "$home_/.continue"
    }
} else {
    # 正常 Windows 路径
    $ClientPath = @{
        claude   = Join-Path $appData "Claude\claude_desktop_config.json"
        cursor   = Join-Path $userProfile ".cursor\mcp.json"
        cline    = Join-Path $appData "Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json"
        continue = Join-Path $userProfile ".continue\config.json"
    }
    $ClientDetect = @{
        claude   = Join-Path $appData "Claude"
        cursor   = Join-Path $userProfile ".cursor"
        cline    = Join-Path $appData "Code\User\globalStorage\saoudrizwan.claude-dev"
        continue = Join-Path $userProfile ".continue"
    }
}
