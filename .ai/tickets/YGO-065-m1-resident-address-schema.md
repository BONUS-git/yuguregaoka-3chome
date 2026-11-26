# YGO-065 M1 の住民と住所の DB のスキーマとマイグレーション
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の FR を実装する最初の 1 単位として、`.ai/db.md` §2「住民・住所」の 8 表のスキーマとマイグレーションを作り、TC-005 のテストを通す。

最初にこの単位を選んだ理由:
- `.ai/roadmap.md` §4 の M1 の行の FR（住所の候補・登録・メールの確認・ログイン・セッション・再認証・流量の制限・プロフィール・入居の一覧）は、どれもこの 8 表のどれかに読み書きする。表がないと、どの FR の経路も書けない。
- `.ai/roadmap.md` §4 の依存の表で、M1 は M0 の「DB・アダプタ（メール）・時計」に依存する。時計とメールのアダプタは登録の経路から要るが、スキーマはそれより前に要る。
- `.ai/tests/test-plan.md` の M1 の結合の TC のうち、経路もアダプタもなしで、表と制約だけで確かめられるのは TC-005 だけ。

## 依存
- YGO-062（M1 のテストの土台）が `状態: done` であること。`package.json`・`package-lock.json`・Vitest の段が `check.sh` で動くことを前提にする。
  YGO-062 が `open` のあいだは、このチケットを始めない（`package.json` がないと Vitest の段が飛び、TC-005 のテストが動いたことを確かめられない）。
- PostgreSQL のサーバーの主版は **18** `[assumed]`（このチケットで決める。`.ai/environment.md` §3.1 の「主版を 1 つに決めて（M0）」の 1 つ。本番のマネージドサービスでも同じ主版を選ぶ、ADR-0010）。
  OQ-086 → 決定と `roadmap.md` §4 の M0 の依存の順（主版を決める → 秘書がマスターに伝える → 道具があることを確かめる → DB のテストを足す）に従い、次の 2 つがそろうまで、このチケットを始めない:
  1. 秘書が、主版 18 をマスターに伝えている。
  2. CI の実行の環境と秘書のジョブの環境で、`initdb --version`・`pg_ctl --version`・`psql --version` が主版 18 を返す（道具はマスターが入れる。OQ-086 → 決定、`.ai/environment.md` §4.1 の 4・§5）。
  主版を 18 から変えるときは、このチケットを始める前に、この節と範囲の主版を直し、秘書が改めて伝える。

## 範囲
対象の FR と TC:
- FR-003（住所の割り当て・`addresses.address_text` の UNIQUE・`tenancies` の is_current の部分一意）
- TC-005（FR-003、結合）: `addresses.address_text` の UNIQUE と、`tenancies` の is_current の部分一意の制約に当たると挿入が失敗する

作るもの:
- **マイグレーション** `migrations/0001_residents_addresses.sql`: `.ai/db.md` §2「住民・住所」の 8 表 `residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets`・`addresses`・`tenancies` を、db.md の列・一意・外部キー・CHECK・索引のとおりに作る。
  - CHECK: `residents` の誕生日の月・日と月日の組み合わせ、`credentials` の TOTP の列の組み、`auth_tokens` の `purpose` と対の列、`staff_roles` の `role` など、db.md §2 のこの 8 表に書かれたものすべて。
  - 索引: `credentials` の (`email_key_version`)・(`email_hmac_key_version`)・(`totp_key_version`) の NULL を除く部分索引、`sessions` と `auth_tokens` の (`resident_id`)・(`expires_at`)、`tenancies` の `WHERE is_current` の部分一意など、db.md §2 のこの 8 表に書かれたものすべて。db.md が「足さない」とした索引は作らない。
  - 当て方は `psql -v ON_ERROR_STOP=1 --single-transaction -f` `[assumed]`。マイグレーションの道具は依存に足さない `[assumed]`。
  - db.md に NOT NULL・既定が書かれていない列は、SQL のコメントにその箇所ごとに `[assumed]` と書く。
