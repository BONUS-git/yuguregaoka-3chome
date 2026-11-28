# YGO-094 M1 FR-091 登録の受け付け
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。YGO-071 の範囲の 4（FR-091 の登録の受け付け）。
`POST /api/v1/registrations` が 201 `{"status":"accepted"}` を返し、同じトランザクションで `auth_tokens` の行を書いて J18 `mail.send` を積む（`api.md` §5・§7 F-02、ADR-0102 の D6・D7）。

## 依存
- 全体の順（`.ai/roadmap.md` §4「M1 の FR のチケット」）: 各チケットは、表の「前に要るチケット」に書いたチケットだけを待つ。
- 前に要るチケット（どれも `状態: done` になるのを待つ）:
  - YGO-062（テストの土台）
  - YGO-077（6 表のチケット。`auth_tokens`）
  - YGO-081（`jobs` のキューに積む口）・YGO-085（KeyProvider の偽の鍵。トークンの鍵付きのハッシュと暗号化）
  - YGO-091（範囲の 1）・YGO-090（範囲の 2）
  - YGO-093（流量の制限の部品。TC-019 の 429）
- 待つもの:
  - YGO-078（`package.json` とロックファイル）。YGO-078 は YGO-088（実装のジョブで `node`・`npm` を動かす権限）を待つ。
  - 秘書の CI の定義（`check.yml`）の `prepare.sh` の段（ADR-0109 の D2・G-079）。CI が緑になるのはそのあと。このチケットの `done` は、`sh scripts/check.sh` がネットワークなしで通ることで決める `[assumed]`。

## 範囲
- 201 の本文を `{"status":"accepted"}` にし、住所・ID・`Set-Cookie` を返さない。招待と紹介者の項目を受け取らない（ADR-0030）。
- 同じトランザクションで `auth_tokens` の行（`purpose` は確認、`token_hash` は鍵付きのハッシュ、`mail_token_*` は暗号化したトークン）を書き、J18 を `{kind: "email_verification", auth_token_id}` で積む。`email_verified_at` は NULL のまま。
- 登録の経路に YGO-093 の流量の制限をつなぐ。400・409・429 では行も J18 も作らない。
- TC-018・TC-019 のテスト。

## 直さないところ
- J18 のハンドラ（メールを送ること）: YGO-096。
- メールの確認の完了（TC-020）: ログインの経路を使うので YGO-097。このチケットの受け入れ確認に TC-020 は入れない。
- 使用中のメールアドレスでの登録（`registration_attempt_notice`、ADR-0102 の D8）の TC-027（FR-092）: `roadmap.md` §4 の行き先の表のとおり、YGO-095 が done になってから FR-092 の残りとして切る。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-094 M1 FR-091 登録の受け付け`・`状態: done`・`M: M1`。
2. TC-018・TC-019 のテストがあり、`sh scripts/check.sh` が通る（JUnit XML に `skipped` がない）。
3. どのテストもネットワークなしで動く。
