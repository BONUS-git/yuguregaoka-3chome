# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の機能を実装するチケットが、それぞれ TC のテストを足すだけで済むように、テストを動かす土台を先に作る。

## 確かめた事実
- すでにある（範囲から外す）:
  - `scripts/check.sh`。今は文書の確認だけで、テストは動かさない。
  - `.gitignore` の `node_modules/` の行。
- ない（範囲に入れる）:
  - `scripts/prepare.sh`・`package.json`・ロックファイル（`package-lock.json`）・`src/`・`test/`。
  - `.gitignore` の `test-results/` の行。
- `.github/` はない。CI の設定は秘書の `.github/workflows/check.yml` で、足すのはマスター（CLAUDE.md・`.ai/environment.md` §5・§10.1）。
- 秘書の CI が `check.sh` の前に `prepare.sh` を動かすかどうかは、このレポジトリからは確かめられない。CLAUDE.md は「push のたびに `scripts/check.sh` を動かす」とだけ書き、`prepare.sh` には触れていない。`.github/workflows/check.yml` はこのレポジトリにない。
- ADR-0009: TypeScript・Fastify・Vitest。
- ADR-0052 の D3・`.ai/environment.md` §3.2・§4.1・§5: `prepare.sh` は npm の依存だけを入れ（`npm ci`）、OS の道具は入れない。CI は `prepare.sh` → `check.sh` の順に動かす。
- `.ai/roadmap.md` §4 の M0 の行: M0 の内容に「Vitest を `check.sh` からつなぐ」があり、ほかに 2 プロセス（web / worker）の骨組み・PostgreSQL とキュー・C3 の空の形・時刻を外から差し替えられる時計・アダプタ・`scripts/dev-db.sh`・`check.sh` の使い捨ての PostgreSQL・`APP_ENV` と環境変数の読み込みがある。
  `.ai/environment.md` §3.1（`engines` を M0 で書く）・§3.2（`prepare.sh` を M0 で作る）・§4.1（M0 で `check.sh` を広げる）も、この土台を M0 のものとしている。
- `.ai/tests/test-plan.md`: テストの名前の頭に `TC-NNN …` を書く決まりがある。TC-033（FR-092、単体）は「ルートの一覧に OAuth と WebAuthn の経路がない」。M1 の TC のうち、DB も FR の機能もなしで確かめられるのはこれだけ。

