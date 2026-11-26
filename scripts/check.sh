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

# M1 の図に「未設計」の受け渡しが残っていないこと。シーケンス図の web と worker のあいだの
# 受け渡し（図に出るジョブ Jn）が、どれも async.md §2 のジョブの一覧の行にあること
# （YGO-051、reviews/0003 の R-060）。
for f in .ai/diagrams/m1-*.md; do
    [ -e "$f" ] || continue
    if grep -q '未設計' "$f"; then
        echo "$f に「未設計」が残っている（ジョブは async.md に設計して図から指す）" >&2
        exit 1
    fi
done
seq=.ai/diagrams/m1-registration-sequence.md
if [ -e "$seq" ]; then
    jobs=$(sed -n '/^```mermaid/,/^```/p' "$seq" | grep -oE 'J[0-9]+' | sort -u || true)
    for j in $jobs; do
        grep -qE "^\| $j \| " .ai/async.md || {
            echo "$seq に出る $j の行が async.md §2 のジョブの一覧にない" >&2
            exit 1
        }
    done
fi

echo "check: ok"
