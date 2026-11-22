# YGO-013 R-003 差し戻しと抑止の手紙は、暗号化した本文が消えない
状態: done

## 目的
`.ai/reviews/0001-design-review.md` の R-003 の指摘を直します。`returned`・`suppressed` の手紙は郵便受けに入らないので、「受取人全員が郵便受けから削除したとき」に消すという `db.md` §4 の条件が起きず、暗号化した本文と宛先が無期限に残ります。届いた手紙も、受取人全員が消したことを見て消すジョブがありません。
レビューの直し方の案に沿って J14 に条件を足し、あわせて次の 2 つを決めます。送った人から見た手紙の消え方を状態でそろえ、ブロックを明かさないこと（T-06）。送った人の退去で届いていない手紙をすぐに消すこと（NFR-002）。
退去の表と保持期間の表（ADR-0075）が変わるので、ADR-0075 の生きている決定と新しい決定をまとめた ADR-0077 を作り、ADR-0075 を置き換えます。
マスターの判断は要らない（技術と設計の細部で、数値は `[assumed]`）ので、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/adr/0077-letters-purged-after-settling-or-recipient-deletion.md`（新規、題「退去処理と保持期間（確定した手紙も消す）」）: ADR-0075 の決定（退去の表・長期不在・保持期間の表・配達回を消さない・新聞の組み直し）を引き継ぎ、次を決める。
  - 退去の表: 退去した住民が送った届いていない手紙（`pending`・`scheduled`・`held`・`blocked`・`returned`・`suppressed`）は J7 が即時に消す。退去した住民が受け取った郵便受けの行（`mailbox_items`）も、`residents` を消す前に J7 が即時に消す（外部キーは CASCADE にしない）。
  - 保持期間の表: 手紙の `blocked`・`returned`・`suppressed`・`delivered`・通報された手紙の行。
  - 手紙の保持 D1〜D6: D1 `letters.settled_at`（書くのは J5 の手順 3 だけ。J4 は書かず、J6 が持ち越す回の `returned`・`suppressed` の手紙は `scheduled` に戻して次の便に移す）。D2 `returned`・`suppressed` は `settled_at`、`blocked` は `decided_at` から 30 日。D3 `delivered` は `settled_at` から 30 日を過ぎ、`deleted_at IS NULL` の郵便受けの行がなくなったあとの次の J14（宛先と郵便受けの行も同じトランザクション）。D4 `reports` の行がある手紙は消さない。D5 送信済みの一覧と詳細は、状態にかかわらず確定から 30 日まで返す。D6 `erasure_log` に記録しない。
- `.ai/adr/0075-account-deletion-and-retention-keep-delivery-runs.md`: 状態を `置き換え（→ 0077）`。
- `.ai/adr/README.md`: 0075 の行に「ADR-0077 で置き換え」、0077 の行。
- `.ai/db.md`: 冒頭の関連 ADR、§2 `letters` の `settled_at`、§4 の手紙（本体）・宛先・郵便受けの行と手紙の状態遷移図、§5 の 2（退去で届いていない手紙を消す）、§9 の OQ-030 の行、ADR-0075 の参照を ADR-0077 に。
- `.ai/async.md`: 冒頭の関連 ADR、§1 の J14 の行、J4 の宛先の振り分け、J5 の手順 3、J6 の手順 2、J7 の手順 1 と手順 8（受け取った郵便受けの行の削除）、J14 の出力と対象の表、ADR-0075 の参照を ADR-0077 に。
- `.ai/api.md`: 冒頭の関連 ADR、§2.2 の `letters` と `mailbox_items` の行、§7 F-04 の「送信済みに出す期間」、ADR-0075 の参照を ADR-0077 に。
- `.ai/security.md`: 冒頭の関連 ADR、§2.1 の手紙の本文の行、§2.4、§7 T-06、ADR-0075 の参照を ADR-0077 に。
- `.ai/roadmap.md`: 冒頭の関連 ADR（0075 と 0077 の説明）、§3 の MVP の行、§4 の「MVP で依存する ADR」、M6 の行、A-13、S2-3 の行。
- `.ai/environment.md`・`.ai/requirements.md`・`.ai/open-questions.md`: ADR-0075 の参照を ADR-0077 に（OQ の状態と本文の中身は変えない）。
- 直さないところと理由
  - ADR-0013・ADR-0076・ADR-0073・ADR-0048 の中の ADR-0075 や「受取人全員が削除すれば `letters` の行が消え」の記述: それぞれの決定の記録で、ADR-0077 と食い違わないので変えない。
  - OQ-030 の状態（持ち越し）と本文: 30 日は答えまでの仮の値で、答えで変わる箇所は ADR-0077 と `db.md` §9 に書いた。
  - 手紙の通報を受取人に限ること（R-004）、ほかの指摘（R-014・R-015・R-024 以降）、各文書の「他の文書への変更提案（別チケット）」の節、FR / NFR の対応表（FR-097 を含む）には手を付けない。
  - `features.md`・`architecture.md`: 手紙の保持の条件と送信済みの期間を書いていないので変えない。

## 受け入れ確認
- `.ai/adr/0077-letters-purged-after-settling-or-recipient-deletion.md` の題が「0077 — 退去処理と保持期間（確定した手紙も消す）」、状態の行が `採用` で、冒頭に「ADR-0075 を丸ごと置き換える」とある。退去の表の手紙の行に `pending / scheduled / held / blocked / returned / suppressed` を「即時に本文と宛先ごと消す」とある。保持期間の表に `returned / suppressed` と `delivered` と通報された手紙の行がある。退去の表に「その住民が受け取った郵便受けの行（`mailbox_items`」の行があり「即時に消す」とある。D1 に `settled_at`、「書くのは J5 の手順 3 だけ」、J4 は書かないこと、J6 が `returned`・`suppressed` の手紙を `scheduled` に戻して移すことがある。D2 に「30 日」、D3 に「`settled_at` から 30 日を過ぎ」と `deleted_at IS NULL` と、J7 が退去した受取人の郵便受けの行を消すことがある。D4 に `reports`、D5 に「状態にかかわらず確定の時刻」と T-06、D6 に `erasure_log` がある。「配達回を消さないこと」と「新聞の組み直し」の節がある。
- `.ai/adr/0075-account-deletion-and-retention-keep-delivery-runs.md` の状態の行が `置き換え（→ 0077）`。`.ai/adr/README.md` の 0075 の行に「ADR-0077 で置き換え」があり、0077 の行がある。
- `.ai/db.md` §2 `letters` の `settled_at` の行に「書くのは J5 の手順 3 だけ」と J6 の持ち越しがあり、J7 がない。§2 `mailbox_items` の `resident_id` の行に「CASCADE なし」と J7 が消すことがある。§4 の郵便受けの行の「消す」の欄に、受取人のアカウント削除で J7 が即時に削除するとある。状態遷移図に `suppressed --> scheduled` と `returned --> scheduled`（J6）がある。§5 に「受け取った郵便受けの行」がある。§4 の手紙（本体）の行に「`settled_at` から 30 日」「受取人全員」「ADR-0077」「送信済みに出す期間」がある。状態遷移図に `pending --> [*]`・`scheduled --> [*]`・`delivered --> [*]`・`suppressed --> [*]`・`returned --> [*]` があり、`pending --> returned` がない。§5 の 2 に、届いていない手紙（`returned`・`suppressed` を含む）を即時に削除するとある。§9 の OQ-030 の行に「ADR-0077 を置き換える」がある。
- `.ai/async.md` J7 の手順 1 に、送った届いていない手紙を `returned` にせず削除することと `scheduled` の郵便受けの行の削除がある。J14 の対象の表に `state IN ('returned', 'suppressed')` の行と、`settled_at < now() - interval '30 days'` を含む `state = 'delivered'` の行がある。J4 の宛先の振り分けに「J4 は `settled_at` を書かない」、J5 の手順 3 に「`settled_at` を書くのはこの手順だけ」、J6 の手順 2 に `returned`・`suppressed` の手紙を `scheduled` に戻して移すことがある。J7 の手順 8 に `mailbox_items` の削除、手順 9 に `residents` の物理削除がある。
- `.ai/api.md` §7 F-04 に「送信済みに出す期間」があり、確定の時刻から 30 日まで返し、そのあとは一覧に出さず `/sent/{id}` が 404 になることが書かれている。§2.2 の `letters` の行に J7 の削除と ADR-0077 がある。
- `.ai/security.md` §7 T-06 に「状態にかかわらず確定の時刻」と ADR-0077 の D5 があり、「弱い手がかり」の語がない。§2.1 の手紙の本文の行に ADR-0077 と送った人の退去の扱いがある。
- `.ai/roadmap.md` の A-13 に「手紙の保持（ADR-0077 の D2〜D5）」の (i)〜(iv) があり、(i) は 29 日と 31 日の送信済みの確かめと、J6 で持ち越した回の `suppressed`・`delivered` の `settled_at` が同じ値であること。(iii) に受取人の 1 人が退去したときの確かめがある。§3 の MVP の行・§4 の「MVP で依存する ADR」・M6 の行に 0077 があり 0075 がない。
- `.ai/` の文書（`adr/`・`reviews/`・`tickets/` を除く）に `ADR-0075` の語がない。
- `.ai/open-questions.md` に新しい OQ がなく、OQ-030 は `持ち越し` のままである。
- `sh scripts/check.sh` が `check: ok` で終わる。
