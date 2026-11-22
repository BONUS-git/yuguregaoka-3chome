# YGO-017 R-007 「他文書の変更提案（別チケット）」の節が 6 つ残り、そろえ直しが先送りされている
状態: done

## 目的
条件 2・3 を進めるため、`.ai/reviews/0001-design-review.md` の R-007 を直します。
`api.md` §10・`architecture.md` §9・`async.md` §9・`db.md` §10・`security.md` §9・`open-questions.md` §7 の 6 つの提案の節を消し、各項目を次の 3 つに分けて扱います。

| 分類 | 扱い |
|---|---|
| (A) すでに取り込み済み | 節から消すだけ |
| (B) ほかの指摘の範囲にない | 今回、対象の文書に取り込む |
| (C) ほかの指摘が設計を持つ | 取り込まずに消す。中身はその指摘の根拠と直し方の案にある。下の「直さないところ」に引き継ぎ先を書く |

決定は変えないので、ADR-0085 は作りません。ADR の中の「別チケット」と、消した節への参照の言い回しを直すだけです。
マスターの判断は要りません（レビューの「マスターの判断: 不要」のとおり）。`open-questions.md` に新しい問いは足しません。

## 範囲
- `.ai/api.md`: §10 の提案の節を消し、§11 を §10 にする。§4 のブロックの注記、§7「段階 2 以降」に画像のアップロードと J13（`image.process`）を同じトランザクションで積むこと、§9 の投函の取り消し API。
- `.ai/architecture.md`: §9 の提案の節を消す。§2 の C2 のブロック、§4 の 3（締め切りは `running` にする、配達回の行は API が作る）、§4 の 4 の後に組版の順。
- `.ai/async.md`: §9 の提案の節を消し、§10 を §9 にする。§3 の時刻表の後の ADR-0004 の扱い、§3 の工程の表の「準備」の行、J1 の `moderation_queue` の UNIQUE の注記、J4 の `prepared_at` の注記、J6 の「その他の扱い」に持ち越し先の追跡、§8 の差し戻しの行。
- `.ai/requirements.md`: FR-020・FR-024・FR-027・FR-048・FR-072・FR-075 の未確定の行き先を R-026 にする（値は R-026 で決める）。
- `.ai/features.md`: F-08 の行に、ブロック・通報・送信の上限の扱いが R-026・R-031 で決まることを書く。
- `.ai/db.md`: §10 の提案の節を消す。§2「通知」の冒頭と §4 の `sessions` の行の表の定義の参照、§4 の `delivery_runs` の作成の欄。
- `.ai/security.md`: §9 の提案の節を消し、§10 を §9 にする。§3.3 に `sessions` の項目、§3.5 に流量の制限の項目、§4.1 にロールの付与の記録の項目を移す（表の定義は R-025）。
- `.ai/open-questions.md`: §7 の提案の節を消す。OQ-029 の決定の参照、OQ-034 の担当文書、OQ-081 の決めていないこと、§6 の Q-002・Q-003 の行（消した §7 の項の番号を指していた）。
- ADR の言い回し（決定と状態の行は変えない）: `adr/0002`・`0007`・`0012`・`0013`・`0015`・`0016`・`0017`・`0018`・`0019`・`0020`・`0021`・`0065`。
- `.ai/retros.md`（新規）: R-007 の記録。

## 直さないところと理由
- (C) の項目と引き継ぎ先（R-008 以降は手を付けない、というマスターの指示による）:
  - `delivery_runs.prepared_at` → R-010
  - 宛先の振り分けの結果（`letter_recipients`）→ R-015
  - `moderation_queue` の UNIQUE → R-013
  - 差出人・投稿者・ブロックの時点の住所の文字列（`letters`・`board_posts`・`blocks`）→ R-029
  - `sessions`・`staff_roles`・`rate_limit_buckets` の表の定義 → R-025
  - FR-020・FR-024・FR-027・FR-048・FR-072・FR-075 と新しい FR（ブロック・通報・送信上限）→ R-026
  - F-08 の範囲（ブロック・通報・送信上限）→ R-026・R-031
  - OQ-030 → R-032
  - ADR-0001 の `users` → R-046
