#!/usr/bin/env bash
# Default: compile PDFs + HTML, then push the repo tree to sibling consumers (site, app).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$ROOT/tools/sync-public-knowledge.sh"

cmd=${1:-}

show_help() {
  echo "Usage: ./run.sh [command]"
  echo ""
  echo "  (default | rebuild)  Build PDFs + HTML, then sync to ../living-way-site and ../living-way-app when present."
  echo "  build-only             Build only; skip sync (e.g. no sibling repos, or CI without consumers)."
  echo "  sync                   Sync only; no LaTeX/HTML build (fast refresh of public-knowledge mirrors)."
  echo "  help                   Show this help."
}

do_build() {
  echo "==> Building PDFs and HTML..."
  echo "Compiling The_Living_Way.tex..."
  pdflatex -interaction=nonstopmode The_Living_Way.tex >/dev/null || echo "Warning: PDF build for Living Way had errors."

  echo "Compiling The_Living_Suttas.tex..."
  pdflatex -interaction=nonstopmode The_Living_Suttas.tex >/dev/null || echo "Warning: PDF build for Living Suttas had errors."

  echo "Compiling The_Living_Architecture.tex..."
  pdflatex -interaction=nonstopmode The_Living_Architecture.tex >/dev/null || echo "Warning: PDF build for Living Architecture had errors."

  (cd "$ROOT" && ./tools/build_html.sh)

  echo "==> Build complete."
}

sync_consumers() {
  if [[ ! -f "$SYNC_SCRIPT" ]]; then
    echo "ERROR: missing $SYNC_SCRIPT" >&2
    return 1
  fi
  if [[ ! -x "$SYNC_SCRIPT" ]]; then
    chmod +x "$SYNC_SCRIPT" || true
  fi

  local synced=false
  if [[ -d "$ROOT/../living-way-site" ]]; then
    echo "==> Syncing to living-way-site/public-knowledge/ ..."
    "$SYNC_SCRIPT" "$ROOT/../living-way-site/public-knowledge/"
    synced=true
  fi
  if [[ -d "$ROOT/../living-way-app" ]]; then
    echo "==> Syncing to living-way-app/public-knowledge/ ..."
    "$SYNC_SCRIPT" "$ROOT/../living-way-app/public-knowledge/"
    synced=true
  fi
  if [[ "$synced" == false ]]; then
    echo "==> No sibling repos at ../living-way-site or ../living-way-app — skipped sync."
    echo "    (Clone them next to this repo, or run: ./tools/sync-public-knowledge.sh <dest>)"
  fi
}

case "$cmd" in
  help|-h|--help)
    show_help
    ;;
  build-only)
    do_build
    ;;
  sync)
    sync_consumers
    ;;
  rebuild|"")
    do_build
    sync_consumers
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    show_help >&2
    exit 1
    ;;
esac
