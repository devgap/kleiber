#!/bin/bash
# install-brain.sh — project Kleiber global brain into ~/.claude (reversible).
# Usage: install-brain.sh install | uninstall
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC="$REPO_ROOT/docs/templates/global-CLAUDE.md"
DEST="$HOME/.claude/CLAUDE.md"
CMD="${1:-install}"

case "$CMD" in
  install)
    [ -f "$SRC" ] || { echo "missing source: $SRC"; exit 1; }
    mkdir -p "$HOME/.claude"
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
      cp "$DEST" "${DEST}.bak-$(date +%s)"
      echo "backed up existing $DEST"
    fi
    ln -sfn "$SRC" "$DEST"
    echo "linked $DEST -> $SRC"
    ;;
  uninstall)
    if [ -L "$DEST" ]; then rm "$DEST"; echo "removed symlink $DEST"; fi
    LATEST=""
    for f in "${DEST}".bak-*; do [ -e "$f" ] && LATEST="$f"; done
    [ -n "$LATEST" ] && { cp "$LATEST" "$DEST"; echo "restored $LATEST -> $DEST"; }
    ;;
  *) echo "usage: install-brain.sh install|uninstall"; exit 1 ;;
esac
