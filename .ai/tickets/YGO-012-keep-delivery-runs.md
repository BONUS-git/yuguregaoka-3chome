# YGO-012 R-002 配達回（`delivery_runs`）を 30 日で消すと、届いた手紙と過去の新聞が消えるか、削除が失敗する
状態: done

## 目的
`.ai/reviews/0001-design-review.md` の R-002 の指摘を直します。配達回（`delivery_runs`）は 8 つの表（`letters`・`mailbox_items`・`delivery_notifications`・`newspapers`・`newspaper_articles`・`external_news_items`・`board_posts`・`moderation_queue`）から外部キーで指され、郵便受けとバックナンバーは `done` の回だけを返します。そのため 30 日で消すと、削除が失敗するか、古い手紙と紙面が返らなくなります。レビューの 1 つ目の案「配達回は消さない」を採り、ADR と文書をそろえます。マスターの判断は要らないので、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/adr/0075-account-deletion-and-retention-keep-delivery-runs.md`（新規）: ADR-0013 の生きている決定（退去のときの処理・長期不在のときの処理・保持期間・新聞の組み直し）を今の状態に書き直して移し、配達回を消さないこと（J14 も J7 も消さない・外部キーは CASCADE・SET NULL にしない・API の `done` の条件は変えない）を決める。
- `.ai/adr/0013-account-deletion-and-retention.md`: 状態を `置き換え（→ 0075）` にする。
- `.ai/adr/0076-delivery-notification-web-push-retention-30-days.md`（新規）: ADR-0025 の生きている決定（ADR-0035 が直した箇所を含む D1〜D9）を今の状態に書き直して移し、D7 の保持を「配達回の `finished_at` から 30 日で J14 が消す。配達回は消さない（ADR-0075）ので、消す順番の決まりは置かない」にする。
- `.ai/adr/0025-delivery-notification-web-push-with-count.md`: 状態を `置き換え（→ 0076）` にする（D7 の「J14 が `delivery_runs` より先に消す」と ADR-0013 の参照が、配達回を消さない決定と食い違うため）。
- `.ai/adr/README.md`: 0013 の行に「ADR-0075 で置き換え」、0025 の行に「ADR-0076 で置き換え」を付け、0075 と 0076 の行を足す。
- `ADR-0025` の参照を `ADR-0076` に付け替え、冒頭の関連 ADR・根拠の一覧を直す: `requirements.md`・`features.md`・`architecture.md`・`api.md`・`async.md`・`db.md`・`security.md`・`environment.md`・`roadmap.md`・`open-questions.md`・ADR-0075。
- `.ai/db.md` §9 の OQ-030 の行と `.ai/roadmap.md` の S2-3 の行: 保持期間を決めるときは「新しい ADR で決め、ADR-0075 を置き換える」と書く。
- `.ai/db.md` §10: OQ-030 を「決定」に更新するという 4 の提案を消す（OQ-030 は持ち越しのままで、ADR-0075 の数値は仮置きのため）。
- `.ai/db.md`: §2 `delivery_runs` の表の下に「行は消さない」と 8 つの外部キーを書く。§2 `delivery_notifications` と §4 の通知の記録の行から「`delivery_runs` より先に消す」を外す。§4 の配達回の行を「削除しない」にする。
- `.ai/async.md`: §4 J14 の対象の表から `delivery_runs` の行を外し、出力に「`delivery_runs` の行は消さない」を書く。§8 の「`delivery_runs` の保持期間」の行と、§9 の db.md への提案の 5 を消す。
- `.ai/roadmap.md`: A-13 に、31 日後の J14 のあとも配達回の行・郵便受けの手紙・紙面が残り、通知の記録が消えることを足す。冒頭の関連 ADR に 0075 を足す。§3 の表の MVP の行と §4 の「MVP で依存する ADR」に、ADR-0076 と並べて ADR-0075 を足し、範囲の「0001〜0023」「0001〜0021」を置き換え済みの ADR-0013 を除く「0001〜0012・0014〜0023」「0001〜0012・0014〜0021」に分ける。
- `ADR-0013` の参照を `ADR-0075` に付け替え、冒頭の関連 ADR の一覧を直す: `requirements.md`・`api.md`・`async.md`・`db.md`・`security.md`・`environment.md`・`roadmap.md`・`open-questions.md`。
- 直さないところと理由
  - ADR-0013・ADR-0025 を参照するほかの ADR（ADR-0075 を除く）: それぞれの決定の記録なので変えない。
  - OQ-030 の状態・紙面の保持期間の値・FR-097（R-007・R-026・R-032 の範囲）は変えない。`db.md` §10 は 4 の提案を消すだけ、`api.md` の別チケットの提案の節は番号の付け替えだけにする。
  - `features.md`・`architecture.md`: 配達回の保持を書いていないので、`ADR-0025` の番号の付け替えのほかは変えない。
  - レビューのファイル・ほかの指摘には手を付けない。

## 受け入れ確認
- `.ai/adr/0075-account-deletion-and-retention-keep-delivery-runs.md` があり、状態の行が `採用`、「配達回を消さないこと」の節に J14 と J7 が `delivery_runs` を消さないこと・外部キーを CASCADE にも SET NULL にもしないこと・`done` の条件を変えないことが書かれている。保持期間の表の `delivery_runs` の行が「消さない」である。
- `.ai/adr/0013-account-deletion-and-retention.md` の状態の行が `置き換え（→ 0075）` である。
- `.ai/adr/README.md` の一覧に 0075 の行があり、0013 の行に「ADR-0075 で置き換え」がある。
- `.ai/db.md` §2 `delivery_runs` の表の下に「行は消さない」があり、§4 の配達回の行に「30 日」がなく「削除しない」がある。
- `.ai/db.md` と `.ai/async.md` に「`delivery_runs` より先」がない。
- `.ai/async.md` §4 J14 の対象の表に `delivery_runs` の行がない。§8 に「`delivery_runs` の保持期間」の行がなく、§9 の db.md の提案が 4 つである。
- `.ai/roadmap.md` の A-13 に「31 日」と「`delivery_runs` の行は残り」と `delivery_notifications` が消えることが書かれている。
- `.ai/roadmap.md` §3 の表の MVP の行に「ADR-0001〜0012・ADR-0014〜0023」と `ADR-0075`・`ADR-0076` があり、§4 の「MVP で依存する ADR」に「0001〜0012・0014〜0021」と `0075`・`0076` がある。
- `requirements.md`・`api.md`・`async.md`・`db.md`・`security.md`・`environment.md`・`roadmap.md`・`open-questions.md` に `ADR-0013` がなく、`async.md`・`db.md`・`security.md`・`api.md`・`roadmap.md` の冒頭の関連 ADR と `environment.md` の冒頭の根拠に 0075 がある。
- `.ai/adr/0076-delivery-notification-web-push-retention-30-days.md` があり、状態の行が `採用`、D7 に「`finished_at` から 30 日」と「消す順番の決まりは置かない」がある。D1〜D9 があり、D6 に送り先の検査（`https` だけ・許可するホスト・プライベートなどの宛先の拒否・リダイレクトに従わない）が書かれている。
- `.ai/adr/0025-delivery-notification-web-push-with-count.md` の状態の行が `置き換え（→ 0076）` で、`.ai/adr/README.md` の 0025 の行に「ADR-0076 で置き換え」と 0076 の行がある。
- `requirements.md`・`features.md`・`architecture.md`・`api.md`・`async.md`・`db.md`・`security.md`・`environment.md`・`roadmap.md`・`open-questions.md`・ADR-0075 に `ADR-0025` がない。`api.md`・`async.md`・`db.md`・`security.md` の冒頭の関連 ADR、`environment.md` の冒頭の根拠、`roadmap.md` の冒頭の関連 ADR に 0076 がある。
- ADR-0075 の「配達回を消さないこと」の 4 が ADR-0076 の D7 を指し、「消す順番の決まりは置かない」と書かれている。
- `.ai/db.md` §9 の OQ-030 の行と `.ai/roadmap.md` の S2-3 に「新しい ADR で決め、ADR-0075 を置き換える」がある。`.ai/db.md` §10 に OQ-030 の項目がない。
- `.ai/open-questions.md` に新しい OQ がなく、OQ-030 は `持ち越し` のままである。
- `sh scripts/check.sh` が `check: ok` で終わる。
