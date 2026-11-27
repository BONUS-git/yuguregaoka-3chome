# YGO-072 R-067 package.json がないと check.sh がテストを飛ばして通る
状態: open
M: M1

## 目的
`reviews/0004-phase-evaluation-2026-11-27.md` の R-067（区別: 中、評価の ID: E-021）を直す。
`scripts/check.sh` の 1 の段（Node.js とロックファイル）と 6 の段（Vitest）は `if [ -e package.json ]` で飛ばすので、`test/` にテストがあっても `package.json` がなければ `check: ok` になる。確かめる相手があるのに飛ばす組み合わせを、失敗にする。

## 依存
- この段を入れると、`package.json` がない間は、それ以降のすべての変更で `check.sh` が失敗する。そのため、YGO-078（`package.json` とロックファイル。YGO-062 から分けた）と同じ変更か、YGO-078 の done のあとに入れる `[assumed]`。

## 範囲
- `scripts/check.sh`: `test/` の下に `*.test.ts` が 1 つ以上あり、`package.json` がないときに、理由（`package.json` がないためテストを動かせない）を出して止まる段を足す。
- 段の注記に、YGO-072 と reviews/0004 の R-067 を書く。

## 直さないところ
- `package.json`・`package-lock.json` を作ること: YGO-078 で扱う。`scripts/prepare.sh` は YGO-062 で作った。
- 1 の段と 6 の段の中身（主版の確かめ・Vitest の結果の読み方）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-072 R-067 package.json がないと check.sh がテストを飛ばして通る`・`状態: done`・`M: M1`。
2. `scripts/check.sh` に、`test/` の `*.test.ts` があることと `package.json` がないことの両方を条件にして `exit 1` する段があり、その注記に `YGO-072` と `R-067` がある。
3. このチケットが done になった変更で、`package.json` がある（YGO-078 と同じ変更か、YGO-078 が `状態: done`）。

## 確かめた事実（変更 20261127-936bd4 の時点）
- `package.json`・`package-lock.json` はない。
- `test/test_TC_033_no_oauth_webauthn_routes.test.ts` はある。
- YGO-078（`.ai/tickets/YGO-078-m1-package-json-lockfile-vitest.md`）は `状態: open`。YGO-078 の変更は、実装のジョブで `npm` と `sh scripts/prepare.sh` が権限で拒まれ、同じ段（ロックファイルの作成）で 3 回止まり（変更 20261127-54c015・20261127-5812ca・20261127-6b7da1）、どれも `.ai/` の記録だけで終わった（G-080）。権限が変わるまで YGO-078 を出し直しても進まない（G-082）。
- `scripts/check.sh` には、テストがあり `package.json` がないときに止める段はまだない。1 の段と 6 の段は `if [ -e package.json ]` で飛ばしている。前の YGO-072 の変更（c741492）が変えたのは、このチケットの事実の節だけ。
- この変更では段とテストを入れなかった。段を入れると `package.json` がない間は `sh scripts/check.sh` が失敗し、それ以降のどの変更もマージできなくなる。テストは Vitest で動かすので、`package.json` がないと動かず JUnit XML もできない。
- `scripts/check.sh` には、このチケットが `状態: done` なのに `package.json` がないときに止める段がある（受け入れ確認 3 を固定のコードで確かめる）。
- 受け入れ確認 1〜3 は、どれも満たしていない。

## 止まっている理由と再開の条件
- 理由: 依存の節のとおり、この段は YGO-078 と同じ変更か YGO-078 の done のあとに入れる。今入れると、TC-033 のテストがあり `package.json` がないため `check.sh` がすぐ失敗し、それ以降のすべての変更がマージできなくなる。受け入れ確認 3（`package.json` がある）も満たせないので、`状態: open` のままにする。
- 再開の条件: YGO-078 が `状態: done` で、`package.json` がある（または YGO-078 と同じ変更で入れる）。
- 再開のときの作り方 `[assumed]`:
  1. 段: `scripts/check.sh` の 1 の段の前に、`test/` の下に `*.test.ts` が 1 つ以上あり `package.json` がないとき、理由（`package.json` がないためテストを動かせない）を出して `exit 1` する段を足す。注記に `YGO-072` と `R-067` を書く。テストがないときは、この段では止めない。
  2. テスト: 名前に TC-NNN を入れたテストを足す。`check.sh` を一時ディレクトリに写し、テストがあり `package.json` がない組み合わせで 0 以外で終わることを確かめる。ネットワークを使わず、結果は `test-results/junit.xml` に書かれる。`check.sh` の写しは `mktemp -d` で作った一時ディレクトリに置き、子のプロセスで動かす。写しには `package.json` を置かない。
  3. 文書: 同じ変更で `.ai/environment.md`（§4.1 の段の一覧）と `.ai/tests/test-plan.md` をそろえ、このチケットを `状態: done` にする。
