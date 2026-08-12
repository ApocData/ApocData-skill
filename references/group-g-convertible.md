# G. 可转债（2 个）

可转债元数据与转股价历史。

## G1. 可转债列表 `convertible-bonds`

可转债基本信息（按债券或正股搜索）。

```bash
curl -s -G "$BASE/convertible-bonds" --data-urlencode "q=超声"
curl -s "$BASE/convertible-bonds?stkCode=688535.SH"
# 返回: ts_code, bond_short_name, stk_code, stk_short_name, issue_size,
#       value_date, maturity_date, coupon_rate, conv_price
```

**示例问题**：「华海诚科有没有发行可转债？」

---

## G2. 可转债转股价变动 `cb-price-chg`

可转债转股价的历史调整记录。

```bash
curl -s "$BASE/cb-price-chg?tsCode=127026.SZ&limit=10"
# 返回: publish_date, change_date, convert_price_initial,
#       convertprice_bef, convertprice_aft
```

**示例问题**：「超声转债下修过转股价吗？」
