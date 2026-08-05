# ApocData · A-Share AI Data Skill

> Zero-auth, zero-dependency. Use `curl` to call 46 active A-share data endpoints
> (quotes / financials / fund flows / factors / announcements / macro).
> Compatible with Claude, ChatGPT, Qwen, Kimi, DeepSeek and any AI agent
> that supports tool calling.

The [`SKILL.md`](./SKILL.md) in this repository is a capability card that can
be loaded directly into AI agents, letting LLMs query A-share market data
and complete research tasks without any SDK.

<p align="center">
  <b>English</b> |
  <a href="./README.zh-CN.md">简体中文</a>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Data Service Platform](#data-service-platform)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Endpoint Overview](#endpoint-overview)
- [Combined Analysis Example](#combined-analysis-example)
- [Editions & Capabilities](#editions--capabilities)
- [Notes & Compliance](#notes--compliance)

---

## Overview

ApocData focuses on AI-native access to China's A-share market, designed for
AI agents, quantitative research, investment content, and institutional
applications. We provide unified endpoints for quotes, financials, fund flows,
dragon-tiger boards, quantitative factors, macro indicators, and more.

---

## Data Service Platform

**Platform URL:** <https://www.apocdata.com>

The data service platform is the unified entry point for ApocData. It provides:

- **Open API (no auth)** — This is what the Skill connects to. No registration,
  no token required. Ideal for quick experiments and lightweight usage.
- **OpenAPI documentation & SDKs** — Python / TypeScript supported.
- **Platform editions (with API key)** — Higher quotas, deeper history,
  lower latency, and richer data fields. See [Editions & Capabilities](#editions--capabilities).

> The base URL used by this Skill: `https://data.tianqis.com/api/blade-dataplatform/open/data`

---

## Installation

### macOS / Linux

```bash
# Pinned to v1.1.0 — check https://github.com/ApocData/ApocData-skill/releases for latest
mkdir -p ~/.claude/skills/apocdata
curl -o ~/.claude/skills/apocdata/SKILL.md \
  https://raw.githubusercontent.com/ApocData/ApocData-skill/v1.1.0/SKILL.md
```

### Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force -Path ~\.claude\skills\apocdata
Invoke-WebRequest `
  -Uri https://raw.githubusercontent.com/ApocData/ApocData-skill/v1.1.0/SKILL.md `
  -OutFile ~\.claude\skills\apocdata\SKILL.md
```

### China users (Gitee mirror)

```bash
mkdir -p ~/.claude/skills/apocdata
curl -o ~/.claude/skills/apocdata/SKILL.md \
  https://gitee.com/apocdata/ApocData-skill/raw/v1.1.0/SKILL.md
```

Restart Claude Code or Claude Desktop after installation. The Skill takes
effect automatically.

---

## Basic Usage

All endpoints are HTTP GET. Call them directly with `curl`:

```bash
BASE="https://data.tianqis.com/api/blade-dataplatform/open/data"

# Single stock quote
curl -s "$BASE/quote?symbol=000001"

# Stock basic info (incl. PE/PB/market cap)
curl -s "$BASE/stock?symbol=000001"
```

Full parameters, return fields, and example questions for each endpoint:
see [`SKILL.md`](./SKILL.md).

---

## Endpoint Overview

46 active endpoints in total, grouped by data dimension (`/news` deprecated, not counted):

### Real-time Quotes & K-line (7)

| Endpoint      | Description                                |
| ------------- | ------------------------------------------ |
| `quote`       | Latest change/volume/price for one stock   |
| `quotes`      | Batch quotes, up to 10 stocks              |
| `daily`       | Daily K history, ≤ 30 records              |
| `ranking`     | Market-wide gain/loss rankings             |
| `index-daily` | Index daily K                              |
| `hk-daily`    | Hong Kong daily K                          |
| `tech-factor` | Technical factors (MACD/KDJ/RSI/BOLL/MA)   |

### Fundamentals & Financials (5)

| Endpoint    | Description                              |
| ----------- | ---------------------------------------- |
| `stock`     | Stock basics (industry / cap / PE / PB)  |
| `financial` | Financials (ROE / revenue / net profit), ≤ 4 periods |
| `express`   | Earnings express reports                 |
| `dividend`  | Dividend and share allotment plans       |
| `cyq-perf`  | Chip distribution and profit ratio       |

### Shareholders & Governance (6)

| Endpoint        | Description                          |
| --------------- | ------------------------------------ |
| `holders`       | Top 10 shareholders / circulating    |
| `holder-number` | Historical shareholder count         |
| `share-float`   | Lock-up release records              |
| `repurchase`    | Share buyback plans and progress     |
| `block-trade`   | Block trade records                  |
| `survey`        | Institutional research visits        |

### Fund Flows (5)

| Endpoint      | Description                              |
| ------------- | ---------------------------------------- |
| `moneyflow`   | Stock fund flow and main net inflow      |
| `hsgt`        | HSGT (North/South bound) fund flow       |
| `sector-flow` | Sector / concept / regional fund flow    |
| `hk-hold`     | Stock holdings via HSGT                  |
| `margin`      | Margin trading and short selling summary |

### Dragon-Tiger & Sentiment (6)

| Endpoint           | Description                       |
| ------------------ | --------------------------------- |
| `dragon-tiger`     | Dragon-tiger list / stock history |
| `limit-list`       | Limit up / down / broken pools    |
| `limit-step`       | Consecutive limit-up ladder       |
| `hot-rank`         | EastMoney popularity ranking      |
| `hot-money`        | Famous hot-money directory        |
| `hot-money-detail` | Hot-money trade details           |

### Sectors & Concepts (4)

| Endpoint           | Description                  |
| ------------------ | ---------------------------- |
| `concepts`         | EastMoney concept directory  |
| `concept-stocks`   | Concept constituent stocks   |
| `ths-boards`       | THS industry / concept boards |
| `ths-board-stocks` | THS board constituents       |

### News & Announcements (1 active, 1 deprecated)

| Endpoint        | Description                              |
| --------------- | ---------------------------------------- |
| ~~`news`~~      | **Deprecated** — returns HTTP 410 + migration hint. Use `/announcements` instead. |
| `announcements` | Company announcements (AI summary + markdown) |

### Macro Economics (3)

| Endpoint           | Description                          |
| ------------------ | ------------------------------------ |
| `macro`            | Macro indicator history (GDP/CPI/PPI/PMI) |
| `macro/latest`     | Latest macro indicator values        |
| `macro/definition` | Macro indicator definitions          |

### Search & Utilities (5)

| Endpoint    | Description                            |
| ----------- | -------------------------------------- |
| `stocks`    | Search stocks by name / code           |
| `indexes`   | Search indexes by name / code          |
| `calendar`  | A-share trading calendar               |
| `st`        | ST / delisting risk status             |
| `factors`   | Quant factor registry (sanitized)      |

### Convertible Bonds (2)

| Endpoint            | Description                       |
| ------------------- | --------------------------------- |
| `convertible-bonds` | Convertible bond basic info       |
| `cb-price-chg`      | Conversion price change records   |

### Agent Enhancements (2)

| Endpoint            | Description                                  |
| ------------------- | -------------------------------------------- |
| `profile/full`      | Aggregated 8-dimension stock profile         |
| `factor-categories` | Quant factor business categories and counts |

---

## Combined Analysis Example

When asked *"Analyze the valuation of 688017"*, the agent will call in sequence:

```bash
BASE="https://data.tianqis.com/api/blade-dataplatform/open/data"
curl -s "$BASE/stock?symbol=688017"          # PE/PB/market cap
curl -s "$BASE/quote?symbol=688017"          # current price
curl -s "$BASE/financial?symbol=688017"      # ROE/net profit
curl -s "$BASE/daily?symbol=688017&limit=30" # recent trend
```

---

## Editions & Capabilities

ApocData is organized into four editions to match different use cases.
All editions share the same API contract; capabilities are filtered by
edition whitelist. **This Skill defaults to the no-auth open endpoints.
Upgrade to a platform edition with API key for higher quotas and deeper data.**

### Edition Lineup

| SKU   | Edition      | Target Users                                          |
| ----- | ------------ | ----------------------------------------------------- |
| FREE  | Free         | Individuals / AI agent demos                          |
| PRO   | Professional | Investment research / content creators                |
| QUANT | Quant        | Quantitative research teams                           |
| ENT   | Enterprise   | Institutional embedding / private deployment          |

### Capability Comparison (selected)

| Capability         | Free        | Pro            | Quant   | Enterprise       |
| ------------------ | ----------- | -------------- | ------- | ---------------- |
| Daily calls        | 2,000       | 50,000         | 300,000 | Custom           |
| QPS limit          | 2           | 10             | 30      | Custom           |
| Snapshot latency   | 15 min      | 1 min          | ≤ 30s   | Custom (≤ 10s)   |
| Daily K depth      | 30 days     | 5 yrs + adj.   | Full    | Full             |
| Quant factors      | —           | 20             | Full    | Full + custom    |
| MCP Tools          | 8           | 14             | 18      | 18+ custom       |
| Availability SLO   | best-effort | 99.0%          | 99.5%   | 99.9% (contract) |
| Support            | Community   | Email 48h      | Email 24h | Dedicated channel + phone |

> All editions include OpenAPI docs, SDKs, status page, and usage dashboard.
> Full capability matrix and pricing details available upon request.

### Add-ons (stackable on existing editions)

| Add-on         | Name              | Description                          |
| -------------- | ----------------- | ------------------------------------ |
| ADD-HIST-10Y   | History extension | Daily K from 30 days to 10 years     |
| ADD-FACTOR-50  | Factor extension  | Pro factors: 20 → 70                 |
| ADD-MCP-PRO    | Agent pack        | Unlock all 18 MCP tools              |
| ADD-BULK       | Usage-based       | Overflow billing, no upgrade needed  |
| ADD-ENT-SLA    | Enterprise SLA    | 99.9% · dedicated bandwidth          |
| ADD-WHITELABEL | White-label       | Custom domain + docs                 |

> Pricing, upgrades, and business inquiries: **<drawsea@163.com>**

---

## Notes & Compliance

**Usage conventions**

- All endpoints are **read-only and authentication-free**. No registration
  or token required.
- `symbol` uses a **6-digit numeric code** (e.g., `688017`), no exchange suffix.
- Recommended request timeout: 10 seconds.
- Data source: ApocData, synchronized with A-share data ingestion cycles.

**Compliance**

- Quote data is delayed (not exchange-licensed real-time data).
- Derived data is cleaned and structured; redistribution is prohibited.
- News contains only titles and links; full content copyright belongs to the
  original publishers.
- Factors and signals are for research purposes only and **do not constitute
  any investment advice**.

---

Contact: <drawsea@163.com>
