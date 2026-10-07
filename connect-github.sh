#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v gh >/dev/null 2>&1; then
  GH="$(command -v gh)"
elif [[ -x "$HOME/.local/bin/gh" ]]; then
  GH="$HOME/.local/bin/gh"
else
  printf 'GitHub CLI(gh)를 찾지 못했습니다. %s\n' "$ROOT"
  exit 1
fi

printf '브라우저에서 GitHub 로그인을 완료하세요. 계정이 없다면 먼저 https://github.com/signup 에서 가입해야 합니다.\n'
"$GH" auth login --hostname github.com --git-protocol https --web --scopes repo,workflow
"$GH" auth setup-git
"$GH" auth status --hostname github.com
