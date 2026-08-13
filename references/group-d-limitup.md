# D. 涨跌停与情绪（4 个）

打板、连板、板块情绪、筹码结构。**A 股短线散户最关注的视角。**

## D1. 涨跌停池 `limit-list`

某交易日的涨停 / 跌停 / 炸板个股。

```bash
curl -s "$BASE/limit-list?kind=U&date=20260518&limit=30"
# kind=U 涨停 / D 跌停 / Z 炸板，date 缺省取最新交易日
# 注: date 传非交易日（周末/节假日）时，不会自动回退到前一交易日，而是返回空数组
# 返回: trade_date, ts_code, name, industry, close, pct_chg, amount,
#       first_time, last_time, open_times, up_stat, limit_times, limit
```

**示例问题**：「今天有多少只涨停？」「最近一个交易日的跌停股」

---

## D2. 连板天梯 `limit-step`

某交易日连板个股，按连板数排列。

```bash
curl -s "$BASE/limit-step?limit=30"
# date 缺省取最新交易日
# 返回: trade_date, ts_code, name, nums（连板数）
```

**示例问题**：「今天最高几连板？」「现在的连板天梯」

---

## D3. 板块资金流榜 `sector-flow`

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

## D4. 筹码分布 `cyq-perf`

个股筹码分布与获利比例。

```bash
curl -s "$BASE/cyq-perf?symbol=000001&limit=5"
# 返回: trade_date, his_low, his_high, cost_5pct, cost_50pct, cost_95pct,
#       weight_avg（加权平均成本）, winner_rate（获利比例）
```

**示例问题**：「平安银行现在的获利盘比例是多少？」「主力成本大概在哪？」
