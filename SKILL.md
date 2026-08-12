---
name: apocdata
description: "Use when users ask for A-share stock quotes, financials, capital flows, technical factors, news, announcements, sectors, convertible bonds, macro data, or comprehensive stock analysis through the ApocData public API. Trigger keywords: 股票, 行情, 估值, 财务, 资金流, 涨停, 跌停, 炸板, 打板, 连板, 板块, 概念, 可转债, 宏观, 公告, 调研, 龙虎榜, 游资, 北向资金, 两融, 排行, 人气榜, 指数, 筹码, 获利盘, ST, 分红, 回购, 大宗交易, 量化因子, 技术面, 交易日历, 下修, 转股价, 业绩快报, 股东户数, 解禁, profile, ApocData, A股数据. Do NOT trigger for: cryptocurrency, crypto, Bitcoin, US stocks, US market, futures, options, forex, Hong Kong stocks, 加密货币, 比特币, 美股, 期货, 外汇, or any non-A-share market."
---

# 天启至数™ · ApocData Skill — A 股数据 Skill

> **天启技能** —— 免鉴权，零依赖，直接用 curl 调用，支持 Claude / OpenAI / 通义千问等所有 Agent。

## 安装

```bash
# v2.0.0 多文件结构（推荐）
mkdir -p ~/.claude/skills/apocdata
curl -sL https://github.com/ApocData/ApocData-skill/archive/refs/tags/v2.0.0.tar.gz \
  | tar xz -C ~/.claude/skills/apocdata --strip-components=1
```

重启 Claude Code 后自动生效。

---

## 基础用法

所有接口均为 HTTP GET，用 curl 直接调用：

```bash
BASE="https://www.apocdata.com/api/blade-dataplatform/open/data"

# 查单只股票行情
curl -s "$BASE/quote?symbol=000001"

# 查股票基本信息（含 PE/PB/市值）
curl -s "$BASE/stock?symbol=000001"
```

### OpenAPI 3 接入（GPT Actions / Coze / Dify / n8n / Zapier）

| 端点 | 用途 |
|---|---|
| `https://www.apocdata.com/api/blade-dataplatform/open/data/openapi.json` | **OpenAPI 3 JSON（推荐，导入即用）**，免鉴权匿名访问，覆盖全部公开接口 |

> spec 的 `servers.url` 已内置为公网基址，导入后各接口路径直接拼接即可调用，无需再改 base。

无需注册，匿名可访问。

---

## 场景速查（按用户意图找接口组合）

> 拿到自然语言意图时，**优先查本表选定接口组合**，再去参考文件看字段细节，避免漏调或乱调。

| 用户意图 | 推荐调用顺序 | 关键说明 |
|---|---|---|
| 个股综合画像 / 「这只票怎么样」 | **推荐**：`profile/full?symbol=X`（一次返回 8 维数据） | 等价于并发调 8 个单接口，延时减 60%+ |
| 个股综合画像（分步精细化） | `quote` → `stock` → `financial` → `tech-factor` → `moneyflow` → `announcements` | 需要按维度独立控制 limit/fields 时用 |
| 估值评估 / 「贵不贵」 | `stock` → `financial` → `daily?limit=30` | 看 PE/PB/PEG，结合近期走势判断 |
| 资金动向追踪 / 「主力在干嘛」 | `moneyflow` → `hsgt` → `hk-hold` → `dragon-tiger` → `hot-money-detail` | 北向 20:00 后更新 |
| 涨停盘后复盘 / 「今天涨停的共性」 | `limit-list?kind=U` → `limit-step` → `sector-flow` → `hot-money-detail` | date 不传默认最新交易日 |
| 板块 / 概念热度 | `sector-flow` → `concepts` → `concept-stocks` 或 `ths-boards` → `ths-board-stocks` | 东财与同花顺双源，可交叉验证 |
| 新闻 / 市场事件 | ~~`news?q=关键词`~~ **已下线** → 改用 `announcements` 查正式披露 | `/news` 接口已下线 |
| 公告 / 事件驱动 | `announcements` → `survey` → `share-float` → `repurchase` → `dividend` | announcements 返回 Markdown 全文 + AI 摘要 |
| 大盘择时 / 宏观判断 | `index-daily?tsCode=000300.SH` → `macro/latest?type=PMI` → `macro/latest?type=CPI` → `hsgt` | 宏观接口最多 12 条 |
| 可转债套利 | `convertible-bonds` → `cb-price-chg` → `quote`(正股) | 用 stkCode 反查正股可转债 |
| 找游资偏好的票 | `hot-money` → `hot-money-detail` → `dragon-tiger` | 当日游资明细 + 历史席位 |
| 退市/风险排查 | `st` → `share-float` → `holders` → `announcements` | st 返回 null 即非 ST |
| 业绩超预期追踪 | `express` → `financial` → `survey` → `announcements` | express 是季报前的先行指标 |
| 找具体行业 / 名字模糊 | `stocks?q=关键词` → `stock` 逐只确认 | 支持代码、名称、行业三种模糊匹配 |

---

## 接口分组总览

> 全部 **45 个活跃业务接口按使用场景分 11 组**（`/news` 已下线）。详细参数和返回字段见对应的参考文件。

