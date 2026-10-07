#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if command -v gh >/dev/null 2>&1; then
  GH="$(command -v gh)"
elif [[ -x "$HOME/.local/bin/gh" ]]; then
  GH="$HOME/.local/bin/gh"
else
  printf 'GitHub CLI(gh)를 찾지 못했습니다.\n' >&2
  exit 1
fi

REPO_NAME="${1:-html-share}"
VISIBILITY="${VISIBILITY:-public}"
if [[ ! "$REPO_NAME" =~ ^[A-Za-z0-9._-]+$ ]]; then
  printf '저장소 이름은 영문·숫자·점·밑줄·하이픈만 사용할 수 있습니다.\n' >&2
  exit 2
fi
if [[ "$VISIBILITY" != "public" && "$VISIBILITY" != "private" ]]; then
  printf 'VISIBILITY는 public 또는 private이어야 합니다.\n' >&2
  exit 2
fi
if [[ ! -f site/index.html ]]; then
  printf 'site/index.html 파일이 없습니다.\n' >&2
  exit 2
fi
if ! "$GH" auth status --hostname github.com >/dev/null 2>&1; then
  printf 'GitHub 로그인이 필요합니다. 먼저 ./connect-github.sh 를 실행하세요.\n' >&2
  exit 3
fi

OWNER="$("$GH" api user --jq '.login')"
FULL_REPO="$OWNER/$REPO_NAME"

if [[ ! -d .git ]]; then
  git init -b main
fi

git config user.name "$("$GH" api user --jq '.name // .login')"
git config user.email "$OWNER@users.noreply.github.com"
git add .
if ! git diff --cached --quiet || ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git commit -m "Publish HTML document"
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  if "$GH" repo view "$FULL_REPO" --json name --jq '.name' >/dev/null 2>&1; then
    git remote add origin "https://github.com/$FULL_REPO.git"
  else
    "$GH" repo create "$FULL_REPO" "--$VISIBILITY" --disable-wiki --description "Published HTML documents"
    git remote add origin "https://github.com/$FULL_REPO.git"
  fi
fi

git push -u origin main

PAGES_ENDPOINT="repos/$FULL_REPO/pages"
PAGES_FIELDS=(-F 'build_type=workflow' -F 'source[branch]=main' -F 'source[path]=/')
if "$GH" api "$PAGES_ENDPOINT" --silent >/dev/null 2>&1; then
  "$GH" api -X PUT "$PAGES_ENDPOINT" "${PAGES_FIELDS[@]}" --silent
else
  "$GH" api -X POST "$PAGES_ENDPOINT" "${PAGES_FIELDS[@]}" --silent
fi

"$GH" workflow run deploy-pages.yml -R "$FULL_REPO" --ref main
RUN_ID=""
for _ in $(seq 1 15); do
  RUN_ID="$("$GH" run list -R "$FULL_REPO" --workflow deploy-pages.yml --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)"
  [[ -n "$RUN_ID" && "$RUN_ID" != "null" ]] && break
  sleep 2
done
if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
  printf '워크플로 실행은 요청됐지만 실행 ID를 찾지 못했습니다. GitHub Actions 탭을 확인하세요.\n' >&2
  exit 4
fi
"$GH" run watch "$RUN_ID" -R "$FULL_REPO" --compact --exit-status

PAGE_URL="$("$GH" api "$PAGES_ENDPOINT" --jq '.html_url')"
printf '\n배포 완료: %s\n' "$PAGE_URL"
