# YGO-031 K-005 R-011 failed の配達回で後の回が止まる
状態: done
M: M3

## 目的
`triage.md` 仕分け 3（最新の回）の「今決める」K-005（出どころ R-011）を決める。
配達回の `failed` を誰がいつ書くかが決まっておらず、後の回の公開の条件が `async.md` の中で「前の回が `done` か `skipped`」と「前の回がすべて `done`」に分かれていた。どちらでも `failed` の回が 1 つあると後の定時配達が止まる。
R-011 の直し方の案に沿って `[assumed]` で決め、ADR-0016 を丸ごと置き換える ADR-0092 に書く。R-011 はマスターの判断を「不要」としており、新しい要回答は 0 件。

決めたこと（ADR-0092）:
- D5: `failed` を書くのは J0 だけ。J6 の再試行が尽きた（pg-boss の `delivery.carry_over:<run_id>` が `failed`）とき、`running` の枝の先頭で、別のトランザクションで書き、`alert=delivery_run_failed` をログに書く。J6 を積み直さない。
- D6: 後の回の J5 は、古い回がすべて `done`・`skipped`・`failed` のどれかになるまで積まない。
- D7: `failed` の回の中身は動かさず、`finished_at` は NULL。郵便受けには何も出ず、送った人には「投函済み」のまま。運用者が直す手順は暫定で `gaps.md` G-053（M3）。

D7 で `failed` の回に残る `mailbox_items` を年齢の見せる条件に数えないために、年齢の条件の正本（ADR-0073 の D4 (a)）を変える。前の決定の一部を変えるので、ADR-0073 の決定（D1〜D8）を同じ番号で引き継ぎ、D4 (a) に「行の配達回（`delivery_run_id`）が `done`」を足した ADR-0093 で ADR-0073 を丸ごと置き換える（`[assumed]`）。

## K の選び方
仕分け 3 の「今決める」は K-003・K-005〜K-009・K-011〜K-013・K-016。K-003（地図）は YGO-026 で `INDEX.md` と図を作ってあり決め済み。仕分け 3 は K の順を指定していないので、残りで番号の若い K-005 を選んだ。
R-048（`reviews/0002`）は M2〜M4 の今決めるが M1 を止めないようにと指摘している。K-005 は M3 の設計だが、マスターの指示（今決めるを 1 件決める）に従った。M1 の範囲（`roadmap.md` の `- M1:` の行）は変えない。

## 範囲
- `.ai/adr/0092-delivery-runs-tick-and-failed-runs.md`（新規）: ADR-0016 の決定を D1〜D4 に移し、D5〜D7 を足す。
- `.ai/adr/0016-delivery-run-pipeline-and-tick.md`: 状態の行だけ `置き換え（→ 0092）` にする。
- `.ai/adr/README.md`: 0016 に置き換えを書き、0092 を足す。
- `.ai/async.md`: 関連 ADR・§2 の J0 の行・§3 の見出しと `failed` の意味・状態遷移図・J0 の 3 と 5・擬似コード・J5 のきっかけ・J6 の失敗とやり直し・§6 の持ち越しの失敗の行・§7 の監視の行・持ち越しのテストの行。
- `.ai/db.md` §2 の `delivery_runs.status`。
- `.ai/api.md` §7 F-01 の年齢の見せる条件 (a)・F-03 の `GET /mailbox/items/{id}`: 行の配達回が `done` であることを条件にし、J4 が準備し終えた `failed` の回の手紙で送り手の年齢が見えないようにする（ADR-0093 の D4 (a)・ADR-0092 の D7）。
- `.ai/adr/0093-age-birthday-immutable-shown-for-done-runs.md`（新規）: ADR-0073 の D1〜D8 を同じ番号で移し、D4 (a) に配達回が `done` の条件を足す。
- `.ai/adr/0073-age-and-birthday-required-immutable.md`: 状態の行だけ `置き換え（→ 0093）` にする。
- `.ai/security.md` §4.2 の権限表の年齢の行・`.ai/db.md` §9 の OQ-064 の決定の欄: 見せる条件に、行の配達回が `done`（`failed` の回の行は数えない、ADR-0092 の D7）を足す。
- ADR-0073 の参照の付け替え（ADR-0093 へ。D の番号は同じ）: `api.md`・`architecture.md`・`async.md`・`db.md`・`features.md`・`mvp.md`・`open-questions.md`・`requirements.md`・`roadmap.md`・`security.md`・`INDEX.md`・`diagrams/m1-*.md` の ADR の行・採用の ADR（0027・0041・0057・0069・0074・0078）・`adr/README.md`（0041 の注記・0073 の置き換え・0093 の行）。
- `.ai/roadmap.md`: 上の付け替えと、F-03 の行・MVP で依存する ADR の 0016・0073 を 0092・0093 にする（M1 の範囲の行は変えない）。
- `.ai/mvp.md`・`.ai/brief-map.md`: 参照の ADR-0016 を ADR-0092 にする（`mvp.md` の状態の行と M の範囲は変えない）。
- `.ai/gaps.md`: G-053（M3）を足し、G-052 に K-005 が済んだことを書く。
- `.ai/INDEX.md`: ADR-0092・ADR-0093 とこのチケットを載せ、ジョブの行に ADR-0092 を足す。

