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

## 確かめた事実（変更 20261127-e16545 の時点）
- YGO-062（`.ai/tickets/YGO-062-m1-test-harness.md`）は `状態: done`。範囲は台本・設定・例のテストまでで、`package.json` とロックファイルは YGO-078（`状態: open`）に分けた。
- `package.json`・`package-lock.json` はない。
- `test/test_TC_033_no_oauth_webauthn_routes.test.ts` はある。
- YGO-078 を止めているのは、実装のジョブが `node`・`npm` のコマンド（と、確かめていない `sh scripts/prepare.sh`）を動かす権限がないこと（G-080。`sh scripts/check.sh` は動く）。与えるのは秘書のジョブの実行の設定で、OQ-086 とは別。

## 止まっている理由と再開の条件
- 理由: 依存の節のとおり、この段は YGO-078 と同じ変更か YGO-078 の done のあとに入れる。今入れると、TC-033 のテストがあり `package.json` がないため `check.sh` がすぐ失敗し、それ以降のすべての変更がマージできなくなる。受け入れ確認 3（`package.json` がある）も満たせないので、`状態: open` のままにする。
- 再開の条件: YGO-078 が `状態: done` で、`package.json` がある（または YGO-078 と同じ変更で入れる）。
- 再開のときの作り方 `[assumed]`:
  1. 段: `scripts/check.sh` の 1 の段の前に、`test/` の下に `*.test.ts` が 1 つ以上あり `package.json` がないとき、理由（`package.json` がないためテストを動かせない）を出して `exit 1` する段を足す。注記に `YGO-072` と `R-067` を書く。テストがないときは、この段では止めない。
  2. テスト: 名前に TC-NNN を入れたテストを足す。`check.sh` を一時ディレクトリに写し、テストがあり `package.json` がない組み合わせで 0 以外で終わることを確かめる。ネットワークを使わず、結果は `test-results/junit.xml` に書かれる。
  3. 文書: 同じ変更で `.ai/environment.md`（§4.1 の段の一覧）と `.ai/tests/test-plan.md` をそろえ、このチケットを `状態: done` にする。
