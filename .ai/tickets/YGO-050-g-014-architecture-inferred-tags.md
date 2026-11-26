# YGO-050 G-014 architecture.md の秘書の技術の判断の区分を [inferred] に直す
状態: done
M: M1

## 目的
条件 10 のために、`gaps.md` の G-014（暫定・M1、出どころ R-038）を閉じる。
R-038（`reviews/0001-design-review.md`、区別: 軽微、マスターの判断: 不要）は、`architecture.md` が秘書の技術の判断（2 プロセス・PostgreSQL・TypeScript など）に `[explicit]` を付けていることを挙げた。これらは構想にはなく、秘書が ADR で決めたことなので `[explicit]` は誤り。
同じ ADR の判断を原則として書く `async.md`・`db.md`・`api.md` の区分も、`architecture.md` と食い違わないよう同じ変更でそろえる。
`gaps.md` 冒頭の決まり（YGO-043）に従い、題に G-014 を 1 つ付けたこのチケットで 1 行を閉じる。

## 仕分け
- `triage.md` は K の順を指定していない。
- 直し方は R-038 の案のうち「[inferred] にする」を選ぶ。構想の「技術選定は秘書に任せる」「API・DB・バッチの責務を明確にする」「必要以上に複雑にしない」から読み取った判断で、ADR の番号は今の行にすでにあるため、区分を外すより `[inferred]` の方が CLAUDE.md の区分の決まりに合う。
- 決定の中身は変えないので、ADR を足したり置き換えたりしない。マスターに決めてもらうことはなく、新しい OQ・要回答は 0 件。

## 確かめた事実（直す前）
- `architecture.md` の `[explicit]` は 12 か所: §1 の 1（1 コードベース・2 プロセス）、§1 の 2（即時性を持ち込まない、P-1）、C2 の「配達はしない」、C4 のジョブの一覧、C7、§6 の言語・ランタイム・API・クライアント・DB・ジョブキュー・組版・ホスティングの「デプロイはしない」（NFR-071）。
- 構想（`brief.md`）にあるのは、技術選定を秘書に任せること・API・DB・バッチの責務の明確化・必要以上に複雑にしないこと・即時性の排除・デプロイしないこと・AI による非同期モデレーション・セキュリティの判断を LLM の自由裁量に依存させないこと。
- ほかの文書にも、秘書の ADR の判断に `[explicit]` を付けた箇所が 5 つある: `async.md` §1 の 1（非同期処理はすべて worker、ADR-0100）・2（PostgreSQL の上の pg-boss 相当、ADR-0010）、`db.md` §1 の 1（PostgreSQL が唯一の正本、ADR-0010）・2（主キーは UUID v4、ADR-0082）、`api.md` §1 の 3（同期で返すのは「受け付けた」まで、ADR-0004・ADR-0100）。
- `requirements.md` の `[explicit]`（NFR-051・NFR-055・NFR-071 など）は構想か CLAUDE.md の原文を出どころにしていて、秘書の ADR を出どころにしたものはない。`environment.md` §1 の 1・5 と `roadmap.md` の「デプロイはしない」は構想・CLAUDE.md にある。

## 範囲
- このチケット。
- `.ai/architecture.md`: §1 の 1・C2 の「配達はしない」・C4 のジョブの一覧・C7・§6 の 6 行（言語・ランタイム、API、クライアント、DB、ジョブキュー、組版）の `[explicit]` を `[inferred]` にする。ほかの文字は変えない。
- `.ai/async.md`: §1 の 1・2 の `[explicit]` を `[inferred]` にする。
- `.ai/db.md`: §1 の 1・2 の `[explicit]` を `[inferred]` にする。
- `.ai/api.md`: §1 の 3 の `[explicit]` を `[inferred]` にする。
- `.ai/gaps.md`: G-014 の行の理由と出どころの列だけ。
- `.ai/INDEX.md`: チケットの一覧に 1 行。

## 直さないところと理由
- `architecture.md` §1 の 2（P-1 の即時性）と §6 の「デプロイはしない」（NFR-071）: 構想にあるので `[explicit]` のまま。
- `async.md` §1 の 6（LLM は審査のラベルを返すだけ、ADR-0005）と 7（P-1）、`db.md` §1 の 4（P-1・P-2）、`api.md` §1 の 1・2（P-1・P-2）と 5（NFR-011）: 構想（AI による非同期モデレーション・LLM の自由裁量に依存させない・即時性と数値評価の排除）にあるので `[explicit]` のまま。
- `adr/`・`open-questions.md`: 決定の中身を変えないのでかからない。
- `status.md`・`mvp.md`・`triage.md`・`scripts/check.sh`: 秘書・仕分けのジョブが書く文書か、この変更でかからない。文書だけの変更で、テストは足さない。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-050 G-014 architecture.md の秘書の技術の判断の区分を [inferred] に直す`・`状態: done`・`M: M1`。題の G 番号は G-014 だけ。
2. `architecture.md` §1 の 1（1 コードベース・2 プロセス）・§2 の C2 の「配達はしない」・C4 のジョブの一覧・C7 の行・§6 の言語・ランタイム、API、クライアント、DB、ジョブキュー、組版の 6 行が `[inferred]` になっている。
3. `architecture.md` に残る `[explicit]` は 2 か所で、§1 の 2（即時性を持ち込まない、P-1）と §6 のホスティングの行の「デプロイはしない」（NFR-071）。
4. `async.md` §1 の 1（ADR-0100）・2（ADR-0010）、`db.md` §1 の 1（ADR-0010）・2（ADR-0082）、`api.md` §1 の 3（ADR-0004、ADR-0100）が `[inferred]` になっている。`async.md` に残る `[explicit]` は §1 の 6・7、`db.md` は §1 の 4、`api.md` は §1 の 1・2・5。
5. `gaps.md` の G-014 の行は 5 列で、向かう M は `M1`。理由の列に `YGO-050`・`async.md`・`db.md`・`api.md` と「残りはない」があり、出どころの列は `R-038（YGO-050）`。ほかの G の行には差分がない。
6. `INDEX.md` のチケットの一覧に `.ai/tickets/YGO-050-g-014-architecture-inferred-tags.md` がある。
7. `adr/`・`open-questions.md`・`status.md` に差分がない（新しい ADR・OQ・要回答は 0 件）。
8. `sh scripts/check.sh` が `check: ok` で終わり、check:consolidation の「今の M（M1）の範囲の点検」が 12 件に減って G-014 が出ない。
