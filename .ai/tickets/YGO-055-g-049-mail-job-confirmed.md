# YGO-055 G-049 確認と再設定のメールのジョブ J18 を確かめて閉じる
状態: done
M: M1

## 目的
条件 10 のために、`gaps.md` の G-049（暫定・M1、出どころ 図 `diagrams/m1-components.md`・`diagrams/m1-registration-sequence.md`）を閉じる。
G-049 は、確認と再設定のメールを送る worker のジョブが `async.md` にないことを挙げた。中身は YGO-051（done、題は R-060）で直っていて、足りないのは題に G-049 を持つチケットだけ。
`gaps.md` 冒頭の決まり（YGO-043）に従い、題に G-049 を 1 つ付けたこのチケットで 1 行を閉じる。

## 仕分け
- `triage.md` は K の順を指定していない。
- 決定の中身は変えないので、ADR を足したり置き換えたりしない（ADR-0103 は作らない）。マスターに決めてもらうことはなく、新しい OQ・要回答は 0 件。
- G-049 の理由の列が、置き換わった ADR-0101 と前のペイロード（`{kind, auth_token_id}` だけ）を指していた。今の決定（ADR-0102 の D7・D8）を指す参照の直しで、決定は変えない。

## 確かめた事実
- `async.md` §2 に J18 `mail.send` の行があり、きっかけの列に「同じトランザクション」と「ADR-0102 の D7・D8」がある。ペイロードの列は `{kind, auth_token_id}` か `{kind, resident_id}`（`kind = registration_attempt_notice`）。
- `async.md` §4 に「J18 — 確認と再設定のメール（`mail.send`）（M1 から）」の節があり、期限は `auth_tokens.expires_at` だけで決まり、J18 の遅れ・再試行・送り直しで延びない（確認は登録から 24 時間、ADR-0087 の D2）。
- `async.md` §5 に J18 の再試行の行、§6 に「確認と再設定のメールを送れなかった（J18）」の行、§9 の FR-092 の行に「§4 J18」がある。
- `db.md` §2 の `auth_tokens` に `mail_token_encrypted`・`mail_token_key_version`・`old_email_encrypted`・`old_email_key_version` の列があり、ADR-0102 の D7 を指す。
- `api.md` §2.4 のバッチの行と §7 F-02 が J18 を指し、§7 の `POST /api/v1/email-verifications`・`POST /api/v1/email-verification-requests`・`POST /api/v1/password-reset-requests`・`PUT /api/v1/me/email` の行に J18 `mail.send` がある。
- `environment.md` §8.1 の `MAIL_ADAPTER` の行は「J18 `mail.send` が使う」で、使うのは worker だけ。
- M1 の図（`diagrams/m1-components.md`・`diagrams/m1-registration-sequence.md`・`diagrams/m1-er.md`）に J18 があり、「未設計」と `G-049` はない。
- ADR-0033・0080・0087・0090・0102 の状態の行は `- 状態: 採用`、ADR-0101 は `- 状態: 置き換え（→ 0102）`。

## 範囲
- このチケット。
- `.ai/gaps.md`: G-049 の行の理由と出どころの列だけ。理由の列の参照を ADR-0102 の D7・D8 に直し、出どころの列に 2 つめのチケットを `・` でつなぐ（`（YGO-051・YGO-055）`、YGO-054 と同じ書き方）`[assumed]`。
- `.ai/INDEX.md`: チケットの一覧に 1 行。

## 直さないところと理由
- `async.md`・`db.md`・`api.md`・`environment.md`・`security.md`・`diagrams/`: J18 の設計はそろっていて、直すところがない。
- `adr/`・`open-questions.md`: 決定の中身を変えないのでかからない。
- `status.md`・`mvp.md`・`triage.md`・`scripts/check.sh`: 秘書・仕分けのジョブが書く文書か、この変更でかからない。文書だけの変更で、テストは足さない。
- G-051・G-065・G-068: 「1 つのことだけ」の指示に従い、それぞれのチケットに回す。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-055 G-049 確認と再設定のメールのジョブ J18 を確かめて閉じる`・`状態: done`・`M: M1`。題の G 番号は G-049 だけで、R 番号はない。
2. `async.md` §2 に `| J18 | \`mail.send\` |` の行があり、きっかけの列に「同じトランザクション」と「ADR-0102 の D7・D8」がある。
3. `async.md` §4 に J18 の節があり、期限が J18 の遅れ・再試行・送り直しで延びない（確認は登録から 24 時間、ADR-0087 の D2）と書かれている。
4. `async.md` §5 に `| J18 \`mail.send\` |` の行、§6 に「確認と再設定のメールを送れなかった（J18）」の行があり、§9 の `| FR-092 |` の行が「§4 J18」を指す。
5. `db.md` §2 の `auth_tokens` に `mail_token_encrypted`・`mail_token_key_version`・`old_email_encrypted`・`old_email_key_version` の 4 列があり、ADR-0102 の D7 を指す。
6. `api.md` §7 F-02 と §7 の 4 つのエンドポイントの行（`email-verifications`・`email-verification-requests`・`password-reset-requests`・`me/email`）が J18 を指す。`environment.md` §8.1 の `MAIL_ADAPTER` の行の使う側が worker だけ。
7. `diagrams/m1-components.md`・`diagrams/m1-registration-sequence.md`・`diagrams/m1-er.md` に J18 があり、`diagrams/` に「未設計」と `G-049` がない。
8. ADR-0033・0080・0087・0090・0102 の状態の行が `- 状態: 採用`、ADR-0101 が `- 状態: 置き換え（→ 0102）`。
9. `gaps.md` の G-049 の行は 5 列で、向かう M は `M1`。理由の列に `ADR-0101` がなく、`ADR-0102 の D7`、`registration_attempt_notice` と `{kind, resident_id}`、`YGO-055`、「残りはない」がある。出どころの列の終わりが `（YGO-051・YGO-055）`。ほかの G の行に差分がない。
10. `INDEX.md` のチケットの一覧に `.ai/tickets/YGO-055-g-049-mail-job-confirmed.md` がある。
11. `adr/`・`open-questions.md`・`async.md`・`db.md`・`api.md`・`environment.md`・`security.md`・`diagrams/`・`mvp.md`・`status.md`・`triage.md` に差分がない（新しい ADR・OQ・要回答は 0 件）。
12. `sh scripts/check.sh` が `check: ok` で終わり、check:consolidation の「今の M（M1）の範囲の点検」に G-049 が出ない。
