#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$ApiKey = "",
    [string]$Only = "",
    [string]$Skip = "",
    [switch]$DryRun,
    [switch]$Uninstall,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    @"
Usage: install.ps1 [options]

天启至数一键安装:把 MCP 配置写入本机 AI 客户端。

Options:
  -ApiKey <KEY>        直接指定 API Key(也可用 TIANQI_API_KEY 环境变量)
  -Only <a,b>          只安装指定客户端(claude,cursor,cline,continue)
  -Skip <a,b>          跳过指定客户端
  -DryRun              打印将执行的操作,不写盘
  -Uninstall           从所有配置中移除 tianqi 条目
  -Help                显示帮助

环境变量:
  TIANQI_API_KEY       预先提供 API Key,跳过交互提示
"@ | Write-Host
}

if ($Help) { Show-Usage; exit 0 }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "lib\clients.ps1")

# ---------------- 校验 --Only / --Skip ----------------
function Test-ClientList($flagName, $list) {
    if ([string]::IsNullOrEmpty($list)) { return }
    foreach ($id in $list.Split(",")) {
        if ($ClientIds -notcontains $id) {
            Write-Host "$flagName 含非法值: $id(合法:$($ClientIds -join ','))" -ForegroundColor Red
            exit 4
        }
    }
}

Test-ClientList "-Only" $Only
Test-ClientList "-Skip" $Skip

# ---------------- Banner ----------------
@"

╭──────────────────────────────────────────╮
│  天启至数 · 一键安装                      │
╰──────────────────────────────────────────╯
"@ | Write-Host

# ---------------- API Key ----------------
function Get-ApiKey {
    if ($ApiKey) { return $ApiKey }
    if ($env:TIANQI_API_KEY) { return $env:TIANQI_API_KEY }
    if ($env:TIANQI_NONINTERACTIVE -eq "1") {
        Write-Host "未提供 API Key。请用 -ApiKey 或 TIANQI_API_KEY 环境变量。" -ForegroundColor Red
        exit 2
    }
    # 交互式输入(SecureString)
    $secure = Read-Host -AsSecureString "请输入 API Key (https://tianqis.com/signup)"
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
    if ([string]::IsNullOrEmpty($plain)) {
        Write-Host "API Key 为空" -ForegroundColor Red
        exit 2
    }
    return $plain
}

$apiKey = Get-ApiKey

# ---------------- Key 脱敏 ----------------
function Get-MaskedKey($k) {
    if ($k.Length -le 10) { return ("*" * $k.Length) }
    return "$($k.Substring(0,6))…$($k.Substring($k.Length-4,4))"
}