## 直さないところと理由
- `status.md`: 秘書が書く（変更禁止）。
- `triage.md`: 仕分けの記録で、仕分けのジョブが扱う。
- `open-questions.md`: 新しい要回答はなく、同じ論点の OQ もない。OQ-042 の影響の欄の ADR-0016 は決定のときの記録。
- `roadmap.md` の M1 の範囲の行とテストのケースの数: M1 の範囲は変わらない。テストは `async.md` §7 の持ち越しの行に足したので、ケースの数は変わらない。
- ほかの ADR（0035・0086 など）の ADR-0016 の参照、置き換え済みの ADR（0036・0048）とチケットの ADR-0073 の参照: その ADR やチケットを決めたときの記録で、変えない。
- `scripts/check.sh`: 確かめるのは文書だけで、足さない。

## 受け入れ確認
1. ADR-0092 の 3 行目が `- 状態: 採用` で、D1〜D7 がある。D5 に `failed` を書くのは J0 だけ・別のトランザクション・`alert=delivery_run_failed`、D6 に `done`・`skipped`・`failed`、D7 に `finished_at` が NULL と G-053 がある。
2. ADR-0016 の 3 行目が `- 状態: 置き換え（→ 0092）` で、ほかの行は変わっていない。
3. `adr/README.md` の 0016 の行に `ADR-0092 で置き換え` があり、0092 の行がある。
4. `async.md` に `ADR-0016` が 0 件。§3 の J0 の 3・擬似コード（`prev runs all settled`）・J5 のきっかけが `done`・`skipped`・`failed` の条件で、「`done` または `skipped`」だけの条件と `prev runs all done` がない。
5. `async.md` の状態遷移図の `running --> failed` が J0 で、J0 の 5 と擬似コードの `running` の枝の先頭に、J6 が尽きたら `failed` を書く処理がある。J6 の失敗とやり直しに「J6 は `failed` を書かない」と G-053 がある。
6. `async.md` §6 に持ち越しの失敗の行、§7 の監視に `alert=delivery_run_failed` の行、テストの持ち越しの行に `failed` の確かめがある。
7. `db.md` §2 の `delivery_runs.status` の行に、`failed` を書くのは J0 だけとある。
8. `mvp.md`・`brief-map.md` に `ADR-0016` が 0 件で、`ADR-0092` がある。`mvp.md` の状態の行と M の表の FR は変わっていない。
9. `api.md` §7 F-01 の年齢の見せる条件の見出しが ADR-0093 の D4 を引き、(a) に「行の配達回（`delivery_run_id`）が `done`」と ADR-0092 の D7 があり、F-03 の `GET /mailbox/items/{id}` に「配達回が `done` でない項目」は 404 とある。ADR-0092 の D7・`async.md` J6 の失敗とやり直し・§6 の持ち越しの失敗の行に、準備済みの `mailbox_items` も配達回が `done` でないので見せず年齢の条件に数えないことがある。
10. ADR-0093 の 3 行目が `- 状態: 採用` で、D1〜D8 があり、D4 (a) に「行の配達回（`delivery_run_id`）が `done`」と「`failed` の回など `done` でない回の行は数えない」がある。ADR-0073 の 3 行目が `- 状態: 置き換え（→ 0093）` で、ほかの行は変わっていない。`adr/README.md` の 0073 の行に `ADR-0093 で置き換え` があり、0093 の行がある。
11. `security.md` §4.2 の権限表の「年齢を見る」の行に「配達回が `done`」と「`failed` の回の行は数えない、ADR-0092 の D7」がある。`db.md` §9 の OQ-064 の決定の欄の `mailbox_items` の条件に「行の配達回（`delivery_runs.status`）が `done`」と「`failed` の回の行は数えない」がある。
12. `api.md`・`architecture.md`・`async.md`・`db.md`・`features.md`・`mvp.md`・`open-questions.md`・`requirements.md`・`roadmap.md`・`security.md`・`INDEX.md`・`diagrams/`・採用の ADR（0027・0041・0057・0069・0074・0078）に `ADR-0073` が 0 件。`mvp.md` の状態の行は変わっていない。
13. `gaps.md` に G-053（向かう M は M3、出どころ R-011）があり、G-052 に K-005 と YGO-031 がある。`INDEX.md` に ADR-0092・ADR-0093 とこのチケットがあり、どのファイルもある。`sh scripts/check.sh` が `check: ok` で終わる。
