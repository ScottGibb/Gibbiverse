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
  echo "No raw-content directory at $RAW_DIR — exiting"
  exit 1
fi

# Ensure link-fixer helper files exist so main.py doesn't error on open()
LINKS_FILE="$ROOT_DIR/raw-content/links.yaml"
TOPICS_FILE="$ROOT_DIR/raw-content/topics.txt"

if [ ! -f "$LINKS_FILE" ]; then
    echo "No links file found, exiting"
    exit 1
fi

if [ ! -f "$TOPICS_FILE" ]; then
    echo " No topics file found, exiting"
    exit 1
fi

echo "Running link-fixer..."
cd "$LINK_FIXER_DIR"
uv sync
uv run main.py --path "$CONTENT_DIR" --links "$LINKS_FILE" --topics "$TOPICS_FILE" || {
  echo "link-fixer returned non-zero exit code; aborting." >&2
  exit 1
}

# echo "Starting Hugo dev server (ctrl-c to stop)."
cd "$ROOT_DIR"
hugo server

