# YGO-014 R-004 手紙を通報する人が受取人かを確かめていない
状態: done

## 目的
`.ai/reviews/0001-design-review.md` の R-004 の指摘を直します。`POST /api/v1/reports` には通報する人の条件がなく、手紙の ID を知っている住民なら誰でも手紙を通報できました。送った人は投函の応答で手紙の `{id}` を受け取るので、自分の `blocked`・`pending`・`held` の手紙を通報して、モデレーターに本文を復号させる経路ができていました。これは `blocked` を見る経路を作らないこと（ADR-0069 の D5）と、本文に触れる場面を限ること（NFR-005、`security.md` §2.3）に反します。
レビューの直し方の案に沿って、手紙を通報できるのを受取人だけにし、手紙は郵便受けの行の ID で指し、条件に合わなければ同じ 202 で何も保存しないことにします。
ADR-0036 の D2（通報された手紙の確かめ）に条件を足すことになるので、ADR-0036 の生きている決定（D1〜D7）と新しい決定（D8〜D10）をまとめた ADR-0078 を作り、ADR-0036 を置き換えます。
マスターの判断は要らない（レビューの「マスターの判断: 不要」。技術と設計の細部で `[assumed]`）ので、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/adr/0078-letter-reports-by-recipients-only.md`（新規、題「手紙の通報は受取人だけ、確かめは条件付きで 1 通」）: ADR-0036 の D1〜D7（方針・通報された手紙の確かめ・住民を守る制限を外せる設定にしない・止める内容・年齢・違法な物の取引・要求の区分）を今の状態に書き直して引き継ぎ、次を決める。
  - D8 手紙を通報できるのは受け取った住民だけ。郵便受けの行が本人のもの・`kind = 'letter'`・`visible_at <= now()`・`deleted_at IS NULL`・手紙が `delivered` のときだけ `reports` に行を作る。
  - D9 手紙の通報は `mailbox_item_id` で指し、`letter_id` は 400。`reports.content_id` には API が引いた `letters.id` を書き、郵便受けの行の ID は保存しない。掲示板の投稿は `board_post_id`。
  - D10 条件に合わないときは、受け付けたときと同じ 202 で何も保存しない（ADR-0014 の 404 の例外）。
- `.ai/adr/0036-reported-letters-viewable-by-moderators-protections-not-self-removable.md`: 状態を `置き換え（→ 0078）`。
- `.ai/adr/README.md`: 0036 の行に「ADR-0078 で置き換え」、0078 の行。
- `.ai/api.md`: 冒頭の関連 ADR、§2.2 の `reports` の行、§4 の 404 の例外、§7 F-08 の `POST /api/v1/reports` の行と「手紙の通報」の節と「通報された手紙の取得」、§9 の OQ-003 の項目。
- `.ai/security.md`: 冒頭の関連 ADR、§2.3 (c)、§4.2 の手紙の表と通報の表、§4.3、§5.4 の 1、§7 T-18。
- `.ai/db.md`: 冒頭の関連 ADR、§2 `reports` の `reporter_id`・`content_id`。
- `.ai/requirements.md` の NFR-005、`.ai/features.md` §5 の NFR-005 の行。
- `.ai/roadmap.md`: 冒頭の関連 ADR の 0078、A-09 の手紙の通報の確かめ。
- `.ai/architecture.md`・`.ai/open-questions.md`・`.ai/requirements.md`・`.ai/features.md`・`.ai/security.md`・`.ai/db.md`・`.ai/roadmap.md`・`.ai/api.md`: ADR-0036 の参照を ADR-0078 に（OQ の状態と本文の中身は変えない）。
- 直さないところと理由
  - ADR-0072・ADR-0026・ADR-0040・ADR-0069 などの中の ADR-0036 の参照: それぞれの決定の記録で、ADR-0078 は ADR-0036 の決定を同じ番号（D1〜D7）で引き継いでいるので変えない。
  - ADR-0077 の D4 と `db.md`・`async.md` の「通報された手紙は消さない」: `reports` の行がある手紙という一般の書き方で、ADR-0078 と食い違わないので変えない。
  - 通報の流量の制限（R-018）、ほかの指摘（R-005 以降）、各文書の「他の文書への変更提案（別チケット）」の節、FR / NFR の対応表には手を付けない。
  - `async.md`: 通報を作る処理と通報する人の条件を書いていないので変えない。

## 受け入れ確認
- `.ai/adr/0078-letter-reports-by-recipients-only.md` の題が「0078 — 手紙の通報は受取人だけ、確かめは条件付きで 1 通」、状態の行が `採用` で、冒頭に「ADR-0036 を丸ごと置き換える」とある。D1〜D7 があり、D2 に通報が `open`・当事者でない・二要素認証済み・1 通だけ・`view_letter`・`no-store`・404 がある。D8 に `mailbox_items.resident_id`・`kind = 'letter'`・`visible_at <= now()`・`deleted_at IS NULL`・`delivered` がある。D9 に `mailbox_item_id`、`letter_id` の 400、`content_id` に `letters.id` を書くこと、郵便受けの行の ID を保存しないことがある。D10 に「同じ 202」と「`reports` に行を作らない」がある。
- `.ai/adr/0036-reported-letters-viewable-by-moderators-protections-not-self-removable.md` の状態の行が `置き換え（→ 0078）`。`.ai/adr/README.md` の 0036 の行に「ADR-0078 で置き換え」があり、0078 の行がある。
- `.ai/api.md` §7 F-08 に「**手紙の通報**」の節があり、`mailbox_item_id`、`letter_id` は 400 `validation_failed`、`kind = 'letter'`・`visible_at`・`deleted_at IS NULL`・`delivered` の条件、条件に合わないときの「同じ 202」と「何も保存しない」が書かれている。`POST /api/v1/reports` の行に `mailbox_item_id` と `board_post_id` と ADR-0078 がある。§4 に手紙の通報が 404 の例外で 202 を返すことがある。§2.2 の `reports` の行に ADR-0078 の D8 がある。
- `.ai/security.md` §4.2 の手紙の表に「手紙を通報する」の行があり、送信者の欄が ✗、受取人の欄が ✓ で `delivered` の条件がある。§4.2 の通報の表に「掲示板の投稿を通報する」と「手紙を通報する」の行がある。§4.3 に手紙の通報の 202 の例外がある。§5.4 の 1 に `mailbox_item_id` と、送った人が自分の手紙を通報できないことがある。§2.3 (c) に、通報の行ができるのは受取人が通報した `delivered` の手紙だけとある。§7 T-18 に ADR-0078 の D8 がある。
- `.ai/db.md` §2 `reports` の `content_id` の行に `letters.id`・`mailbox_item_id`・`delivered`・「郵便受けの行の ID は保存しない」がある。`reporter_id` の行に「その手紙を受け取った住民」がある。
- `.ai/requirements.md` の NFR-005 に「手紙を通報できるのは受け取った住民だけ」と ADR-0078 の D2・D8 がある。`.ai/features.md` の NFR-005 の行に「送った人は自分の手紙を通報できない」がある。
- `.ai/roadmap.md` の A-09 に手紙の通報の確かめ（`letter_id` の 400、ほかの住民の行・`visible_at` の前・削除した行・新聞の行・存在しない ID の 202 で `reports` の行が増えないこと）がある。冒頭の関連 ADR に 0078 がある。
- `.ai/` の文書（`adr/`・`reviews/`・`tickets/` を除く）に `0036` の語がない。
- `.ai/open-questions.md` に新しい OQ がない。
- `sh scripts/check.sh` が `check: ok` で終わる。
