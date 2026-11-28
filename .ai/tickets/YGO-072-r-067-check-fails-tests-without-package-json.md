# YGO-072 R-067 G-083 package.json がないと check.sh がテストを飛ばして通る
状態: open
M: M1

## 目的
`reviews/0004-phase-evaluation-2026-11-27.md` の R-067（区別: 中、評価の ID: E-021）を直す。
`scripts/check.sh` の 1 の段（Node.js とロックファイル）と 6 の段（Vitest）は `if [ -e package.json ]` で飛ばすので、`test/` にテストがあっても `package.json` がなければ `check: ok` になる。確かめる相手があるのに飛ばす組み合わせを、失敗にする。
あわせて `.ai/gaps.md` の G-083（R-076。`check.sh` のチケットの名前に依る段）を、ADR-0109 の D8・D12 によりこのチケットで追う。

## 依存
- 前提: YGO-078（`.ai/tickets/YGO-078-m1-package-json-lockfile-vitest.md`。`package.json` とロックファイル。YGO-062 から分けた）が `状態: done`、または同じ変更で `package.json` を入れること。どちらも満たさない間は、このチケットの指示を出さない `[assumed]`。
- 順: YGO-088（G-080。実装のジョブで許すコマンドの一覧が動くのを確かめる）→ YGO-078 → このチケット。YGO-078 は YGO-088 のあとに出し、このチケットは、前提の行のとおり YGO-078 が `状態: done` になってから（または同じ変更で `package.json` を入れる形で）出す。
- 理由: この段を入れると、`package.json` がない間は、それ以降のすべての変更で `check.sh` が失敗する。

## 範囲
- `scripts/check.sh`: `test/` の下に `*.test.ts` が 1 つ以上あるか `src/` があり、`package.json` がないときに、理由（`package.json` がないためテストを動かせない）を出して止まる段を足す。
- 段の注記に、YGO-072 と reviews/0004 の R-067 を書く。
- G-083: `scripts/check.sh` の t062・t078・t072 の段（特定のチケットが done ならファイルがある、という形の段）を、チケットの名前に依らない 1 つの段にまとめる。その段は、t062・t078・t072 の段が確かめていた事実をすべて確かめる: テスト（`test/` の `*.test.ts`）・コード（`src/` の `*.ts`）・道具（`scripts/prepare.sh`・`vitest.config.ts`・`package.json`）のどれかがあるなら、`package.json`・`package-lock.json`・`scripts/prepare.sh`・`vitest.config.ts`・`src/app.ts`・`test/test_TC_033_no_oauth_webauthn_routes.test.ts` がすべてあり、Vitest の段（6 の段）のあとで `test-results/junit.xml` がある `[assumed]`。`test-results/junit.xml` は Vitest が書くので、その確かめは Vitest の段のあとに置く。道具も条件に入れるので、`scripts/prepare.sh` だけを消しても段が失敗する（YGO-078 の受け入れ確認 9 と両立する）。注記に `G-083` と `R-076` を書く。
- `.ai/gaps.md` の G-083 の行を、この変更で閉じる（理由の列に済んだことと「残りはない」、出どころの列に `（YGO-072）`）。

## 直さないところ
- `package.json`・`package-lock.json` を作ること: YGO-078 で扱う。`scripts/prepare.sh` は YGO-062 で作った。
- 1 の段と 6 の段の中身（主版の確かめ・Vitest の結果の読み方）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-072 R-067 G-083 package.json がないと check.sh がテストを飛ばして通る`・`状態: done`・`M: M1`。
2. `scripts/check.sh` に、「`test/` の `*.test.ts` か `src/` があり、`package.json` がない」を条件にして `exit 1` する段があり、その注記に `YGO-072` と `R-067` がある。テストもコードもないときは、この段で止まらない。
3. このチケットが done になった変更で、`package.json` がある（YGO-078 が `状態: done`、または同じ変更で `package.json` を入れた）。
4. `scripts/check.sh` に `.ai/tickets/` を含む行がない。テスト（`test/` の `*.test.ts`）・コード（`src/` の `*.ts`）・道具（`scripts/prepare.sh`・`vitest.config.ts`・`package.json`）のどれかがあるときに、`package.json`・`package-lock.json`・`scripts/prepare.sh`・`vitest.config.ts`・`src/app.ts`・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`・`test-results/junit.xml` を確かめる段があり、その注記に `G-083` と `R-076` がある。`test-results/junit.xml` を確かめる行は、Vitest を動かす行より後にある。
5. `.ai/gaps.md` の G-083 の行の理由の列に「残りはない」があり、出どころの列に `（YGO-072）` がある。
6. `test/sh/` に、名前に TC の番号を入れたシェルのテストがあり、`scripts/check.sh` から動く。テストは 3 つの組み合わせ（`test/` の `*.test.ts` があり `package.json` がない → 0 以外／`src/` があり `package.json` がない → 0 以外／どちらもない → この段で止まらない）を確かめ、結果を JUnit XML で `test-results/` に書く。ネットワークを使わない。

