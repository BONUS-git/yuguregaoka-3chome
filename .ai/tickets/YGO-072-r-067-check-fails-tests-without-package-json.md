# YGO-072 R-067 package.json がないと check.sh がテストを飛ばして通る
状態: open
M: M1

## 目的
`reviews/0004-phase-evaluation-2026-11-27.md` の R-067（区別: 中、評価の ID: E-021）を直す。
`scripts/check.sh` の 1 の段（Node.js とロックファイル）と 6 の段（Vitest）は `if [ -e package.json ]` で飛ばすので、`test/` にテストがあっても `package.json` がなければ `check: ok` になる。確かめる相手があるのに飛ばす組み合わせを、失敗にする。

## 依存
- この段を入れると、`package.json` がない間は、それ以降のすべての変更で `check.sh` が失敗する。そのため、YGO-062 と同じ変更か、YGO-062 の done のあとに入れる `[assumed]`。

## 範囲
- `scripts/check.sh`: `test/` の下に `*.test.ts` が 1 つ以上あり、`package.json` がないときに、理由（`package.json` がないためテストを動かせない）を出して止まる段を足す。
- 段の注記に、YGO-072 と reviews/0004 の R-067 を書く。

## 直さないところ
- `package.json`・`package-lock.json`・`scripts/prepare.sh` を作ること: YGO-062 で扱う。
- 1 の段と 6 の段の中身（主版の確かめ・Vitest の結果の読み方）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-072 R-067 package.json がないと check.sh がテストを飛ばして通る`・`状態: done`・`M: M1`。
2. `scripts/check.sh` に、`test/` の `*.test.ts` があることと `package.json` がないことの両方を条件にして `exit 1` する段があり、その注記に `YGO-072` と `R-067` がある。
3. このチケットが done になった変更で、`package.json` がある（YGO-062 と同じ変更か、YGO-062 が `状態: done`）。
