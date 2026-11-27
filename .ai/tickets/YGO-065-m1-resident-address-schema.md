# YGO-065 M1 の住民と住所の DB のスキーマとマイグレーション
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の FR を実装する最初の 1 単位として、`.ai/db.md` §2「住民・住所」の `addresses`・`tenancies` の 2 表のマイグレーションを作り、TC-005 のテストを通す。

最初にこの単位を選んだ理由:
- `.ai/roadmap.md` §4 の M1 の行の FR（住所の候補・登録・メールの確認・ログイン・セッション・再認証・流量の制限・プロフィール・入居の一覧）は、どれも「住民・住所」の 8 表のどれかに読み書きする。表がないと、どの FR の経路も書けない。
- `.ai/tests/test-plan.md` の M1 の結合の TC のうち、経路もアダプタもなしで、表と制約だけで確かめられるのは TC-005 だけ。TC-005 が使うのは `addresses`・`tenancies` の 2 表。

範囲の分け方（YGO-073、`reviews/0004-phase-evaluation-2026-11-27.md` の R-068）: もとの範囲は 4 枚に分けた。このチケットに残るのは `addresses`・`tenancies` の表と TC-005 だけで、ほかは次のチケットに移した。
- 依存を足すときのロックファイルの ADR（ADR-0103 を置き換える ADR-0106）と `ADR-0103` の参照の直し: YGO-075
- 使い捨ての PostgreSQL・主版 18 の確かめ・ひな型の DB・`pg`/`@types/pg` の依存・`test/setup.ts`・`environment.md` §3.1・§4.1 の直し: YGO-076
- 残りの 6 表（`residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets`）と `tenancies.resident_id` の外部キー: YGO-077

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）が `状態: done` であること。`package.json`・`package-lock.json`・Vitest の段が `check.sh` で動くことを前提にする。
- 依存の順: YGO-062 → YGO-075（ADR-0106）と YGO-078（`package.json` とロックファイル。並んで進む）→ YGO-076（使い捨ての PostgreSQL）→ **YGO-065（このチケット）** → YGO-077（残りの 6 表）。
  - YGO-076 が `状態: done` であること。`check.sh` が使い捨ての PostgreSQL を起こし、`migrations/*.sql` をひな型の DB `yuguregaoka_template` に当て、`test/setup.ts` がファイルごとの DB を指す `DATABASE_URL` を組み立てることを前提にする。PostgreSQL の主版 18 と道具があることの確かめは YGO-076 の依存の節にある。

## 範囲
対象の FR と TC:
- FR-003（住所の割り当て・`addresses.address_text` の UNIQUE・`tenancies` の is_current の部分一意）
- TC-005（FR-003、結合）: `addresses.address_text` の UNIQUE と、`tenancies` の is_current の部分一意の制約に当たると挿入が失敗する

作るもの:
- **マイグレーション** `migrations/0001_addresses_tenancies.sql`: `.ai/db.md` §2「住民・住所」の `addresses`・`tenancies` の 2 表を、db.md の列・一意・外部キー・索引のとおりに作る。
  - 一意と索引: `addresses.address_text` の UNIQUE と、`tenancies` の (`address_id`) `WHERE is_current` の部分一意の索引。db.md が「足さない」とした索引は作らない。
  - 外部キー: `tenancies.address_id` → `addresses`。`tenancies.resident_id` は外部キーのない `uuid NULL` で作る `[assumed]`（この時点では `residents` がない。外部キーは YGO-077 が `ALTER TABLE` で足す）。
  - db.md に NOT NULL・既定が書かれていない列は、SQL のコメントにその箇所ごとに `[assumed]` と書く。
