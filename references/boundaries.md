# 接口边界与已知行为（必读）

> 这一段直接影响 LLM 调用准确率，**调任何接口前先扫一眼本节**。

## limit 上限速查（超限会**静默截断**，不会报错）

| 接口 | 文档上限 | 注意 |
|---|---|---|
| `daily` | 30 | 超过传 100 也只返 30 |
| `macro` | 12 | 同上 |
| `quotes` | 10 只 symbol | 多传的会被丢弃 |
| `ranking` / `limit-list` / `dragon-tiger` / `limit-step` / `hot-money-detail` / `sector-flow` / `concepts` / `concept-stocks` / `ths-boards` / `ths-board-stocks` / `hot-rank` | 50 | 静默截断 |
| `announcements` | 30 | announcements 默认 5，单条正文较长时建议取 1-5 条；~~`news`~~ 已下线 |
| `survey` / `block-trade` / `holder-number` / `share-float` / `repurchase` / `dividend` / `moneyflow` / `hsgt` / `hk-hold` / `cb-price-chg` / `tech-factor` / `cyq-perf` / `express` / `margin` / `financial` | 见各接口示例 | 通常 10 或 4 |
| `calendar` | 起止跨度 ≤ 366 天 | **超范围会显式报错（非静默）** |

## 数据稀疏接口（返回空数组 ≠ 接口异常）

| 接口 | 已知情况 | 建议 |
|---|---|---|
| `express` | 仅季报前后约 1 个月窗口有数据；很多公司近年未发布快报，返回的可能是 2-3 年前记录 | 必须检查 `end_date`；需要最新财务数据改用 `financial` |
| `block-trade` / `survey` | 部分小盘股长期无大宗/无调研 | 空返回不代表股票有问题 |

## 参数易错点（来自实测）

- **枚举参数优先用英文**：`sector-flow?type=industry/concept/region`（中文 `行业/概念/地域` 仍兼容但需 URL 编码，bash 直传中文偶发被吞）
- **中文搜索关键字必须 URL 编码**：`q=` / `industry=` 等带中文时（如 `announcements?q=年报`、`stocks?q=银行`），bash 直接拼 URL 会 `HTTP 400`；请用 `curl -G --data-urlencode "q=年报"`，或在代码里交给 HTTP 客户端自动编码
- **symbol vs tsCode**：A 股个股一律 6 位数字 `symbol=000001`（不带交易所后缀）；指数用带后缀的 `tsCode=000300.SH`；可转债正股反查用 `stkCode=688535.SH`
- **日期格式统一 YYYYMMDD**：start/end 必须**成对**传入，单传无效
- **错误参数返回结构化失败**：HTTP 状态码为 400，响应体为 `code=400, success=false`，并通过 `X-Tdc-Error-Code` / `X-Tdc-Error-Field` 标明错误；Agent 必须先检查 HTTP 状态和 `success`，再读取 `data`
- **不存在的 symbol 返回 `RESOURCE_NOT_FOUND`**：响应体为 `code=400, success=false`，应校验代码或先调用 `stocks` 搜索；正常股票的 `st` 数据仍可能为 `null`

## 性能基线（实测）

- 单接口 P50 延时 130-180ms，10 并发无排队
- `announcements`（含 Markdown 全文）单条 174ms，**最 token 重**
- 复杂画像建议**并发拉取**而非串行

## HTTP 响应 Header（机器可读 meta）

> 所有 `/open/data/*` 接口都会在 **HTTP 响应头**里携带额外元信息。**JSON 响应体结构不变**，header 是附加增强。Agent 可读 header 来感知限流额度/截断状态/数据稀疏/错误码，避免误判。

