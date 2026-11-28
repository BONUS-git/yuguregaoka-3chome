# YGO-072 R-067 G-083 package.json がないと check.sh がテストを飛ばして通る
状態: open
M: M1

## 目的
`reviews/0004-phase-evaluation-2026-11-27.md` の R-067（区別: 中、評価の ID: E-021）を直す。
`scripts/check.sh` の 1 の段（Node.js とロックファイル）と 6 の段（Vitest）は `if [ -e package.json ]` で飛ばすので、`test/` にテストがあっても `package.json` がなければ `check: ok` になる。確かめる相手があるのに飛ばす組み合わせを、失敗にする。
あわせて `.ai/gaps.md` の G-083（R-076。`check.sh` のチケットの名前に依る段）を、ADR-0108 の D3・D7 によりこのチケットで追う。

## 依存
- この段を入れると、`package.json` がない間は、それ以降のすべての変更で `check.sh` が失敗する。そのため、YGO-078（`package.json` とロックファイル。YGO-062 から分けた）と同じ変更か、YGO-078 の done のあとに入れる `[assumed]`。

## 範囲
- `scripts/check.sh`: `test/` の下に `*.test.ts` が 1 つ以上あり、`package.json` がないときに、理由（`package.json` がないためテストを動かせない）を出して止まる段を足す。
- 段の注記に、YGO-072 と reviews/0004 の R-067 を書く。
- G-083: `scripts/check.sh` の t062・t078・t072 の段（特定のチケットが done ならファイルがある、という形の段）を、チケットの名前に依らない 1 つの段にまとめる。その段は、t062・t078・t072 の段が確かめていた事実をすべて確かめる: テスト（`test/` の `*.test.ts`）・コード（`src/` の `*.ts`）・道具（`scripts/prepare.sh`・`vitest.config.ts`・`package.json`）のどれかがあるなら、`package.json`・`package-lock.json`・`scripts/prepare.sh`・`vitest.config.ts`・`src/app.ts`・`test/test_TC_033_no_oauth_webauthn_routes.test.ts` がすべてあり、Vitest の段（6 の段）のあとで `test-results/junit.xml` がある `[assumed]`。`test-results/junit.xml` は Vitest が書くので、その確かめは Vitest の段のあとに置く。道具も条件に入れるので、`scripts/prepare.sh` だけを消しても段が失敗する（YGO-078 の受け入れ確認 9 と両立する）。注記に `G-083` と `R-076` を書く。
- `.ai/gaps.md` の G-083 の行を、この変更で閉じる（理由の列に済んだことと「残りはない」、出どころの列に `（YGO-072）`）。

## 直さないところ
- `package.json`・`package-lock.json` を作ること: YGO-078 で扱う。`scripts/prepare.sh` は YGO-062 で作った。
- 1 の段と 6 の段の中身（主版の確かめ・Vitest の結果の読み方）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-072 R-067 G-083 package.json がないと check.sh がテストを飛ばして通る`・`状態: done`・`M: M1`。
2. `scripts/check.sh` に、`test/` の `*.test.ts` があることと `package.json` がないことの両方を条件にして `exit 1` する段があり、その注記に `YGO-072` と `R-067` がある。
3. このチケットが done になった変更で、`package.json` がある（YGO-078 と同じ変更か、YGO-078 が `状態: done`）。
4. `scripts/check.sh` に `.ai/tickets/` を含む行がない。テスト（`test/` の `*.test.ts`）・コード（`src/` の `*.ts`）・道具（`scripts/prepare.sh`・`vitest.config.ts`・`package.json`）のどれかがあるときに、`package.json`・`package-lock.json`・`scripts/prepare.sh`・`vitest.config.ts`・`src/app.ts`・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`・`test-results/junit.xml` を確かめる段があり、その注記に `G-083` と `R-076` がある。`test-results/junit.xml` を確かめる行は、Vitest を動かす行より後にある。
5. `.ai/gaps.md` の G-083 の行の理由の列に「残りはない」があり、出どころの列に `（YGO-072）` がある。

## 確かめた事実（変更 20261128-69c910 の時点）
- 直っていない: `scripts/check.sh` の 1 の段（9 行目）と 6 の段（184 行目）は `if [ -e package.json ]` でテストを飛ばしている。テストがあり `package.json` がないときに止める段はない。
- `package.json`・`package-lock.json`・`node_modules/` はない。テストは `test/test_TC_033_no_oauth_webauthn_routes.test.ts` が 1 つある。
- YGO-078（`.ai/tickets/YGO-078-m1-package-json-lockfile-vitest.md`）は `状態: open`。実装のジョブではコマンドを動かす道具（Bash）が拒まれるため、YGO-078 は同じ段（ロックファイルの作成）で 6 回止まっている（G-080・G-082）。
- `scripts/check.sh` の 176〜180 行目には、このチケットが `状態: done` なのに `package.json` がないときに止める段がある（受け入れ確認 3 を固定のコードで確かめる）。
- 今は段もテストも入れられない。理由は次の 3 つ。
  - 段を入れると、今のレポジトリ（テストはあり、`package.json` はない）がちょうど失敗の組み合わせになり、`sh scripts/check.sh` が 0 以外で終わって、この変更もそれ以降のどの変更もマージできなくなる。
  - テストは Vitest で動き、結果を `test-results/junit.xml` に出す。`package.json` がないと Vitest が動かず、XML もできない。
  - `done` にすると 176〜180 行目の段が失敗にし、受け入れ確認 3（`package.json` がある）も満たせない。`package.json` を入れるのは YGO-078 の範囲。
- 受け入れ確認 1〜3 は、どれも満たしていない。

## 止まっている理由と再開の条件
- 理由: 依存の節のとおり、この段は YGO-078 と同じ変更か YGO-078 の done のあとに入れる。今入れると、TC-033 のテストがあり `package.json` がないため `check.sh` がすぐ失敗し、それ以降のすべての変更がマージできなくなる。受け入れ確認 3（`package.json` がある）も満たせないので、`状態: open` のままにする。
- 再開の条件: YGO-078 が `状態: done` で、`package.json` がある（または YGO-078 と同じ変更で入れる）。
- 再開のときの作り方 `[assumed]`:
  1. 段: `scripts/check.sh` の 1 の段の前に、`test/` の下に `*.test.ts` が 1 つ以上あり `package.json` がないとき、理由（`package.json` がないためテストを動かせない）を出して `exit 1` する段を足す。注記に `YGO-072` と `R-067` を書く。テストがないときは、この段では止めない。
  2. テスト: 名前に TC-NNN を入れたテストを足す。`check.sh` を一時ディレクトリに写し、テストがあり `package.json` がない組み合わせで 0 以外で終わることを確かめる。ネットワークを使わず、結果は `test-results/junit.xml` に書かれる。`check.sh` の写しは `mktemp -d` で作った一時ディレクトリに置き、子のプロセスで動かす。写しには `package.json` を置かない。
  3. 文書: 同じ変更で `.ai/environment.md`（§4.1 の段の一覧）と `.ai/tests/test-plan.md` をそろえ、このチケットを `状態: done` にする。
