# YGO-065 M1 の住民と住所の DB のスキーマとマイグレーション
状態: done
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`.ai/db.md` §2「住民・住所」の表のマイグレーションと、それを `check.sh` で確かめる土台を作る単位だった。1 回の変更の大きさを超えるため、下のとおり分けた。

## 分割済み
YGO-073 で分割済み（`reviews/0004-phase-evaluation-2026-11-27.md` の R-068）。後継: YGO-075・YGO-076・YGO-077・YGO-103。
このチケットには範囲も受け入れ確認も残らない。依存の順の中でこのチケットがいた位置は YGO-103 が持つ。

範囲の項目ごとの移り先:
- ADR-0103 を置き換える ADR-0106・`.ai/` に残る `ADR-0103` の参照の直し・`.ai/INDEX.md` の ADR の行: YGO-075
- 使い捨ての PostgreSQL を `check.sh` から起こすこと: YGO-076
- PostgreSQL の主版 18 と道具があることの確かめ: YGO-076
- `migrations/*.sql` を当てるひな型の DB `yuguregaoka_template` と、`test/setup.ts` のファイルごとの DB: YGO-076
- `pg`/`@types/pg` の依存とロックファイル: YGO-076
- `scripts/` に残る `ADR-0103` の参照の直し: YGO-076
- `.ai/environment.md` §3.1・§4.1 の直し: YGO-076
- 残りの 6 表（`residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets`）とその CHECK・索引: YGO-077
- `tenancies.resident_id` の `residents` への外部キー: YGO-077
- `addresses`・`tenancies` のマイグレーション `migrations/0001_addresses_tenancies.sql`: YGO-103
- TC-005 のテスト `test/test_TC_005_address_tenancy_unique.test.ts`: YGO-103
- `.ai/db.md` §2 の「DDL は書かない」の直し: YGO-103

受け入れ確認の項目ごとの移り先（分割の直前の 1〜9）:
1. 見出し・状態・M の行: YGO-103 の受け入れ確認 1（見出しは YGO-103 のもの）
2. YGO-062・YGO-078・YGO-076 が done: YGO-103 の受け入れ確認 2
3. `check.sh` がネットワークなしで `check: ok`: YGO-103 の受け入れ確認 3
4. `junit.xml` の TC-005 が passed: YGO-103 の受け入れ確認 4
5. マイグレーションに 2 表の `CREATE TABLE` だけがある: YGO-103 の受け入れ確認 5
6. UNIQUE と `WHERE is_current` の部分一意の索引: YGO-103 の受け入れ確認 6
7. db.md §2 と食い違わない・`[assumed]` のコメント: YGO-103 の受け入れ確認 7（`tenancies.resident_id` の外部キーは YGO-077）
8. db.md §2 に「DDL は書かない」が残っていない: YGO-103 の受け入れ確認 8
9. TC-005 の `tenancies` の行の `resident_id` が NULL: YGO-103 の受け入れ確認 9

ADR-0106 の受け入れ確認は YGO-075、使い捨ての PostgreSQL と道具の受け入れ確認は YGO-076、残りの 6 表の受け入れ確認は YGO-077 にある。

`.ai/triage.md` の仕分け 15 と仕分け 14 の行（「YGO-065（open）に残る移り先のない 3 項目は、そのチケットの範囲にある」）は、前の回の仕分けの記録で、このジョブは書き換えない（仕分けのジョブが書く文書で、前の回は書き換えない決まり）。そのため、`.ai/` に YGO-065 を open の担い手として指す行が残るのはこの 2 行だけで、今の事実ではない。その 3 項目（2 表のマイグレーション・TC-005 のテスト・`.ai/db.md` §2 の「DDL は書かない」の直し）の今の担い手は YGO-103。
