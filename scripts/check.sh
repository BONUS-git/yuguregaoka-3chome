#!/bin/sh
# このレポジトリの確認の入り口（SEC-056）。秘書の変更のジョブは、これが通らないとマージに進めない。
# ネットワークなしで動くこと。コードとテストが増えたら、ここから動かす。
set -eu
cd "$(dirname "$0")/.."

# 1. Node.js とロックファイルを確かめる（YGO-062、.ai/environment.md §4.1 の 1、ADR-0103）。
# package.json があるときだけ。node がない・主版が engines.node と違うときは、要る主版を出して止まる。
if [ -e package.json ]; then
    need=$(sed -n 's/.*"node"[[:space:]]*:[[:space:]]*"\([0-9][0-9]*\)\..*/\1/p' package.json | head -n 1)
    [ -n "$need" ] || { echo "package.json の engines.node に主版（例: \"26.x\"）がない" >&2; exit 1; }
    command -v node >/dev/null 2>&1 || {
        echo "node がない: 検証の環境に Node.js $need を入れる（package.json の engines.node）" >&2
        exit 1
    }
    have=$(node -p 'process.versions.node.split(".")[0]')
    [ "$have" = "$need" ] || {
        echo "node の主版が $have で engines.node の $need と違う: 検証の環境に Node.js $need を入れる" >&2
        exit 1
    }
    [ -e package-lock.json ] || {
        echo "package-lock.json がない: 依存を変える変更の中でロックファイルを作ってコミットする（ADR-0103）" >&2
        exit 1
    }
    # package.json の依存の名前がどれもロックファイルにあり、版に範囲の記号（^・~）がないこと。
    node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const lock = JSON.parse(fs.readFileSync("package-lock.json", "utf8"));
const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
let bad = 0;
for (const [name, ver] of Object.entries(deps)) {
  if (!lock.packages || !lock.packages["node_modules/" + name]) {
    console.error("package.json の " + name + " が package-lock.json にない（依存を変えたらロックファイルも直す）");
    bad = 1;
  }
  if (/^[\^~]/.test(ver)) {
    console.error("package.json の " + name + " の版 " + ver + " に範囲の記号がある（版は固定する）");
    bad = 1;
  }
}
process.exit(bad);
'
fi

