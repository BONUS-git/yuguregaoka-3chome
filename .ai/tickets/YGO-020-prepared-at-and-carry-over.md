# YGO-020 R-010 準備が終わらないとき、持ち越し（J6）が積まれない
状態: done

## 目的
条件 2・3 を進めるため、`.ai/reviews/0001-design-review.md` の R-010（区別: 中、マスターの判断: 不要）を直します。
`async.md` §3 の J0 の擬似コードで、「新聞の行があり準備が済んでいない → J4」が最後の「持ち越しの打ち切りを過ぎた → J6」より先に当たるので、J4 が失敗し続けると J6 に届きません。J5 の枝と休刊の J3 の枝も、打ち切りのあとに先に当たります。
また、準備の完了を判断する `delivery_runs.prepared_at` が `db.md` になく、J4 に書く手順もありません。
指摘の直し方の案のとおり、`prepared_at` を `db.md` に取り込んで J4 の最後で書き、J0 の `running` の枝の先頭で打ち切りを判断して J6 を積みます。
指摘の行番号は古いですが、中身は今の文書にも当てはまります。

決めることはどれも技術と設計の細部なので `[assumed]` で決めます。
- `prepared_at` は、J4 がすべての宛先を書き終えた最後のトランザクションで `now()` を書く。`pending` の間は NULL、`done` の回は NULL でない（CHECK 2 本）。J6 は書き換えない。
- J5 と J6 の手順 0 で配達回の行を `FOR UPDATE` でロックし、打ち切りのときに両方が動いても `done` の回の手紙を移さない。
- J4 の区切りごとのトランザクションは、はじめに配達回の行を `FOR SHARE` でロックし、`status <> 'running'` か `now() >= carry_over_cutoff` なら何も書かずに成功で終える。J6 の手順 0 の `FOR UPDATE` と直列になり、持ち越した回に J4 が行を足さない。

前の決定は変わりません（ADR-0016 の打ち切りのあとに J6、ADR-0017 の準備と公開の 2 段）。ADR-0086 は作らず、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/async.md`: §2 の表の J4 の行。§3 の工程の表の「準備」の行・J0 の箇条と擬似コード。J4 の出力（区切りごとの `FOR SHARE`）・冪等性・失敗とやり直し。J6 の手順 0 の注記。J5 の手順 0。J6 のきっかけと手順 0。§6 の「準備が間に合わない」「公開の失敗」の行。§7 の「持ち越し」の行（ケースの数は変えない）。
- `.ai/db.md`: §2 `delivery_runs` の `prepared_at` の行と CHECK 2 本。
- `.ai/adr/0017-delivery-prepare-then-publish.md`: 影響の `prepared_at` の行（状態は `採用` のまま）。
- `.ai/retros.md`: R-010 の節。

## 直さないところと理由
- 前の回の条件（`prev runs all done`）と、`failed` を書く手順: R-011 の範囲。
- `running` の回に残る `pending` の手紙: R-012 の範囲。
- NFR-028: R-026 の範囲。
- ほかの ADR: 決定は変わらないので変えない。
- `status.md`: レポジトリにまだない。実装はまだなく、文書だけの変更。
- テストのコード: 足さない。確かめる内容は `async.md` §7 に書く。

## 受け入れ確認
1. `async.md` §3 の J0 の擬似コードで、`running` の枝の最初の条件が `now >= carry_over_cutoff(run)` で J6 を積む。`grep -n "carry_over_cutoff" .ai/async.md` で擬似コードの中に出るのはその 1 か所だけ。
2. 擬似コードの J4 の枝の条件が `run.prepared_at is null`、J5 の枝の条件が `run.prepared_at is not null`。
3. `grep -n "R-010" .ai/async.md` が何も出さない。
4. `async.md` J4 の出力と冪等性に `UPDATE delivery_runs SET prepared_at = now() WHERE run_id=$1 AND status='running' AND prepared_at IS NULL` がある。J4 の出力と冪等性に、区切りごとのトランザクションで `delivery_runs` の行を `FOR SHARE` でロックし、`status <> 'running'` か `now() >= carry_over_cutoff` なら何も書かずに成功で終える手順がある。
5. `async.md` J5 と J6 に、`FOR UPDATE` の手順 0 とその条件（J5 は `status <> 'running'`・`prepared_at IS NULL`・`now() >= carry_over_cutoff`、J6 は `status <> 'running'`）がある。
6. `async.md` §6 と §7 に `prepared_at` があり、§7 のテストの表は「冪等性（2 回実行）」から「投稿の記事は見出しだけ（ADR-0054）」までの 16 行のままで、この変更で書き換えたのは「持ち越し」の行だけ（行は足しも消しもしない）。
7. `db.md` §2 `delivery_runs` に `prepared_at` の行と `CHECK (status <> 'pending' OR prepared_at IS NULL)`・`CHECK (status <> 'done' OR prepared_at IS NOT NULL)` がある。
8. `grep -rn "prepared_at" .ai --exclude-dir=reviews --exclude-dir=tickets` に、書く箇所（J4・db.md）と読む箇所（J0・J5）の両方が出る。
9. `adr/0017` の状態は `採用` のままで、影響の行に R-010 がない。`.ai/adr/` に `0086-*` がない。
10. `grep -c '^| OQ-[0-9]* |' .ai/open-questions.md` が 90 のまま。`grep -rn "変更[提]案\|別[チ]ケット" .ai --exclude-dir=reviews --exclude-dir=tickets` の結果が変更の前と同じ（`open-questions.md` の :497・:1326、`adr/0036` の :17・:28・:72・:79、`adr/0078` の :16・:72）。
11. `retros.md` に `## 2026-11-23 — 準備が終わらないと持ち越しに進まない分岐の順だった（R-010）` の見出しと、問題・根本原因・気づけなかった理由・再発防止の 4 項がある。`.ai/reviews/` を変えていない。
12. `sh scripts/check.sh` が `check: ok` で終わる。
