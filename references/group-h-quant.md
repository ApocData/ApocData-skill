# H. 量化与技术（2 个）

平台量化因子注册表 + 个股技术指标快照。**做策略/选股的元数据入口。**

## H1. 量化因子注册表 `factors`

平台全部已启用的量化因子**元数据清单**（脱敏，不含计算公式/权重/打分，数量以接口实时返回为准）。

> ⚠️ 本接口返回的是**平台因子注册表**（因子名称、分类、是否启用），**不含个股因子值**，也不接受 `symbol` 参数。  
> 要查某股票的 MACD/KDJ/RSI 等技术指标实际值，请用 `/tech-factor`。

```bash
curl -s "$BASE/factors"
# 返回: rule_id, name, event_type_label, scope, enabled, version, updated_at
# 注意：这是因子配置注册表，非个股计算结果
```

**示例问题**：「平台支持哪些量化因子？」「有没有和涨停/事件相关的因子？」

---

## H2. 技术面因子 `tech-factor`

个股技术指标（MACD/KDJ/RSI/BOLL/均线等，前复权）。

```bash
curl -s "$BASE/tech-factor?symbol=000001&limit=1"
# 返回: trade_date, close, pct_chg, turnover_rate, pe_ttm, pb,
#       macd_qfq, kdj_k_qfq, kdj_d_qfq, rsi_qfq_6, boll_upper_qfq,
#       ma_qfq_5, ma_qfq_20, cci_qfq, wr_qfq 等
```

**示例问题**：「平安银行现在的 MACD 和 KDJ 怎么样？」