| Header | 出现时机 | 含义 |
|---|---|---|
| `X-RateLimit-Limit` | 每次请求 | 当前 IP 每日额度上限（默认 2000） |
| `X-RateLimit-Remaining` | 每次请求 | 当日剩余额度 |
| `X-RateLimit-Reset` | 每次请求 | 额度重置时间（Unix 时间戳，本地次日 0 点） |
| `X-RateLimit-Tier` | 每次请求 | 当前套餐（`free`） |
| `X-Tdc-Limit-Applied` | 列表类接口 | 实际生效的 limit 值 |
| `X-Tdc-Limit-Max` | 列表类接口 | 该接口的 limit 硬上限 |
| `X-Tdc-Limit-Truncated` | **仅当用户传值超过上限** | `true` — 表示请求被静默截断（参考上方上限速查） |
| `X-Tdc-Limit-Requested` | 仅当截断时 | 用户原始传入的 limit 值 |
| `X-Tdc-Coverage` | **仅当返回空数组时** | `sparse` — 表示该接口数据本身就稀疏，空 != 异常 |
| `X-Tdc-Coverage-Reason` | 仅当 Coverage=sparse | 稀疏原因中文说明 |
| `X-Tdc-Fields-Applied` | 仅当 `?fields=` 生效时 | 实际生效的字段白名单 |
| `X-Tdc-Format` | 仅当 `?format=compact` 生效时 | `compact` — 列式输出已应用 |
| `X-Tdc-Format-Row-Count` | 仅紧凑模式 | 实际行数 |
| `X-Tdc-Aggregated-Endpoints` | 仅 `/profile/full` | 聚合的子接口数（恒为 8） |
| `X-Tdc-Aggregation-Time-Ms` | 仅 `/profile/full` | 实际聚合耗时（毫秒） |
| `X-Tdc-Freshness-Tier` | 每次成功请求 | 数据时效粗分类：`intraday` / `post-close` / `t0-morning` / `quarterly` / `metadata` / `aggregated`（详见下方「数据 SLA / Freshness」段落） |
| `X-Tdc-Freshness-Detail` | 每次成功请求 | 时效细节描述（如 `continuous 09:30-15:00, 15min delay`、`daily 17:00`） |
| `Cache-Control` | 每次请求 | `public, max-age=N`（按接口业务属性自动设档，见下方「缓存策略」段落） |
| `X-Tdc-Error-Code` | **仅错误响应** | 机器可读错误码（见下表） |
| `X-Tdc-Error-Field` | 仅错误响应 | 出错的参数名 |
| `X-Tdc-Doc-Url` | 仅错误响应 | 跳转的文档地址 |

## 错误码（X-Tdc-Error-Code 取值）

| 错误码 | 触发场景 | 调用方应对 |
|---|---|---|
| `INVALID_PARAM_VALUE` | 枚举值非法（type/direction/kind/exchange） | 按 msg 文本里的"仅支持 ..."重试 |
| `INVALID_PARAM_FORMAT` | 日期格式错（必须 YYYYMMDD） | 按格式重试 |
| `MISSING_REQUIRED_PARAM` | start/end 非成对传入等 | 补齐参数 |
| `PARAM_OUT_OF_RANGE` | 日期跨度超 366 天等 | 缩短跨度 |
| `RESOURCE_NOT_FOUND` | symbol 在 stock_basic_info 中找不到 | 校验股票代码，或先用 stocks 搜索 |

> 参数错误响应是 `{"code":400,"success":false,"msg":"..."}` 的 R 包装结构，HTTP 状态码为 400。资源不存在默认保持兼容响应，可通过服务端开关升级为 HTTP 404。结构化错误信息同时写入 header。

**`RESOURCE_NOT_FOUND` 响应示例**（Agent 必须识别此结构，不要当成功数据处理）：

```json
// HTTP 400, Header: X-Tdc-Error-Code: RESOURCE_NOT_FOUND
{
  "code": 400,
  "success": false,
  "msg": "未找到股票: 999999"
}
// 正确做法：先用 /stocks?q= 搜索确认正确代码，不要重试同一 symbol
```

## 错误处理决策树（Agent 必执行）

> 遇到任何非 `success=true` 的响应，按以下决策树处理。**不要忽略错误直接输出分析结论**。

### 1. 限流应对

| 信号 | 判断 | 行动 |
|---|---|---|
| `X-RateLimit-Remaining` ≤ 10 | 额度即将耗尽 | 停止非必要调用，优先完成当前分析；告知用户"今日额度接近上限" |
| `X-RateLimit-Remaining` = 0 | 额度已耗尽 | **立即停止所有调用**；告知用户"今日 API 额度已用完，明日自动恢复"；不要重试 |
| HTTP 429 | 被限流 | 同上，不要重试——重试只会浪费额度 |

### 2. 参数错误重试（仅以下情况值得重试）

| 错误码 | 原因 | 重试策略 |
|---|---|---|
| `INVALID_PARAM_VALUE` | 枚举值传错 | 读 `msg` 里的合法值列表，修正后重试 **1 次** |
| `INVALID_PARAM_FORMAT` | 日期格式错 | 确认 YYYYMMDD 格式后重试 **1 次** |
| `MISSING_REQUIRED_PARAM` | 缺参数 | 补齐后重试 **1 次** |
| `PARAM_OUT_OF_RANGE` | 跨度超限 | 缩短日期跨度到 ≤ 366 天后重试 **1 次** |
| `RESOURCE_NOT_FOUND` | symbol 不存在 | **不要重试同一 symbol**；先用 `stocks` 搜索确认正确代码 |

