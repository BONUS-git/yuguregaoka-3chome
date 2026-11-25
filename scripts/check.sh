#!/bin/sh
# このレポジトリの確認の入り口（SEC-056）。秘書の変更のジョブは、これが通らないとマージに進めない。
# ネットワークなしで動くこと。コードとテストが増えたら、ここから動かす。
set -eu
cd "$(dirname "$0")/.."

test -s .ai/brief.md
test -s LICENSE
for f in .ai/*.md .ai/adr/*.md .ai/reviews/*.md; do
    [ -e "$f" ] || continue
    test -s "$f" || { echo "空の文書: $f" >&2; exit 1; }
done

# 今の M の FR（roadmap.md の「- M<n>: FR-…」の行）と NFR-013 の正本の行に、
# 未決の書き方が残っていないこと（YGO-027、reviews/0002 の R-050、retros.md 2026-11-25）。
m_line=$(grep -E '^- M[0-9]+: FR-' .ai/roadmap.md || true)
[ -n "$m_line" ] || { echo "roadmap.md に今の M の範囲の行（- M<n>: FR-…）がない" >&2; exit 1; }
ids=$(printf '%s\n' "$m_line" | sed 's/^- M[0-9]*: //' | tr ',' '\n' | tr -d ' ')
for id in $ids NFR-013; do
    row=$(grep -E "^\| $id \|" .ai/requirements.md || true)
    [ -n "$row" ] || { echo "requirements.md に $id の行がない" >&2; exit 1; }
    case "$row" in
        *'秘書が ADR に記録して決定する'*|*'未確定（open-questions'*)
            echo "requirements.md の $id の行が未決のまま（今の M の FR は決めた中身と ADR で書く）" >&2
            exit 1
            ;;
    esac
done

echo "check: ok"
