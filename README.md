# ApocData · A-Share AI Data Skill

<p align="center">
  <b>English</b> |
  <a href="./README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/endpoints-45-green" alt="45 endpoints"/>
  <img src="https://img.shields.io/badge/auth-none-brightgreen" alt="No auth required"/>
  <img src="https://img.shields.io/badge/MCP-46_tools-blue" alt="MCP 46 tools"/>
  <img src="https://img.shields.io/badge/license-Apache_2.0-blue" alt="License"/>
</p>
> Zero-auth, zero-dependency. Use `curl` to call 45+ A-share data endpoints
> (quotes / financials / fund flows / factors / announcements / macro).
> Compatible with Claude, ChatGPT, Qwen, Kimi, DeepSeek and any AI agent
> that supports tool calling.

The [`SKILL.md`](./SKILL.md) in this repository is a capability card that can
be loaded directly into AI agents, letting LLMs query A-share market data
and complete research tasks without any SDK.

---

## Quick Try

Copy-paste and run, no config needed:

```bash
curl -s "https://www.apocdata.com/api/blade-dataplatform/open/data/quote?symbol=600519"
```

<details>
<summary>Click to expand sample response</summary>

```json
{
  "code": 200, "success": true,
  "data": {
    "symbol": "600519", "name": "Kweichow Moutai",
    "close": 1528.00, "pct_chg": -0.52,
    "volume": 2856321, "delayed_minutes": 15
  }
}
```

*Actual response has more fields; above is a simplified example.*
</details>

---

## Why ApocData?

| | **ApocData** | tushare | akshare | iFinD |
|---|---|---|---|---|
| Auth | **None** | Paid token | Python env + install | Application approval |
| Setup steps | **0** | 3+ (register → token → config) | 2+ (pip + deps) | Manual review |
| AI Agent native | **Skill + MCP** | Plugin (legacy) | Not supported | Not supported |
| curl one-liner | **Direct** | Need SDK | Need SDK | Need SDK |
| A-share endpoints | **45** | 100+ (paywalled) | 100+ (free) | 200+ (paid) |
| MCP support | **46 tools** | None | None | None |

*Comparison based on publicly available info as of 2026-08.*

---

## Table of Contents

- [Overview](#overview)
- [Data Service Platform](#data-service-platform)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Basic Usage](#basic-usage)
- [Endpoint Overview](#endpoint-overview)
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

> The base URL used by this Skill: `https://www.apocdata.com/api/blade-dataplatform/open/data`

---

## Installation

### Quick Install (recommended)

```bash
mkdir -p ~/.claude/skills/apocdata
curl -sL https://github.com/ApocData/ApocData-skill/archive/refs/tags/v2.0.0.tar.gz \
  | tar xz -C ~/.claude/skills/apocdata --strip-components=1
```

Restart Claude Code and the skill will be auto-detected.

### MCP Install (Claude Desktop / Cursor / ChatGPT)

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

### OpenAPI Import (GPT Actions / Dify / Coze / n8n)

```
https://www.apocdata.com/api/blade-dataplatform/open/data/openapi.json
```

Import and use — no auth required.

### Alternative: install script

```bash
curl -sL https://raw.githubusercontent.com/ApocData/ApocData-skill/v2.0.0/scripts/install.sh | bash
```

---

## Project Structure

This Skill uses a **multi-file structure** for progressive loading — the entry
`SKILL.md` is a slim router (~180 lines), and detailed endpoint specs are
loaded on demand from the `references/` directory:

```
├── SKILL.md                  # Entry point (slim router, ~180 lines)
├── README.md                 # This file (human-facing docs)
├── CHANGELOG.md              # Version history
├── references/               # On-demand reference docs (loaded per topic)
│   ├── boundaries.md         # Interface boundaries, headers, error codes, cache, freshness
│   ├── group-a-quote.md      # A. Quotes & Valuation (10 endpoints)
│   ├── group-b-financial.md  # B. Financials & Fundamentals (8 endpoints)
│   ├── group-c-capital.md    # C. Capital Flow (7 endpoints)
│   ├── group-d-limitup.md    # D. Limit-up & Sentiment (4 endpoints)
│   ├── group-e-events.md     # E. Events & Information (3 endpoints)
│   ├── group-f-sector.md     # F. Sectors & Concepts (4 endpoints)
│   ├── group-g-convertible.md # G. Convertible Bonds (2 endpoints)
│   ├── group-h-quant.md      # H. Quant & Technical (2 endpoints)
│   ├── group-i-macro.md      # I. Macro (3 endpoints)
│   ├── group-j-tools.md      # J. Tools (1 endpoint)
│   ├── group-k-agent.md      # K. Agent Enhanced (2 endpoints)
│   ├── examples.md           # Multi-endpoint analysis examples (5 scenarios)
│   └── safety-rules.md       # Financial output safety constraints (6 rules)
└── scripts/
    └── install.sh            # One-line install script
```

**Why multi-file?** A simple query like "what's the price of Moutai" only needs
the entry SKILL.md + one reference file (~4K tokens), instead of loading the
entire 47KB monolith (~15K tokens). This reduces token consumption by 70%+.

---

## Basic Usage

All endpoints are HTTP GET, called with `curl`:

```bash
BASE="https://www.apocdata.com/api/blade-dataplatform/open/data"

# Get real-time quote
curl -s "$BASE/quote?symbol=000001"

# Get stock info (PE/PB/market cap)
curl -s "$BASE/stock?symbol=000001"

# Get comprehensive profile (8 dimensions in one call)
curl -s "$BASE/profile/full?symbol=688017"
```

---

## Endpoint Overview

| Group | Topic | Endpoints |
|-------|-------|-----------|
| A | Quotes & Valuation | 10 |
| B | Financials & Fundamentals | 8 |
| C | Capital Flow | 7 |
| D | Limit-up & Sentiment | 4 |
| E | Events & Information | 2 (+ 1 deprecated) |
| F | Sectors & Concepts | 4 |
| G | Convertible Bonds | 2 |
| H | Quant & Technical | 2 |
| I | Macro | 3 |
| J | Tools | 1 |
| K | Agent Enhanced | 2 |
| **Total** | | **45 active** (+ 1 deprecated) |

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

---

## Endpoint Verification

> **Last verified:** 2026-08-12 12:21 CST

| Check | Result |
|---|---|
| Core endpoints tested | 12/12 -> HTTP 200
| Total active endpoints | 45 (across 11 groups) |
| Avg latency | ~217ms
| Deprecated | `/news` (HTTP 410, documented in group-e) |

Verified endpoints: `quote`, `stock`, `daily`, `financial`, `moneyflow`, `hsgt`,
`limit-list`, `announcements`, `concepts`, `macro/latest`, `calendar`, `profile/full`.
Full 45-endpoint coverage is validated via the scenario quick-reference table in `SKILL.md`.

---

## Notes & Compliance

- All endpoints are **read-only, no auth required**
- Data source: ApocData Cloud (天启云), synced with A-share market data
- Free tier quotes have 15-minute delay (see `delayed_minutes` in response)
- Announcements: T+0 at 08:00; Northbound capital: 20:00
- This Skill is for **research assistance only** — not investment advice
- Financial output safety constraints are enforced via `references/safety-rules.md`

---

## License

See [LICENSE](./LICENSE) for details.