## 範囲
このチケットが作るのは、`roadmap.md` §4 の M0 の行のうち「Vitest を `check.sh` からつなぐ」と、それに要る `scripts/prepare.sh`・`package.json`（`engines` を含む）だけ。
M0 の残り（使い捨ての PostgreSQL・`scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み）は M0 の別のチケットに回す（「直さないところ」）。
`M: M1` とするのは、目的が M1 の TC のテストを動かす土台だから。

- `package.json` とロックファイル: `fastify`・`vitest`・`typescript`・`@types/node` を入れ、版は固定する（範囲の記号を付けない）`[assumed]`。
  `engines.node` には実装の時点の Node.js の Active LTS の主版を書く `[assumed]`。
- `vitest.config.ts`: テストの結果を JUnit XML で `test-results/junit.xml` に書く（標準の出力の報告も残す）`[assumed]`。
- `scripts/prepare.sh`: `npm ci` だけを動かす。OS の道具（PostgreSQL・`tofu`）は入れない。
- `scripts/check.sh` に、今の文書の確認のあと、`check: ok` の前に足す:
  - `node_modules/` がなければ、`sh scripts/prepare.sh` を先に動かすよう出して失敗する（飛ばさない）。
  - ネットワークを使わずに `npx --no-install vitest run` を動かす。失敗したら `check.sh` も失敗する。
  - 終わったあと、`test-results/` に `.xml` のファイルがなければ失敗する。
- `.gitignore`: `test-results/` の行を足す（`node_modules/` の行はすでにある）。
- 例のテスト（TC の名前の決まりの例）:
  - `src/app.ts` に、経路を持たない Fastify のアプリを返す `buildApp()` を置く。
  - `test/tc-033-no-oauth-webauthn-routes.test.ts` を 1 つ足す。テストの名前は `TC-033 …` で始め、
    `buildApp()` のルートの一覧（`printRoutes()` など）に `oauth`・`webauthn` を含む経路がないことを確かめる。ポートは開かない。
  - `skip`・`todo` にしない。
- `.ai/environment.md` を今の状態に合わせて書き直す:
  - §3.2 の「`prepare.sh` は今のレポジトリになく、依存を足す M0 で作る」を消し、`prepare.sh` が `npm ci` を動かすことを書く。
  - §4.1 の「今の `check.sh` は文書の確認だけ」を、文書の確認と Vitest を動かすことに書き直し、JUnit XML の出力先 `test-results/junit.xml` を足す。
    §4.1 の 2〜4（型の検査と lint・使い捨ての PostgreSQL・ひな型のデータベース）は、M0 の別のチケットで足すものとして残す。
  - §3.1 の `engines` の行は、`package.json` に書いた主版と食い違わないようにする。§3.2 の 2 以降（`dev-db.sh`・`.local/`）は M0 の別のチケットで作るものとして残す。
- 地図 `.ai/INDEX.md` と食い違うところがあれば同じ変更で直す（`.ai/` の外のファイルは地図に載せない）。

## 直さないところと理由
- CI の workflow（`.github/`）: CLAUDE.md・`.ai/environment.md` §5・§10.1 のとおり、CI の設定はジョブが書かない（秘書の `check.yml`、足すのはマスター）。
  CI の形（`prepare.sh` → `check.sh`）は §5 の計画のまま。
- 前提: この土台は、CI が `prepare.sh` → `check.sh` の順に動かす形であることを前提にする。CI が `check.sh` だけを動かすと、`node_modules/` がなく `check.sh` は失敗する（受け入れ確認 4）。
  CI の形を決めるのは秘書かマスターで、ジョブは確かめも変えもできないため、OQ にせず前提として書く。
  CI がその形になるまで、「CI が緑」はこのチケットの受け入れ確認に入れない（受け入れ確認は `check.sh` をローカルで動かした結果とファイルの中身だけ）。
- 使い捨ての PostgreSQL の起動と片付け（§4.1 の 3・4、§4.4）: `roadmap.md` §4 の M0 の別のチケットで、初めて DB を使う TC より前に足す。
- `scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み（`roadmap.md` §4 の M0 の行の残り）: M0 の別のチケットで足す。
- 型の検査と lint（§4.1 の 2）: このチケットでは足さない。
- M1 の FR の機能の実装: 別のチケットで 1 つずつ。
- `.ai/status.md`: 秘書が書くもので、ジョブは変えない。
- 新しい ADR・OQ・要回答は 0 件（道具は ADR-0009 と ADR-0052 で決まっている。版や設定の細部は `[assumed]`）。
- このチケットを切る変更では、チケットと `.ai/INDEX.md` のチケットの一覧の 1 行だけを足す `[assumed]`。
  `scripts/check.sh` は `.ai/` の下のファイルが `.ai/INDEX.md` に載っていないと失敗するため。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）`・`状態: done`・`M: M1`。
2. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` が終了コード 0 で `check: ok` で終わり、`test-results/` に JUnit XML（`.xml`）が 1 つ以上できる。
3. その XML に、名前に `TC-033` を含む `testcase` がちょうど 1 つあり、その中に `skipped`・`failure`・`error` の要素がない。
4. `node_modules/` がない状態で `sh scripts/check.sh` を動かすと、終了コードが 0 でなく、`prepare.sh` を動かすよう出す。
5. `scripts/check.sh` に、ネットワークを使うコマンド（`npm ci`・`npm install`・`curl`・`wget` など）がなく、`vitest` は `npx --no-install` で呼ぶ。
6. `scripts/prepare.sh` があり、`npm ci` を動かす。
7. `package.json` に `fastify`・`vitest`・`typescript`・`@types/node` があり、どの版にも `^`・`~` が付いていない。ロックファイル `package-lock.json` がある。
8. `.gitignore` に `test-results/` と `node_modules/` の行がある。
9. この変更で `.github/` の下のファイルを足していない・変えていない。
10. `.ai/environment.md` に「`prepare.sh` は今のレポジトリになく」と「今の `check.sh` は文書の確認だけ」が残っておらず、§4.1 に `test-results/junit.xml` が書かれている。
11. `.ai/environment.md` §3.1・§3.2・§4.1 の「M0 で」の記述が、このチケットで作ったものと食い違わない: §3.1 の `engines` の主版が `package.json` と同じで、§3.2 の `dev-db.sh`・`.local/` と §4.1 の 2〜4 は M0 で足すものとして残り、作ったと書かれていない。
12. このチケットの「範囲」に、`roadmap.md` §4 の M0 の行のうち作るもの（Vitest を `check.sh` からつなぐ・`prepare.sh`）と、M0 の別のチケットに回すもの（使い捨ての PostgreSQL・`dev-db.sh`・時計・アダプタ）が書かれている。