- **使い捨ての PostgreSQL**（`.ai/environment.md` §4.1 の 4・5）を `scripts/check.sh` に足す。YGO-062 が「初めて DB を使う TC より前に足す」としていて、TC-005 がその最初の TC のため、このチケットで作る。
  - `mktemp -d` の一時ディレクトリに `initdb` し、`pg_ctl start` で起こす。`listen_addresses=''`（TCP で待ち受けない）で、Unix ソケットは一時ディレクトリの中。
  - 片付けの `trap` を EXIT・INT・TERM・HUP に掛ける。止められない・消せないときは失敗する（§4.4）。
  - `initdb`・`pg_ctl`・`psql` がなければ、理由を出して失敗する（飛ばさない）。
  - マイグレーションを当てたひな型の DB `yuguregaoka_template` を作り、テストのファイルごとに `CREATE DATABASE ... TEMPLATE yuguregaoka_template` で DB を作る `[assumed]`。
  - 接続は `.ai/environment.md` §4.2 のとおり `DATABASE_URL` を使う。`check.sh` がテストに渡すのは、ソケットのディレクトリとひな型の DB の名前だけ。テストの準備のコード（`test/setup.ts` など）が、それを使ってファイルごとの DB を作り、その DB を指す `DATABASE_URL` を組み立てる。`.env*` のファイルは使わない（§4.2）。
  - 依存の節で決めて伝えた主版（18）を `.ai/environment.md` §3.1 の表の PostgreSQL の行に書く。`check.sh` は `initdb --version` の主版がそれと合うかを確かめ、合わなければ要る主版を出して失敗する。
- **DB のドライバ**: `pg` を `dependencies`、`@types/pg` を `devDependencies` に固定の版で足し、ロックファイルを直す `[assumed]`。
  - ADR-0103 の D1 のネットワークの例外は「最初のロックファイル」だけで、依存を足す変更の根拠にならない。そのため ADR-0104 を作り、「依存を足す・変える変更ごとに、その変更の中でロックファイルを直す」として D1〜D3 を丸ごと書き直し、ADR-0103 の状態を `置き換え（→ 0104）` にする。
  - 今の状態を書く文書（`.ai/environment.md` など）と `scripts/` に残る `ADR-0103` の参照を、同じ変更で `ADR-0104` に直す。
- **TC-005 のテスト** `test/test_TC_005_address_tenancy_unique.test.ts`（名前は `TC-005 …` で始める。`skip`・`todo` にしない）:
  - 同じ `address_text` の `addresses` の行を 2 回挿入すると、2 回目が SQLSTATE `23505` で失敗する。
  - 同じ `address_id` に `is_current = true` の `tenancies` の行を 2 つ入れると、2 つ目が `23505` で失敗する。
  - `is_current = false` の行は、同じ住所に `is_current = true` の行があっても入る。
  - 値は偽の値（住所は `夕暮ヶ丘三丁目 2-5` など、メールは `test@example.invalid`。`.ai/environment.md` §4.2）。
- **文書をそろえる**（同じ変更で今の状態に書き直す）:
  - `.ai/environment.md` §4.1: 4・5 をこのチケットで作ったものとして書き、3（型の検査と lint）だけを M0 の別のチケットで足すものとして残す。「この順に足す」の文言は消す。
  - `.ai/environment.md` §3.1: PostgreSQL の行に主版（18 `[assumed]`）と、`check.sh` が `initdb --version` で確かめることを書く。
  - `.ai/db.md` §2 の「DDL は書かない」を、DDL の正本は `migrations/` とする記述に直す。
  - `.ai/INDEX.md`: ADR-0104 の行を足し、ADR-0103 の行の末尾を状態に合わせる。

