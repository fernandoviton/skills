#!/usr/bin/env bash
set -euo pipefail

# Install skills and agents from github.com/fernandoviton/skills
# Usage: curl -fsSL https://raw.githubusercontent.com/fernandoviton/skills/main/install.sh | bash
#   or:  bash install.sh [-g] [target-dir]
#   -g   Install globally to ~/.claude/skills (user-level, all projects)

REPO_URL="https://github.com/fernandoviton/skills.git"
GLOBAL=false

while getopts "g" opt; do
  case "$opt" in
    g) GLOBAL=true ;;
    *) echo "Usage: $0 [-g] [target-dir]"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ "$GLOBAL" = true ]; then
  TARGET="$HOME/.claude"
else
  TARGET="${1:-.}"
  TARGET="$(cd "$TARGET" && pwd)"
  TARGET="$TARGET/.claude"
fi

if [ ! -d "$TARGET" ]; then
  echo "Creating $TARGET"
  mkdir -p "$TARGET"
fi

# Clone to a temp dir
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR/skills-repo"

SRC="$TMPDIR/skills-repo"

# Copy skills
if [ -d "$SRC/skills" ]; then
  mkdir -p "$TARGET/skills"
  cp -r "$SRC/skills/"* "$TARGET/skills/"
  echo "Installed skills:"
  find "$TARGET/skills" -name "SKILL.md" | while read -r f; do
    name=$(grep -m1 '^name:' "$f" | sed 's/name: *//')
    echo "  - $name"
  done
fi

# Copy agents
if [ -d "$SRC/agents" ]; then
  mkdir -p "$TARGET/agents"
  cp -r "$SRC/agents/"* "$TARGET/agents/"
  echo "Installed agents:"
  for f in "$TARGET/agents/"*; do
    echo "  - $(basename "$f")"
  done
fi

echo ""
echo "Done! Skills installed to $TARGET/"
