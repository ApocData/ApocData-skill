# 天启至数 Apocdata — A股数据服务

> ## 让 AI 读懂 A 股公告
>
> **为 AI 而生的 A 股公告与基本面数据库 · 解析过 · 结构化 · 可溯源**

> 全市场公告解析为结构化数据：
> AI 摘要 · 类型 · 重要性 · 情感倾向，条条可溯源；
> 并覆盖行情、财务、资金流、龙虎榜、宏观等 45+ 数据接口。
> 免费体验额度开箱即用，注册解锁更高额度与更多能力。
> 已上架 WorkBuddy / skills.sh / LobeHub 等主流技能商店，
> 兼容 WorkBuddy、Codex、Hermes、DeepSeek、Kimi、千问、智谱清言
> 及任何支持工具调用的 AI Agent。

本仓库提供的 [`SKILL.md`](./SKILL.md) 是一份可直接装入 AI Agent 的能力卡片，
让大模型无需任何 SDK，即可查询 A 股市场数据并完成投研分析。

<p align="center">
  <a href="./README.md">English</a> |
  <b>简体中文</b>
</p>


<p align="center">
  <img src="https://img.shields.io/badge/endpoints-45-green" alt="45 endpoints"/>
  <img src="https://img.shields.io/badge/MCP-46_tools-blue" alt="MCP 46 tools"/>
  <img src="https://img.shields.io/badge/free_tier-available-brightgreen" alt="免费体验额度"/>
  <img src="https://img.shields.io/badge/license-Apache_2.0-blue" alt="License"/>
</p>

---

## 10 秒体验

复制粘贴即可运行，无需任何配置：

```bash
curl -s "https://www.apocdata.com/api/blade-dataplatform/open/data/quote?symbol=600519"
```

<details>
<summary>点击展开返回示例</summary>

```json
{
  "code": 200, "success": true,
  "data": {
    "symbol": "600519", "name": "贵州茅台",
    "close": 1528.00, "pct_chg": -0.52,
    "volume": 2856321, "delayed_minutes": 15
  }
}
```

*实际返回字段更丰富，以上为简化示例。*
</details>

---

## 公告解析 —— 从 PDF 到结构化数据

传统数据源提供公告原文，需自行阅读与解析；天启至数 Apocdata 输出解析后的结构化数据，AI 可直接使用。

每份公告包含：

- **AI 摘要**（`summary`）—— 核心事项提炼，无需通读全文
- **类型分类**（`category`）—— 业绩、分红、回购、增持、减持、诉讼等，支持程序化筛选
- **重要性分级**（`importance`）—— 快速定位需重点关注的公告
- **情感倾向**（`sentiment`）—— 利好、利空、中性，辅助判断影响方向
- **原始链接**（`url`）—— 每条结论均可回溯至公告原文

同时返回：`title`、`ann_date`、`publish_time`、`keywords`、`source`，
以及 `content`（Markdown 全文，需 `includeContent=true`）。

覆盖全市场公告，含沪深港通标的、ST 及退市风险类证券。

---

## 为什么选择天启至数 Apocdata

| | **天启至数 Apocdata** | 数据源A | 数据源B | 数据源C |
|---|---|---|---|---|
| 公告解析 | **结构化 + AI 摘要 + 情感倾向** | 原始文本 | 原始文本 | 原始文本 |
| 接入门槛 | **免费体验额度，无需注册** | 需付费 token | 需 Python 环境 | 需申请审批 |
| 配置步骤 | **0 步** | 3+ 步（注册→token→配置） | 2+ 步（pip+依赖） | 人工审核 |
| AI Agent 原生 | **Skill + MCP** | 旧版插件 | 不支持 | 不支持 |
| curl 直调 | **支持** | 需 SDK | 需 SDK | 需 SDK |
| A 股接口数 | **45** | 100+（付费墙） | 100+（免费） | 200+（付费） |
| MCP 支持 | **46 个工具** | 无 | 无 | 无 |

> *对比基于 2026-08 公开信息与实测。*

---


## 核心能力

- **公告解析**：全市场公告经 AI 解析，输出结构化字段
  （`title` / `category` / `importance` / `ann_date` / `summary` / `sentiment` / `url`），
  可直接用于推理，并可溯源至原文（市面主流数据源多以原始文本提供公告）