> **重试上限：同一接口同一参数最多重试 1 次。** 第二次仍失败则停止，向用户说明情况。

### 3. 数据异常降级

| 信号 | 判断 | 行动 |
|---|---|---|
| `success=true` + 空数组 | 数据稀疏，非异常 | 在输出中注明"该接口当前无数据"；**不要**解读为"接口异常" |
| `success=true` + 关键字段 `null` | 字段本身无数据（如银行股 `grossprofit_margin` 为空） | 标注"该字段本期未披露"，**不要**用 null 值计算比率 |
| `success=false` | 接口异常 | **停止该接口的分析结论**；如有替代接口则切换（如 `express` 失败改 `financial`），否则告知用户 |
| `profile/full` 某维度返回 `{}` 或 `[]` | 子接口失败不影响整体 | 用已返回的维度继续分析，注明"XX 维度数据暂不可用" |

### 4. 僵尸数据检测（数据时效校验）

每次拿到数据后，**必须**检查时效性再输出结论：

| 检查项 | 判断方法 | 异常阈值 | 行动 |
|---|---|---|---|
| `trade_date` | 与当前日期对比 | 非交易日数据超过 3 个自然日未更新 | 标注"数据可能滞后，请注意时效" |
| `delayed_minutes` | 响应字段直接返回 | > 15 分钟（盘中）或 > 次日 09:00（盘后） | 明确告知用户数据延迟时长 |
| `X-Tdc-Freshness-Tier` | 响应 header | `intraday` 但已收盘 → 是快照；`post-close` 但当前 < 17:00 → 可能还是昨日数据 | 在输出中标注数据实际时效 |
| `X-Tdc-Coverage: sparse` | 响应 header | 空数组 + sparse 标记 | 不要输出"该股票无数据"的确定性结论，改为"该接口数据暂不可用" |

### 5. 并发调用容错

多接口并发场景（如 `profile/full` 或手动串联 5-6 个接口）：

- **部分成功**：用成功的接口数据继续分析，失败的接口标注"XX 数据暂不可用"
- **全部失败**：停止分析，向用户报告
- **数据矛盾**（如行情显示涨停但资金流显示大幅净流出）：在输出中明确标注矛盾，不做确定性结论，建议用户交叉验证

## 字段裁剪 `?fields=`（token 优化，全局支持）

**所有 45 个活跃业务接口都支持** `?fields=col1,col2,...` 字段白名单（`/news` 已下线，不计入）；对 Map 或 List<Map> 响应进行裁剪，不适用的数据形状会保持原样。响应只保留指定字段，列序保持参数顺序，不存在的字段自动忽略：

```bash
# 财务接口只取关键字段（60+ 字段 → 3 字段）
curl -s "$BASE/financial?symbol=000001&fields=roe,revenue,net_profit"

# 公告只取标题摘要不取 Markdown 全文（节省 80% token）
curl -s "$BASE/announcements?symbol=000001&fields=title,summary,ann_date"

# 任意接口都能用：行情只取 3 个核心字段
curl -s "$BASE/quote?symbol=600519&fields=symbol,close,pct_chg"

# 排行榜只取代码和涨幅
curl -s "$BASE/ranking?direction=gain&limit=20&fields=symbol,pct_chg"
```

响应 header 回显 `X-Tdc-Fields-Applied`，可校验是否裁剪生效。

> 历史版本仅 `financial` / `announcements` 显式支持；自 2026-05 起全局 advice 统一处理，所有接口生效。

## 紧凑模式 `?format=compact`（列式输出，节省 60-70% token）

所有**列表类接口**支持列式输出——把"每行重复的字段名"提取到顶部 `columns`，行数据用数组的数组，**对 LLM token 极友好**。

```bash
# 默认行式（适合人类阅读）
curl -s "$BASE/ranking?limit=3"
# 返回: { "data": [
#   { "symbol":"000001", "name":"平安银行", "close":10.78, "pct_chg":0.94 },
#   { "symbol":"600519", "name":"贵州茅台", "close":1273.38, "pct_chg":-0.97 },
#   { "symbol":"688017", "name":"绿的谐波", "close":62.5, "pct_chg":3.21 }
# ]}

# 紧凑模式（同样数据，token 减半）
curl -s "$BASE/ranking?limit=3&format=compact"
# 返回: { "data": {
#   "columns": ["symbol","name","close","pct_chg"],
#   "rows": [
#     ["000001","平安银行",10.78,0.94],
#     ["600519","贵州茅台",1273.38,-0.97],
#     ["688017","绿的谐波",62.5,3.21]
#   ]
# }}
```

