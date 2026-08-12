# A. 行情与估值（10 个）

涵盖个股/指数实时与历史行情、估值快照、股票搜索、涨跌排行与人气榜。**做任何分析前的起点。**

## A1. 实时行情 `quote`

查单只股票最新涨跌、量价。

```bash
curl -s "$BASE/quote?symbol=688017"
# 返回: symbol, name, trade_date, open, high, low, close,
#       pre_close, change, pct_chg, volume, amount
# 延迟信息: delayed_minutes, as_of
```

**参数**：`symbol` — 6 位代码（不带交易所后缀，如 `600519`、`000001`）

**字段语义**：
- `open/high/low/close` — FREE/PRO 套餐为 15 分钟延迟快照，QUANT/ENT 为实时
- `volume/amount` — **当日累计**成交量/成交额（所有套餐语义一致）
- `delayed_minutes` / `as_of` — 数据延迟分钟数和时间戳，Agent 应据此标注时效

**示例问题**：「688017 今天涨了多少？」「茅台现在什么价格？」

---

## A2. 批量行情 `quotes`

最多同时查 10 只股票，字段语义与 `quote` 一致（volume/amount 为当日累计）。

```bash
curl -s "$BASE/quotes?symbols=000001,600519,000858"
```

**示例问题**：「帮我看下茅台、五粮液、平安银行今天的涨跌」

---

## A3. 日K历史 `daily`

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

## A4. 股票基本信息 `stock`

行业、市值、PE、PB、上市日期。

```bash
curl -s "$BASE/stock?symbol=688017"
# 返回: symbol, name, market, industry, pe, pb, total_mv, circ_mv
```

**示例问题**：「688017 的估值怎么样？PE 是多少？」

---

## A5. 股票搜索 `stocks`

按名称/代码关键词搜索，支持行业和市场过滤。**已自动排除 B 股（200xxx/900xxx），仅返回 A 股**。

```bash
# 中文参数必须 URL 编码
curl -s -G "$BASE/stocks" \
  --data-urlencode "q=银行" \
  --data-urlencode "industry=银行" \
  --data-urlencode "market=主板" \
  --data-urlencode "limit=20"
curl -s "$BASE/stocks?q=688017"
```

**参数**：`q`（关键词）、`industry`（行业）、`market`（市场板块）、`limit`（上限 50）、`cursor`（翻页游标）

> **服务边界**：ApocData 当前仅覆盖 A 股（沪深主板/创业板/科创板），不提供 B 股、北交所、港股、美股数据。

**示例问题**：「帮我找所有银行股」「搜索新能源相关股票」

---

## A6. ST 状态 `st`

是否 ST / 退市风险，正常股返回 null。

```bash
curl -s "$BASE/st?symbol=000001"
```

**示例问题**：「这只股票有退市风险吗？」

---

## A7. 涨跌幅排行榜 `ranking`

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

## A8. 指数列表搜索 `indexes`

按名称/代码搜索指数。

```bash
curl -s -G "$BASE/indexes" --data-urlencode "q=沪深300"
curl -s "$BASE/indexes?market=CSI&limit=20"
# 返回: ts_code, name, market, publisher, category, base_date, base_point
```

**示例问题**：「沪深300 的指数代码是多少？」「有哪些中证指数？」

---

## A9. 指数日K `index-daily`

指数日K行情（用指数 tsCode 查询，可先用 `indexes` 查代码）。

```bash
curl -s "$BASE/index-daily?tsCode=000300.SH&limit=30"
# 常用：000001.SH 上证指数、000300.SH 沪深300、399006.SZ 创业板指
# 返回: trade_date, open, high, low, close, pre_close, change, pct_chg, vol, amount
```

**示例问题**：「沪深300 最近 30 天走势」「上证指数昨天涨了多少？」

---

## A10. 人气榜 `hot-rank`

东方财富人气榜（个股热度排名）。

```bash
curl -s "$BASE/hot-rank?limit=30"
# 返回: trade_date, ts_code, ts_name, rank, pct_change, current_price, hot, concept
```

**示例问题**：「今天 A 股人气榜前 10 是哪些？」
