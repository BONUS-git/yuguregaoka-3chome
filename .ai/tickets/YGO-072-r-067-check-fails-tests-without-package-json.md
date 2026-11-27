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

## 残り
受け入れ確認を 1 行ずつ、今のファイルと照らした結果。どれも満たさないため、段を入れずに `状態: open` のままにする。

| 番号 | 結果 | 根拠 |
|---|---|---|
| 1 | 満たさない | 2 行目が `状態: open`（2・3 が片付くまで） |
| 2 | 満たさない | 段を入れていない。今入れると、`package.json` がなく `test/test_TC_033_no_oauth_webauthn_routes.test.ts` があるため、`check.sh` が必ず `exit 1` になる |
| 3 | 満たさない | `package.json` がない。作るのは YGO-062 の範囲（「直さないところ」）で、YGO-062 は `状態: open` |

- なぜ実装しないか:
  - 段を今入れると、それ以降のすべての変更で `check.sh` が失敗し、マージに進めなくなる（「依存」の節）。
  - YGO-062 が止まっている。ジョブの環境に node と npm がなく（`command not found: node`）、ロックファイルを作る段に進めない（YGO-062 の「残り」の節）。
  - この形を確かめるテスト（名前に TC-NNN を入れ、`test-results/` に JUnit XML を書くもの）は Vitest で動かす。Vitest は `package.json` と `node_modules/` がないと動かない。
- 片付く条件: YGO-062 が `状態: done` になる。それには、マスターが主版 26 の Node.js と npm をジョブの環境に入れる（OQ-086 の決定。新しい OQ は立てない）。または、YGO-062 を実装する変更にこの段を入れる。
- そのあとの手順:
  1. `check.sh` の 1 の段（Node.js とロックファイル）より前に段を足す。注記に `YGO-072` と reviews/0004 の `R-067` を書く。条件は「`find test -name '*.test.ts'` の結果が空でない」かつ「`package.json` がない」。そのとき「`package.json` がないため test/ のテストを動かせない」を標準エラーに出して `exit 1`。
  2. Vitest のテストを足す。名前に `YGO-072` と TC-NNN を入れ、その TC が `.ai/tests/test-plan.md` になければ同じ変更で足す `[assumed]`。テストは一時ディレクトリに `check.sh` と偽の `*.test.ts` を写して（`package.json` は置かない）動かし、終了コードが 0 でないことと出した文を確かめる。
  3. `.ai/environment.md` §4.1 の「1 と 6 は `package.json` があるときだけ動く」の文に、`test/` に `*.test.ts` があって `package.json` がないときは失敗する（YGO-072）ことを足す。
  4. `sh scripts/check.sh` が `check: ok` で終わり、`test-results/junit.xml` で 2 のテストが passed であることを確かめてから、`状態: done` にしてこの節を消す。