- (A) の項目: OQ-029 の決定、FR-006・FR-010、NFR-092、features.md の各項、`credentials`・`body_key_version`・`rule_version`、認証とセッションの経路、J7 の手順 0、郵便受けとバックナンバーは `done` の回だけ（api.md §1・§7 F-03・F-06）、worker が 2 台でも 1 回分（async.md §5）、`architecture.md` に `users` がないこと。ADR-0010 は async.md §5 に書いてあるので変えない。
- 約 30 の ADR の「影響」の欄にある節の番号（`api.md` §11・`async.md` §10・`security.md` §10 など）: 決めたときの記録なので変えない `[assumed]`。
- `open-questions.md` の見出しの「（未確定）」: R-036 の範囲。
- OQ-053（違法な物の取引）の「別のチケット」「別チケット」: マスターの答えの引用とマスターの指示なので変えない。
- `reviews/`、`status.md`（レポジトリにまだない。実装はまだなく、文書だけの変更）。コード・テスト・検証の手順・依存。

## 受け入れ確認
1. `grep -rn "変更提案" .ai --exclude-dir=reviews --exclude-dir=tickets` が何も出さない。
2. `grep -rn "別チケット" .ai --exclude-dir=reviews --exclude-dir=tickets` に出るのが、`open-questions.md` の OQ-043 のマスターの答え（:497）と OQ-053 の内容（:1326）、`adr/0036`（:17・:28・:72・:79）と `adr/0078`（:16・:72）の、マスターの答えの引用とマスターの指示の行だけ。
3. `api.md` の最後の節が `## §10 FR / NFR との対応表`、`async.md` が `## §9 FR / NFR との対応表`、`security.md` が `## §9 FR/NFR との対応表`。
4. `db.md` の最後の節が `## §9 OQ への依存（仮の扱い）`、`architecture.md` が `## §8 仮置きの一覧`、`open-questions.md` が `## §6 旧 ID との対応表`。
5. `db.md` §4 の `delivery_runs` の行に「API が `pending` で冪等に作る（api.md §2.3）」と J1・J6・「J5 の手順 1」がある。`architecture.md` §4 の 3 に「`running` にする」と「api.md §2.3」がある。
6. `architecture.md` C2 に「ブロックの登録の受け付け（手紙を送るときにはブロックを見ない」がある。§4 に「組版（J3）は審査（J2）が終わるか審査の打ち切り」がある。
7. `api.md` §7「段階 2 以降」に `image.process` と「同じトランザクション」がある。
8. `async.md` J6 に「持ち越し先の `run_id` は `delivery_runs` に持たない」がある。§3 の「準備」の行に `prepared_at` と R-010 がある。J1 の冪等性に R-013 がある。
9. `open-questions.md` の OQ-034 の担当文書が `api.md` §3、OQ-029 の決定に「（ADR-0012）」がある。§6 の表に「を参照」がない。
10. `security.md` §3.3 に `sessions` の項目の一覧と R-025、§3.5 に `window_start`、§4.1 に `granted_by` がある。`db.md` §2「通知」に「R-025」がある。
11. `adr/0007` の影響に「ADR-0011 に記録する」がある。`adr/0016` に「ADR-0004 を置き換える ADR に書く」がある。`adr/0017` に R-010、`adr/0065` に R-029、`adr/0013` の影響の OQ-030 の行に R-032 がある。変えた 12 の ADR とも、状態の行は変更の前と同じ。
12. `.ai/adr/` に `0085-*` がない。`open-questions.md` §2 の表の `| OQ-NNN |` の行が 90 で、変更の前と同じ。
13. `.ai/retros.md` に「R-007」の見出しと、問題・根本原因・気づけなかった理由・再発防止の 4 項がある。
14. `requirements.md` の FR-020・FR-024・FR-027・FR-048・FR-072・FR-075 の 6 行に「（open-questions へ）」がなく、6 行とも「`reviews/0001-design-review.md` の R-026 で決める」がある。
15. `features.md` §2 の F-08 の行に「R-026・R-031」がある。
16. `sh scripts/check.sh` が `check: ok` で終わる。