test -s .ai/brief.md
test -s LICENSE
for f in .ai/*.md .ai/adr/*.md .ai/reviews/*.md; do
    [ -e "$f" ] || continue
    test -s "$f" || { echo "空の文書: $f" >&2; exit 1; }
done

# 今の M（M1）の FR（roadmap.md の「- M1: <名前>。FR-…」の行）と NFR-013 の正本の行に、
# 未決の書き方が残っていないこと（YGO-027、reviews/0002 の R-050、retros.md 2026-11-25）。
m_line=$(grep -E '^- M1: ' .ai/roadmap.md || true)
[ -n "$m_line" ] || { echo "roadmap.md に今の M の範囲の行（- M1: <名前>。FR-…）がない" >&2; exit 1; }
ids=$(printf '%s\n' "$m_line" | grep -oE 'FR-[0-9]{3}' || true)
[ -n "$ids" ] || { echo "roadmap.md の今の M の行（- M1: <名前>。FR-…）に FR がない" >&2; exit 1; }
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

# M1 の図のそれぞれに「- FR:」「- ADR:」「- 確かめた M: M1」の行と mermaid のブロックがあり、
# ADR の行はどれも状態が「採用」の ADR を指し、FR の行は roadmap.md の「- M1: <名前>。FR-…」の行にあること
# （YGO-060、条件 4）。
m1_fr=$(grep -E '^- M1: ' .ai/roadmap.md | grep -oE 'FR-[0-9]{3}' || true)
[ -n "$m1_fr" ] || { echo "roadmap.md に M1 の FR の行（- M1: <名前>。FR-…）がない" >&2; exit 1; }
for f in .ai/diagrams/m1-*.md; do
    [ -e "$f" ] || continue
    grep -qE '^- FR: FR-[0-9]{3}' "$f" || { echo "$f に「- FR: FR-NNN, …」の行がない" >&2; exit 1; }
    grep -qE '^- ADR: [0-9]{4}' "$f" || { echo "$f に「- ADR: NNNN, …」の行がない" >&2; exit 1; }
    grep -qxF -- '- 確かめた M: M1' "$f" || { echo "$f に「- 確かめた M: M1」の行がない" >&2; exit 1; }
    grep -qxF -- '```mermaid' "$f" || { echo "$f に mermaid のブロックがない" >&2; exit 1; }
    for n in $(grep -E '^- ADR: ' "$f" | grep -oE '[0-9]{4}' | sort -u); do
        af=$(ls .ai/adr/"$n"-*.md 2>/dev/null | head -n 1 || true)
        [ -n "$af" ] || { echo "$f が指す ADR-$n のファイルが .ai/adr/ にない" >&2; exit 1; }
        grep -qxF -- '- 状態: 採用' "$af" || {
            echo "$f が採用でない ADR-$n を指している（$af の状態の行を見て今の ADR に直す）" >&2
            exit 1
        }
    done
    for id in $(grep -E '^- FR: ' "$f" | grep -oE 'FR-[0-9]{3}' | sort -u); do
        printf '%s\n' "$m1_fr" | grep -qxF -- "$id" || {
            echo "$f の $id が roadmap.md §4 の M1 の FR にない" >&2
            exit 1
        }
    done
done

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

# YGO-062 を done にしたなら、その範囲の土台のファイルがそろっていること（retros.md 2026-11-26 の 2 回目）。
t062=.ai/tickets/YGO-062-m1-test-harness.md
if [ -e "$t062" ] && grep -qxF '状態: done' "$t062"; then
    for f in scripts/prepare.sh vitest.config.ts src/app.ts test/test_TC_033_no_oauth_webauthn_routes.test.ts; do
        [ -e "$f" ] || { echo "$t062 は done なのに $f がない" >&2; exit 1; }
    done
fi
# YGO-078 を done にしたなら、package.json・ロックファイル・prepare.sh がそろっていること（YGO-062 から分けた範囲）。
t078=.ai/tickets/YGO-078-m1-package-json-lockfile-vitest.md
if [ -e "$t078" ] && grep -qxF '状態: done' "$t078"; then
    for f in package.json package-lock.json scripts/prepare.sh; do
        [ -e "$f" ] || { echo "$t078 は done なのに $f がない" >&2; exit 1; }
    done
fi
# YGO-072 を done にしたなら、package.json があること（reviews/0004 の R-067、受け入れ確認 3）。
t072=.ai/tickets/YGO-072-r-067-check-fails-tests-without-package-json.md
if [ -e "$t072" ] && grep -qxF '状態: done' "$t072"; then
    [ -e package.json ] || { echo "$t072 は done なのに package.json がない" >&2; exit 1; }
fi

# 6. Vitest を動かす（ADR-0009、.ai/environment.md §4.1 の 6）。ネットワークは使わない。
# 結果は test-results/junit.xml。skip・todo は通っていないと数え、名前に TC-NNN のないテストも失敗にする。
if [ -e package.json ]; then
    [ -d node_modules ] || { echo "node_modules/ がない: 先に sh scripts/prepare.sh を動かす" >&2; exit 1; }
    rm -rf test-results
    npx --no-install vitest run
    xml=test-results/junit.xml
    [ -s "$xml" ] || { echo "$xml ができていない（vitest.config.ts の junit の報告を見る）" >&2; exit 1; }
    grep -q '<testcase' "$xml" || { echo "$xml にテストが 1 つもない" >&2; exit 1; }
    if grep -q '<skipped' "$xml"; then
        echo "$xml に skip か todo のテストがある（通っていないと数える）" >&2
        exit 1
    fi
    nontc=$(grep -oE '<testcase[^>]*>' "$xml" | grep -vE ' name="[^"]*TC-[0-9]{3}' || true)
    [ -z "$nontc" ] || { echo "名前に TC-NNN のないテストがある: $nontc" >&2; exit 1; }
fi

echo "check: ok"