# ---------------- JSON 合并 (内联) ----------------
function Merge-DictConfig($obj, $isUninstall, $key, $url) {
    if (-not $obj.PSObject.Properties['mcpServers'] -or $null -eq $obj.mcpServers) {
        $obj | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    if ($isUninstall) {
        if ($obj.mcpServers.PSObject.Properties['tianqi']) {
            $obj.mcpServers.PSObject.Properties.Remove('tianqi')
        }
    } else {
        $tianqi = [PSCustomObject]@{
            url = $url
            headers = [PSCustomObject]@{ Authorization = "Bearer $key" }
        }
        $obj.mcpServers | Add-Member -NotePropertyName tianqi -NotePropertyValue $tianqi -Force
    }
    return $obj
}

function Merge-ArrayConfig($obj, $isUninstall, $key, $url) {
    if (-not $obj.PSObject.Properties['experimental'] -or $null -eq $obj.experimental) {
        $obj | Add-Member -NotePropertyName experimental -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    if (-not $obj.experimental.PSObject.Properties['modelContextProtocolServers'] -or `
        $null -eq $obj.experimental.modelContextProtocolServers) {
        $obj.experimental | Add-Member -NotePropertyName modelContextProtocolServers -NotePropertyValue @() -Force
    }
    $arr = @($obj.experimental.modelContextProtocolServers | Where-Object { $_.name -ne "tianqi" })
    if (-not $isUninstall) {
        $entry = [PSCustomObject]@{
            name = "tianqi"
            transport = [PSCustomObject]@{
                type = "sse"
                url = $url
                headers = [PSCustomObject]@{ Authorization = "Bearer $key" }
            }
        }
        $arr = $arr + $entry
    }
    $obj.experimental.modelContextProtocolServers = $arr
    return $obj
}

# ---------------- Install one client ----------------
$mcpUrl = "https://mcp.tianqis.com/sse"

function Install-OneClient($id) {
    $label   = $ClientLabel[$id]
    $path    = $ClientPath[$id]
    $detect  = $ClientDetect[$id]
    $adapter = $ClientAdapter[$id]

    if (-not (Test-Path $detect -PathType Container)) {
        Write-Host "  [跳过] $label`t未检测到"
        return "skip"
    }

    $existing = [PSCustomObject]@{}
    $hadFile = $false
    if (Test-Path $path -PathType Leaf) {
        $hadFile = $true
        try {
            $existing = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($null -eq $existing) { $existing = [PSCustomObject]@{} }
        } catch {
            Write-Host "  [失败] $label`tJSON 损坏: $path" -ForegroundColor Red
            return "fail"
        }
        if (-not $DryRun) {
            $ts = Get-Date -Format "yyyyMMdd-HHmmss"
            $bk = "$path.tianqi.bak.$ts.$PID"
            Copy-Item $path $bk
        }
    }

    if ($adapter -eq "dict") {
        $merged = Merge-DictConfig $existing $Uninstall.IsPresent $apiKey $mcpUrl
    } else {
        $merged = Merge-ArrayConfig $existing $Uninstall.IsPresent $apiKey $mcpUrl
    }

    if ($DryRun) {
        Write-Host "  [dry-run] $label`t将写入 $path"
        return "ok"
    }

    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $json = $merged | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($path, $json + "`n", [System.Text.UTF8Encoding]::new($false))

    if ($hadFile) {
        Write-Host "  [完成] $label`t已合并"
    } else {
        Write-Host "  [完成] $label`t已新建"
    }
    return "ok"
}

# ---------------- Should install (filter) ----------------
function Test-ShouldInstall($id) {
    if ($Only) {
        if ($Only.Split(",") -notcontains $id) { return $false }
    }
    if ($Skip) {
        if ($Skip.Split(",") -contains $id) { return $false }
    }
    return $true
}

# ---------------- 主循环 ----------------
Write-Host ""
Write-Host "正在检测已安装的 AI 客户端..."
Write-Host ""

$installed = 0; $skipped = 0; $failed = 0
foreach ($id in $ClientIds) {
    if (-not (Test-ShouldInstall $id)) { continue }
    $result = Install-OneClient $id
    switch ($result) {
        "ok"   { $installed++ }
        "skip" { $skipped++ }
        "fail" { $failed++ }
    }
}

Write-Host ""

if ($installed -eq 0 -and $skipped -gt 0 -and $failed -eq 0) {
    Write-Host "未检测到任何已安装的 AI 客户端。请先安装 Claude Desktop / Cursor / Cline 或 Continue 后再试。" -ForegroundColor Red
    exit 5
}

Write-Host "完成!配置 $installed 个,跳过 $skipped 个,失败 $failed 个。"

if ($installed -gt 0) {
    $masked = Get-MaskedKey $apiKey
    Write-Host ""
    Write-Host "以下客户端需要手动添加 MCP 配置:"
    Write-Host ""
    Write-Host "  [Claude Code CLI]"
    Write-Host "  claude mcp add tianqi $mcpUrl ``"
    Write-Host "    --header `"Authorization: Bearer $masked`""
    Write-Host ""
    Write-Host "  [千问 / Kimi / DeepSeek 等 Web 端]"
    Write-Host "  URL:  $mcpUrl"
    Write-Host "  Auth: Bearer $masked"
    Write-Host ""
    Write-Host "详细配置:https://data.tianqis.com/ycl/docs"
}

if ($failed -gt 0) { exit 1 }
