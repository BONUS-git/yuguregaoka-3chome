# YGO-084 M1 の worker のジョブの実行
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「2 プロセス（web / worker）の骨組み」のうち、M1 の TC が使う「worker が `jobs` から J14・J18 を取ってハンドラを動かす部分」を作る。YGO-074 で切った M0 の部品のチケットの 1 枚。
使う M1 の TC: TC-017（J14）・TC-020（J18）。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-103 のあとに並べる。依存の順: YGO-062 → YGO-075 と YGO-078（並んで進む）→ YGO-076 → YGO-103 → **YGO-084（このチケット）**。YGO-103 が `状態: done` であること。
- 部品どうしの順: YGO-080・YGO-082・YGO-086 → YGO-081・YGO-083・YGO-085 → YGO-084。このチケットは YGO-080（差し替えられる時計）・YGO-081（`jobs` のキュー）・YGO-083（モックのメールのアダプタ）・YGO-085（KeyProvider の偽の鍵。J18 が `EMAIL_KEYRING` で復号する、`async.md` §4 J18）の `状態: done` を待つ。

## 範囲
- worker の入口（`src/worker.ts`、ADR-0100）`[assumed]`: 設定（YGO-082）を読み、キュー（YGO-081）からジョブを取り、名前ごとに登録したハンドラに、時計（YGO-080）・DB の接続・メールのアダプタ（YGO-083）・KeyProvider（YGO-085）を渡して動かす。
- J14 `retention.purge`・J18 `mail.send` の名前でハンドラを登録する口。このチケットでは中身のないハンドラを置かない（中身は FR のチケットが登録する）`[assumed]`。
- テストからは、ポートを開かずに、積んだジョブを 1 回取って動かし終わるまで待てる口（差し替えた時計で J14・J18 を動かす、`tests/test-plan.md` の種類「ジョブ」）`[assumed]`。
- 部品だけを確かめる TC は `.ai/tests/test-plan.md` にないため、このチケットはテストを足さない `[assumed]`。使う FR のチケット（YGO-092・YGO-097）の TC-017・TC-020 で確かめる。

## 直さないところと理由
- J14・J18 のハンドラの中身: YGO-092（J14）・YGO-096（J18）。
- web の入口（`src/server.ts`）と開発の起動のコマンド（`npm run dev:worker` など、`environment.md` §3.2）: M1 の TC が使わないため、使う TC のチケットを切るときに扱う。
- cron と M1 より後のジョブ（J0〜J8・J15〜J17）: 使う M のチケット。
- 新しい OQ・要回答・ADR は 0 件。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-084 M1 の worker のジョブの実行`・`状態: done`・`M: M1`。
2. YGO-062・YGO-078・YGO-103・YGO-080・YGO-081・YGO-083・YGO-085 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
4. worker がキューから取ったジョブを、名前で登録したハンドラに、時計・DB の接続・メールのアダプタ・KeyProvider を渡して動かす。
5. テストから、ポートを開かずに、積んだジョブを取って動かし終わるまで待てる。
