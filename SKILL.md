---
name: apocdata
description: Use when users ask for A-share or Hong Kong, China stock market quotes, financials, capital flows, technical factors, announcements, sectors, convertible bonds, macro data, or comprehensive stock analysis through the ApocData public API.
---

# 天启至数™ · ApocData Skill — A 股数据 Skill

> **天启技能** —— 免鉴权，零依赖，直接用 curl 调用，支持 Claude / OpenAI / 通义千问等所有 Agent。

## 安装（两步，无需 pip）

```bash
mkdir -p ~/.claude/skills/apocdata
curl -o ~/.claude/skills/apocdata/SKILL.md \
  https://raw.githubusercontent.com/ApocData/ApocData-skill/main/SKILL.md
```

重启 Claude Code 后自动生效。

---

## 基础用法

所有接口均为 HTTP GET，用 curl 直接调用：

```bash
BASE="https://data.tianqis.com/api/blade-dataplatform/open/data"

# 查单只股票行情
curl -s "$BASE/quote?symbol=000001"

# 查股票基本信息（含 PE/PB/市值）
curl -s "$BASE/stock?symbol=000001"
```

### OpenAPI 3 接入（GPT Actions / Coze / Dify / n8n / Zapier）

提供标准 **OpenAPI 3.0 JSON**，可一键导入到 GPT Actions / Coze / Dify / n8n / Zapier 等平台，自动生成全部公开接口：

| 端点 | 用途 |
|---|---|
| `https://data.tianqis.com/api/blade-dataplatform/open/data/openapi.json` | **OpenAPI 3 JSON（推荐，导入即用）**，免鉴权匿名访问，覆盖全部公开接口 |

> spec 的 `servers.url` 已内置为公网基址，导入后各接口路径直接拼接即可调用，无需再改 base。
> 注：Knife4j 默认页 `doc.html` 与 springdoc 默认 `/v3/api-docs` 在公网域名下被前端 SPA 路由占用、不对外；对接一律以上面的 `openapi.json` 为准。

无需注册，匿名可访问。

---

## 场景速查（按用户意图找接口组合）

> 拿到自然语言意图时，**优先查本表选定接口组合**，再去下方接口字典看字段细节，避免漏调或乱调。

| 用户意图 | 推荐调用顺序 | 关键说明 |
|---|---|---|
| 个股综合画像 / 「这只票怎么样」 | **推荐**：`profile/full?symbol=X`（一次返回 8 维数据） | 等价于并发调 8 个单接口，延时减 60%+ |
| 个股综合画像（分步精细化） | `quote` → `stock` → `financial` → `tech-factor` → `moneyflow` → `announcements` | 需要按维度独立控制 limit/fields 时用 |
| 估值评估 / 「贵不贵」 | `stock` → `financial` → `daily?limit=30` | 看 PE/PB/PEG，结合近期走势判断 |
| 资金动向追踪 / 「主力在干嘛」 | `moneyflow` → `hsgt` → `hk-hold` → `dragon-tiger` → `hot-money-detail` | 北向 20:00 后更新 |
| 涨停盘后复盘 / 「今天涨停的共性」 | `limit-list?kind=U` → `limit-step` → `sector-flow` → `hot-money-detail` | date 不传默认最新交易日 |
| 板块 / 概念热度 | `sector-flow` → `concepts` → `concept-stocks` 或 `ths-boards` → `ths-board-stocks` | 东财与同花顺双源，可交叉验证 |
| 公告 / 事件驱动 | `announcements` → `survey` → `share-float` → `repurchase` → `dividend` | announcements 返回 Markdown 全文 + AI 摘要 |
| 大盘择时 / 宏观判断 | `index-daily?tsCode=000300.SH` → `macro/latest?type=PMI` → `macro/latest?type=CPI` → `hsgt` | 宏观接口最多 12 条 |
| 可转债套利 | `convertible-bonds` → `cb-price-chg` → `quote`(正股) | 用 stkCode 反查正股可转债 |
| 找游资偏好的票 | `hot-money` → `hot-money-detail` → `dragon-tiger` | 当日游资明细 + 历史席位 |
| 退市/风险排查 | `st` → `share-float` → `holders` → `announcements` | st 返回 null 即非 ST |
| 业绩超预期追踪 | `express` → `financial` → `survey` → `announcements` | express 是季报前的先行指标 |
| 找具体行业 / 名字模糊 | `stocks?q=关键词` → `stock` 逐只确认 | 支持代码、名称、行业三种模糊匹配 |

---

## 接口边界与已知行为（必读）

> 这一段直接影响 LLM 调用准确率，**调任何接口前先扫一眼本节**。

### limit 上限速查（超限会**静默截断**，不会报错）

| 接口 | 文档上限 | 注意 |
|---|---|---|
| `daily` | 30 | 超过传 100 也只返 30 |
| `macro` | 12 | 同上 |
| `quotes` | 10 只 symbol | 多传的会被丢弃 |
| `ranking` / `limit-list` / `dragon-tiger` / `limit-step` / `hot-money-detail` / `sector-flow` / `concepts` / `concept-stocks` / `ths-boards` / `ths-board-stocks` / `hot-rank` | 50 | 静默截断 |
| `announcements` | 5 | 单条含 Markdown 全文 5-10KB，token 紧张时优先调 1-2 条 |
| `survey` / `block-trade` / `holder-number` / `share-float` / `repurchase` / `dividend` / `moneyflow` / `hsgt` / `hk-hold` / `hk-daily` / `cb-price-chg` / `tech-factor` / `cyq-perf` / `express` / `margin` / `financial` | 见各接口示例 | 通常 10 或 4 |
| `calendar` | 起止跨度 ≤ 366 天 | **超范围会显式报错（非静默）** |

### 数据稀疏接口（返回空数组 ≠ 接口异常）

| 接口 | 已知情况 | 建议 |
|---|---|---|
| `express` | 仅季报前后约 1 个月窗口有数据 | 没数据时改查 `financial` |
| `block-trade` / `survey` | 部分小盘股长期无大宗/无调研 | 空返回不代表股票有问题 |

