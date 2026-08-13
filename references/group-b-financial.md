# B. 财务与基本面（8 个）

覆盖财务报表、业绩快报、分红、股东结构、限售/回购/大宗等基本面与股本事件。**适合做估值评判和长期分析。**

## B1. 财务数据 `financial`

ROE、营收、净利润等，最多 4 期。嵌套指标（如 pe_ratio/pb_ratio 等）已扁平化到顶层，直接用顶层字段名即可。单条返回 60+ 字段，token 紧张时建议加 `?fields=` 裁剪。

```bash
curl -s "$BASE/financial?symbol=000001&limit=4"
# 返回: report_period, report_type, roe, revenue, net_profit,
#       grossprofit_margin, eps, bps, debt_to_assets, pe_ratio, pb_ratio 等 60+ 字段
#       注: 上述字段按报告期稀疏填充——最新期可能缺 eps/bps、银行股 grossprofit_margin 常为空，以实际返回为准
# 注: pe_ratio 为动态 PE（TTM 滚动市盈率），pb_ratio 为市净率（MRQ 最新报告期）
#     与 Wind/Choice 等终端的 PE 口径可能存在细微差异，以实际返回为准

# token 优化：只取关键字段（节省 90% token）
curl -s "$BASE/financial?symbol=000001&limit=4&fields=roe,revenue,net_profit,pe_ratio"
```

**示例问题**：「平安银行的 ROE 怎么样？」「最近 4 期净利润趋势」

---

## B2. 业绩快报 `express`

个股业绩快报（营收、净利润、EPS、ROE）。

> ⚠️ **数据可能很旧**：express 返回的是公司发布过的所有业绩快报历史记录，按 `end_date` 降序排列。很多公司近年未发布业绩快报，最近一条可能是 2-3 年前的数据。**必须检查 `end_date` 判断时效性**，不要将旧数据误认为最新。
> 如果需要最新财务数据，优先使用 `financial` 接口。

```bash
curl -s "$BASE/express?symbol=000001&limit=4"
# 返回: end_date, ann_date, revenue, n_income, total_profit, diluted_eps,
#       diluted_roe, yoy_net_profit, total_assets
```

**示例问题**：「平安银行最新业绩快报」（注意检查 end_date 是否为近期）

---

## B3. 分红送配 `dividend`

个股历史分红送配方案。

```bash
curl -s "$BASE/dividend?symbol=000001&limit=10"
# 返回: end_date, ann_date, div_proc, stk_div, cash_div, cash_div_tax,
#       record_date, ex_date, pay_date
```

**示例问题**：「平安银行的分红方案」「茅台今年分红多少？」

---

## B4. 十大股东 `holders`

最新期十大股东 / 十大流通股东。

```bash
curl -s "$BASE/holders?symbol=000001&holderCategory=top10_float"
# 返回: holder_name, hold_amount, hold_ratio, hold_change, holder_type
```

**示例问题**：「平安银行十大流通股东是哪些机构？」

---

## B5. 股东户数 `holder-number`

个股历史股东户数。

```bash
curl -s "$BASE/holder-number?symbol=000001&limit=10"
# 返回: ann_date, end_date, holder_num
```

**示例问题**：「这只股票股东户数是增是减？」

---

## B6. 限售解禁 `share-float`

个股**未来**限售股解禁计划（仅含尚未到日的解禁记录，已完成的解禁不返回）。

```bash
curl -s "$BASE/share-float?symbol=000001&limit=10"
# 返回: ann_date, float_date, float_share, float_ratio, holder_name, share_type
```

**示例问题**：「平安银行近期有解禁吗？解禁多少？」

---

## B7. 股票回购 `repurchase`

个股回购方案与进度。

```bash
curl -s "$BASE/repurchase?symbol=000001&limit=10"
# 返回: ann_date, proc, vol, amount, high_limit, low_limit
```

**示例问题**：「这家公司在回购股票吗？」

---

## B8. 大宗交易 `block-trade`

个股大宗交易记录（成交价、折溢价、买卖营业部）。

```bash
curl -s "$BASE/block-trade?symbol=000001&limit=10"
# 返回: trade_date, price, vol, amount, buyer, seller
```

**示例问题**：「平安银行最近有大宗交易吗？」
