#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"

cd "$FRONTEND_DIR"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh"
  nvm use >/dev/null
fi

if ! command -v node >/dev/null 2>&1; then
  echo "node is not installed. Install Node.js 24 first."
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is not installed. Run: corepack enable && corepack prepare pnpm@10 --activate"
  exit 1
fi

if [[ ! -d node_modules ]]; then
  pnpm install
fi

exec pnpm dev