### 参数易错点（来自实测）

- **枚举参数优先用英文**：`sector-flow?type=industry/concept/region`（中文 `行业/概念/地域` 仍兼容但需 URL 编码，bash 直传中文偶发被吞）
- **中文搜索关键字必须 URL 编码**：`q=` / `industry=` 等带中文时（如 `announcements?q=年报`、`stocks?q=银行`），bash 直接拼 URL 会 `HTTP 400`；请用 `curl -G --data-urlencode "q=年报"`，或在代码里交给 HTTP 客户端自动编码
- **symbol vs tsCode**：A 股个股一律 6 位数字 `symbol=000001`（不带交易所后缀）；指数用带后缀的 `tsCode=000300.SH`；可转债正股反查用 `stkCode=688535.SH`
- **日期格式统一 YYYYMMDD**：start/end 必须**成对**传入，单传无效
- **错误参数会静默回退默认值**（如 `direction=foobar` 会回退到 `direction=gain` 返回涨幅榜），LLM 拼错时返回数据**看起来正常但语义错**，请校验返回中的字段含义是否符合预期
- **不存在的 symbol 返回 200 + `data: {}`**，不会报 404，需要判空

### 性能基线（实测）

- 单接口 P50 延时 130-180ms，10 并发无排队
- `announcements`（含 Markdown 全文）单条 174ms，**最 token 重**
- 复杂画像建议**并发拉取**而非串行

### HTTP 响应 Header（机器可读 meta）

> 所有 `/open/data/*` 接口都会在 **HTTP 响应头**里携带额外元信息。**JSON 响应体结构不变**，header 是附加增强。Agent 可读 header 来感知限流额度/截断状态/数据稀疏/错误码，避免误判。

| Header | 出现时机 | 含义 |
|---|---|---|
| `X-RateLimit-Limit` | 每次请求 | 当前 IP 每日额度上限（默认 2000） |
| `X-RateLimit-Remaining` | 每次请求 | 当日剩余额度 |
| `X-RateLimit-Reset` | 每次请求 | 额度重置时间（Unix 时间戳，本地次日 0 点） |
| `X-RateLimit-Tier` | 每次请求 | 当前套餐（`free`） |
| `X-Tdc-Limit-Applied` | 每次请求 | 实际生效的 limit 值 |
| `X-Tdc-Limit-Max` | 每次请求 | 该接口的 limit 硬上限 |
| `X-Tdc-Limit-Truncated` | **仅当用户传值超过上限** | `true` — 表示请求被静默截断（参考下方上限速查） |
| `X-Tdc-Limit-Requested` | 仅当截断时 | 用户原始传入的 limit 值 |
| `X-Tdc-Coverage` | **仅当返回空数组时** | `sparse` — 表示该接口数据本身就稀疏，空 != 异常 |
| `X-Tdc-Coverage-Reason` | 仅当 Coverage=sparse | 稀疏原因中文说明 |
| `X-Tdc-Fields-Applied` | 仅当 `?fields=` 生效时 | 实际生效的字段白名单 |
| `X-Tdc-Format` | 仅当 `?format=compact` 生效时 | `compact` — 列式输出已应用 |
| `X-Tdc-Format-Row-Count` | 仅紧凑模式 | 实际行数 |
| `X-Tdc-Aggregated-Endpoints` | 仅 `/profile/full` | 聚合的子接口数（恒为 8） |
| `X-Tdc-Aggregation-Time-Ms` | 仅 `/profile/full` | 实际聚合耗时（毫秒） |
| `X-Tdc-Freshness-Tier` | 每次成功请求 | 数据时效粗分类：`intraday` / `post-close` / `t0-morning` / `quarterly` / `metadata` / `aggregated`（详见下方「数据 SLA / Freshness」段落） |
| `X-Tdc-Freshness-Detail` | 每次成功请求 | 时效细节描述（如 `continuous 09:30-15:00, 15min delay`、`daily 17:00`） |
| `Cache-Control` | 每次请求 | `public, max-age=N`（按接口业务属性自动设档，见下方「缓存策略」段落） |
| `X-Tdc-Error-Code` | **仅错误响应** | 机器可读错误码（见下表） |
| `X-Tdc-Error-Field` | 仅错误响应 | 出错的参数名 |
| `X-Tdc-Doc-Url` | 仅错误响应 | 跳转的文档地址 |

### 错误码（X-Tdc-Error-Code 取值）

| 错误码 | 触发场景 | 调用方应对 |
|---|---|---|
| `INVALID_PARAM_VALUE` | 枚举值非法（type/direction/kind/exchange） | 按 msg 文本里的"仅支持 ..."重试 |
| `INVALID_PARAM_FORMAT` | 日期格式错（必须 YYYYMMDD） | 按格式重试 |
| `MISSING_REQUIRED_PARAM` | start/end 非成对传入等 | 补齐参数 |
| `PARAM_OUT_OF_RANGE` | 日期跨度超 366 天等 | 缩短跨度 |
| `RESOURCE_NOT_FOUND` | symbol 在 stock_basic_info 中找不到 | 校验股票代码，或先用 stocks 搜索 |

> 错误响应仍是 `{"code":400,"success":false,"msg":"..."}` 的 R 包装结构，HTTP 状态码保持 200。**结构化错误信息全部在 header 里**——这是兼容性优先的设计。

### 字段裁剪 `?fields=`（token 优化，全局支持）

**所有 46 个公开接口都支持** `?fields=col1,col2,...` 字段白名单，节省 LLM token。响应只保留指定字段，列序保持参数顺序，不存在的字段自动忽略：

```bash
# 财务接口只取关键字段（60+ 字段 → 3 字段）
curl -s "$BASE/financial?symbol=000001&fields=roe,revenue,net_profit"

# 公告只取标题摘要不取 Markdown 全文（节省 80% token）
curl -s "$BASE/announcements?symbol=000001&fields=title,summary,ann_date"

# 任意接口都能用：行情只取 3 个核心字段
curl -s "$BASE/quote?symbol=600519&fields=symbol,close,pct_chg"

# 排行榜只取代码和涨幅
curl -s "$BASE/ranking?direction=gain&limit=20&fields=symbol,pct_chg"
```

