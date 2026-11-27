# YGO-076 check.sh の使い捨ての PostgreSQL と主版 18 の確かめ
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`.ai/environment.md` §4.1 の 4（使い捨ての PostgreSQL を起こす）・5（ひな型のデータベース）を `scripts/check.sh` に足し、DB を使う最初の TC（TC-005、YGO-065）を動かせるようにする。
YGO-073 で YGO-065 から分けた 2 枚目（道具の追加）。範囲は `check.sh` の DB の段と、テストが DB に繋ぐための道具（ドライバとテストの準備のコード）だけで、表（マイグレーション）と TC のテストは入れない。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）が `状態: done` であること。`package.json`・`package-lock.json`・Vitest の段が `check.sh` で動くことを前提にする。
- 依存の順: YGO-078（`package.json` とロックファイル）→ YGO-075（ADR-0106）→ **YGO-076（このチケット）** → YGO-065（`addresses`・`tenancies`）→ YGO-077（残りの 6 表）。
  - YGO-075 が `状態: done` であること。`pg`・`@types/pg` を足す変更でロックファイルを直す根拠は ADR-0106 の D1。
- PostgreSQL のサーバーの主版は **18** `[assumed]`（`.ai/environment.md` §5.1 の一覧の `initdb`・`pg_ctl`・`psql` の行と §3.1 の PostgreSQL の行。本番のマネージドサービスでも同じ主版を選ぶ、ADR-0010）。
  OQ-086 → 決定と `roadmap.md` §4 の M0 の依存の順（主版を決める → 秘書がマスターに伝える → 道具があることを確かめる → DB のテストを足す）に従い、次の 2 つがそろうまで、このチケットを始めない:
  1. 秘書が、主版 18 をマスターに伝えている。
  2. CI の実行の環境と秘書のジョブの環境で、`initdb --version`・`pg_ctl --version`・`psql --version` が主版 18 を返す（道具はマスターが入れる。OQ-086 → 決定、`.ai/environment.md` §4.1 の 4・§5.1）。
  主版を 18 から変えるときは、このチケットを始める前に、`.ai/environment.md` §3.1・§5.1 の主版を直し、秘書が改めて伝える。

## 範囲
- **使い捨ての PostgreSQL**（`.ai/environment.md` §4.1 の 4）を `scripts/check.sh` の Vitest の段の前に足す。
  - `mktemp -d` の一時ディレクトリに `initdb` し、`pg_ctl start` で起こす。`listen_addresses=''`（TCP で待ち受けない）で、Unix ソケットは一時ディレクトリの中。
  - 片付けの `trap` を EXIT・INT・TERM・HUP に掛ける。止められない・消せないときは失敗する（§4.4）。
  - `initdb`・`pg_ctl`・`psql` がなければ、理由を出して失敗する（飛ばさない）。
  - `initdb --version` の主版が `.ai/environment.md` §3.1 の PostgreSQL の行の主版（§5.1 の一覧と同じ 18）と合うかを確かめ、合わなければ要る主版を出して失敗する。
  - `package.json` があるときだけ動かす（Vitest の段と同じ条件）`[assumed]`。ただし `package.json` がなく `migrations/*.sql` があるときは、確かめる相手があるのに段を飛ばすことになるため、理由を出して失敗する（黙って飛ばさない）。
- **ひな型のデータベース**（§4.1 の 5）: `yuguregaoka_template` を作り、`migrations/*.sql` を名前の順に `psql -v ON_ERROR_STOP=1 --single-transaction -f` で当てる `[assumed]`。マイグレーションの道具は依存に足さない `[assumed]`。このチケットの時点では `migrations/` にファイルがなく、空のひな型になる（表は YGO-065・YGO-077 が足す）。
- **接続**（`.ai/environment.md` §4.2）: `check.sh` がテストに渡すのは、ソケットのディレクトリとひな型の DB の名前の環境変数だけ。テストの準備のコード `test/setup.ts` が、それを使ってテストのファイルごとに `CREATE DATABASE ... TEMPLATE yuguregaoka_template` で DB を作り、その DB を指す `DATABASE_URL` を組み立てる `[assumed]`。`.env*` のファイルは使わない（§4.2）。`vitest.config.ts` の `setupFiles` に `test/setup.ts` を足す。
- **DB のドライバ**: `pg` を `dependencies`、`@types/pg` を `devDependencies` に固定の版で足し、ADR-0106 の D1 のとおり同じ変更でロックファイルを直す `[assumed]`。
- **文書をそろえる**（同じ変更で今の状態に書き直す）:
  - `.ai/environment.md` §4.1: 冒頭の文を、`check.sh` が 1・2・4・5・6・7 を動かす形にし、4・5 をこのチケットで作ったものとして書く。3（型の検査と lint）は、M1 の TC が依存しないため M1 のチケットにせず §4.1 の 3 として残すと書く `[assumed]`。
  - `.ai/environment.md` §3.1: PostgreSQL の行に、`check.sh` が `initdb --version` の主版を確かめることを書く。

## 直さないところと理由
- マイグレーションの表と TC-005 のテスト: YGO-065。残りの 6 表: YGO-077。
- 型の検査と lint（§4.1 の 3）: M1 の TC はどれも型の検査と lint の結果を確かめないため、M1 のチケットにしない `[assumed]`。
- `scripts/dev-db.sh`（開発の DB）: `check.sh` は使い捨ての PostgreSQL を使い、TC はこの台本を使わない。
- CI の workflow（`.github/`）・`.ai/status.md`: ジョブは書かない（CLAUDE.md）。
- 新しい OQ・要回答は 0 件（主版はマスターに聞かず秘書が伝える（OQ-086 → 決定）。ひな型の DB と接続の形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-076 check.sh の使い捨ての PostgreSQL と主版 18 の確かめ`・`状態: done`・`M: M1`。
2. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed（`skipped`・`failure`・`error` の要素がない）のまま。
3. `scripts/check.sh` の使い捨ての PostgreSQL が `listen_addresses=''` で起き、`trap` が EXIT・INT・TERM・HUP に掛かっている。
4. `initdb`・`pg_ctl`・`psql` のどれかがないとき、`check.sh` は理由を出して終了コード 0 以外で終わる（飛ばさない）。`package.json` がなく `migrations/*.sql` があるときも、`check.sh` は理由を出して終了コード 0 以外で終わる。
5. `scripts/check.sh` に、`initdb --version` の主版を `.ai/environment.md` §3.1 の PostgreSQL の行の主版（§5.1 の一覧と同じ 18）と比べ、合わなければ終了コード 0 以外で終わる段がある。
6. `scripts/check.sh` がひな型の DB `yuguregaoka_template` を作り、`migrations/*.sql` を `psql -v ON_ERROR_STOP=1 --single-transaction -f` で名前の順に当てる。
7. `test/setup.ts` がファイルごとの DB を `TEMPLATE yuguregaoka_template` で作り、その DB を指す `DATABASE_URL` を組み立てる。`scripts/check.sh` が渡す環境変数はソケットのディレクトリとひな型の DB の名前だけ。
8. `scripts/check.sh` に、ネットワークを使うコマンド（`npm ci`・`npm install`・`curl`・`wget` など）がない。
9. `package.json` の `dependencies` に `pg`、`devDependencies` に `@types/pg` があり、版に `^`・`~` がない。`package-lock.json` に両方の名前がある。
10. `.ai/environment.md` §4.1 の 4・5 が作ったものとして書かれ、3 は M1 の TC が依存しないため M1 のチケットにしないと書かれていて、「この順に」の文言がない。§3.1 の PostgreSQL の行に `initdb --version` の主版の確かめが書かれている。