- **TC-005 のテスト** `test/test_TC_005_address_tenancy_unique.test.ts`（名前は `TC-005 …` で始める。`skip`・`todo` にしない）:
  - 同じ `address_text` の `addresses` の行を 2 回挿入すると、2 回目が SQLSTATE `23505` で失敗する。
  - 同じ `address_id` に `is_current = true` の `tenancies` の行を 2 つ入れると、2 つ目が `23505` で失敗する。
  - `is_current = false` の行は、同じ住所に `is_current = true` の行があっても入る。
  - `tenancies` の行は `resident_id` を NULL で入れる（db.md §2 で NULL を許す列。YGO-077 が `residents` への外部キーを足したあとも、テストを直さずに通る）`[assumed]`。
  - 値は偽の値（住所は `夕暮ヶ丘三丁目 2-5` など。`.ai/environment.md` §4.2）。
- **文書をそろえる**（同じ変更で今の状態に書き直す）:
  - `.ai/db.md` §2 の「DDL は書かない」を、DDL の正本は `migrations/` とする記述に直す。

## 直さないところと理由
- ADR-0106 と `ADR-0103` の参照の直し: YGO-075。
- 使い捨ての PostgreSQL・ひな型の DB・`pg` の依存・`test/setup.ts`（`.ai/environment.md` §4.1 の 4・5）: YGO-076。
- 型の検査と lint（`.ai/environment.md` §4.1 の 3）: M1 の TC はどれも型の検査と lint の結果を確かめないため、M1 のチケットにせず、§4.1 の 3 として残す `[assumed]`（YGO-062・YGO-076 と同じ）。
- 残りの 6 表と `tenancies.resident_id` の外部キー: YGO-077。
- 経路・登録のトランザクション・409 の応答（TC-006 ほか）: 時計とメールのアダプタが要るため、YGO-071 で切る FR のチケットで。
- `roadmap.md` §4 の M0 の行の残りのうち M1 の TC が使う部品: YGO-080（差し替えられる時計）・YGO-086（pg-boss の依存）・YGO-081（`jobs` のキューに積む口）・YGO-082（環境変数の読み込みと `MAIL_ADAPTER` の選択）・YGO-083（モックのメールのアダプタ）・YGO-084（worker のジョブの実行）・YGO-085（KeyProvider の偽の鍵）。どれもこのチケットのあとに並べる。
- `scripts/dev-db.sh`（開発の DB の台本。`check.sh` は使い捨ての PostgreSQL を使い、TC はこの台本を使わない）と `APP_ENV` の起動の検査（M1 の TC はどれも確かめない）: M1 の TC が使わないため M1 のチケットにせず、使う TC のチケットを切るときに扱う `[assumed]`。
- 「住民・住所」より後の表（手紙・配達回・新聞など）: 使う M のチケットで足す。
- CI の workflow（`.github/`）・`.ai/status.md`: ジョブは書かない（CLAUDE.md）。
- 新しい OQ・要回答は 0 件（マイグレーションの形と列の細部は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-065 M1 の住民と住所の DB のスキーマとマイグレーション`・`状態: done`・`M: M1`。
2. YGO-062・YGO-078・YGO-076 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わる。
4. `test-results/junit.xml` に、名前に `TC-005` を含む `testcase` があり、その中に `skipped`・`failure`・`error` の要素がない（passed）。
5. `migrations/0001_addresses_tenancies.sql` があり、`addresses`・`tenancies` の 2 つの `CREATE TABLE` があり、ほかの表の `CREATE TABLE` がない。
6. そのマイグレーションに、`addresses.address_text` の UNIQUE と、`tenancies` の `address_id` の `WHERE is_current` の部分一意の索引がある。
7. マイグレーションの列・一意・外部キー・索引が `.ai/db.md` §2 の `addresses`・`tenancies` の表と食い違わない（`tenancies.resident_id` の外部キーだけは YGO-077 で足し、その箇所に `[assumed]` のコメントがある）。db.md に書かれていない NOT NULL・既定には、その箇所に `[assumed]` のコメントがある。
8. `.ai/db.md` §2 に「DDL は書かない」が残っていない。
9. TC-005 のテストが `tenancies` に入れる行は、どれも `resident_id` が NULL（仮の UUID を入れない）。