响应 header 回显 `X-Tdc-Fields-Applied`，可校验是否裁剪生效。

> 历史版本仅 `financial` / `announcements` 显式支持；自 2026-05 起全局 advice 统一处理，所有接口生效。

### 紧凑模式 `?format=compact`（列式输出，节省 60-70% token）

所有**列表类接口**支持列式输出——把"每行重复的字段名"提取到顶部 `columns`，行数据用数组的数组，**对 LLM token 极友好**。

```bash
# 默认行式（适合人类阅读）
curl -s "$BASE/ranking?limit=3"
# 返回: { "data": [
#   { "symbol":"000001", "name":"平安银行", "close":10.78, "pct_chg":0.94 },
#   { "symbol":"600519", "name":"贵州茅台", "close":1273.38, "pct_chg":-0.97 },
#   { "symbol":"688017", "name":"绿的谐波", "close":62.5, "pct_chg":3.21 }
# ]}

# 紧凑模式（同样数据，token 减半）
curl -s "$BASE/ranking?limit=3&format=compact"
# 返回: { "data": {
#   "columns": ["symbol","name","close","pct_chg"],
#   "rows": [
#     ["000001","平安银行",10.78,0.94],
#     ["600519","贵州茅台",1273.38,-0.97],
#     ["688017","绿的谐波",62.5,3.21]
#   ]
# }}
```

**适用接口**：所有返回列表的接口（ranking / limit-list / stocks / concepts / financial / moneyflow / dragon-tiger / hot-money-detail / ...）

**自动跳过**（保持原结构）：
- 单条接口（`quote` / `stock` / `macro/latest` / `st`）
- 综合画像（`profile/full`，本身是聚合 Map）
- `calendar`（已经是字符串数组）
- 错误响应（保持 R.fail 结构）

**响应 header**：`X-Tdc-Format: compact` + `X-Tdc-Format-Row-Count: <实际行数>`

### 缓存策略 `Cache-Control`（自动透明）

所有响应都会带 `Cache-Control` header，**CDN / 浏览器 / OkHttp / okhttp 等中间层可安全复用**，无需调用方手动处理：

| 接口类别 | max-age | 包含接口 |
|---|---|---|
| **盘中实时** | `5s` | `quote` / `quotes` / `ranking` / `hot-rank` / `sector-flow` / `moneyflow` / `limit-list` / `limit-step` / `dragon-tiger` / `hot-money-detail` |
| **盘后日更** | `5min`（300s） | `daily` / `index-daily` / `hk-daily` / `hsgt` / `hk-hold` / `margin` / `cyq-perf` / `tech-factor` / `financial` / `express` / `dividend` / `share-float` / `repurchase` / `holder-number` / `block-trade` / `announcements` / `survey` / `holders` |
| **元数据/低频** | `1h`（3600s） | `stock` / `stocks` / `st` / `indexes` / `factors` / `factor-categories` / `concepts*` / `ths-boards*` / `convertible-bonds` / `cb-price-chg` / `hot-money` / `calendar` / `macro*` |
| **综合画像** | `30s` | `profile/full`（取所有子接口最严约束） |
| **错误响应** | `no-store` | 所有 `success=false`（防止错误结果被中间层固化） |

**典型实践**：写本地脚本批量拉数据时，直接用 OkHttp / requests 默认配置即可——cache 行为完全由后端 header 控制。重复拉同一接口在 max-age 窗口内**直接命中缓存零延时**。

### 数据 SLA / Freshness（接口数据时效）

每次成功响应都会带 `X-Tdc-Freshness-Tier` + `X-Tdc-Freshness-Detail` header，让 Agent 知道**该接口的数据多新**，避免拿"昨天的数据当今天用"。

| Tier | 含义 | 涉及接口 |
|---|---|---|
| `intraday` | 盘中实时（FREE 套餐 15min 延迟） | `quote` / `quotes` / `ranking` / `hot-rank` / `sector-flow` / `moneyflow` |
| `post-close` | 盘后批量更新 | 16:30：`limit-list` / `limit-step` / `dragon-tiger` / `hot-money-detail` / `cyq-perf`；17:00-18:00：`daily` / `index-daily` / `hk-daily` / `tech-factor` / `margin` / `block-trade`；20:00：`hsgt` / `hk-hold` |
| `t0-morning` | 当天 T+0 早上 08:00 入库 | `announcements` / `survey` |
| `quarterly` | 季报披露窗口（报告期后约 1 个月） | `financial` / `express` / `dividend` / `share-float` / `repurchase` / `holder-number` / `holders` |
| `metadata` | 元数据/字典低频更新 | `stock` / `stocks` / `st` / `indexes` / `factors` / `factor-categories` / `concepts*` / `ths-boards*` / `convertible-bonds` / `cb-price-chg` / `hot-money` / `calendar` / `macro*` |
| `aggregated` | 聚合接口（取最严约束） | `profile/full` |

**Agent 典型用法**：
- 看到 `Freshness-Tier=intraday` 且当前已收盘 → 数据是 14:55 快照
- 看到 `post-close` 且当前 19:00 → 数据应是当日 17:00 的
- 看到 `t0-morning` 且当前 07:00 → 数据可能还是昨日的，下次调用时间放到 08:30 后

---

## 工具列表

> 全部 **46 个接口按使用场景分 11 组**，编号采用 A1/A2、B1/B2 形式以体现分组归属。同一组内的接口通常配合使用。

