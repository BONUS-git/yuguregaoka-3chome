# YGO-039 R-025 G-067 TOTP の秘密を収集する項目にそろえる
状態: done
M: M1

## 目的
条件 8 のために、レビューの指摘 R-025（中。セッション・役割・二要素認証・流量の制限の保存先が定義されておらず、TOTP の秘密が `security.md` §2.1（集めるもの）にも §6.1（秘密の一覧）にもない）を片づける。表の定義という中心の点は YGO-027（ADR-0089、`db.md` §2）ですでに済んでいる。残っている食い違いは、`security.md` §2.1 の収集する項目の表に TOTP の秘密の行がないことだけなので、そこを `db.md` §2 の `credentials` の TOTP の列にそろえる。

## 仕分け
- `triage.md` の最新の回（仕分け 4）に、R-025 を扱う K-NNN はない（今決める K は K-017 だけで、K の順の指定もない）。R-025 を扱っているのは `gaps.md` の G-067（暫定・M1）で、題に G-067 を付けた。
- M の判定: `roadmap.md` の `- M1:` の行に FR-092・FR-098・FR-100 があり、M1 の範囲の行に `sessions`・`staff_roles`・`credentials` の TOTP の列・`rate_limit_buckets`（ADR-0089）があるので、M1 にかかわる。

## 確かめた済みの箇所
- `db.md` §2: `credentials` の TOTP の 4 列（`totp_secret_encrypted`・`totp_key_version`・`totp_enabled_at`・`totp_last_step`）と CHECK、`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets` の表がある。`push_subscriptions.session_id` は `FK→sessions`。`staff_roles` を「実装で決める」とする文はない。
- `security.md` §3.3（セッション）・§4.1（ロール）・§6.1 の「メールアドレスの暗号化鍵」の行（TOTP の秘密も AAD に用途を入れて暗号化する、ADR-0089 の D3）。
- `async.md` の `keys.reencrypt`（TOTP の秘密を再暗号化する）・J7 の最初の手順（`credentials` の行を TOTP の秘密ごと消す）・J14（期限切れの `sessions`）・`erasure.replay`。`diagrams/m1-er.md` の `credentials` の TOTP の列。

## 範囲
- `.ai/security.md` §2.1 の表: 「パスワード（ハッシュ）」の行の直後に「TOTP の秘密」の行を足す（目的・暗号化の形・平文を持たないこと・保持期間）。
- `.ai/gaps.md` の G-067: 残りがないことに書き直し、出どころを `R-025（YGO-027・YGO-039）` にする。
- `.ai/INDEX.md`: 「認証の表」の行に `.ai/security.md` §2.1 を足し、このチケットを足す。

## 直さないところと理由
- ADR-0019・0020・0079・0080・0081・0085 の「R-025 で決める」の文と状態の行: YGO-027 で変えないと決めているため。
- `security.md` §2.1 の `auth_tokens` の行: R-025 の直し方の案（TOTP の秘密を §2.1・§6.1 に足す）に入っていないため。
- `security.md` §6.1・`db.md` §2: すでに R-025 の直し方の案のとおりで、差分はない。
- ADR: 決定を変えないので足さず、状態も変えない。新しい要回答は 0 件。
- `open-questions.md`・`triage.md`・`reviews/`・`mvp.md`・`roadmap.md`・`status.md`: 変えない。
- テスト: 文書だけの変更で足さない。

## 受け入れ確認
- `.ai/security.md` §2.1 の表に「TOTP の秘密」の行があり、AES-256-GCM で暗号化し鍵はメールアドレスと同じ鍵輪で AAD に用途 `totp` を入れること（ADR-0089 の D3）、平文は DB・ログに持たないこと、退去で J7 の最初の手順が `credentials` の行ごと消すこと（ADR-0091 の D8）が書かれている。
- `.ai/security.md` §6.1 の「メールアドレスの暗号化鍵」の行に、TOTP の秘密（`credentials.totp_secret_encrypted`）の暗号化が書かれている（差分はない）。
- `.ai/db.md` §2 に `sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets` の見出しと `credentials` の TOTP の 4 列があり、`push_subscriptions.session_id` が `FK→sessions` で、「実装で決める」の文がない（差分はない）。
- `.ai/gaps.md` の G-067 の行が 5 列で、理由に「残りはない」、出どころに `R-025（YGO-027・YGO-039）` がある。
- `.ai/INDEX.md` の「認証の表」の行に `.ai/security.md` §2.1 があり、チケットの一覧に `.ai/tickets/YGO-039-totp-secret-collected-items.md` がある。
- `.ai/adr/`・`.ai/open-questions.md`・`.ai/triage.md`・`.ai/reviews/` に差分がない。
- `sh scripts/check.sh` が `check: ok` を出す。
