# K. Agent 增强（2 个）

为 Agent / LLM 场景设计的聚合与元数据端点。**一次调用替代多次单接口拼接，token 利用率最大化。**

## K1. 个股综合画像 `profile/full`

**一次返回 8 维数据**：basic + quote + financial(4期) + tech-factor + cyq-perf + moneyflow(5日) + hk-hold(5日) + announcements(3条)。等价于并发调 8 次单接口，延时减少 60%+。

```bash
curl -s "$BASE/profile/full?symbol=688017"
# 返回结构（顶层 data 字段下）:
# {
#   "basic":               { symbol, name, industry, market, ... },
#   "quote":               { close, pct_chg, volume, ... },
#   "financial_trend":     [ {report_period, roe, revenue, ...}, ... ]  // 4 期
#   "technical":           { macd_qfq, macd_dif_qfq, macd_dea_qfq, kdj_k_qfq, kdj_d_qfq, rsi_qfq_6, boll_upper_qfq, ma_qfq_5, ma_qfq_20, ... },
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

## K2. 量化因子分类目录 `factor-categories`

返回所有 event_type 业务分类的人类可读说明 + 各类因子数量（`factor_count`）。配合 `factors` 使用：`factors` 列出因子（脱敏），`factor-categories` 解释每个分类是干什么的。

> 注：主要类目包括价值/成长/盈利质量/动量反转/博弈/资金情绪/技术信号/微观结构/波动率/流动性/规模杠杆等，数据库如有额外分类会自动补充。具体数量和分类以接口实时返回为准。

```bash
curl -s "$BASE/factor-categories"
# 返回所有类目；有因子的（factor_count>0）：
#   { "event_type_label": "基本面事件", "factor_count": 68 },
#   { "event_type_label": "技术信号",   "factor_count": 61 },
#   { "event_type_label": "资金异动",   "factor_count": 18 },
#   { "event_type_label": "价格异动",   "factor_count": 4 },
#   { "event_type_label": "微观结构",   "factor_count": 2 },
#   { "event_type_label": "资金流",     "factor_count": 1 },
#   其余类目（价值/成长/盈利质量/动量反转/博弈/资金情绪/波动率/流动性/规模杠杆）factor_count 当前为 0
# ]
```

**示例问题**：「平台支持哪些类别的因子？」「有没有博弈类的因子？大概多少个？」