## 直さないところと理由
- 経路・登録のトランザクション・409 の応答（TC-006 ほか）: 時計とメールのアダプタが要るため、M1 の次のチケットで。
- 時計・メールのアダプタ・`scripts/dev-db.sh`・キュー・2 プロセスの骨組み・`APP_ENV`: `roadmap.md` §4 の M0 の行の残りで、それぞれ別のチケットで。
- 型の検査と lint（`.ai/environment.md` §4.1 の 3）: このチケットでは足さない。§4.1 は 3〜5 を「この順に足す」としているが、4・5 を先にする。TC-005 は DB を使う最初のテストで、4・5 がないと動かせない。3 は DB に依存せず、あとから足しても 4・5 を変えずに済む。そのため §4.1 の書き直しで「この順に」を消す。
- 「住民・住所」より後の表（手紙・配達回・新聞など）: 使う M のチケットで足す。
- CI の workflow（`.github/`）・`.ai/status.md`: ジョブは書かない（CLAUDE.md）。
- 新しい OQ・要回答は 0 件（ドライバ・マイグレーションの形・PostgreSQL の主版は技術の細部で `[assumed]`。主版はマスターに聞かず、秘書が伝える（OQ-086 → 決定）。接続の変数は `environment.md` §4.2 の `DATABASE_URL` で決まっている。ネットワークの例外は ADR-0104 で決める）。
- このチケットを切る変更では、このチケットと `.ai/INDEX.md` のチケットの一覧の 1 行だけを足す。`scripts/check.sh` は `.ai/` の下のファイルが `.ai/INDEX.md` に載っていないと失敗するため。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-065 M1 の住民と住所の DB のスキーマとマイグレーション`・`状態: done`・`M: M1`。
2. YGO-062 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わる。
4. `test-results/junit.xml` に、名前に `TC-005` を含む `testcase` があり、その中に `skipped`・`failure`・`error` の要素がない（passed）。
5. `migrations/0001_residents_addresses.sql` があり、`residents`・`credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets`・`addresses`・`tenancies` の 8 つの `CREATE TABLE` がある。
6. そのマイグレーションに、`addresses.address_text` の UNIQUE と、`tenancies` の `address_id` の `WHERE is_current` の部分一意の索引がある。
7. マイグレーションの列・一意・外部キー・CHECK・索引が `.ai/db.md` §2「住民・住所」の表と食い違わない。db.md に書かれていない NOT NULL・既定には、その箇所に `[assumed]` のコメントがある。
8. `scripts/check.sh` の使い捨ての PostgreSQL が `listen_addresses=''` で起き、`trap` が EXIT・INT・TERM・HUP に掛かっている。
9. `initdb`・`pg_ctl`・`psql` のどれかがないとき、`check.sh` は理由を出して終了コード 0 以外で終わる（飛ばさない）。
10. `scripts/check.sh` に、ネットワークを使うコマンド（`npm ci`・`npm install`・`curl`・`wget` など）がない。
11. `package.json` の `dependencies` に `pg`、`devDependencies` に `@types/pg` があり、版に `^`・`~` がない。`package-lock.json` に両方の名前がある。
12. ADR-0104 があり 3 行目が `- 状態: 採用`、ADR-0103 の 3 行目が `- 状態: 置き換え（→ 0104）`。`.ai/INDEX.md` の両方の ADR の行の末尾が状態と同じ。
13. `.ai/environment.md` §4.1 の 4・5 が作ったものとして書かれ、3 だけが M0 の別のチケットで足すものとして残っていて、「この順に」の文言がない。`.ai/db.md` §2 に「DDL は書かない」が残っていない。
14. `.ai/`（チケットを除く）と `scripts/` に、今の決定として `ADR-0103` を指す記述が残っていない（ADR-0104 と ADR-0103 の本文、経緯を書く `retros.md`・`triage.md` を除く）。
15. `.ai/environment.md` §3.1 の PostgreSQL の行に、このチケットの依存の節と同じ主版（`[assumed]` 付き）が書かれ、`scripts/check.sh` に `initdb --version` の主版をそれと比べ、合わなければ終了コード 0 以外で終わる段がある。
16. テストの準備のコード（`test/setup.ts` など）がファイルごとの DB を指す `DATABASE_URL` を組み立て、`scripts/check.sh` が渡す環境変数はソケットのディレクトリとひな型の DB の名前だけ。
