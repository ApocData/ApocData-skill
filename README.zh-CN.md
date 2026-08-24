# ApocData · 天启至数 · A 股数据 Skill

> 免鉴权、零依赖，用 `curl` 直接调用 A 股行情 / 财务 / 资金 / 因子 / 公告等 45 个活跃数据接口，
> 支持 Claude、ChatGPT、通义千问、Kimi、DeepSeek 等所有支持工具调用的 AI Agent。

本仓库提供的 [`SKILL.md`](./SKILL.md) 是一份可直接装入 AI Agent 的能力卡片，
让大模型无需任何 SDK，即可查询 A 股市场数据并完成投研分析。

<p align="center">
  <a href="./README.md">English</a> |
  <b>简体中文</b>
</p>


<p align="center">
  <img src="https://img.shields.io/badge/endpoints-45-green" alt="45 endpoints"/>
  <img src="https://img.shields.io/badge/auth-none-brightgreen" alt="No auth required"/>
  <img src="https://img.shields.io/badge/MCP-46_tools-blue" alt="MCP 46 tools"/>
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

## 为什么选 ApocData？

| | **ApocData** | tushare | akshare | 同花顺 iFinD |
|---|---|---|---|---|
| 鉴权 | **无需** | 付费 Token | Python 环境 + akshare 安装 | 申请审批 |
| 安装步骤 | **0** | 3+（注册→获取 token→配置） | 2+（pip install + 依赖） | 5+ |
| MCP 支持 | **✅ 46 工具** | ❌ | ❌ | ❌ |
| Skill 支持 | **✅ Claude / GPT / 通义** | ❌ | ❌ | ❌ |
| 一行 curl 可用 | **✅** | ❌ | ❌ | ❌ |
| 接口数 | 45 | 100+（老旧） | 50+ | 有限 |

> *对比基于 2026-08 实测。tushare 免费档部分接口可用但需注册 token；akshare 需 Python 环境。*

---

## 目录

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

ApocData（天启至数）专注于为 AI Agent 提供 A 股市场数据服务，面向 AI Agent、
量化研究、投研内容与机构应用，提供行情、财务、资金流、龙虎榜、量化因子、
宏观经济等全维度数据接口。

---

## 数据服务平台

**平台网址：** <https://www.apocdata.com>

数据服务平台是 ApocData 的统一入口，提供：

- **免鉴权开放接口** —— 本 Skill 对接的就是这一组接口，无需注册、无需 Token，
  适合快速体验与轻量调用。
- **OpenAPI 文档与 SDK** —— 支持 Python / TypeScript。
- **平台版本（带 API Key）** —— 提供更高配额、更深历史、更低延迟与更多数据维度，
  详见下方 [版本与能力](#版本与能力)。

> 本 Skill 使用的开放接口 BASE 地址：`https://www.apocdata.com/api/blade-dataplatform/open/data`

---

## 安装

### macOS / Linux

```bash
# v2.0.0 多文件结构，查看最新版本: https://github.com/ApocData/ApocData-skill/releases
mkdir -p ~/.claude/skills/apocdata
curl -sL https://github.com/ApocData/ApocData-skill/archive/refs/tags/v2.0.0.tar.gz \
  | tar xz -C ~/.claude/skills/apocdata --strip-components=1
```

### Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force -Path ~\.claude\skills\apocdata
Invoke-WebRequest -Uri https://github.com/ApocData/ApocData-skill/archive/refs/tags/v2.0.0.tar.gz -OutFile ~\Downloads\apocdata.tar.gz
tar xzf ~\Downloads\apocdata.tar.gz -C ~\.claude\skills\apocdata --strip-components=1
```

### 国内用户（Gitee 镜像）

```bash
mkdir -p ~/.claude/skills/apocdata
curl -sL https://gitee.com/apocdata/ApocData-skill/repository/archive/v2.0.0.tar.gz \
  | tar xz -C ~/.claude/skills/apocdata --strip-components=1
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

导入即用，免鉴权。

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
| `hot-rank`         | 东方财富人气榜      |
| `hot-money`        | 知名游资名录        |
| `hot-money-detail` | 游资交易明细        |

### 板块与概念（4）

| 接口                 | 说明          |
| ------------------ | ----------- |
| `concepts`         | 东方财富概念板块目录   |
| `concept-stocks`   | 概念板块成分股     |
| `ths-boards`       | 同花顺行业 / 概念板块 |
| `ths-board-stocks` | 同花顺板块成分股    |

### 新闻与公告（1 活跃，1 已下线）

| 接口              | 说明                          |
| --------------- | --------------------------- |
| ~~`news`~~      | **已下线** — 调用返回 HTTP 410 + 迁移提示，请改用 `/announcements`。 |
| `announcements` | 公司公告（含 AI 摘要与 Markdown 全文） |

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

ApocData 按使用场景分为四档版本，所有版本共用同一套 API 契约，能力按版本白名单返回。
**本 Skill 默认对接免鉴权开放接口；如需更高配额或更深数据，可升级至带 API Key
的平台版本。**

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

- 所有接口**只读、免鉴权**，无需注册或 Token。
- `symbol` 统一使用 **6 位数字代码**（如 `688017`），不带交易所后缀。
- 单次请求建议超时 10 秒。
- 数据来源：ApocData，与 A 股数据落库周期同步。

**合规说明**

- 行情为延迟数据，非交易所授权实时行情。
- 衍生数据为清洗后的结构化数据，禁止二次转售。
- 新闻仅含标题与链接，正文版权归原媒体所有。
- 因子与信号属研究用途，**不构成任何投资建议**。

---

联系方式：<yclszkj@163.com>
