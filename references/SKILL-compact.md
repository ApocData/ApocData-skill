# ApocData Skill — 精简版（小模型专用）

> **适用**：<15B 参数的本地模型或上下文窗口有限的场景。完整版见 `SKILL.md`。
> 所有接口 HTTP GET，免鉴权，BASE = `https://www.apocdata.com/api/blade-dataplatform/open/data`

## 场景速查

| 用户意图 | 接口 | 要点 |
|---|---|---|
| 个股综合画像 | `profile/full?symbol=X` | 一次返回 8 维数据 |
| **多只股票批量查** | **`quotes?symbols=A,B,C`** | **3 只以上必须用，最多 10 只** |
| 单只行情 | `quote?symbol=000001` | 15min 延迟快照 |
| 估值+走势 | `stock` → `financial` → `daily?limit=30` | 看 PE/PB |
| 资金追踪 | `moneyflow` → `hsgt` → `hk-hold` | 北向 20:00 后更新 |
| 涨停复盘 | `limit-list?kind=U` → `limit-step` → `sector-flow` | date 不传默认最新 |
| 公告查询 | `announcements` | 可用 `fields=title,summary,ann_date` 省 token |
| 新闻 | ~~`news`~~ **已下线** → 用 `announcements` | — |
| 可转债 | `convertible-bonds` → `cb-price-chg` | 用 stkCode 反查正股 |
| 搜索的股票 | `stocks?q=关键词` | 支持名称/代码/行业模糊匹配 |
| 退市排查 | `st` → `share-float` → `holders` | st 返回 null 即非 ST |
| 业绩快报 | `express` → `financial` | 仅季报前后有数据 |

## limit 上限（超限静默截断，不报错）

| 接口 | 上限 | 接口 | 上限 |
|---|---|---|---|
| `daily` | 30 | `quotes` | 10 只 |
| `macro` | 12 | `ranking`/`limit-list`/`dragon-tiger` 等 | 50 |
| `announcements` | 30 | `calendar` | 跨度 ≤ 366 天 |

## 参数易错点

- **symbol**：A 股 6 位代码（`000001`）；指数用 `tsCode=000300.SH`；可转债用 `stkCode=688535.SH`
- **日期 YYYYMMDD**：start/end 必须成对传入
- **中文参数必须 URL 编码**：`curl -G --data-urlencode "q=银行"`
- **枚举参数用英文**：`sector-flow?type=industry`（不用 `行业`）

## 错误码速查

| 错误码 | 含义 | 应对 |
|---|---|---|
| `RESOURCE_NOT_FOUND` | symbol 不存在 | **不要重试**，先用 `stocks?q=` 搜索 |
| `INVALID_PARAM_VALUE` | 枚举值非法 | 按 msg 提示的合法值重试 1 次 |
| `INVALID_PARAM_FORMAT` | 日期格式错 | 确认 YYYYMMDD 后重试 1 次 |
| `MISSING_REQUIRED_PARAM` | 缺参数 | 补齐后重试 1 次 |

错误响应结构：`{"code":400,"success":false,"msg":"..."}`，HTTP 400。

## 注意事项

- 空数组 ≠ 报错：`success=true` + 空数组是数据稀疏，注明即可
- 输出必须标注数据时效（`trade_date` / `delayed_minutes`）
- token 紧张时：用 `?fields=` 裁剪 + `?format=compact` 紧凑模式
- 禁止输出买卖指令，末尾加免责声明
