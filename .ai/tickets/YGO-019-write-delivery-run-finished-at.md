# YGO-019 R-009 配達回の `finished_at` を書くジョブがない
状態: done

## 目的
条件 2・3 を進めるため、`.ai/reviews/0001-design-review.md` の R-009（区別: 中、マスターの判断: 不要）を直します。
`delivery_runs.finished_at` は J14（`delivery_notifications` の保持の起点）と J15（新聞の通知の期限）が読みますが、書く手順がどのジョブ（J1・J5・J6）にもありません。
指摘の直し方の案のとおり、J5・J6 の手順 5 で `finished_at = now()` を書くと明記し、`skipped` の回の起点（持ち越した時刻）も決めます。
指摘の行番号は古いですが、中身は今の文書にも当てはまります。

決めることはどれも技術と設計の細部なので `[assumed]` で決めます。
- J5 の値は、同じトランザクションの手順 3 の `settled_at` と同じ（`now()` はトランザクションの始まりの時刻）。
- `pending`・`running`・`failed` の間は NULL で、CHECK `(status IN ('done', 'skipped')) = (finished_at IS NOT NULL)` で守る。

前の決定は変わりません（ADR-0076 の D2・D7、ADR-0085 の保持期間の表と「`skipped` の回があるので配達回の時刻では手紙の確定の時刻を決められない」はそのまま成り立ちます）。ADR-0086 は作らず、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/async.md`: §2 の表の J5・J6 の行。§3 の状態の遷移の下に、`started_at`・`finished_at` を書くジョブと NULL の状態の 1 段落。J1 の出力。J5 の出力・手順 5・冪等性。J6 の出力・手順 5・冪等性・失敗とやり直し。J14 の `delivery_notifications` の行。J15 の期限の行。§7 の「持ち越し」と「通知の重複と期限」（ケースの数は変えない）。
- `.ai/db.md`: §2 `delivery_runs` の `started_at`・`finished_at` の説明と CHECK。
- `.ai/roadmap.md`: A-15 の (4)・(5)。
- `.ai/retros.md`: R-009 の節。

## 直さないところと理由
- `delivery_runs.prepared_at`: R-010 の範囲。
- `failed` にする手順（誰が書くか）: R-011 の範囲。`failed` の回は `finished_at` が NULL のまま、とだけ書く。
- ほかの ADR: 決定は変わらないので変えない。
- `status.md`: レポジトリにまだない。実装はまだなく、文書だけの変更。
- テストのコード: 足さない。確かめる内容は `async.md` §7 と `roadmap.md` A-15 に書く。

## 受け入れ確認
1. `async.md` J5 の手順 5 に `finished_at = now()` と「`settled_at` と同じ値」があり、冪等性に `UPDATE delivery_runs SET status='done', finished_at=now() WHERE run_id=$1 AND status='running'` がある。
2. `async.md` J6 の手順 5 に `finished_at = now()` と「持ち越した時刻」があり、冪等性に `SET status='skipped', finished_at=now()` がある。失敗とやり直しに「`failed` の回は `finished_at` が NULL のまま」がある。
3. `async.md` J1 の出力に `started_at` があり、§2 の表の J5・J6 の行に `finished_at` がある。
4. `async.md` J14 の `delivery_notifications` の行に「J5 が `done` と同じ UPDATE で書いた公開の時刻」があり、J15 の期限の行に「J5 が書いた `delivery_runs.finished_at`」がある。§7 の「持ち越し」と「通知の重複と期限」の行に `finished_at` がある。
5. `db.md` §2 `delivery_runs` の `finished_at` の説明に J5・J6 と「`pending`・`running`・`failed` の間は NULL」があり、表の下に `CHECK ((status IN ('done', 'skipped')) = (finished_at IS NOT NULL))` がある。
6. `grep -n "finished_at" .ai/async.md` の結果に、書く箇所（J5・J6 の手順 5 と冪等性）と読む箇所（J14・J15）の両方が出る。
7. `roadmap.md` の A-15 の (5) に「J5 が `done` と同じ UPDATE で書いた `delivery_runs.finished_at`」があり、(4) に J6 で持ち越した回の `finished_at` がある。
8. `retros.md` に `## 2026-11-23 — 配達回の終わりの時刻を書くジョブがなかった（R-009）` の見出しと、問題・根本原因・気づけなかった理由・再発防止の 4 項がある。
9. `.ai/adr/` に `0086-*` がなく、`grep -c '^| OQ-[0-9]* |' .ai/open-questions.md` が 90 のまま。
10. `grep -rn "変更[提]案\|別[チ]ケット" .ai --exclude-dir=reviews --exclude-dir=tickets` の結果が変更の前と同じ（`open-questions.md` の :497・:1326、`adr/0036` の :17・:28・:72・:79、`adr/0078` の :16・:72）。
11. `.ai/reviews/` を変えていない。
12. `sh scripts/check.sh` が `check: ok` で終わる。
