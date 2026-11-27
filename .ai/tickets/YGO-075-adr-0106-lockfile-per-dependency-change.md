# YGO-075 ADR-0106 依存を足す変更ごとにロックファイルを直す
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
ADR-0103 の D1 のネットワークの例外（`npm install --package-lock-only --ignore-scripts`）は「最初のロックファイル」だけで、YGO-076 が `pg`・`@types/pg` を足す変更の根拠にならない。
依存を足す・変える変更ごとに、その変更の中でロックファイルを直す決定を ADR-0106 にし、ADR-0103 を置き換える。
YGO-073 で YGO-065 から分けた 1 枚目（ADR の置き換え）。範囲は ADR の置き換えとその参照の直しだけで、道具の追加と機能の実装は入れない。

番号は ADR-0106 とする。ADR-0105 は CI の定義の確かめの置き場所（`.ai/adr/0105-ci-definition-check-in-ygo-070.md`、`採用`）で使っている。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）が `状態: done` であること（YGO-073 の依存の節: 分けたチケットの実装は YGO-062 の done を待つ。受け入れ確認 6 の TC-033 の testcase は、YGO-078 で `package.json` とロックファイルが入り、`check.sh` の Vitest の段が動いてはじめてできる）。
- 依存の順: YGO-078（`package.json` とロックファイル）→ **YGO-075（このチケット）** → YGO-076（使い捨ての PostgreSQL）→ YGO-065（`addresses`・`tenancies`）→ YGO-077（残りの 6 表）。YGO-073 の分割先のチケットの中ではこのチケットが最初で、前に待つのは YGO-078 だけ。

## 範囲
- `.ai/adr/0106-<短い英語の名前>.md` を作る（題は 40 字まで、3 行目は `- 状態: 採用`）。ADR-0103 の D1〜D3 を丸ごと書き直す（一部だけ変えない。CLAUDE.md の ADR の決まり）:
  - D1 依存を足す・変える変更ごとに、その変更の中で `package.json` を書いたあと `npm install --package-lock-only --ignore-scripts` を 1 回試し、できた `package-lock.json` を同じ変更に入れる。ネットワークの例外はこの 1 つのコマンドだけで、`sh scripts/check.sh` はネットワークなしのまま（NFR-063）。
  - D2 作れなかったら止まった段を残す（ADR-0103 の D2 と同じ中身）。
  - D3 `prepare.sh` はロックファイルを作らない（ADR-0103 の D3 と同じ中身）。
- ADR-0103 の 3 行目を `- 状態: 置き換え（→ 0106）` にする。
- `.ai/adr/README.md` の ADR の一覧に ADR-0106 の行を足す。
- `.ai/INDEX.md`: ADR-0106 の行（末尾 `— 採用`）を足し、ADR-0103 の行の末尾を `— 置き換え（→ 0106）` にする。「環境・秘密・費用」の行のロックファイルの ADR を ADR-0106 にする。
- 今の状態を書く文書と `scripts/` に残る今の決定としての `ADR-0103` の参照を `ADR-0106` に直す（`.ai/environment.md` §3.1・§3.2 の 1・§4.1 の 1・§5・§5.1 の表、`scripts/check.sh` と `scripts/prepare.sh` のコメントと出力の文など）。チケット（`tickets/`）、経緯を書く `retros.md`・`triage.md`・`reviews/`、ADR-0103・ADR-0104・ADR-0105 の本文は直さない。

## 直さないところと理由
- `pg`・`@types/pg` の追加とロックファイルの直し: YGO-076（道具の追加）。
- `scripts/check.sh` の動き: コメントと出力の文の ADR の番号だけを直し、確かめの段は変えない。
- 新しい OQ・要回答は 0 件（ロックファイルの直し方は技術の決定で、ADR に書く）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-075 ADR-0106 依存を足す変更ごとにロックファイルを直す`・`状態: done`・`M: M1`。
2. `.ai/adr/0106-*.md` があり 3 行目が `- 状態: 採用`、D1 に「依存を足す・変える変更ごと」にロックファイルを直すことが書かれている。
3. `.ai/adr/0103-first-lockfile-in-dependency-change.md` の 3 行目が `- 状態: 置き換え（→ 0106）`。
4. `.ai/INDEX.md` の ADR-0103 と ADR-0106 の行の末尾が、それぞれの 3 行目の状態と同じ（`sh scripts/check.sh` の地図の確認が通る）。
5. `.ai/`（`tickets/`・`retros.md`・`triage.md`・`reviews/`・ADR-0103〜0105 の本文を除く）と `scripts/` に、今の決定として `ADR-0103` を指す記述が残っていない。
6. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed（`skipped`・`failure`・`error` の要素がない）のまま。
