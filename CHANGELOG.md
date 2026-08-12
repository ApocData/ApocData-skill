# Changelog

All notable changes to the ApocData Skill are documented in this file.

---

## [v2.0.0] — 2026-08-12

### 🏗️ Breaking: Multi-file restructuring

The single-file SKILL.md (1182 lines / 47KB) has been split into a multi-file
structure following Claude Code skill conventions:

- **Entry SKILL.md** slimmed from 1182 → ~180 lines (token reduction: ~70%+ for simple queries)
- **14 reference files** in `references/` directory, loaded on demand
- **Progressive loading**: simple queries now only load entry + 1 reference file

### Added

- `references/boundaries.md` — Interface boundaries, HTTP headers, error codes, cache strategy, freshness SLA
- `references/group-a-quote.md` through `references/group-k-agent.md` — 11 endpoint group files
- `references/examples.md` — 5 multi-endpoint analysis scenarios
- `references/safety-rules.md` — 6 mandatory financial output safety rules
- `scripts/install.sh` — One-line install script for multi-file structure
- `CHANGELOG.md` — This file

### Changed

- Installation command updated from single-file `curl` to `tar.gz` extraction
- YAML front matter `description` enhanced with Chinese trigger keywords
- Scenario quick-reference table preserved in entry file for routing
- Endpoint dictionary moved to `references/` with navigation table

### Migration from v1.x

```bash
# Old (v1.x, single file) — no longer recommended
curl -L --fail -o ~/.claude/skills/apocdata/SKILL.md \
  https://raw.githubusercontent.com/ApocData/ApocData-skill/v1.1.0/SKILL.md

# New (v2.x, multi-file) — recommended
mkdir -p ~/.claude/skills/apocdata
curl -sL https://github.com/ApocData/ApocData-skill/archive/refs/tags/v2.0.0.tar.gz \
  | tar xz -C ~/.claude/skills/apocdata --strip-components=1
```

---

## [v1.1.0] — 2026-08-03

### Added

- Global `?fields=` support for all 45 active endpoints
- Global `?format=compact` columnar output mode (60-70% token savings)
- HTTP response headers: `X-Tdc-Limit-*`, `X-Tdc-Coverage-*`, `X-Tdc-Freshness-*`
- `Cache-Control` headers for all endpoints
- `/profile/full` comprehensive profile endpoint (8 dimensions)
- `/factor-categories` endpoint
- Error code system via `X-Tdc-Error-Code` / `X-Tdc-Error-Field` headers
- Financial output safety constraints (6 mandatory rules)
- Scenario quick-reference table (13 intent → endpoint combinations)

### Fixed

- Parameter validation: structured error responses with HTTP 400
- Limit truncation now reported via `X-Tdc-Limit-Truncated` header
- Data sparsity annotation via `X-Tdc-Coverage: sparse` header

---

## [v1.0.0] — 2026-05-26

### Initial release

- 45 active A-share data endpoints across 11 groups
- Zero-auth, zero-dependency (pure HTTP GET + curl)
- OpenAPI 3.0 JSON spec for GPT Actions / Coze / Dify integration
- Key differentiators:
  - Announcements with full Markdown content + AI summary
  - 150+ quantitative factor registry
  - Retail investor perspective data (limit-up board, hot money, dragon-tiger)
- Compatible with Claude / ChatGPT / Qwen / Kimi / DeepSeek
