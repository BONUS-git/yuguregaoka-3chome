#!/bin/sh
# 依存の取り込み（ADR-0052 の D3・ADR-0103 の D3、.ai/environment.md §3.2 の 1）。
# npm の依存だけを、コミットしたロックファイルのとおりに入れる。OS の道具（PostgreSQL・tofu）は入れない。
# ロックファイルはここでは作らない（作るのは依存を変える変更の中、ADR-0103 の D1）。
set -eu
cd "$(dirname "$0")/.."

if [ ! -e package.json ]; then
    echo "prepare: package.json がないので入れる依存はない"
    exit 0
fi
if [ ! -e package-lock.json ]; then
    echo "prepare: package-lock.json がない。依存を変える変更の中でロックファイルを作ってコミットする（ADR-0103）" >&2
    exit 1
fi
command -v npm >/dev/null 2>&1 || {
    echo "prepare: npm がない。検証の環境に Node.js（package.json の engines.node の主版）を入れる" >&2
    exit 1
}
npm ci --no-audit --no-fund
