#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

BIN_TARGET="$HOME/.local/bin"
mkdir -p "$BIN_TARGET"
chmod +x "$HERE/bin/meeting"
ln -sf "$HERE/bin/meeting" "$BIN_TARGET/meeting"
echo "✓ CLI:   $BIN_TARGET/meeting -> $HERE/bin/meeting"

# Claude Code skill
SKILL_DIR="$HOME/.claude/skills/meeting"
mkdir -p "$SKILL_DIR"
cp "$HERE/skills/claude/meeting/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "✓ skill: $SKILL_DIR/SKILL.md (/meeting in Claude Code)"

case ":$PATH:" in
  *":$BIN_TARGET:"*) ;;
  *) echo "⚠ add to PATH:  export PATH=\"$BIN_TARGET:\$PATH\"" ;;
esac

echo
echo "next: run 'meeting setup'  (brew install whisper-cpp + download model ~1.6GB)"
