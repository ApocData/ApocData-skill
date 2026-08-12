# I. 宏观（3 个）

GDP/CPI/PPI/PMI 历史与定义。**做大盘择时与板块景气度判断。**

## I1. 宏观指标历史 `macro`

GDP / CPI / PPI / PMI，最多 12 条。

```bash
curl -s "$BASE/macro?type=CPI&limit=12"
# 返回: period, value, yoy_growth, mom_growth
```

**示例问题**：「最近 12 个月 CPI 走势」

---

## I2. 宏观指标最新值 `macro/latest`

```bash
curl -s "$BASE/macro/latest?type=PMI"
# 返回: period, value, unit, yoy_growth
```

**示例问题**：「现在 PMI 是多少？」「最新 GDP 增速」

---

## I3. 宏观指标定义 `macro/definition`

查宏观指标的含义、单位、统计频率。

```bash
curl -s "$BASE/macro/definition?type=CPI"
# 返回: indicator_code, indicator_name, unit, frequency, description
# type 可选 GDP/CPI/PPI/PMI
```

**示例问题**：「CPI 这个指标是什么意思？」「PMI 多久更新一次？」
