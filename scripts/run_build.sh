#!/usr/bin/env sh
set -euo pipefail

# run_build.sh
# 1) copy files from raw-content -> content (rsync)
# 2) ensure link-fixer helper files exist (links.yaml/topics.txt)
# 3) run the Python link-fixer against the content directory
# 4) start Hugo dev server (replaces this process so the server stays running)

# Usage: ./scripts/run_build.sh

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RAW_DIR="$ROOT_DIR/raw-content"
CONTENT_DIR="$ROOT_DIR/content"
LINK_FIXER_DIR="$ROOT_DIR/link-fixer"

echo "ROOT_DIR: $ROOT_DIR"

if [ -d "$RAW_DIR" ]; then
  echo "Copying raw content from $RAW_DIR -> $CONTENT_DIR"
  mkdir -p "$CONTENT_DIR"
  rsync -av --delete "$RAW_DIR/" "$CONTENT_DIR/"
else
  echo "No raw-content directory at $RAW_DIR — skipping copy step"
fi

# Ensure link-fixer helper files exist so main.py doesn't error on open()
LINKS_FILE="$ROOT_DIR/raw-content/links.yaml"
TOPICS_FILE="$ROOT_DIR/raw-content/topics.txt"

if [ ! -f "$LINKS_FILE" ]; then
  echo "Creating empty $LINKS_FILE"
  mkdir -p "$(dirname "$LINKS_FILE")"
  printf "{}\n" > "$LINKS_FILE"
fi

if [ ! -f "$TOPICS_FILE" ]; then
  echo "Creating empty $TOPICS_FILE"
  printf "\n" > "$TOPICS_FILE"
fi

echo "Running link-fixer..."
if command -v python3 >/dev/null 2>&1; then
  PY=python3
elif command -v python >/dev/null 2>&1; then
  PY=python
else
  echo "Python not found in PATH. Install Python 3.12+ and try again." >&2
  exit 1
fi

"$PY" "$LINK_FIXER_DIR/main.py" --path "$CONTENT_DIR" --links "$LINKS_FILE" --topics "$TOPICS_FILE" || {
  echo "link-fixer returned non-zero exit code; aborting." >&2
  exit 1
}

