#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EDITOR_DIR="$ROOT_DIR/store-screenshots"
COMMAND="${1:-help}"

setup() {
  (
    cd "$EDITOR_DIR"
    npm install
    npx playwright install chromium
  )
}

require_dependencies() {
  if [[ ! -d "$EDITOR_DIR/node_modules" ]]; then
    echo "Dependencies are missing. Run: $0 setup" >&2
    exit 1
  fi
}

case "$COMMAND" in
  setup)
    setup
    ;;
  capture)
    "$ROOT_DIR/scripts/capture-app-store-screenshots.sh"
    ;;
  edit)
    require_dependencies
    cd "$EDITOR_DIR"
    exec npm run dev
    ;;
  export)
    require_dependencies
    cd "$EDITOR_DIR"
    exec npm run export
    ;;
  all)
    require_dependencies
    "$ROOT_DIR/scripts/capture-app-store-screenshots.sh"
    cd "$EDITOR_DIR"
    exec npm run export
    ;;
  *)
    cat <<EOF
Usage: $0 {setup|capture|edit|export|all}

  setup    Install editor and browser dependencies
  capture  Build the app and capture six Simulator screens
  edit     Start the screenshot editor
  export   Export all App Store sizes to a ZIP
  all      Capture source screens and export the ZIP
EOF
    ;;
esac
