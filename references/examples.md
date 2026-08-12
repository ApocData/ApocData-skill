# 综合分析示例

> 复杂用户意图通常需要 3-6 个接口配合。下方示例**直接对应入口文件「场景速查」**，给出可复用的调用模板。

## 场景 1：个股综合画像（「帮我看下 688017 怎么样」）

```bash
BASE="https://www.apocdata.com/api/blade-dataplatform/open/data"

# 1) 基本面 + 估值
curl -s "$BASE/stock?symbol=688017"            # PE/PB/市值/行业
curl -s "$BASE/quote?symbol=688017"            # 当前股价 + 涨跌幅

# 2) 财务趋势
curl -s "$BASE/financial?symbol=688017&limit=4"  # 最近 4 期 ROE/净利润

# 3) 技术面 + 筹码
curl -s "$BASE/tech-factor?symbol=688017&limit=1"  # MACD/KDJ/RSI/均线
curl -s "$BASE/cyq-perf?symbol=688017&limit=1"     # 主力成本/获利盘

# 4) 资金动向
curl -s "$BASE/moneyflow?symbol=688017&limit=5"    # 近 5 日主力净流入
curl -s "$BASE/hk-hold?symbol=688017&limit=5"      # 北向持仓变动

# 5) 近期事件
curl -s "$BASE/announcements?symbol=688017&limit=3&includeContent=false"  # 近 3 条公告摘要
```

**综合判断要点**：估值（stock）+ 业绩（financial）+ 资金（moneyflow/hk-hold）+ 催化（announcements）四维交叉。

---

## 场景 2：涨停盘后复盘（「今天涨停的票有什么共性」）

```bash
# 1) 当日涨停池
curl -s "$BASE/limit-list?kind=U&limit=50"
# 2) 连板天梯（高度）
curl -s "$BASE/limit-step?limit=30"
# 3) 板块资金流（找共同主线）
curl -s "$BASE/sector-flow?type=concept&limit=10"
curl -s "$BASE/sector-flow?type=industry&limit=10"
# 4) 当日游资明细（谁在炒）
curl -s "$BASE/hot-money-detail?limit=30"
```

---

## 场景 3：北向资金跟踪（「外资最近在买什么」）

```bash
# 1) 北向整体净流入趋势
curl -s "$BASE/hsgt?limit=10"
# 2) 对具体股票的持仓变动（需指定 symbol 逐只查）
curl -s "$BASE/hk-hold?symbol=600519&limit=10"
curl -s "$BASE/hk-hold?symbol=000858&limit=10"
# 3) 配合龙虎榜看机构席位
curl -s "$BASE/dragon-tiger?limit=30"
```

---

## 场景 4：可转债套利筛选（「找有机会的可转债」）

```bash
# 1) 可转债列表 / 关键词搜索
curl -s -G "$BASE/convertible-bonds" --data-urlencode "q=超声"
# 2) 转股价历史调整（看下修信号）
curl -s "$BASE/cb-price-chg?tsCode=127026.SZ&limit=10"
# 3) 配合正股行情判断折溢价
curl -s "$BASE/quote?symbol=688535"
```

---

## 场景 5：宏观择时（「现在能进场吗」）

```bash
# 1) 大盘趋势
curl -s "$BASE/index-daily?tsCode=000300.SH&limit=30"
# 2) 宏观先行指标
curl -s "$BASE/macro/latest?type=PMI"
curl -s "$BASE/macro/latest?type=CPI"
# 3) 资金面
curl -s "$BASE/hsgt?limit=10"        # 北向流向
curl -s "$BASE/margin?limit=10"      # 两融变化
```
