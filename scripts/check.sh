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

# 確かめ済みの mvp.md に古い参照が残っていないこと（YGO-053、reviews/0003 の R-062、gaps.md G-050）。
# mvp.md が指す ADR は、どれも状態が「採用」であること。
mvp=.ai/mvp.md
if [ -e "$mvp" ]; then
    adrs=$(grep -oE 'ADR-[0-9]{4}' "$mvp" | sort -u | sed 's/^ADR-//' || true)
    for n in $adrs; do
        af=$(ls .ai/adr/"$n"-*.md 2>/dev/null | head -n 1 || true)
        [ -n "$af" ] || { echo "$mvp が指す ADR-$n のファイルが .ai/adr/ にない" >&2; exit 1; }
        grep -qxF -- '- 状態: 採用' "$af" || {
            echo "$mvp が採用でない ADR-$n を指している（$af の状態の行を見て今の ADR に直す）" >&2
            exit 1
        }
    done
    # mvp.md で「持ち越し」と書いた行の OQ は、open-questions.md の表でも「持ち越し」であること。
    oqs=$(grep '持ち越し' "$mvp" | grep -oE 'OQ-[0-9]{3}' | sort -u || true)
    for q in $oqs; do
        grep -qE "^\| $q \|[^|]*\| 持ち越し \|" .ai/open-questions.md || {
            echo "$mvp は $q を持ち越しと書いているが、open-questions.md の表では持ち越しでない" >&2
            exit 1
        }
    done
fi

# 地図（INDEX.md）に .ai/ の下のすべてのファイルが載り、地図のパスがどれも実在すること（YGO-059、条件 6）。
# ADR の行の末尾の状態は、その ADR の 3 行目（- 状態: …）と同じであること。
idx=.ai/INDEX.md
if [ -e "$idx" ]; then
    for f in $(find .ai -type f ! -name '.*' | sort); do
        grep -qF -- "\`$f\`" "$idx" || { echo "$f が $idx に載っていない" >&2; exit 1; }
    done
    for p in $(grep -oE '`\.ai/[^` ]+`' "$idx" | tr -d '`' | sort -u); do
        [ -e "$p" ] || { echo "$idx の $p が実在しない（正しいパスに直すか消す）" >&2; exit 1; }
    done
    for af in .ai/adr/[0-9]*.md; do
        [ -e "$af" ] || continue
        st=$(sed -n '3s/^- 状態: //p' "$af")
        [ -n "$st" ] || { echo "$af の 3 行目が状態の行（- 状態: …）でない" >&2; exit 1; }
        grep -qxF -- "- \`$af\` — $st" "$idx" || {
            echo "$idx の $af の行の末尾が状態（$st）と合っていない" >&2
            exit 1
        }
    done
fi

echo "check: ok"
