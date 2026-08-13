# C. 资金博弈（7 个）

主力/北向/两融/龙虎/游资全口径资金视角。**短线择时与盯盘核心。**

## C1. 个股资金流 `moneyflow`

个股超大单/大单/中单/小单买卖额与主力净流入。

```bash
curl -s "$BASE/moneyflow?symbol=000001&limit=10"
# 返回: trade_date, buy_elg_amount, sell_elg_amount, buy_lg_amount, sell_lg_amount,
#       buy_md_amount, sell_md_amount, buy_sm_amount, sell_sm_amount, net_mf_amount
# 注: net_mf_amount = 超大单+大单+中单+小单的净买入额之和（即四类资金净流口的代数和）
#     各分项 buy_xxx_amount - sell_xxx_amount = 该档净流入；net_mf_amount 为四项之和
```

**示例问题**：「平安银行最近主力是流入还是流出？」

---

## C2. 沪深港通资金流 `hsgt`

北向（陆股通）、南向（港股通）每日资金流。

```bash
curl -s "$BASE/hsgt?limit=10"
# 返回: trade_date, hgt, sgt, ggt_ss, ggt_sz, north_money, south_money
```

**示例问题**：「最近北向资金是买还是卖？」「今天北向净流入多少？」

---

## C3. 沪深港通持股 `hk-hold`

个股被沪深港通（北向）持股记录。

> **数据频率**：hk-hold 为**季度数据**（每季度末更新一次），非每日更新。返回的 trade_date 为季末日期（如 20260630、20260331）。

```bash
curl -s "$BASE/hk-hold?symbol=000001&limit=10"
# 返回: trade_date, name, ratio（持股占比）, vol（持股量）
```

**示例问题**：「北向资金持有平安银行多少？」

---

## C4. 融资融券 `margin`

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

## C5. 龙虎榜 `dragon-tiger`

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

## C6. 游资名录 `hot-money`

知名游资席位名录。

```bash
curl -s "$BASE/hot-money?limit=50"
# 返回: name（游资名）, orgs（关联营业部）
```

**示例问题**：「有哪些知名游资？」

---

## C7. 游资交易明细 `hot-money-detail`

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