| 组别 | 主题 | 接口数 |
|---|---|---|
| [A](#a-行情与估值10-个) | 行情与估值 | 10 |
| [B](#b-财务与基本面8-个) | 财务与基本面 | 8 |
| [C](#c-资金博弈8-个) | 资金博弈 | 8 |
| [D](#d-涨跌停与情绪4-个) | 涨跌停与情绪 | 4 |
| [E](#e-事件与信息2-个) | 事件与信息 | 2 |
| [F](#f-板块概念4-个) | 板块/概念 | 4 |
| [G](#g-可转债2-个) | 可转债 | 2 |
| [H](#h-量化与技术2-个) | 量化与技术 | 2 |
| [I](#i-宏观3-个) | 宏观 | 3 |
| [J](#j-工具1-个) | 工具 | 1 |
| [K](#k-agent-增强2-个) | **🆕 Agent 增强**（一次拉全 / 因子分类） | **2** |

---

## A. 行情与估值（10 个）

涵盖个股/指数实时与历史行情、估值快照、股票搜索、涨跌排行与人气榜。**做任何分析前的起点。**

### A1. 实时行情 `quote`

查单只股票最新涨跌、量价。

```bash
curl -s "$BASE/quote?symbol=688017"
# 返回: symbol, name, trade_date, open, high, low, close,
#       pre_close, change, pct_chg, volume, amount
```

**示例问题**：「688017 今天涨了多少？」「茅台现在什么价格？」

---

### A2. 批量行情 `quotes`

最多同时查 10 只股票。

```bash
curl -s "$BASE/quotes?symbols=000001,600519,000858"
```

**示例问题**：「帮我看下茅台、五粮液、平安银行今天的涨跌」

---

### A3. 日K历史 `daily`

最近 N 条日K，或按日期区间查询，均最多 30 条。

```bash
# 最近 N 条
curl -s "$BASE/daily?symbol=000001&limit=30"
# 按日期区间（start/end 为 YYYYMMDD，需成对传入）
curl -s "$BASE/daily?symbol=000001&start=20260101&end=20260331"
# 返回: trade_date, open, high, low, close, volume, amount, pct_chg
```

**示例问题**：「平安银行最近 30 天走势」「平安银行 2026 年 1 月的日K」

---

### A4. 股票基本信息 `stock`

行业、市值、PE、PB、上市日期。

```bash
curl -s "$BASE/stock?symbol=688017"
# 返回: symbol, name, market, industry, pe, pb, total_mv, circ_mv
```

**示例问题**：「688017 的估值怎么样？PE 是多少？」

---

### A5. 股票搜索 `stocks`

按名称/代码关键词搜索，支持行业过滤。

```bash
# 中文参数必须 URL 编码
curl -s -G "$BASE/stocks" \
  --data-urlencode "q=银行" \
  --data-urlencode "industry=银行" \
  --data-urlencode "limit=20"
curl -s "$BASE/stocks?q=688017"
```

**示例问题**：「帮我找所有银行股」「搜索新能源相关股票」

---

### A6. ST 状态 `st`

是否 ST / 退市风险，正常股返回 null。

```bash
curl -s "$BASE/st?symbol=000001"
```

**示例问题**：「这只股票有退市风险吗？」

---

### A7. 涨跌幅排行榜 `ranking`

全市场按当日涨跌幅排序，涨幅榜 / 跌幅榜。

```bash
# 涨幅榜（默认）
curl -s "$BASE/ranking?direction=gain&limit=20"
# 跌幅榜
curl -s "$BASE/ranking?direction=loss&limit=20"
# 返回: symbol, name, trade_date, close, change, pct_chg, volume, amount
# direction=gain（涨幅榜）/ loss（跌幅榜），limit 最多 50
```

**示例问题**：「今天涨得最多的 10 只股票」「今日跌幅榜前 20」

---

### A8. 指数列表搜索 `indexes`

按名称/代码搜索指数。

```bash
curl -s -G "$BASE/indexes" --data-urlencode "q=沪深300"
curl -s "$BASE/indexes?market=CSI&limit=20"
# 返回: ts_code, name, market, publisher, category, base_date, base_point
```

**示例问题**：「沪深300 的指数代码是多少？」「有哪些中证指数？」

---

### A9. 指数日K `index-daily`

指数日K行情（用指数 tsCode 查询，可先用 `indexes` 查代码）。

```bash
curl -s "$BASE/index-daily?tsCode=000300.SH&limit=30"
# 常用：000001.SH 上证指数、000300.SH 沪深300、399006.SZ 创业板指
# 返回: trade_date, open, high, low, close, pre_close, change, pct_chg, vol, amount
```

**示例问题**：「沪深300 最近 30 天走势」「上证指数昨天涨了多少？」

---

### A10. 人气榜 `hot-rank`

东方财富人气榜（个股热度排名）。

```bash
curl -s "$BASE/hot-rank?type=A股市场&limit=30"
# type 可选 A股市场 / ETF基金
# 返回: trade_date, ts_code, ts_name, rank, pct_change, current_price
```

**示例问题**：「今天 A 股人气榜前 10 是哪些？」

---

## B. 财务与基本面（8 个）

覆盖财务报表、业绩快报、分红、股东结构、限售/回购/大宗等基本面与股本事件。**适合做估值评判和长期分析。**

### B1. 财务数据 `financial`

ROE、营收、净利润等，最多 4 期。单条返回 60+ 字段，token 紧张时建议加 `?fields=` 裁剪。

```bash
curl -s "$BASE/financial?symbol=000001&limit=4"
# 返回: report_period, report_type, roe, revenue, net_profit,
#       grossprofit_margin, eps, bps, debt_to_assets 等 60+ 字段
#       注: 上述字段按报告期稀疏填充——最新期可能缺 eps/bps、银行股 grossprofit_margin 常为空，以实际返回为准

# token 优化：只取关键字段（节省 90% token）
curl -s "$BASE/financial?symbol=000001&limit=4&fields=roe,revenue,net_profit"
```

**示例问题**：「平安银行的 ROE 怎么样？」「最近 4 期净利润趋势」

---

### B2. 业绩快报 `express`

个股业绩快报（营收、净利润、EPS、ROE）。

```bash
curl -s "$BASE/express?symbol=000001&limit=4"
# 返回: end_date, ann_date, revenue, n_income, total_profit, diluted_eps,
#       diluted_roe, yoy_net_profit, total_assets
```

**示例问题**：「平安银行最新业绩快报」「这家公司净利润同比增长多少？」

---

### B3. 分红送配 `dividend`

个股历史分红送配方案。

```bash
curl -s "$BASE/dividend?symbol=000001&limit=10"
# 返回: end_date, ann_date, div_proc, stk_div, cash_div, cash_div_tax,
#       record_date, ex_date, pay_date
```

**示例问题**：「平安银行的分红方案」「茅台今年分红多少？」

---

### B4. 十大股东 `holders`

最新期十大股东 / 十大流通股东。

```bash
curl -s "$BASE/holders?symbol=000001&holderCategory=top10_float"
# 返回: holder_name, hold_amount, hold_ratio, hold_change, holder_type
```

**示例问题**：「平安银行十大流通股东是哪些机构？」

---

### B5. 股东户数 `holder-number`

个股历史股东户数。

```bash
curl -s "$BASE/holder-number?symbol=000001&limit=10"
# 返回: ann_date, end_date, holder_num
```

**示例问题**：「这只股票股东户数是增是减？」

---

### B6. 限售解禁 `share-float`

个股限售股解禁记录。

```bash
curl -s "$BASE/share-float?symbol=000001&limit=10"
# 返回: ann_date, float_date, float_share, float_ratio, holder_name, share_type
```

**示例问题**：「平安银行近期有解禁吗？解禁多少？」

---

### B7. 股票回购 `repurchase`

个股回购方案与进度。

```bash
curl -s "$BASE/repurchase?symbol=000001&limit=10"
# 返回: ann_date, proc, vol, amount, high_limit, low_limit
```

**示例问题**：「这家公司在回购股票吗？」

---

### B8. 大宗交易 `block-trade`

个股大宗交易记录（成交价、折溢价、买卖营业部）。

```bash
curl -s "$BASE/block-trade?symbol=000001&limit=10"
# 返回: trade_date, price, vol, amount, buyer, seller
```

**示例问题**：「平安银行最近有大宗交易吗？」

---

## C. 资金博弈（8 个）

主力/北向/两融/龙虎/游资全口径资金视角。**短线择时与盯盘核心。**

### C1. 个股资金流 `moneyflow`

个股超大单/大单/中单/小单买卖额与主力净流入。

```bash
curl -s "$BASE/moneyflow?symbol=000001&limit=10"
# 返回: trade_date, buy_elg_amount, sell_elg_amount, buy_lg_amount, sell_lg_amount,
#       buy_md_amount, sell_md_amount, buy_sm_amount, sell_sm_amount, net_mf_amount
```

**示例问题**：「平安银行最近主力是流入还是流出？」

---

### C2. 沪深港通资金流 `hsgt`

北向（陆股通）、南向（港股通）每日资金流。

```bash
curl -s "$BASE/hsgt?limit=10"
# 返回: trade_date, hgt, sgt, ggt_ss, ggt_sz, north_money, south_money
```

**示例问题**：「最近北向资金是买还是卖？」「今天北向净流入多少？」

---

### C3. 沪深港通持股 `hk-hold`

个股被沪深港通（北向）持股记录。

```bash
curl -s "$BASE/hk-hold?symbol=000001&limit=10"
# 返回: trade_date, name, ratio（持股占比）, vol（持股量）
```

**示例问题**：「北向资金持有平安银行多少？」

---

### C4. 港股日K `hk-daily`

查询中国香港股票日 K 行情，代码必须带 `.HK` 后缀。

```bash
curl -s "$BASE/hk-daily?tsCode=00700.HK&limit=30"
# 返回: trade_date, open, high, low, close, pre_close, change, pct_chg, vol, amount
```

**示例问题**：「腾讯控股最近 30 个交易日走势」「阿里巴巴-SW 昨天涨了多少？」

---

### C5. 融资融券 `margin`

两市融资融券交易汇总（**交易所级别聚合**）。

> ⚠️ 本接口仅支持按交易所（`exchange=SSE/SZSE/BSE`）筛选，**不支持按个股过滤**（`symbol` 参数无效）。  
> 要查个股资金流向请用 `/moneyflow`。

```bash
curl -s "$BASE/margin?exchange=SSE&limit=10"
# exchange 可选 SSE/SZSE/BSE，不传则返回三所合并
# 返回: trade_date, exchange_id, rzye（融资余额）, rzmre（融资买入额）,
#       rqye（融券余额）, rzrqye（融资融券余额）
```

**示例问题**：「最近两融余额是多少？」「融资余额在增加吗？」「上交所两融情况？」

---

### C6. 龙虎榜 `dragon-tiger`

某交易日龙虎榜单，或某个股的上榜历史。

```bash
# 当日榜单（date 缺省取最新交易日）
curl -s "$BASE/dragon-tiger?date=20260518&limit=30"
# 某个股上榜历史
curl -s "$BASE/dragon-tiger?symbol=000001"
# 返回: trade_date, ts_code, name, close, pct_change, turnover_rate, amount,
#       l_buy, l_sell, net_amount, reason
```

**示例问题**：「今天龙虎榜有哪些股票？」「平安银行上过龙虎榜吗？」

---

### C7. 游资名录 `hot-money`

知名游资席位名录。

```bash
curl -s "$BASE/hot-money?limit=50"
# 返回: name（游资名）, orgs（关联营业部）
```

**示例问题**：「有哪些知名游资？」

---

### C8. 游资交易明细 `hot-money-detail`

某交易日游资买卖明细，或某个股的游资记录。

```bash
# 当日明细（date 缺省取最新交易日）
curl -s "$BASE/hot-money-detail?date=20260518&limit=30"
# 某个股的游资记录
curl -s "$BASE/hot-money-detail?symbol=600730"
# 返回: trade_date, ts_code, ts_name, buy_amount, sell_amount,
#       net_amount, hm_name, hm_orgs
```

**示例问题**：「今天游资都在买什么？」

---

## D. 涨跌停与情绪（4 个）

打板、连板、板块情绪、筹码结构。**A 股短线散户最关注的视角。**

### D1. 涨跌停池 `limit-list`

某交易日的涨停 / 跌停 / 炸板个股。

```bash
curl -s "$BASE/limit-list?kind=U&date=20260518&limit=30"
# kind=U 涨停 / D 跌停 / Z 炸板，date 缺省取最新交易日
# 返回: trade_date, ts_code, name, industry, close, pct_chg, amount,
#       first_time, last_time, open_times, up_stat, limit_times, limit
```

**示例问题**：「今天有多少只涨停？」「最近一个交易日的跌停股」

---

### D2. 连板天梯 `limit-step`

某交易日连板个股，按连板数排列。

```bash
curl -s "$BASE/limit-step?limit=30"
# date 缺省取最新交易日
# 返回: trade_date, ts_code, name, nums（连板数）
```

**示例问题**：「今天最高几连板？」「现在的连板天梯」

---

### D3. 板块资金流榜 `sector-flow`

最新交易日行业/概念/地域板块的资金流排行。

```bash
# 推荐：英文枚举（bash 直传不踩 URL 编码坑）
curl -s "$BASE/sector-flow?type=industry&limit=20"
curl -s "$BASE/sector-flow?type=concept&limit=20"
curl -s "$BASE/sector-flow?type=region&limit=20"

# 兼容：中文枚举仍受理（需 URL 编码）
curl -s "$BASE/sector-flow?type=%E8%A1%8C%E4%B8%9A&limit=20"
# 返回: trade_date, name, pct_change, net_amount, net_amount_rate, rank
```

**示例问题**：「今天哪个行业资金流入最多？」「概念板块资金流排行」

---

### D4. 筹码分布 `cyq-perf`

个股筹码分布与获利比例。

```bash
curl -s "$BASE/cyq-perf?symbol=000001&limit=5"
# 返回: trade_date, his_low, his_high, cost_5pct, cost_50pct, cost_95pct,
#       weight_avg（加权平均成本）, winner_rate（获利比例）
```

**示例问题**：「平安银行现在的获利盘比例是多少？」「主力成本大概在哪？」

---

## E. 事件与信息（2 个）

公告、机构调研两类事件信息源。**事件驱动策略的输入。**

### E1. 公司公告 `announcements`

按股票查公告（标题、AI 摘要、Markdown 完整正文、公告日期、类型、链接），**支持区间/类型/关键字过滤**，上限 30 条。

```bash
# 默认：最新 5 条，含完整 content
curl -s "$BASE/announcements?symbol=000001"
# 返回: title, summary, content, ann_date, publish_time, category,
#       importance, sentiment, keywords, source, url

# 按日期区间查（YYYYMMDD）
curl -s "$BASE/announcements?symbol=000001&startDate=20260101&endDate=20260331&limit=30"

# 按公告类型精确过滤（注意：category 取值较粗，实际为 company_announcement / policy_news，
# 并非 annual_report 这类细分报告类型；要定位"年报/定增"等具体报告请用 q 标题关键字）
curl -s "$BASE/announcements?symbol=000001&category=company_announcement"

# 按标题关键字模糊搜索（不走 content 全文；q 含中文，用 -G --data-urlencode，否则 bash 直传 400）
curl -s -G "$BASE/announcements" --data-urlencode "symbol=000001" --data-urlencode "q=年度报告"

# 列表浏览模式：跳过 content 全文，省 80% 网络流量
curl -s "$BASE/announcements?symbol=000001&limit=20&includeContent=false"

# 列表 + 字段裁剪组合（最极致省 token）
curl -s "$BASE/announcements?symbol=000001&limit=20&includeContent=false&fields=title,ann_date,category,sentiment"
```

**示例问题**：
- 「平安银行最近发布了哪些公告？」（默认 5 条）
- 「工行 2026 年 1-3 月所有公告」（startDate + endDate + limit=30）
- 「茅台 2025 年报全文」（用 `q=年度报告` 定位，再读 content；category 不区分报告细分类型）
- 「中国国航有没有定增公告？」（q=定增）

> 历史版本上限是 5 条且无过滤；自 2026-05-27 起增加区间/类型/关键字过滤，上限提到 30。

---

### E2. 机构调研 `survey`

个股机构调研接待记录。

```bash
curl -s "$BASE/survey?symbol=600101&limit=5"
# 返回: surv_date, rece_place, rece_mode, rece_org, comp_rece
```

**示例问题**：「这家公司最近接待了哪些机构调研？」

---

## F. 板块/概念（4 个）

东财与同花顺双源板块目录与成分股查询。**做主题/概念轮动必备。**

### F1. 东财概念板块 `concepts`

东方财富概念板块目录（最新交易日，含当日热度/领涨股）。

```bash
curl -s "$BASE/concepts?q=AI&limit=30"
# 返回: theme_code, name, pct_change, hot, z_t_num, main_change,
#       lead_stock, lead_stock_code
```

**示例问题**：「有哪些 AI 相关概念板块？」

---

### F2. 概念成分股 `concept-stocks`

某概念板块的成分股（themeCode 可从 `concepts` 获取）。

```bash
curl -s "$BASE/concept-stocks?themeCode=000894.DC&limit=50"
# 返回: ts_code, name, industry, reason, hot_num
```

**示例问题**：「光通信概念里有哪些股票？」

---

### F3. 同花顺板块 `ths-boards`

同花顺行业/概念板块指数。

```bash
curl -s -G "$BASE/ths-boards" --data-urlencode "q=机器人" --data-urlencode "limit=30"
# 返回: ts_code, name, count（成分数）, exchange, list_date, type
```

**示例问题**：「同花顺有哪些机器人板块？」

---

### F4. 同花顺板块成分 `ths-board-stocks`

某同花顺板块的成分股（tsCode 可从 `ths-boards` 获取）。

```bash
curl -s "$BASE/ths-board-stocks?tsCode=886108.TI&limit=50"
# 返回: con_code, con_name
```

**示例问题**：「这个板块的成分股有哪些？」

---

## G. 可转债（2 个）

可转债元数据与转股价历史。

### G1. 可转债列表 `convertible-bonds`

可转债基本信息（按债券或正股搜索）。

```bash
curl -s -G "$BASE/convertible-bonds" --data-urlencode "q=超声"
curl -s "$BASE/convertible-bonds?stkCode=688535.SH"
# 返回: ts_code, bond_short_name, stk_code, stk_short_name, issue_size,
#       value_date, maturity_date, coupon_rate, conv_price
```

**示例问题**：「华海诚科有没有发行可转债？」

---

### G2. 可转债转股价变动 `cb-price-chg`

可转债转股价的历史调整记录。

```bash
curl -s "$BASE/cb-price-chg?tsCode=127026.SZ&limit=10"
# 返回: publish_date, change_date, convert_price_initial,
#       convertprice_bef, convertprice_aft
```

**示例问题**：「超声转债下修过转股价吗？」

---

## H. 量化与技术（2 个）

平台量化因子注册表 + 个股技术指标快照。**做策略/选股的元数据入口。**

### H1. 量化因子注册表 `factors`

平台全部已启用的量化因子**元数据清单**（154 个，脱敏，不含计算公式/权重/打分）。

> ⚠️ 本接口返回的是**平台因子注册表**（因子名称、分类、是否启用），**不含个股因子值**，也不接受 `symbol` 参数。  
> 要查某股票的 MACD/KDJ/RSI 等技术指标实际值，请用 `/tech-factor`。

```bash
curl -s "$BASE/factors"
# 返回: rule_id, name, event_type_label, scope, enabled, version, updated_at
# 注意：这是因子配置注册表，非个股计算结果
```

**示例问题**：「平台支持哪些量化因子？」「有没有和涨停/事件相关的因子？」

---

### H2. 技术面因子 `tech-factor`

个股技术指标（MACD/KDJ/RSI/BOLL/均线等，前复权）。

```bash
curl -s "$BASE/tech-factor?symbol=000001&limit=1"
# 返回: trade_date, close, pct_chg, turnover_rate, pe_ttm, pb,
#       macd_qfq, kdj_k_qfq, kdj_d_qfq, rsi_qfq_6, boll_upper_qfq,
#       ma_qfq_5, ma_qfq_20, cci_qfq, wr_qfq 等
```

**示例问题**：「平安银行现在的 MACD 和 KDJ 怎么样？」

---

## I. 宏观（3 个）

GDP/CPI/PPI/PMI 历史与定义。**做大盘择时与板块景气度判断。**

### I1. 宏观指标历史 `macro`

GDP / CPI / PPI / PMI，最多 12 条。

```bash
curl -s "$BASE/macro?type=CPI&limit=12"
# 返回: period, value, yoy_growth, mom_growth
```

**示例问题**：「最近 12 个月 CPI 走势」

---

### I2. 宏观指标最新值 `macro/latest`

```bash
curl -s "$BASE/macro/latest?type=PMI"
# 返回: period, value, unit, yoy_growth
```

**示例问题**：「现在 PMI 是多少？」「最新 GDP 增速」

---

### I3. 宏观指标定义 `macro/definition`

查宏观指标的含义、单位、统计频率。

```bash
curl -s "$BASE/macro/definition?type=CPI"
# 返回: indicator_code, indicator_name, unit, frequency, description
# type 可选 GDP/CPI/PPI/PMI
```

**示例问题**：「CPI 这个指标是什么意思？」「PMI 多久更新一次？」

---

## J. 工具（1 个）

通用查询辅助。

### J1. 交易日历 `calendar`

查询区间内 A 股交易日列表，跨度最多 366 天。

```bash
curl -s "$BASE/calendar?start=20260101&end=20260331"
# 不传参默认查当年 1 月 1 日至今
curl -s "$BASE/calendar"
# 返回: ["20260102","20260105","20260106", ...]  按 YYYYMMDD 升序

# detail=true 返回 List<{trade_date, pretrade_date}>，便于算"上一交易日"
curl -s "$BASE/calendar?start=20260101&end=20260331&detail=true"
# 返回: [
#   {"trade_date":"20260102","pretrade_date":null},   // 区间内首日 pretrade_date=null
#   {"trade_date":"20260105","pretrade_date":"20260102"},
#   {"trade_date":"20260106","pretrade_date":"20260105"}, ...
# ]
```

**示例问题**：「2026 年 3 月有哪些交易日？」「最近一个交易日是哪天？」「20260301 的上一交易日是几号？」（用 detail=true）

---

## K. Agent 增强（2 个）

为 Agent / LLM 场景设计的聚合与元数据端点。**一次调用替代多次单接口拼接，token 利用率最大化。**

### K1. 个股综合画像 `profile/full`

**一次返回 8 维数据**：basic + quote + financial(4期) + tech-factor + cyq-perf + moneyflow(5日) + hk-hold(5日) + announcements(3条)。等价于并发调 8 次单接口，延时减少 60%+。

```bash
curl -s "$BASE/profile/full?symbol=688017"
# 返回结构（顶层 data 字段下）:
# {
#   "basic":               { symbol, name, industry, market, ... },
#   "quote":               { close, pct_chg, volume, ... },
#   "financial_trend":     [ {report_period, roe, revenue, ...}, ... ]  // 4 期
#   "technical":           { macd, kdj_k, rsi6, ma_5, ma_20, ... },
#   "chip_distribution":   { cost_50pct, weight_avg, winner_rate, ... },
#   "money_flow_5d":       [ {trade_date, net_mf_amount, ...}, ... ]   // 5 日
#   "north_capital":       [ {trade_date, ratio, vol, ...}, ... ]      // 5 日
#   "recent_announcements":[ {title, summary, ann_date, ...}, ... ]    // 3 条
# }
# 响应 Header:
#   X-Tdc-Aggregated-Endpoints: 8
#   X-Tdc-Aggregation-Time-Ms: <实际聚合耗时>
```

**容错保证**：任一子调用失败不影响整体——对应字段返回空对象 `{}` 或空数组 `[]`。

**示例问题**：「帮我看下 688017 怎么样」「全面分析一下平安银行」 → 直接调本端点即可，不需要再串联调 8 个接口。

---

### K2. 量化因子分类目录 `factor-categories`

返回 **15 个** event_type 业务分类的人类可读说明 + 各类因子数量（`factor_count`）。配合 `factors` 使用：`factors` 列出 **154** 个因子（脱敏），`factor-categories` 解释每个分类是干什么的。

> 注：15 个类目中**当前实际有因子的是 6 个**（合计 154）；另外 9 个（价值/成长/盈利质量/动量反转/博弈/资金情绪/波动率/流动性/规模杠杆）类目已建但 `factor_count` 当前为 0。

```bash
curl -s "$BASE/factor-categories"
# 返回 15 个类目；当前有因子的（factor_count>0，合计 154）：
#   { "event_type_label": "基本面事件", "factor_count": 68 },
#   { "event_type_label": "技术信号",   "factor_count": 61 },
#   { "event_type_label": "资金异动",   "factor_count": 18 },
#   { "event_type_label": "价格异动",   "factor_count": 4 },
#   { "event_type_label": "微观结构",   "factor_count": 2 },
#   { "event_type_label": "资金流",     "factor_count": 1 },
#   其余 9 个（价值/成长/盈利质量/动量反转/博弈/资金情绪/波动率/流动性/规模杠杆）factor_count 当前为 0
# ]
```

**示例问题**：「平台支持哪些类别的因子？」「有没有博弈类的因子？大概多少个？」

---

## 综合分析示例

> 复杂用户意图通常需要 3-6 个接口配合。下方示例**直接对应顶部「场景速查」**，给出可复用的调用模板。

### 场景 1：个股综合画像（「帮我看下 688017 怎么样」）

```bash
BASE="https://data.tianqis.com/api/blade-dataplatform/open/data"

# 1) 基本面 + 估值
curl -s "$BASE/stock?symbol=688017"            # PE/PB/市值/行业
curl -s "$BASE/quote?symbol=688017"            # 当前股价 + 涨跌幅

# 2) 财务趋势
curl -s "$BASE/financial?symbol=688017&limit=4"  # 最近 4 期 ROE/净利润

# 3) 技术面 + 筹码
curl -s "$BASE/tech-factor?symbol=688017&limit=1"  # MACD/KDJ/RSI/均线
curl -s "$BASE/cyq-perf?symbol=688017&limit=1"     # 主力成本/获利盘

# 4) 资金动向
curl -s "$BASE/moneyflow?symbol=688017&limit=5"    # 近 5 日主力净流入
curl -s "$BASE/hk-hold?symbol=688017&limit=5"      # 北向持仓变动

# 5) 近期事件
curl -s "$BASE/announcements?symbol=688017&limit=3"  # 近 3 条公告全文
```

**综合判断要点**：估值（stock）+ 业绩（financial）+ 资金（moneyflow/hk-hold）+ 催化（announcements）四维交叉。

---

### 场景 2：涨停盘后复盘（「今天涨停的票有什么共性」）

```bash
# 1) 当日涨停池
curl -s "$BASE/limit-list?kind=U&limit=50"
# 2) 连板天梯（高度）
curl -s "$BASE/limit-step?limit=30"
# 3) 板块资金流（找共同主线）
curl -s "$BASE/sector-flow?type=concept&limit=10"
curl -s "$BASE/sector-flow?type=industry&limit=10"
# 4) 当日游资明细（谁在炒）
curl -s "$BASE/hot-money-detail?limit=30"
```

---

### 场景 3：北向资金跟踪（「外资最近在买什么」）

```bash
# 1) 北向整体净流入趋势
curl -s "$BASE/hsgt?limit=10"
# 2) 对具体股票的持仓变动（需指定 symbol 逐只查）
curl -s "$BASE/hk-hold?symbol=600519&limit=10"
curl -s "$BASE/hk-hold?symbol=000858&limit=10"
# 3) 配合龙虎榜看机构席位
curl -s "$BASE/dragon-tiger?limit=30"
```

---

### 场景 4：可转债套利筛选（「找有机会的可转债」）

```bash
# 1) 可转债列表 / 关键词搜索
curl -s -G "$BASE/convertible-bonds" --data-urlencode "q=超声"
# 2) 转股价历史调整（看下修信号）
curl -s "$BASE/cb-price-chg?tsCode=127026.SZ&limit=10"
# 3) 配合正股行情判断折溢价
curl -s "$BASE/quote?symbol=688535"
```

---

### 场景 5：宏观择时（「现在能进场吗」）

```bash
# 1) 大盘趋势
curl -s "$BASE/index-daily?tsCode=000300.SH&limit=30"
# 2) 宏观先行指标
curl -s "$BASE/macro/latest?type=PMI"
curl -s "$BASE/macro/latest?type=CPI"
# 3) 资金面
curl -s "$BASE/hsgt?limit=10"        # 北向流向
curl -s "$BASE/margin?limit=10"      # 两融变化
```

---

## 注意事项

- 所有接口**只读、免鉴权**，无需注册或 token
- symbol 统一用 **6 位数字代码**（688017），不带交易所后缀；指数/可转债用带后缀的 `tsCode`
- 单次请求建议超时 10 秒；复杂画像优先**并发**而非串行调用
- **数据为空 ≠ 接口异常**，参考「数据稀疏接口」段落；不存在的 symbol 会返回 200 + 空对象
- **错误参数会静默回退**默认值（不报错），LLM 拼错枚举值时返回看似正常的数据可能语义不符，请校验
- **token 紧张时**：优先调 `stock`/`quote`/`tech-factor` 等扁平接口；`financial`（单条 60+ 字段）和 `announcements`（含 Markdown 全文）按需酌情减少 limit
- 数据来源：天启云(ApocData Cloud)，与 A 股数据落库周期同步（实时行情 14:55 滚动，公告 T+0 当天 08:00，北向 20:00）
