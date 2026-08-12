# E. 事件与信息（3 个）

新闻、公告、机构调研三类事件信息源。新闻用于市场信息检索，公告用于公司正式披露。**事件驱动分析的输入。**

## E1. ~~新闻搜索 `news`~~ 【已下线】

> **该接口已下线**，调用将返回 HTTP 410 + `{"success":false, "msg":"/news 接口已下线..."}`。
> 新闻数据源不再对外提供。按股票查正式披露请改用 `/announcements`；关键词搜索媒体报道的功能后续将以新接口形式重新上线，请关注 Skill 更新。

旧调用方兼容说明：方法签名保留但不再执行业务逻辑，`q` 参数已改为可选，不会因缺少必填参数而报 400。

---

## E2. 公司公告 `announcements`

按股票查公告（标题、AI 摘要、公告日期、类型、链接；可选 Markdown 完整正文），**支持区间/类型/关键字过滤**，默认 5 条、上限 30 条。

```bash
# 默认：最新 5 条，不含完整 content
curl -s "$BASE/announcements?symbol=000001"
# 返回: title, summary, ann_date, publish_time, category,
#       importance, sentiment, keywords, source, url

# 全文场景：显式开启 content，并主动降低 limit
curl -s "$BASE/announcements?symbol=000001&limit=1&includeContent=true"

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

## E3. 机构调研 `survey`

个股机构调研接待记录。

```bash
curl -s "$BASE/survey?symbol=600101&limit=5"
# 返回: surv_date, rece_place, rece_mode, rece_org, comp_rece
```

**示例问题**：「这家公司最近接待了哪些机构调研？」
