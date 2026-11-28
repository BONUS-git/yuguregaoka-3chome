# YGO-075 ADR-0106 依存を足す変更ごとにロックファイルを直す
状態: done
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
ADR-0103 の D1 のネットワークの例外（`npm install --package-lock-only --ignore-scripts`）は「最初のロックファイル」だけで、YGO-076 が `pg`・`@types/pg` を足す変更の根拠にならない。
依存を足す・変える変更ごとに、その変更の中でロックファイルを直す決定を ADR-0106 にし、ADR-0103 を置き換える。
YGO-073 で YGO-065 から分けた 1 枚目（ADR の置き換え）。範囲は ADR の置き換えとその参照の直しだけで、道具の追加と機能の実装は入れない。

番号は ADR-0106 とする。ADR-0105 は CI の定義の確かめの置き場所（`.ai/adr/0105-ci-definition-check-in-ygo-070.md`、`採用`）で使っている。

## 依存
- YGO-062（M1 のテストの土台）が `状態: done` であること（YGO-073 の依存の節: 分けたチケットの実装は YGO-062 の done を待つ）。
- 依存の順: **YGO-075（このチケット）** と YGO-078（`package.json` とロックファイル）→ YGO-076（使い捨ての PostgreSQL）→ YGO-103（`addresses`・`tenancies`）→ YGO-077（残りの 6 表）。YGO-073 の分割先のチケットの中ではこのチケットが最初。
- このチケットは YGO-078 の done を待たない。範囲が `.ai/` の文書だけで、TC-033 の testcase の確かめは YGO-078 の受け入れ確認 3 が受け持つ（下の「範囲の外にしたこと」）。

## 範囲
- `.ai/adr/0106-<短い英語の名前>.md` を作る（題は 40 字まで、3 行目は `- 状態: 採用`）。ADR-0103 の D1〜D3 を丸ごと書き直す（一部だけ変えない。CLAUDE.md の ADR の決まり）:
  - D1 依存を足す・変える変更ごとに、その変更の中で `package.json` を書いたあと `npm install --package-lock-only --ignore-scripts` を 1 回試し、できた `package-lock.json` を同じ変更に入れる。ネットワークの例外はこの 1 つのコマンドだけで、`sh scripts/check.sh` はネットワークなしのまま（NFR-063）。
  - D2 作れなかったら止まった段を残す（ADR-0103 の D2 と同じ中身）。
  - D3 `prepare.sh` はロックファイルを作らない（ADR-0103 の D3 と同じ中身）。
- ADR-0103 の 3 行目を `- 状態: 置き換え（→ 0106）` にする。
- `.ai/adr/README.md` の ADR の一覧に ADR-0106 の行を足す。
- `.ai/INDEX.md`: ADR-0106 の行（末尾 `— 採用`）を足し、ADR-0103 の行の末尾を `— 置き換え（→ 0106）` にする。「環境・秘密・費用」の行のロックファイルの ADR を ADR-0106 にする。
- 今の状態を書く `.ai/` の文書に残る今の決定としての `ADR-0103` の参照を `ADR-0106` に直す（`.ai/environment.md` の関連 ADR・§3.1・§3.2 の 1・§4.1 の 1・§5。§5.1 の表には `ADR-0103` の参照がない）。`scripts/` には触れない（`scripts/` のコメントと出力の文の `ADR-0103` は YGO-076 の範囲と受け入れ確認 11 で直す。下の「範囲の外にしたこと」）。チケット（`tickets/`）、経緯を書く `retros.md`・`triage.md`・`reviews/`、ADR-0103・ADR-0104・ADR-0105 の本文は直さない。

## 直さないところと理由
- `pg`・`@types/pg` の追加とロックファイルの直し: YGO-076（道具の追加）。
- `scripts/check.sh`・`scripts/prepare.sh`: この変更では触れない。コメントと出力の文の `ADR-0103` は YGO-076 で `ADR-0106` に直す。
- 新しい OQ・要回答は 0 件（ロックファイルの直し方は技術の決定で、ADR に書く）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-075 ADR-0106 依存を足す変更ごとにロックファイルを直す`・`状態: done`・`M: M1`。
2. `.ai/adr/0106-*.md` があり 3 行目が `- 状態: 採用`、D1 に「依存を足す・変える変更ごと」にロックファイルを直すことが書かれている。
3. `.ai/adr/0103-first-lockfile-in-dependency-change.md` の 3 行目が `- 状態: 置き換え（→ 0106）`。
4. `.ai/INDEX.md` の ADR-0103 と ADR-0106 の行の末尾が、それぞれの 3 行目の状態と同じ（`sh scripts/check.sh` の地図の確認が通る）。
5. `.ai/`（`tickets/`・`retros.md`・`triage.md`・`reviews/`・ADR-0103〜0105 の本文を除く）に、今の決定として `ADR-0103` を指す記述が残っていない。
6. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、この変更で `scripts/`・`package*.json`・`src/`・`test/`・`.github/` を変えていない。

## 範囲の外にしたこと
この変更の範囲は、マスターの指示で `.ai/` の文書だけ（コード・`scripts/`・`package.json`・ロックファイル・`.github/` には触れない）。そのため次の 2 つをこのチケットから外し、受け入れ確認 5・6 をこの形にした。

- **`scripts/` の `ADR-0103`**: `scripts/check.sh` と `scripts/prepare.sh` のコメントと出力の文に `ADR-0103` が残る。この変更で、`check.sh` を次に触る YGO-076 の範囲と受け入れ確認 11 に移した。受け入れ確認 5 は `.ai/` だけを見る。YGO-076 はこのチケットの done を待つが、このチケットは `scripts/` の直しを待たないので、待ち合いは起きない。
- **TC-033 の testcase**: `package.json` がなく、`check.sh` の Vitest の段が動かないため、`test-results/junit.xml` ができない。YGO-078 の受け入れ確認 3 が確かめる。

## 確かめた事実
- YGO-078 は `状態: open` で、レポジトリに `package.json`・`package-lock.json` がない。
- この変更の範囲は、マスターの指示で `.ai/` の文書だけ（コード・`scripts/`・`package.json`・ロックファイル・`.github/` には触れない）。
- 受け入れ確認 2・3 を満たした（ADR-0106 の 3 行目は `- 状態: 採用`、D1 は「依存を足す・変える変更ごと」。ADR-0103 の 3 行目は `- 状態: 置き換え（→ 0106）`）。
- 受け入れ確認 4: この変更のあと `sh scripts/check.sh` を動かし、`check: ok` で終わった（地図の確認が通る）。`package.json` がないので Vitest の段は動かず、`test-results/junit.xml` はできない。
- `.ai/`（受け入れ確認 5 の除外を除く）で今の決定として `ADR-0103` を指す記述はない。`.ai/adr/README.md` と `.ai/INDEX.md` の置き換えの記録は残る。開いている YGO-078 の `ADR-0103` の参照は `ADR-0106` に直した。
- 受け入れ確認 6: `sh scripts/check.sh` が終了コード 0・`check: ok` で終わった（`sh scripts/prepare.sh` はジョブの環境で動かせず、秘書が検証の前に動かす）。`git diff --stat` に `scripts/`・`package*.json`・`src/`・`test/`・`.github/` が出ない。
- 受け入れ確認 1: 1〜3 行目が見出し・`状態: done`・`M: M1`。
- 新しい OQ・要回答は 0 件。ADR-0106 の題は 20 字。
