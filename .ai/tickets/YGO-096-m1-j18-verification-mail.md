# YGO-096 M1 J18 確認のメールを送るジョブ
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。YGO-071 の範囲の 7 枚に足した部品のチケット。
TC-020 は「モックのメールのアダプタが受けたリンクのトークン」で確認を済ませるので、メールの確認の完了（YGO-097）の前に、J18 `mail.send` の `email_verification` のハンドラ（`.ai/async.md` §4 J18）が要る。前の部品を今の M のチケットとして切る決まりで、このチケットで切る。

## 依存
- 全体の順（`.ai/roadmap.md` §4「M1 の FR のチケット」）: 各チケットは、表の「前に要るチケット」に書いたチケットだけを待つ。
- 前に要るチケット（どれも `状態: done` になるのを待つ）:
  - YGO-062（テストの土台）
  - YGO-077（6 表のチケット。`auth_tokens`・`credentials`）
  - YGO-082（環境変数の読み込みと `MAIL_ADAPTER`）・YGO-083（モックのメールのアダプタ）・YGO-084（worker のジョブの実行）・YGO-085（KeyProvider の偽の鍵。復号）
  - YGO-094（範囲の 4。J18 を積む）
- 待つもの:
  - YGO-078（`package.json` とロックファイル）。YGO-078 は YGO-088（実装のジョブで `node`・`npm` を動かす権限）を待つ。
  - 秘書の CI の定義（`check.yml`）の `prepare.sh` の段（ADR-0109 の D2・G-079）。CI が緑になるのはそのあと。このチケットの `done` は、`sh scripts/check.sh` がネットワークなしで通ることで決める `[assumed]`。

## 範囲
- J18 の `kind = email_verification` のハンドラ: トークンとメールアドレスを復号し、リンクのメールを `MAIL_ADAPTER`（M1 はモック、ADR-0033）で 1 通送り、`mail_token_*` を NULL にする。登録から 24 時間を過ぎていれば送らない（ADR-0087）。
- 部品だけを確かめる TC は `.ai/tests/test-plan.md` にないため、このチケットはテストを足さない `[assumed]`（`check.sh` は名前に TC-NNN のない `testcase` で失敗する）。使う FR のチケット YGO-097 の TC-020 で確かめる。

## 直さないところ
- FR を持たない（部品）。ほかの `kind`（`password_reset`・`email_change`・`email_change_notice`・`registration_attempt_notice`）: それを積む経路の FR のチケット。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-096 M1 J18 確認のメールを送るジョブ`・`状態: done`・`M: M1`。
2. ハンドラが `async.md` §4 J18 のとおりに送った値の列を NULL にし、ペイロードにトークンとメールアドレスを入れない。
3. `sh scripts/check.sh` が通る。