## 確かめた事実（変更 20261128-0ead7e の時点）
- 変更 20261128-99240b（0bbc01ed）で入ったのは、このチケットの書き直しと `.ai/retros.md` の 1 節だけ。`scripts/check.sh` は変わっていない。
- `scripts/check.sh` に TC-066 の段はなく、`test/sh/` もない。`.ai/tests/test-plan.md` の表は TC-065 で終わる。TC-066 は df11fd で使った番号で、レポジトリには残っていない。
- 直っていない: `scripts/check.sh` の 1 の段（9 行目）と 6 の段（184 行目）は `if [ -e package.json ]` でテストを飛ばしている。テストがあり `package.json` がないときに止める段はない。
- チケットの名前に依る段（t062・t078・t072、163〜180 行目）は残っている。177〜180 行目の t072 の段は、このチケットが `状態: done` なのに `package.json` がないときに止める（受け入れ確認 3 を固定のコードで確かめる）。
- あるもの: `test/test_TC_033_no_oauth_webauthn_routes.test.ts`・`src/app.ts`・`vitest.config.ts`・`scripts/prepare.sh`。ないもの: `package.json`・`package-lock.json`・`node_modules/`（ファイルの一覧で確かめた）。
- YGO-078 は `状態: open`。`.ai/gaps.md` の G-083 は閉じていない。
- 計画の段階で、この作業ツリーの `sh scripts/check.sh` は `check: ok`・終了コード 0 で終わった（実装の段階では Bash が拒まれ、動かし直していない。`scripts/check.sh` とテストは変えていない）。
- df11fd の失敗の原因（推定。動かして再現していない）: 再開の作り方 1 の段の条件は、ファイルがあるかだけで決まる。今の木は「`src/` があり、`test/` に `*.test.ts` があり、`package.json` がない」ので、段を入れた `check.sh` は本物の木で `package.json がないためテストを動かせない（YGO-078）` を出して `exit 1` するはず。この変更では、写しの木（`git archive HEAD` を一時ディレクトリに展開したもの）に段を差し込んで動かす再現を試みたが、実装の段階で Bash が拒まれて動かせなかった。確かめたのは、ファイルの一覧と `check.sh` のコードを読んだところまで。
- 受け入れ確認 1〜6 は、どれも満たしていない。

## 止まっている理由と再開の条件
- 理由:
  - 依存の節の前提が済んでいない。今のレポジトリは、テストもコード（`src/`）もあり `package.json` がない。これは段が失敗にする組み合わせそのもので、段を入れると develop の `sh scripts/check.sh` が 0 以外で終わり、この変更自体もそれ以降のすべての変更もマージできなくなる。
  - G-083 でまとめる段（受け入れ確認 4）も `package.json`・`package-lock.json` があることを求めるので、同じ理由で今は失敗する。
  - 受け入れ確認 3（`package.json` がある）は YGO-078 の範囲で、`done` にすると 177〜180 行目の段も失敗にする。そのため `状態: open` のままにする。
- 再開の条件: 依存の節の前提と同じ（YGO-078 が `状態: done`、または同じ変更で `package.json` を入れる）。
- 再開のときの作り方 `[assumed]`:
  1. 判定: `scripts/check.sh` の 1 の段の前に、`test/` の下に `*.test.ts` が 1 つ以上あるか `src/` があり、`package.json` がないとき、`package.json がないためテストを動かせない（YGO-078）` と出して `exit 1` する段を足す。注記に `YGO-072` と `R-067` を書く。テストもコードもないときは、今の扱いのまま（この段では止めない）。
  2. テスト: `test/sh/test_TC_NNN_check_requires_package_json.sh`。TC の番号は、再開のときに `.ai/tests/test-plan.md` に TC を足して決める。`mktemp -d` で作った一時ディレクトリに `check.sh` を写して子のプロセスで動かし、3 つの組み合わせを確かめる: テストがあり `package.json` がない（0 以外）／`src/` があり `package.json` がない（0 以外）／どちらもない（この段では止まらない）。
  3. テストの結果と動かし方: 結果は `test-results/sh-junit.xml` に JUnit XML で書く。6 の段の `rm -rf test-results` より後に `check.sh` から動かし、ネットワークは使わない。
  4. G-083: 受け入れ確認 4 の段を入れ、t062・t078・t072 の段を消す。
  5. 本物の木で通す: テストは一時ディレクトリで組み合わせを試すが、それだけで終えない。段を入れたあと、レポジトリの作業ツリーそのもので `sh scripts/check.sh` を動かし、`check: ok`・終了コード 0 を確かめてから終える。
  6. 文書: 同じ変更で `.ai/environment.md`（§4.1 の段の一覧）・`.ai/tests/test-plan.md`・`.ai/gaps.md` の G-083 の行をそろえ、このチケットを `状態: done` にする。