**适用接口**：所有返回列表的接口（ranking / limit-list / stocks / concepts / financial / moneyflow / dragon-tiger / hot-money-detail / ...）

**自动跳过**（保持原结构）：
- 单条接口（`quote` / `stock` / `macro/latest` / `st`）
- 综合画像（`profile/full`，本身是聚合 Map）
- `calendar`（已经是字符串数组）
- 错误响应（保持 R.fail 结构）

**响应 header**：`X-Tdc-Format: compact` + `X-Tdc-Format-Row-Count: <实际行数>`

## 缓存策略 `Cache-Control`（自动透明）

所有响应都会带 `Cache-Control` header，**CDN / 浏览器 / OkHttp / okhttp 等中间层可安全复用**，无需调用方手动处理：

| 接口类别 | max-age | 包含接口 |
|---|---|---|
| **盘中实时** | `5s` | `quote` / `quotes` / `ranking` / `hot-rank` / `sector-flow` / `limit-list` / `limit-step` / `dragon-tiger` / `hot-money-detail` |
| **盘后日更** | `5min`（300s） | `daily` / `index-daily` / `hsgt` / `hk-hold` / `margin` / `moneyflow` / `cyq-perf` / `tech-factor` / `financial` / `express` / `dividend` / `share-float` / `repurchase` / `holder-number` / `block-trade` / `news` / `announcements` / `survey` / `holders` |
| **元数据/低频** | `1h`（3600s） | `stock` / `stocks` / `st` / `indexes` / `factors` / `factor-categories` / `concepts*` / `ths-boards*` / `convertible-bonds` / `cb-price-chg` / `hot-money` / `calendar` / `macro*` |
| **综合画像** | `30s` | `profile/full`（取所有子接口最严约束） |
| **错误响应** | `no-store` | 所有 `success=false`（防止错误结果被中间层固化） |

**典型实践**：写本地脚本批量拉数据时，直接用 OkHttp / requests 默认配置即可——cache 行为完全由后端 header 控制。重复拉同一接口在 max-age 窗口内**直接命中缓存零延时**。

## 数据 SLA / Freshness（接口数据时效）

每次成功响应都会带 `X-Tdc-Freshness-Tier` + `X-Tdc-Freshness-Detail` header，让 Agent 知道**该接口的数据多新**，避免拿"昨天的数据当今天用"。

| Tier | 含义 | 涉及接口 |
|---|---|---|
| `intraday` | 盘中实时（FREE 套餐 15min 延迟） | `quote` / `quotes` / `ranking` / `hot-rank` / `sector-flow` |
| `post-close` | 盘后批量更新 | 16:30：`limit-list` / `limit-step` / `dragon-tiger` / `hot-money-detail` / `cyq-perf`；17:00-18:00：`daily` / `index-daily` / `tech-factor` / `margin` / `moneyflow` / `block-trade`；20:00：`hsgt` / `hk-hold` |
| `t0-morning` | 当天 T+0 早上 08:00 入库 | `news` / `announcements` / `survey` |
| `quarterly` | 季报披露窗口（报告期后约 1 个月） | `financial` / `express` / `dividend` / `share-float` / `repurchase` / `holder-number` / `holders` |
| `metadata` | 元数据/字典低频更新 | `stock` / `stocks` / `st` / `indexes` / `factors` / `factor-categories` / `concepts*` / `ths-boards*` / `convertible-bonds` / `cb-price-chg` / `hot-money` / `calendar` / `macro*` |
| `aggregated` | 聚合接口（取最严约束） | `profile/full` |

> `profile/full` 的 `aggregated` tier 表示其内部聚合了多个子接口，各子接口时效不同：
> quote/ranking 维度为 `intraday`，moneyflow/daily 维度为 `post-close`，financial 维度为 `quarterly`，stock 维度为 `metadata`。
> 调用方应逐维度检查 `trade_date` 判断各部分数据时效，不要以整体 `Freshness-Tier: aggregated` 为准。

**Agent 典型用法**：
- 看到 `Freshness-Tier=intraday` 且当前已收盘 → 数据是 14:55 快照
- 看到 `post-close` 且当前 19:00 → 数据应是当日 17:00 的
- 看到 `t0-morning` 且当前 07:00 → 数据可能还是昨日的，下次调用时间放到 08:30 后
