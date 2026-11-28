# YGO-080 M1 の差し替えられる時計
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「時刻を外から差し替えられる時計」のうち、M1 の TC が使う部分を作る。YGO-074 で切った M0 の部品のチケットの 1 枚。
使う M1 の TC: TC-016（時計を進めて、期限切れの確認が済まない登録を消す）・TC-017（J14 を差し替えた時計で動かす）。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-103 のあとに並べる。依存の順: YGO-062 → YGO-075 と YGO-078（並んで進む）→ YGO-076 → YGO-103 → **YGO-080（このチケット）**。YGO-103 が `状態: done` であること。
- 部品どうしの順: YGO-080・YGO-082・YGO-086 → YGO-081・YGO-083・YGO-085 → YGO-084。このチケットは先頭の組で、ほかの部品のチケットを待たない。YGO-084 がこのチケットを待つ。

## 前提（変更 20261127-50bc9e の時点で満たされていない）
- YGO-078（`package.json`・`package-lock.json`・Vitest）が `状態: done` でない。develop（9301ab8）に `package.json`・`package-lock.json` がなく、`sh scripts/prepare.sh` は「package.json がないので入れる依存はない」で終わり、`sh scripts/check.sh` は Vitest の段を飛ばして `check: ok` になる。`test-results/` はできず、JUnit XML は書かれない。YGO-078 を止めているものは YGO-078 の「止まっている理由」の節と `gaps.md` の G-080・G-082 にある。
- YGO-103（`addresses`・`tenancies` の 2 表と TC-005）が `状態: done` でない。
- この 2 つがそろい、`sh scripts/prepare.sh` のあと `sh scripts/check.sh` が Vitest を動かして `test-results/junit.xml` を書くまで、このチケットは実装しない（時計のアダプタもテストも足さない）。

## 範囲
- 時計のアダプタ（`src/clock.ts` など）`[assumed]`: 今の時刻を返す 1 つの口を持ち、本物は実時間（JST に固定して扱う、`environment.md` §3.3）を返す。テストでは決まった時刻を返し、進められる時計に差し替えられる。
- web の経路と worker のジョブは、時計を引数で受け取る（モジュールの全体の状態にしない）`[assumed]`。
- 部品だけを確かめる TC は `.ai/tests/test-plan.md` にないため、このチケットはテストを足さない `[assumed]`（`check.sh` は名前に TC-NNN のない `testcase` で失敗する）。時計は、使う FR のチケット（YGO-092）の TC-016・TC-017 で確かめる。

## 直さないところと理由
- `CLOCK_OFFSET`（開発で時刻をずらす変数、`environment.md` §3.2・§8.1）: M1 の TC が使わないため入れない。使う TC のチケットを切るときに扱う。
- DB の側で時刻を比べるところ（`.ai/db.md` §2 と `.ai/async.md` §4 J14 の `now()`）を時計の値で比べるかどうかと、その文書の直し: このチケットでは決めない。TC-016・TC-017 を作る FR のチケット（YGO-092）が、その TC の時刻の扱いとあわせて決め、同じ変更で `db.md`・`async.md` を直す。このチケットが作るのは時計とその差し替え方だけ。
- J14 のハンドラの中身: YGO-092。
- 新しい OQ・要回答・ADR は 0 件。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-080 M1 の差し替えられる時計`・`状態: done`・`M: M1`。
2. YGO-062・YGO-078・YGO-103 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
4. 実時間を返す時計と、決まった時刻を返し進められる時計があり、経路とジョブが時計を引数で受け取る形になっている。
5. `CLOCK_OFFSET` を読むコードがない。
