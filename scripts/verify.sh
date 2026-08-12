#!/usr/bin/env bash
# ApocData Skill — endpoint verification + README timestamp update
# Usage:
#   bash scripts/verify.sh              # verify only
#   bash scripts/verify.sh --update     # verify + update README.md timestamp
set -euo pipefail

BASE="https://www.apocdata.com/api/blade-dataplatform/open/data"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
README="${SCRIPT_DIR}/../README.md"

ENDPOINTS=(
  "quote?symbol=000001"
  "stock?symbol=000001"
  "daily?symbol=000001&limit=1"
  "financial?symbol=000001&limit=1"
  "moneyflow?symbol=000001&limit=1"
  "hsgt?limit=1"
  "limit-list?limit=1"
  "announcements?symbol=000001&limit=1"
  "concepts?limit=1"
  "macro/latest?type=PMI"
  "calendar"
  "profile/full?symbol=000001"
)

TIMESTAMP=$(date '+%Y-%m-%d %H:%M %Z')
PASS=0
FAIL=0
TOTAL_TIME=0

echo "=== ApocData Endpoint Verification ==="
echo "Time: ${TIMESTAMP}"
echo ""

for ep in "${ENDPOINTS[@]}"; do
  name=$(echo "$ep" | cut -d'?' -f1)
  response=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" "$BASE/$ep" 2>/dev/null)
  code=$(echo "$response" | awk '{print $1}')
  time_s=$(echo "$response" | awk '{print $2}')
  time_ms=$(echo "$time_s" | awk '{printf "%.0f", $1 * 1000}')
  TOTAL_TIME=$(echo "$TOTAL_TIME $time_ms" | awk '{printf "%.0f", $1 + $2}')

  if [ "$code" = "200" ]; then
    echo "  ✅ ${name} → ${code} (${time_ms}ms)"
    PASS=$((PASS + 1))
  else
    echo "  ❌ ${name} → ${code} (${time_ms}ms)"
    FAIL=$((FAIL + 1))
  fi
done

AVG_TIME=$((TOTAL_TIME / ${#ENDPOINTS[@]}))

echo ""
echo "Result: ${PASS}/${#ENDPOINTS[@]} passed, avg ${AVG_TIME}ms"

if [ "$FAIL" -gt 0 ]; then
  echo "⚠️  ${FAIL} endpoint(s) failed!"
  exit 1
fi

echo "✅ All endpoints healthy."

# Update README.md timestamp if --update flag is passed
if [ "${1:-}" = "--update" ]; then
  if [ -f "$README" ]; then
    # Use Python for reliable UTF-8 replacement (macOS sed has issues with emoji)
    python3 -c "
import re, sys
with open(sys.argv[1], 'r') as f:
    content = f.read()
content = re.sub(
    r'Last verified:\*\* .*',
    'Last verified:** ' + sys.argv[2],
    content
)
content = re.sub(
    r'Core endpoints tested \| .*',
    'Core endpoints tested | ' + sys.argv[3] + '/' + sys.argv[4] + ' -> HTTP 200',
    content
)
content = re.sub(
    r'Avg latency \| .*',
    'Avg latency | ~' + sys.argv[5] + 'ms',
    content
)
with open(sys.argv[1], 'w') as f:
    f.write(content)
" "$README" "$TIMESTAMP" "$PASS" "${#ENDPOINTS[@]}" "$AVG_TIME"
    echo ""
    echo "README.md updated: timestamp=${TIMESTAMP}, pass=${PASS}/${#ENDPOINTS[@]}, avg=${AVG_TIME}ms"
  else
    echo "README.md not found at ${README}, skipping update."
  fi
fi
