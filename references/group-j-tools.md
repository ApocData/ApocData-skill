# J. 工具（1 个）

通用查询辅助。

## J1. 交易日历 `calendar`

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
