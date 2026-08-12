# F. 板块/概念（4 个）

东财与同花顺双源板块目录与成分股查询。**做主题/概念轮动必备。**

## F1. 东财概念板块 `concepts`

东方财富概念板块目录（最新交易日，含当日热度/领涨股）。

```bash
curl -s "$BASE/concepts?q=AI&limit=30"
# 返回: theme_code, name, pct_change, hot, z_t_num, main_change,
#       lead_stock, lead_stock_code
```

**示例问题**：「有哪些 AI 相关概念板块？」

---

## F2. 概念成分股 `concept-stocks`

某概念板块的成分股（themeCode 可从 `concepts` 获取）。

```bash
curl -s "$BASE/concept-stocks?themeCode=000894.DC&limit=50"
# 返回: ts_code, name, industry, reason, hot_num
```

**示例问题**：「光通信概念里有哪些股票？」

---

## F3. 同花顺板块 `ths-boards`

同花顺行业/概念板块指数。

```bash
curl -s -G "$BASE/ths-boards" --data-urlencode "q=机器人" --data-urlencode "limit=30"
# 返回: ts_code, name, count（成分数）, exchange, list_date, type
```

**示例问题**：「同花顺有哪些机器人板块？」

---

## F4. 同花顺板块成分 `ths-board-stocks`

某同花顺板块的成分股（tsCode 可从 `ths-boards` 获取）。

```bash
curl -s "$BASE/ths-board-stocks?tsCode=886108.TI&limit=50"
# 返回: con_code, con_name
```

**示例问题**：「这个板块的成分股有哪些？」
