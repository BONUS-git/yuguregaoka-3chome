# YGO-077 M1 の住民と認証の 6 表のマイグレーション
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`.ai/db.md` §2「住民・住所」の 8 表のうち、YGO-065 の `addresses`・`tenancies` を除く 6 表 `residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets` のマイグレーションを作る。M1 の登録・確認・ログインの FR のチケット（YGO-090・YGO-092・YGO-094〜YGO-098）は、この 6 表に読み書きする。
YGO-073 で YGO-065 から分けた 4 枚目（機能の実装）。範囲はこの 6 表と、`tenancies.resident_id` の外部キーだけ。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）が `状態: done` であること。
- 依存の順: YGO-062 → YGO-075（ADR-0106）と YGO-078（`package.json` とロックファイル。並んで進む）→ YGO-076（使い捨ての PostgreSQL）→ YGO-065（`addresses`・`tenancies`）→ **YGO-077（このチケット）**。
  - YGO-065 が `状態: done` であること。`migrations/0001_addresses_tenancies.sql` があり、`tenancies.resident_id` が外部キーのない `uuid NULL` で作られていること、TC-005 のテストが `tenancies` の行を `resident_id` NULL で入れること（外部キーを足しても TC-005 を直さずに通る）を前提にする。
  - YGO-076 が `状態: done` であること（`check.sh` がひな型の DB にマイグレーションを当てる）。

## 範囲
- **マイグレーション** `migrations/0002_residents_auth.sql`: 6 表 `residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets` を、`.ai/db.md` §2 の列・一意・外部キー・CHECK・索引のとおりに作る。
  - CHECK: `residents` の年齢・誕生日の月・日と月日の組み合わせ、`credentials` の TOTP の列の組み、`auth_tokens` の `purpose` と対の列、`staff_roles` の `role` など、db.md §2 のこの 6 表に書かれたものすべて。
  - 索引: `credentials` の (`email_key_version`)・(`email_hmac_key_version`)・(`totp_key_version`) の NULL を除く部分索引、`sessions` と `auth_tokens` の (`resident_id`)・(`expires_at`) など、db.md §2 のこの 6 表に書かれたものすべて。db.md が「足さない」とした索引は作らない。
  - 同じファイルで `ALTER TABLE tenancies ADD ... FOREIGN KEY (resident_id) REFERENCES residents` を足す（db.md §2 の `tenancies.resident_id` は FK→residents NULL、外部キーは既定。§2「住民を指す外部キー」）`[assumed]`。YGO-065 の時点では `residents` がないため、外部キーはこのチケットで足す。
  - db.md に NOT NULL・既定が書かれていない列は、SQL のコメントにその箇所ごとに `[assumed]` と書く。
  - 当て方は YGO-076 の `check.sh` のひな型の DB の段（`psql -v ON_ERROR_STOP=1 --single-transaction -f`）。

## 直さないところと理由
- TC のテスト: `.ai/tests/test-plan.md` に、経路を通さずにこの 6 表だけで確かめる TC がない。6 表を使う TC（TC-016・TC-018・TC-020・TC-023 など）は、FR のチケット（YGO-092・YGO-094・YGO-097・YGO-095）が書く。
- 経路・登録のトランザクション・J14・J18: M1 の FR のチケット YGO-089〜YGO-098（`roadmap.md` §4「M1 の FR のチケット」）と、M0 の部品のチケット YGO-080〜YGO-086。
- 「住民・住所」より後の表（手紙・配達回・新聞など）: 使う M のチケットで足す。
- 新しい OQ・要回答は 0 件（列の型と NOT NULL の細部は db.md と `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-077 M1 の住民と認証の 6 表のマイグレーション`・`状態: done`・`M: M1`。
2. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わる（`check.sh` が `0001` と `0002` の 2 つのマイグレーションをひな型の DB に当てる）。
3. `test-results/junit.xml` の名前に `TC-005` を含む `testcase` と `TC-033` を含む `testcase` が、どちらも passed（`skipped`・`failure`・`error` の要素がない）のまま。
4. `migrations/0002_residents_auth.sql` があり、`residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets` の 6 つの `CREATE TABLE` があり、`addresses`・`tenancies` の `CREATE TABLE` がない。
5. そのマイグレーションに、`tenancies` の `resident_id` から `residents` への外部キーを足す `ALTER TABLE` がある。
6. マイグレーションの列・一意・外部キー・CHECK・索引が `.ai/db.md` §2「住民・住所」の 6 表と食い違わない。db.md に書かれていない NOT NULL・既定には、その箇所に `[assumed]` のコメントがある。