| 组别 | 主题 | 接口数 | 参考文件 |
|---|---|---|---|
| A | 行情与估值 | 10 | `references/group-a-quote.md` |
| B | 财务与基本面 | 8 | `references/group-b-financial.md` |
| C | 资金博弈 | 7 | `references/group-c-capital.md` |
| D | 涨跌停与情绪 | 4 | `references/group-d-limitup.md` |
| E | 事件与信息 | 3（活跃 2） | `references/group-e-events.md` |
| F | 板块/概念 | 4 | `references/group-f-sector.md` |
| G | 可转债 | 2 | `references/group-g-convertible.md` |
| H | 量化与技术 | 2 | `references/group-h-quant.md` |
| I | 宏观 | 3 | `references/group-i-macro.md` |
| J | 工具 | 1 | `references/group-j-tools.md` |
| K | Agent 增强 | 2 | `references/group-k-agent.md` |

---

## 参考文件导航

根据用户需求，读取对应的参考文件获取完整接口细节：

### 全局规则（优先读取）

| 参考文件 | 何时读取 |
|---------|---------|
| `references/boundaries.md` | 首次调用任何接口前、遇到错误/空数据时、需理解 header/缓存/freshness 时 |
| `references/safety-rules.md` | 生成任何金融分析输出前（强制行为规则） |

### 接口字典（按主题按需加载）

| 参考文件 | 何时读取 |
|---------|---------|
| `references/group-a-quote.md` | 查行情、估值、排行、指数、搜索股票、ST 状态 |
| `references/group-b-financial.md` | 查财务报表、分红、股东、回购、大宗交易、限售解禁 |
| `references/group-c-capital.md` | 查资金流、北向资金、两融、龙虎榜、游资 |
| `references/group-d-limitup.md` | 查涨跌停、连板天梯、板块资金流、筹码分布 |
| `references/group-e-events.md` | 查公告、机构调研（新闻已下线） |
| `references/group-f-sector.md` | 查概念板块、同花顺板块、成分股 |
| `references/group-g-convertible.md` | 查可转债列表、转股价变动 |
| `references/group-h-quant.md` | 查量化因子注册表、个股技术面因子 |
| `references/group-i-macro.md` | 查 GDP/CPI/PPI/PMI 宏观数据 |
| `references/group-j-tools.md` | 查交易日历 |
| `references/group-k-agent.md` | 用 profile/full 综合画像、factor-categories 因子分类 |

### 示例与场景

| 参考文件 | 何时读取 |
|---------|---------|
| `references/examples.md` | 需要多接口配合的复杂分析场景（综合画像/涨停复盘/北向跟踪/可转债/宏观择时） |

---

## 调用工作流

1. **收到用户意图** → 先查上方「场景速查表」确定接口组合
2. **首次调用前** → 读取 `references/boundaries.md` 了解 limit 上限和参数易错点
3. **需要具体端点参数/返回字段** → 按场景速查表指向的组别，读取对应 `references/group-*.md`
4. **生成分析输出前** → 读取 `references/safety-rules.md` 遵守强制行为规则
5. **简单查询**（如「查下茅台行情」）→ 只需场景速查表 + `group-a-quote.md`，无需加载全部文件

---

## 关键约束速记（调任何接口前先扫一眼）

### limit 上限（超限静默截断，不报错）

| 接口 | 上限 | 接口 | 上限 |
|---|---|---|---|
| `daily` | 30 | `quotes` | 10 只 |
| `macro` | 12 | `ranking`/`limit-list`/`dragon-tiger` 等 | 50 |
| `announcements` | 30 | `calendar` | 跨度 ≤ 366 天（**超范围会报错**） |

### 参数易错点

- **枚举参数优先用英文**：`sector-flow?type=industry/concept/region`
- **中文关键字必须 URL 编码**：用 `curl -G --data-urlencode "q=年报"`
- **symbol vs tsCode**：A 股 `symbol=000001`（6 位）；指数 `tsCode=000300.SH`；可转债 `stkCode=688535.SH`
- **日期格式 YYYYMMDD**：start/end 必须成对传入
- **错误响应**：HTTP 400 + `success=false` + `X-Tdc-Error-Code` header；先检查状态再读 data
- **不存在 symbol**：返回 `RESOURCE_NOT_FOUND`，先用 `stocks` 搜索确认

> 完整 header 说明、错误码表、缓存策略、Freshness SLA、fields 裁剪、compact 模式等详见 `references/boundaries.md`。

---

## 注意事项

- 所有接口**只读、免鉴权**，无需注册或 token
- symbol 统一 **6 位数字代码**；指数/可转债用带后缀的 `tsCode`
- 单次请求超时建议 10 秒；复杂画像优先**并发**调用
- **空数据 ≠ 接口异常**：`success=true` + 空数组是数据稀疏，不是报错
- **token 紧张时**：用 `?fields=` 裁剪 + `?format=compact` 紧凑模式，可省 60-90% token
- 输出分析必须标注数据时效（`trade_date` / `delayed_minutes` / Freshness header）
- 数据来源：天启云(ApocData Cloud)，公告 T+0 08:00，北向 20:00

---

## 金融输出安全约束（摘要）

> 完整规则见 `references/safety-rules.md`。以下为 6 条强制规则摘要：

1. **数据时效透明** — 每次输出必须显示 `trade_date` / `delayed_minutes`
2. **数据来源分层** — 区分原始数据、AI 摘要、模型推断
3. **异常数据约束** — `success=false` 或关键字段缺失时停止确定性结论
4. **交叉验证** — 关键数据至少两个来源确认
5. **禁止买卖指令** — 严禁"买入/卖出/必涨/稳赚"等确定性表述
6. **免责声明** — 每次输出末尾注明"仅供研究参考，不构成投资建议"
