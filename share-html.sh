#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ $# -lt 1 || $# -gt 2 ]]; then
  printf '사용법: %s /경로/문서.html [저장소이름]\n' "$(basename "$0")" >&2
  exit 2
fi
SOURCE="$1"
if [[ ! -f "$SOURCE" ]]; then
  printf 'HTML 파일을 찾지 못했습니다: %s\n' "$SOURCE" >&2
  exit 2
fi
case "${SOURCE##*.}" in
  html|htm|HTML|HTM) ;;
  *) printf 'HTML(.html 또는 .htm) 파일만 배포할 수 있습니다.\n' >&2; exit 2 ;;
esac

cp "$SOURCE" "$ROOT/site/index.html"
if [[ $# -eq 2 ]]; then
  exec "$ROOT/deploy.sh" "$2"
else
  exec "$ROOT/deploy.sh"
fi
