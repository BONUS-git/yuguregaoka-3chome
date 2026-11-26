# YGO-056 G-051 使用中のメールでの登録の応答を確かめて閉じる
状態: done
M: M1

## 目的
条件 10 のために、`gaps.md` の G-051（暫定・M1、出どころ YGO-027（ADR-0087 の D5）・YGO-052）を閉じる。
G-051 は、すでに使われている（`credentials.email_hmac` の UNIQUE に当たる）メールアドレスで登録したときの応答が決まっていないことを挙げた。中身は YGO-052（done、題は R-061）で ADR-0102 の D8 に決まり、文書も直っていて、足りないのは題に G-051 を持つチケットだけ。
`gaps.md` 冒頭の決まりに従い、題に G-051 を 1 つ付けたこのチケットで 1 行を閉じる。

## 仕分け
- `triage.md` の G-051 の行は「YGO-052 の題は R-061 なので、済んだあとに題に G-051 を持つチケットで閉じる」と順を指定している。YGO-052 は done なので、この順に従う。
- 決定の中身は変えないので、ADR を足したり置き換えたりしない。マスターに決めてもらうことはなく、新しい OQ・要回答は 0 件。

## 確かめた事実
- ADR-0102 の状態の行は `- 状態: 採用`。D8「使用中のメールアドレスでの登録」は、`email_hmac` が確認の済んだ住民か、確認が済まず登録から 24 時間を過ぎていない登録に当たるとき、行を作らず住所を押さえず、新しい登録と同じ 201 と同じ本文 `{"status": "accepted"}` を返し、J18 を `registration_attempt_notice`・`{kind, resident_id}` で積むと決めている。D8 は ADR-0080 の D4 を登録の経路に当てはめるもので、期限切れの登録は ADR-0087 の D5 で先に消すので当たらない。
- ADR-0080・ADR-0087 の状態の行は `- 状態: 採用`、ADR-0101 は `- 状態: 置き換え（→ 0102）`。
- `api.md` §2.4 の F-02 の流れに、使用中のメールアドレスなら行を作らず J18 を `registration_attempt_notice`・`{kind, resident_id}` で積む（ADR-0102 の D8）がある。§7 F-02 の `POST /api/v1/registrations` の行と、認証なしの経路の段落がこの場合を書き、ADR-0102 の D8 を指す。
- `async.md` §2 の J18 の行、§4 J18 のきっかけ（「使用中のメールアドレスでの登録」の行）・入力（`registration_attempt_notice` だけは `{kind, resident_id}`）・手順 4・冪等の項、§5 の J18 の行、§6 の J18 の行、§9 の FR-092 の行（使用中のメールアドレスでの登録の知らせ）がこの場合を含む。
- `security.md` §3.1 に「**使用中のメールアドレスでの登録**（ADR-0102 の D8）」の項がある。
- `db.md` §2 の `jobs`（ジョブキュー）の項の J18 のペイロードに `registration_attempt_notice` は `{kind, resident_id}` だけ、がある。
- `diagrams/m1-registration-sequence.md` に「メールアドレスが使用中（…ADR-0102 の D8）」の分岐と `opt kind が registration_attempt_notice` がある。
- `INDEX.md` の地図に「使用中のメールアドレスで登録したときの応答と知らせ」の行があり、ADR の一覧に `0102-auth-tables-mail-and-registered-email.md` がある。
- `api.md`・`async.md`・`security.md`・`diagrams/` に `G-051` の文字はない。

## 範囲
- このチケット。
- `.ai/gaps.md`: G-051 の行の理由と出どころの列だけ。理由の列の「残りはない」の前に YGO-056 で確かめたことを足し、出どころの列の `YGO-052` の後ろに `（YGO-056）` を足す `[assumed]`。
- `.ai/INDEX.md`: チケットの一覧に 1 行。

## 直さないところと理由
- `api.md`・`async.md`・`security.md`・`db.md`・`diagrams/`: この場合の設計はそろっていて、直すところがない。
- `adr/`・`open-questions.md`: 決定の中身を変えないのでかからない。
- `status.md`・`mvp.md`・`triage.md`・`scripts/check.sh`: 秘書・仕分けのジョブが書く文書か、この変更でかからない。文書だけの変更で、テストは足さない。
- G-065: 理由の列の「残りは G-050・G-051」は G-065 のチケットで扱う。G-068 も触れない（「1 つのことだけ」の指示）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-056 G-051 使用中のメールでの登録の応答を確かめて閉じる`・`状態: done`・`M: M1`。題の G 番号は G-051 だけ。
2. ADR-0102・ADR-0080・ADR-0087 の状態の行が `- 状態: 採用`、ADR-0101 が `- 状態: 置き換え（→ 0102）`。
3. ADR-0102 の D8 に、同じ 201、本文 `{"status": "accepted"}`、住所を押さえない、J18 の `registration_attempt_notice`・`{kind, resident_id}` が書かれている。
4. `api.md` §2.4 と §7 F-02 の `POST /api/v1/registrations` の行が ADR-0102 の D8 を指す。
5. `async.md` §2 の J18 の行と §4 J18 の入力に `registration_attempt_notice` と `{kind, resident_id}` がある。
6. `security.md` §3.1 に「使用中のメールアドレスでの登録」の項、`db.md` §2 の `jobs`（ジョブキュー）の項に `registration_attempt_notice` のペイロードがある。
7. `diagrams/m1-registration-sequence.md` に使用中のメールアドレスの分岐があり、`api.md`・`async.md`・`security.md`・`diagrams/` に `G-051` がない。
8. `gaps.md` の G-051 の行は 5 列で、向かう M は `M1`。理由の列に `YGO-056` と「残りはない」があり、出どころの列の終わりが `YGO-052（YGO-056）`。ほかの G の行に差分がない。
9. `INDEX.md` のチケットの一覧に `.ai/tickets/YGO-056-g-051-registered-email-201-confirmed.md` がある。
10. `adr/`・`open-questions.md`・`api.md`・`async.md`・`db.md`・`security.md`・`diagrams/`・`mvp.md`・`status.md`・`triage.md` に差分がない（新しい ADR・OQ・要回答は 0 件）。
11. `sh scripts/check.sh` が `check: ok` で終わり、check:consolidation の「今の M（M1）の範囲の点検」に G-051 が出ない。
