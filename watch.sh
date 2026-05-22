#!/usr/bin/env bash
set -euo pipefail

main_file="${1:-cv.tex}"

if [[ ! -f "$main_file" ]]; then
  echo "Error: '$main_file' not found."
  echo "Usage: ./watch.sh [main-tex-file]"
  exit 1
fi

if command -v latexmk >/dev/null 2>&1; then
  echo "Using latexmk watch mode for $main_file"
  exec latexmk -lualatex -pvc "$main_file"
fi

echo "latexmk not found; using fallback polling mode with lualatex."
echo "Install latexmk for better behavior:"
echo "  sudo tlmgr install latexmk"

build() {
  if lualatex -interaction=nonstopmode "$main_file"; then
    echo "Build succeeded."
  else
    echo "Build failed; watcher will continue running."
  fi
}

last_stamp="$(stat -f "%m" "$main_file")"
echo "Initial build..."
build
echo "Watching $main_file (poll interval: 1s). Press Ctrl+C to stop."

while true; do
  sleep 1
  current_stamp="$(stat -f "%m" "$main_file")"
  if [[ "$current_stamp" != "$last_stamp" ]]; then
    last_stamp="$current_stamp"
    echo "Change detected, rebuilding..."
    build
  fi
done
