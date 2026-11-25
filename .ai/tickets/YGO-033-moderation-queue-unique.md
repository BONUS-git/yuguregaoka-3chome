# YGO-033 K-007 R-013 審査キューの一意制約と持ち越しのラベル
状態: done
M: M1

## 目的
`triage.md` 仕分け 3（最新の回）の「今決める」K-007（出どころ R-013）を決める。
`moderation_queue` に一意制約がなく、J1 のやり直しで同じ投稿の行が重なりうる。持ち越した投稿は移し先の回で新しい行になり、LLM を呼び直して費用を二重に払う。前の回の行は `processed_at` が NULL のまま残り、J14 で消えない。
R-013 の直し方の案（`UNIQUE(content_kind, content_id, delivery_run_id)` を取り込む・持ち越しで前のラベルを継ぐ・未処理の行の保持の起点を決める）に沿って `[assumed]` で決める。R-013 のマスターの判断は「不要」で、新しい要回答は 0 件。

決めたこと（ADR-0095）:
- D1: `moderation_queue` に `UNIQUE(content_kind, content_id, delivery_run_id)`。J1 の挿入は ADR-0094 の D8 の `WHERE NOT EXISTS` のままで、制約は DB の側の守り。
- D2: 投稿を次の回に移すトランザクション（J2 の打ち切りの持ち越し・J6 の手順 3）で、前の回の未処理の行に `processed_at = now()` を書き、`policy_decision` は NULL のまま残す（持ち越した行の印）。モデレーターの人の審査は投稿の今の配達回の行に `policy_decision` と `processed_at` を書き、持ち越した行は変えない（今の回の行がなければ `llm_label` を写して入れる）。
- D3: 移し先の回の J1 は、同じ投稿の前の行のうちいちばん新しい行の `llm_label` だけを写す。判定・規則の ID・ルール表の版は写さず、J2 がその回のルール表で当て直す。
- D4: `created_at` を足し、J14 は `coalesce(processed_at, created_at) < now() - 1 year` の行を消す（1 年は ADR-0091 のまま）。
- D5: `GET /api/v1/admin/moderation-queue` は `awaiting_review` の投稿ごとに、いちばん新しい行（`created_at` が最大、閉じた行も含む）を 1 行だけ返す。移し先の回の J1 を待たずに一覧に出る。

ADR-0094（J1 の `WHERE NOT EXISTS`）と ADR-0091（1 年の保持）の決定は変えずに足すだけなので、どちらも置き換えない。

## K の選び方
仕分け 3 の「今決める」は K-003・K-005〜K-009・K-011〜K-013・K-016。K-003 は YGO-026、K-005 は YGO-031、K-006 は YGO-032 で済んでいる。仕分け 3 は K の順を指定していないので、残りで番号の若い K-007 を選んだ。
K-007 は M3・M4 の設計だが、マスターの指示（今決めるを 1 件決める）に従った。M1 の範囲（`roadmap.md` の `- M1:` の行）は変えない。

## 範囲
- `.ai/adr/0095-moderation-queue-unique-carry-label.md`（新規）: D1〜D5。
- `.ai/db.md`: §2 の `moderation_queue`（`llm_label`・`processed_at` の説明、`created_at`、UNIQUE）・§5 の保持の表の行・§7 の冪等性の表に「審査の重複防止」。
- `.ai/async.md`: §2 の J1 の行・§4 J1 の出力と冪等性・J2 の失敗とやり直し・J6 の手順 3・J14 の対象の表・§6「審査が間に合わない」・§7 のテスト「審査キューの一意と持ち越し」。
- `.ai/roadmap.md` A-04: ケースの数を 18 にし、名前を足す。
- `.ai/api.md`: `GET /api/v1/admin/moderation-queue` の行に D5 と ADR-0095。
- `.ai/gaps.md`: G-052 に K-007 と YGO-033、G-054（M4）を足す。
- `.ai/adr/README.md`・`.ai/INDEX.md`: ADR-0095 とこのチケット、ジョブの行に ADR-0095。

## 直さないところと理由
- `mvp.md`・`triage.md`・`status.md`: マスターの指示と CLAUDE.md で変えない。
- ADR-0094・ADR-0091: 決定を変えないので置き換えない。ADR-0094 の「一意制約は K-007（R-013）で決める」はその ADR を決めたときの記録で、変えない。YGO-032 の同じ記述も同じ。
- `open-questions.md`: 新しい要回答はなく、同じ論点の OQ もない。
- 図（`.ai/diagrams/`）: `moderation_queue` を載せた図はない（M1 の図は M1 の表だけ）。
- `scripts/check.sh`: 確かめるのは文書だけで、足さない。

## 受け入れ確認
1. `.ai/adr/0095-moderation-queue-unique-carry-label.md` の 3 行目が `- 状態: 採用` で、題が 40 字以内、D1〜D5 がある。
2. `db.md` §2 の `moderation_queue` に `created_at` の行と `UNIQUE(content_kind, content_id, delivery_run_id)` の文があり、`processed_at` と `llm_label` の説明に ADR-0095 の D2・D3 があり、`processed_at` の説明に、人の審査が今の配達回の行に書き持ち越した行を変えないことがある。§5 の「モデレーション審査」の行に `coalesce(processed_at, created_at)` があり、§7 の表に「審査の重複防止」の行がある。
3. `async.md` §4 J1 の冪等性に「UNIQUE 制約はまだない」の文と K-007 がなく、ADR-0095 の D1 がある。J1 の出力に D3（`llm_label` だけを写す）、J2 の失敗とやり直しと J6 の手順 3 に D2（`processed_at = now()`・`policy_decision` は NULL）、J2 の失敗とやり直しに人の審査が今の配達回の行に書くこと、J14 の `moderation_queue` の行に `coalesce(processed_at, created_at)`（D4）がある。§2 の J1 の行に ADR-0095 の D3 がある。
4. `async.md` §7 のテストの表の行が 18 で「審査キューの一意と持ち越し」があり、`roadmap.md` A-04 が「18 のケース」で 18 の名前を並べる。
5. `api.md` の `GET /api/v1/admin/moderation-queue` の行に、`awaiting_review` の投稿ごとにいちばん新しい行（`created_at` が最大、閉じた行も含む）を返すことと ADR-0095 がある。ADR-0095 の D2 に人の審査が書く行、D5 に同じ一覧の決め方がある。
6. `gaps.md` の G-052 に K-007 と YGO-033 があり、残る今決めるが K-008 から始まる。G-054 が向かう M `M4`・出どころ R-013（YGO-033、K-007）である。
7. `adr/README.md` と `INDEX.md` に ADR-0095 があり、`INDEX.md` にこのチケットと、ジョブの行の ADR-0095 がある。ADR-0094・ADR-0091・`mvp.md`・`triage.md`・`status.md` は変わっていない。
8. `sh scripts/check.sh` が `check: ok` で終わる。
