# YGO-095 M1 FR-092 ログイン
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。YGO-071 の範囲の 5（FR-092 のログイン `POST /api/v1/sessions`）。
ログインの失敗（アドレスがない・パスワードが違う・確認が済んでいない）をどれも同じ本文の 401 にし、通れば `sessions` の行を作る（`api.md` §5、ADR-0080・ADR-0090）。

## 依存
- 全体の順（`.ai/roadmap.md` §4「M1 の FR のチケット」）: 各チケットは、表の「前に要るチケット」に書いたチケットだけを待つ。
- 前に要るチケット（どれも `状態: done` になるのを待つ）:
  - YGO-062（テストの土台）
  - YGO-077（6 表のチケット。`residents`・`credentials`・`sessions`）
  - YGO-085（KeyProvider の偽の鍵。メールアドレスの HMAC で引く）
  - YGO-094（範囲の 4。登録の受け付け）
- 待つもの:
  - YGO-078（`package.json` とロックファイル）。YGO-078 は YGO-088（実装のジョブで `node`・`npm` を動かす権限）を待つ。
  - 秘書の CI の定義（`check.yml`）の `prepare.sh` の段（ADR-0109 の D2・G-079）。CI が緑になるのはそのあと。このチケットの `done` は、`sh scripts/check.sh` がネットワークなしで通ることで決める `[assumed]`。

## 範囲
- `POST /api/v1/sessions`（`email`・`password`）。失敗はどれも 401（`unauthenticated`）で同じ本文。通れば `sessions` の行と Cookie。
- TC-023 のテスト。確認が済んだ住民は、テストの中で `email_verified_at` を DB に直接書いて作る `[assumed]`（確認の経路は YGO-097）。

## 直さないところ
- 二要素認証（`totp_code`・`second_factor_required`）・ログインの 429・ログアウト・セッションの一覧・再設定: このチケットの後に、その FR のチケットとして切る。
- FR-092 の残りの TC（TC-021・TC-022 のパスワードの検査とハッシュ、TC-024〜TC-032 の送り直し・再設定・メールアドレスとパスワードの変更・流量の制限・J14 と J18 の確かめ）: このチケットが done になってから、FR-092 の残りとして切る。
- セッションの TC（FR-098 の TC-036〜TC-039、FR-100 の TC-040・TC-041）: このチケットが done になってから、その FR のチケットとして切る。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-095 M1 FR-092 ログイン`・`状態: done`・`M: M1`。
2. TC-023 のテストがあり、`sh scripts/check.sh` が通る（JUnit XML に `skipped` がない）。
3. どのテストもネットワークなしで動く。
