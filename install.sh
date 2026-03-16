#!/usr/bin/env bash
set -euo pipefail

# Install skills and agents from github.com/fernandoviton/skills
# Usage: curl -fsSL https://raw.githubusercontent.com/fernandoviton/skills/main/install.sh | bash
#   or:  bash install.sh [target-dir]

REPO_URL="https://github.com/fernandoviton/skills.git"
TARGET="${1:-.}"

# Resolve to absolute path
TARGET="$(cd "$TARGET" && pwd)"

if [ ! -d "$TARGET/.claude" ]; then
  echo "No .claude/ directory found in $TARGET — creating one."
  mkdir -p "$TARGET/.claude"
fi

# Clone to a temp dir
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR/skills-repo"

SRC="$TMPDIR/skills-repo"

# Copy skills
if [ -d "$SRC/skills" ]; then
  mkdir -p "$TARGET/.claude/skills"
  cp -r "$SRC/skills/"* "$TARGET/.claude/skills/"
  echo "Installed skills:"
  find "$TARGET/.claude/skills" -name "SKILL.md" | while read -r f; do
    name=$(grep -m1 '^name:' "$f" | sed 's/name: *//')
    echo "  - $name"
  done
fi

# Copy agents
if [ -d "$SRC/agents" ]; then
  mkdir -p "$TARGET/.claude/agents"
  cp -r "$SRC/agents/"* "$TARGET/.claude/agents/"
  echo "Installed agents:"
  for f in "$TARGET/.claude/agents/"*; do
    echo "  - $(basename "$f")"
  done
fi

echo ""
echo "Done! Skills installed to $TARGET/.claude/"
