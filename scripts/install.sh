#!/usr/bin/env bash
# ApocData Skill — one-line installer
# Usage: curl -sL https://raw.githubusercontent.com/ApocData/ApocData-skill/v2.0.0/scripts/install.sh | bash
set -euo pipefail

VERSION="${APOCDATA_VERSION:-v2.0.0}"
REPO="ApocData/ApocData-skill"
INSTALL_DIR="${HOME}/.claude/skills/apocdata"

echo "🔧 Installing ApocData Skill ${VERSION}..."

# Create target directory
mkdir -p "${INSTALL_DIR}"

# Download and extract
echo "📦 Downloading from GitHub..."
curl -sL "https://github.com/${REPO}/archive/refs/tags/${VERSION}.tar.gz" \
  | tar xz -C "${INSTALL_DIR}" --strip-components=1

# Verify
if [ -f "${INSTALL_DIR}/SKILL.md" ] && [ -d "${INSTALL_DIR}/references" ]; then
  REF_COUNT=$(find "${INSTALL_DIR}/references" -name "*.md" | wc -l | tr -d ' ')
  echo "✅ ApocData Skill ${VERSION} installed successfully!"
  echo "   Entry: ${INSTALL_DIR}/SKILL.md"
  echo "   References: ${REF_COUNT} files in ${INSTALL_DIR}/references/"
  echo ""
  echo "🔄 Restart Claude Code to activate the skill."
else
  echo "❌ Installation failed. Please check your network and try again."
  exit 1
fi