- **全维度覆盖**：行情、财务、估值、资金流、涨停复盘、龙虎榜、板块概念、
  可转债、宏观指标、交易日历等 11 大类 45+ 接口，口径统一
- **多形态接入**：Skill 技能包（一键安装）、MCP 服务器（46 工具）、
  标准 HTTP 接口（curl 直调），覆盖所有主流 AI 生态
- **可溯源**：每一条数据可回溯至原始公告，AI 结论有据可查

---

## AI 使用场景

- 「贵州茅台最近的业绩快报有哪些重点？」→ 结构化抽取业绩关键点，可溯源至原始公告
- 「帮我分析 688017 的估值水平，和同行业相比如何？」→ 聚合 PE/PB/市值 + 财务指标 + 近 30 日走势
- 「最近 30 天有哪些 ST 股票发布了重大公告？」→ 按风险等级排序，每条带 AI 摘要与原文链接
- 「北向资金最近重点流入了哪些行业？」→ 沪深港通 + 行业资金流，自动汇总资金流入居前的行业

---

## 目录

- [公告解析](#公告解析--从-pdf-到结构化数据)
- [为什么选择天启至数 Apocdata](#为什么选择天启至数-apocdata)
- [核心能力](#核心能力)
- [AI 使用场景](#ai-使用场景)
- [产品简介](#产品简介)
- [数据服务平台](#数据服务平台)
- [安装](#安装)
- [基础用法](#基础用法)
- [接口能力总览](#接口能力总览)
- [综合分析示例](#综合分析示例)
- [版本与能力](#版本与能力)
- [注意事项与合规声明](#注意事项与合规声明)

---

## 产品简介

天启至数 Apocdata 是为 AI 而生的 A 股公告与基本面数据库：解析过 · 结构化 · 可溯源。
以公告解析为核心 —— 每份公告都变成 AI 可直接推理的结构化数据 —— 并围绕其提供
行情、财务、资金流、龙虎榜、量化因子、宏观经济等全维度数据接口，
面向 AI Agent、量化研究、投研内容与机构应用。

---

## 数据服务平台

**平台网址：** <https://www.apocdata.com>

数据服务平台是天启至数 Apocdata 的统一入口，提供：

- **免费体验额度开放接口** —— 本 Skill 对接的就是这一组接口，无需注册即可调用，
  适合快速验证与轻量使用。
- **OpenAPI 文档与 SDK** —— 支持 Python / TypeScript。
- **注册与专业版（带 API Key）** —— 提供更高额度、更深历史、更低延迟与更多数据维度，
  详见下方 [版本与能力](#版本与能力)。

> 本 Skill 使用的开放接口 BASE 地址：`https://www.apocdata.com/api/blade-dataplatform/open/data`

---

## 安装

### macOS / Linux

```bash
# v2.0.5 多文件结构，查看最新版本: https://gitee.com/apocdata/ApocData-skill/releases
mkdir -p ~/.claude/skills/apocdata
curl -sL https://gitee.com/apocdata/ApocData-skill/repository/archive/v2.0.5.tar.gz \
  | tar xz -C ~/.claude/skills/apocdata --strip-components=1
```

### Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force -Path ~\.claude\skills\apocdata
Invoke-WebRequest -Uri https://gitee.com/apocdata/ApocData-skill/repository/archive/v2.0.5.tar.gz -OutFile ~\Downloads\apocdata.tar.gz
tar xzf ~\Downloads\apocdata.tar.gz -C ~\.claude\skills\apocdata --strip-components=1
```

### MCP 安装（Claude Desktop / Cursor / ChatGPT）

```json
{
  "mcpServers": {
    "apocdata": {
      "command": "npx",
      "args": ["-y", "@apocdata-info/mcp-server"]
    }
  }
}
```

### OpenAPI 导入（GPT Actions / Dify / Coze / n8n）

```
https://www.apocdata.com/api/blade-dataplatform/open/data/openapi.json
```

导入即用，免费体验额度，无需注册。

---

## 基础用法

所有接口均为 HTTP GET，用 `curl` 直接调用：

```bash
BASE="https://www.apocdata.com/api/blade-dataplatform/open/data"

# 查单只股票行情
curl -s "$BASE/quote?symbol=000001"

# 查股票基本信息（含 PE/PB/市值）
curl -s "$BASE/stock?symbol=000001"
```

每个接口的完整参数、返回字段与示例问题，详见 [`SKILL.md`](./SKILL.md)。

---

## 接口能力总览

共 45 个活跃接口（`/news` 已下线，不计入），按数据维度分类如下：

### 实时行情与 K 线（6）

| 接口            | 说明                                  |
| ------------- | ----------------------------------- |
| `quote`       | 单只股票最新涨跌、量价                  |
| `quotes`      | 批量行情，最多 10 只                  |
| `daily`       | 日 K 历史，最近 N 条或日期区间，≤ 30 条 |
| `ranking`     | 全市场涨跌幅排行榜（涨幅 / 跌幅）        |
| `index-daily` | 指数日 K 行情                         |
| `tech-factor` | 技术面因子（MACD / KDJ / RSI / BOLL / 均线） |

### 基本面与财务（5）

| 接口          | 说明                          |
| ----------- | --------------------------- |
| `stock`     | 股票基本信息（行业 / 市值 / PE / PB） |
| `financial` | 财务数据（ROE / 营收 / 净利润），≤ 4 期 |
| `express`   | 业绩快报                       |
| `dividend`  | 分红送配方案                    |
| `cyq-perf`  | 筹码分布与获利比例                 |

### 股东与公司治理（6）

| 接口              | 说明           |
| --------------- | ------------ |
| `holders`       | 十大股东 / 十大流通股东 |
| `holder-number` | 历史股东户数       |
| `share-float`   | 限售解禁记录       |
| `repurchase`    | 股票回购方案与进度   |
| `block-trade`   | 大宗交易记录       |
| `survey`        | 机构调研接待记录    |

### 资金流向（5）

| 接口            | 说明                |
| ------------- | ----------------- |
| `moneyflow`   | 个股资金流与主力净流入       |
| `hsgt`        | 沪深港通（北向 / 南向）资金流  |
| `sector-flow` | 行业 / 概念 / 地域板块资金流榜 |
| `hk-hold`     | 个股被沪深港通持股记录      |
| `margin`      | 两市融资融券交易汇总        |

### 龙虎榜与打板情绪（6）

| 接口                 | 说明           |
| ------------------ | ------------ |
| `dragon-tiger`     | 龙虎榜单 / 个股上榜历史 |
| `limit-list`       | 涨停 / 跌停 / 炸板池 |
| `limit-step`       | 连板天梯         |
| `hot-rank`         | 人气榜      |
| `hot-money`        | 知名游资名录        |
| `hot-money-detail` | 游资交易明细        |

### 板块与概念（4）

| 接口                 | 说明          |
| ------------------ | ----------- |
| `concepts`         | 东方财富概念板块目录   |
| `concept-stocks`   | 概念板块成分股     |
| `ths-boards`       | 同花顺行业 / 概念板块 |
| `ths-board-stocks` | 同花顺行业板块成分股    |

### 新闻与公告（1 活跃，1 已下线）

| 接口              | 说明                          |
| --------------- | --------------------------- |
| ~~`news`~~      | **已下线** — 调用返回 HTTP 410 + 迁移提示，请改用 `/announcements`。 |
| `announcements` | 公司公告（可选 Markdown 全文；AI 摘要可能为空） |

### 宏观经济（3）

| 接口                 | 说明                            |
| ------------------ | ----------------------------- |
| `macro`            | 宏观指标历史（GDP / CPI / PPI / PMI） |
| `macro/latest`     | 宏观指标最新值                      |
| `macro/definition` | 宏观指标定义与说明                   |

### 搜索与基础工具（5）

| 接口         | 说明                |
| ---------- | ----------------- |
| `stocks`   | 按名称 / 代码搜索股票，支持行业过滤 |
| `indexes`  | 按名称 / 代码搜索指数      |
| `calendar` | A 股交易日历           |
| `st`       | ST / 退市风险状态       |
| `factors`  | 量化因子注册表（脱敏）       |

### 可转债（2）

| 接口                  | 说明        |
| ------------------- | --------- |
| `convertible-bonds` | 可转债基本信息   |
| `cb-price-chg`      | 可转债转股价变动记录 |

### Agent 增强（2）

| 接口                | 说明                       |
| ------------------- | -------------------------- |
| `profile/full`      | 个股 8 维综合画像聚合      |
| `factor-categories` | 量化因子业务分类目录与数量 |

---

## 综合分析示例

问「帮我分析一下 688017 的估值」时，Agent 会依次调用：

```bash
BASE="https://www.apocdata.com/api/blade-dataplatform/open/data"
curl -s "$BASE/stock?symbol=688017"          # PE/PB/市值
curl -s "$BASE/quote?symbol=688017"          # 当前股价
curl -s "$BASE/financial?symbol=688017"      # ROE/净利润
curl -s "$BASE/daily?symbol=688017&limit=30" # 近期走势
```

---

## 版本与能力

天启至数 Apocdata 按使用场景分为四档版本，所有版本共用同一套 API 契约，能力按版本白名单返回。
**本 Skill 默认对接免费体验额度开放接口；注册解锁更高额度与更多数据能力。**

### 版本一览

| SKU   | 版本   | 适用人群           |
| ----- | ----- | ----------------- |
| FREE  | 免费版 | 个人 / Agent 试用  |
| PRO   | 专业版 | 投研 / 内容博主    |
| QUANT | 量化版 | 量化研究团队       |
| ENT   | 企业版 | 机构嵌入 / 私有化   |

### 版本能力对比（节选）

| 能力项     | 免费版       | 专业版    | 量化版   | 企业版         |
| --------- | ----------- | -------- | ------- | ------------- |
| 日调用次数  | 2,000       | 50,000   | 300,000 | 定制          |
| QPS 上限   | 2           | 10       | 30      | 定制          |
| 实时快照延迟 | 15 分钟      | 1 分钟    | ≤ 30s   | 定制（≤ 10s） |
| 日 K 深度  | 30 交易日     | 5 年 + 复权 | 全量    | 全量          |
| 量化因子值  | —           | 20 个     | 全量    | 全量 + 定制    |
| MCP Tools | 8           | 14       | 18      | 18+ 定制       |
| 可用性 SLO | best-effort | 99.0%    | 99.5%   | 99.9%（合同） |
| 技术支持   | 社区         | 邮件 48h  | 邮件 24h | 专属群 + 电话  |

> 所有版本均含 OpenAPI 文档、SDK、状态页与用量看板。完整能力矩阵与价格请联系咨询。

### 附加包（可叠加现有版本）

| 附加包          | 名称       | 说明                       |
| -------------- | --------- | -------------------------- |
| ADD-HIST-10Y   | 历史扩展   | 日 K 从 30 天扩展到 10 年   |
| ADD-FACTOR-50  | 因子扩展   | 专业版因子 20 → 70 个       |
| ADD-MCP-PRO    | Agent 包   | 开放全部 18 个 MCP Tools    |
| ADD-BULK       | 按量调用   | 超额计费，无需升级          |
| ADD-ENT-SLA    | 企业 SLA   | 99.9% · 专属带宽            |
| ADD-WHITELABEL | 白标 / 域名 | 自定义域名 + 文档           |

> 价格、升级或商务咨询请联系：**<yclszkj@163.com>**

---

## 注意事项与合规声明

**调用约定**

- 所有接口**只读**；免费体验额度无需注册即可调用，注册解锁更高额度与更多数据能力。
- `symbol` 统一使用 **6 位数字代码**（如 `688017`），不带交易所后缀。
- 单次请求建议超时 10 秒。
- 数据来源：天启云（A 股市场数据同步）。

**合规说明**

- 行情为延迟数据，非交易所授权实时行情。
- 衍生数据为清洗后的结构化数据，禁止二次转售。
- 新闻仅含标题与链接，正文版权归原媒体所有。
- 因子与信号属研究用途，**不构成任何投资建议**。

---

## 立即开始

免费体验额度，无需注册即可调用；注册用户解锁更高额度与更多数据能力。

[免费体验 →](https://www.apocdata.com) · [注册账号 →](https://www.apocdata.com/register) · [Star on Gitee →](https://gitee.com/apocdata/ApocData-skill)

---

联系方式：<yclszkj@163.com>
