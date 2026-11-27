# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の機能を実装するチケットが、それぞれ TC のテストを足すだけで済むように、テストを動かす土台を先に作る。
CI の定義（`.github/workflows/`）があり `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かすことの確かめは、このチケットの受け入れ確認から外した（もとの 18）。
理由: CI の定義はジョブが書けない・変えられないファイルで（CLAUDE.md）、このチケットに残すと実装の変更で `done` にできない。同じ中身は YGO-070 の受け入れ確認 1 が確かめる（ADR-0105 の D4）。
CI が実際に緑になるかは、M1 の達成の確認で CI の結果を見る。

## 確かめた事実
- ある:
  - `scripts/check.sh`: 最初の段で Node.js とロックファイルを確かめ（`package.json` があるときだけ。`node` がなければ「node がない: 検証の環境に Node.js <主版> を入れる（package.json の engines.node）」と出して終了コード 1）、文書の確認のあと Vitest を `npx --no-install vitest run` で動かし、`test-results/junit.xml` を確かめる（`package.json` があるときだけ）。このチケットが `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する。ネットワークを使うコマンドはない。
  - `scripts/prepare.sh`: `npm ci --no-audit --no-fund` だけを動かす。`package.json` がなければ終了コード 0、`package-lock.json` がなければ 1、`npm` がなければ 1。
  - `vitest.config.ts`（報告は `default` と `junit`、出力は `test-results/junit.xml`）・`src/app.ts`（`buildApp()`）・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`（名前は `TC-033 …` で始まる。`skip`・`todo` でない）。
  - `.gitignore` の `node_modules/`（7 行目）と `test-results/`（13 行目）の行。
- ない: `package.json`・`package-lock.json`。そのため今の `check.sh` は Node.js とロックファイルの段と Vitest の段を飛ばし、`check: ok` は Vitest の土台が動くことの裏付けではない。
- ない: `.github/`。足すのはマスター（`.ai/environment.md` §5）。
- CLAUDE.md は `.github/workflows/check.yml` を秘書の CI の決まった形の名前とし、ジョブは書かない・変えないとする。その CI については「`scripts/check.sh` を push のたびに動かす」とだけ書き、`prepare.sh` に触れていない。
- ADR-0105: D1 CI は `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かし、M1 のテストは Vitest と npm の依存で書く。D2 CI の定義に `prepare.sh` の段を足すのはマスターで、秘書は `package.json` を入れる変更（このチケットの実装）の前にそれをマスターに伝える。D3 `check.sh` は `prepare.sh` も `npm ci` も呼ばず、`node_modules/` がなければ失敗する。D4 CI の定義をファイルで確かめるのは YGO-070 の受け入れ確認 1 で、このチケットには入れない。
- ADR-0009: TypeScript・Fastify・Vitest。
- ADR-0052 の D3・`.ai/environment.md` §3.2・§4.1・§5: `prepare.sh` は npm の依存だけを入れ（`npm ci`）、OS の道具は入れない。CI は `prepare.sh` → `check.sh` の順に動かす。
- ADR-0103: D1 最初のロックファイルは依存を変える変更の中で `npm install --package-lock-only --ignore-scripts` を 1 回試して作り、`package.json` と同じ変更に入れる。D2 作れなければロックファイルを手で書かず、止まった段とエラーの行をチケットに書き、それまでの段のファイルを出す。D3 `prepare.sh` はロックファイルを作らない。
- OQ-086 の決定: 主版 26 の Node.js（npm を含む）を秘書の実装のジョブ・検証・CI の環境に入れるのはマスター。
- `.ai/roadmap.md` §4 の M0 の行: M0 の内容に「Vitest を `check.sh` からつなぐ」があり、ほかに 2 プロセス（web / worker）の骨組み・PostgreSQL とキュー・C3 の空の形・時刻を外から差し替えられる時計・アダプタ・`scripts/dev-db.sh`・`check.sh` の使い捨ての PostgreSQL・`APP_ENV` と環境変数の読み込みがある。
  `.ai/environment.md` §3.1（`engines` を M0 で書く。主版は 26）・§3.2（`prepare.sh` を M0 で作る）・§4.1（M0 で `check.sh` を広げる）も、この土台を M0 のものとしている。
- `.ai/tests/test-plan.md`: テストの名前の頭に `TC-NNN …` を書く決まりがある。TC-033（FR-092、単体）は「ルートの一覧に OAuth と WebAuthn の経路がない」。M1 の TC のうち、DB も FR の機能もなしで確かめられるのはこれだけ。
  ファイルの名前は `test_TC_001_…` の形にする決まりもある。

## 範囲
このチケットが作るのは、`roadmap.md` §4 の M0 の行のうち「Vitest を `check.sh` からつなぐ」と、それに要る `scripts/prepare.sh`・`package.json`（`engines` を含む）だけ。
M0 の残り（使い捨ての PostgreSQL・`scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み）は M0 の別のチケットに回す（「直さないところ」）。
`M: M1` とするのは、目的が M1 の TC のテストを動かす土台だから。

- `package.json` とロックファイル: `fastify` を `dependencies` に、`vitest`・`typescript`・`@types/node` を `devDependencies` に入れ、版は固定する（範囲の記号を付けない）`[assumed]`。
  `package.json` を先に書き、そのあと D1 のコマンドを引数なしで動かす。
  `engines.node` には `.ai/environment.md` §3.1 の Node.js の行の主版（26）を `26.x` と書く。
- `vitest.config.ts`: テストの結果を JUnit XML で `test-results/junit.xml` に書く（標準の出力の報告も残す）`[assumed]`。
  ロックファイルは ADR-0103 の D1 のコマンドで作る（手で書かない）。
- `scripts/prepare.sh`: `npm ci` だけを動かす。OS の道具（PostgreSQL・`tofu`）は入れない。
  `package.json` がなければ終了コード 0。`package.json` があり `package-lock.json` がなければ、ロックファイルを作らず「依存を変える変更の中でロックファイルを作ってコミットする」と出して終了コード 1（ADR-0103 の D3）。`npm` がなければ 1 行で出して止まる。
- `scripts/check.sh` の最初の段（文書の確認より前）に足す（`package.json` があるときだけ）:
  - `node` のコマンドがあるかと、その主版が `package.json` の `engines.node` と合うかを確かめる。足りなければ、要る主版と「検証の環境に Node.js を入れる」ことが分かる文を出して、終了コード 0 以外で止まる（受け入れ確認 13）。
  - `package-lock.json` がない、または `package.json` の依存の名前がロックファイルにないときに失敗する（ネットワークを使わない）。
- `scripts/check.sh` の文書の確認に足す: このチケットが `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する。
- `scripts/check.sh` に、今の文書の確認のあと、`check: ok` の前に足す:
  - `node_modules/` がなければ、`sh scripts/prepare.sh` を先に動かすよう出して失敗する（飛ばさない）。
  - ネットワークを使わずに `npx --no-install vitest run` を動かす。失敗したら `check.sh` も失敗する。
  - 終わったあと、`test-results/junit.xml` がない、`skipped`（skip・todo）がある、名前に TC-NNN のない `testcase` がある、のどれでも失敗する。
- `.gitignore`: `test-results/` と `node_modules/` の行。
- 例のテスト（TC の名前の決まりの例）:
  - `src/app.ts` に、経路を持たない Fastify のアプリを返す `buildApp()` を置く。
  - `test/test_TC_033_no_oauth_webauthn_routes.test.ts` を 1 つ置く（`test-plan.md` のファイルの名前の決まり）。テストの名前は `TC-033 …` で始め、
    `buildApp()` のルートの一覧（`printRoutes()` など）に `oauth`・`webauthn` を含む経路がないことを確かめる。ポートは開かない。
  - `skip`・`todo` にしない。
- `.ai/environment.md` を今の状態に合わせる:
  - §3.2 に、`prepare.sh` が `npm ci` を動かすことを書く。
  - §4.1 に、文書の確認と Vitest を動かすことと、JUnit XML の出力先 `test-results/junit.xml` を書く。§4.1 の 1（Node.js の確かめ）は作ったものとして書く。
    §4.1 の 3〜5（型の検査と lint・使い捨ての PostgreSQL・ひな型のデータベース）は、M0 の別のチケットで足すものとして残す。
  - §3.1 の `engines` の行は、`package.json` に書いた主版と食い違わないようにする。§3.2 の 2 以降（`dev-db.sh`・`.local/`）は M0 の別のチケットで作るものとして残す。
- 地図 `.ai/INDEX.md` と食い違うところがあれば同じ変更で直す（`.ai/` の外のファイルは地図に載せない）。

## 直さないところと理由
- CI の定義（`.github/`）: ジョブが書いてよい範囲の外（CLAUDE.md は `check.yml` を秘書の決まった形の名前とし、ジョブは書かない・変えないとする）。足すのはマスター（`.ai/environment.md` §5）。
  その定義があり `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かすことは、YGO-070 の受け入れ確認 1 で確かめる（ADR-0105 の D4）。
  CI の結果（緑かどうか）は、M1 の達成の確認で見る。
- 前提: この土台は、CI が `prepare.sh` → `check.sh` の順に動かす形（ADR-0105 の D1）であることを前提にする。CI が `check.sh` だけを動かすと、`node_modules/` がなく `check.sh` は失敗する（受け入れ確認 4、ADR-0105 の D3）。
- 使い捨ての PostgreSQL の起動と片付け（§4.1 の 4・5、§4.4）: `roadmap.md` §4 の M0 の別のチケットで、初めて DB を使う TC より前に足す。
- `scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み（`roadmap.md` §4 の M0 の行の残り）: M0 の別のチケットで足す。
- 型の検査と lint（§4.1 の 3）: このチケットでは足さない。
- M1 の FR の機能の実装: 別のチケットで 1 つずつ。
- `.ai/status.md`: 秘書が書くもので、ジョブは変えない。
- 新しい ADR・OQ・要回答は 0 件（道具は ADR-0009 と ADR-0052、ロックファイルは ADR-0103、CI の順と `prepare.sh` の段を足す人と CI の定義の確かめの置き場所は ADR-0105、Node.js を入れるのは OQ-086 で決まっている。版や設定の細部は `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）`・`状態: done`・`M: M1`。
2. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` が終了コード 0 で `check: ok` で終わり、`test-results/` に JUnit XML（`.xml`）が 1 つ以上できる。
3. その XML に、名前に `TC-033` を含む `testcase` がちょうど 1 つあり、その中に `skipped`・`failure`・`error` の要素がない。
4. `node_modules/` がない状態で `sh scripts/check.sh` を動かすと、終了コードが 0 でなく、`prepare.sh` を動かすよう出す。
5. `scripts/check.sh` に、ネットワークを使うコマンド（`npm ci`・`npm install`・`curl`・`wget` など）がなく、`vitest` は `npx --no-install` で呼ぶ。
6. `scripts/prepare.sh` があり、`npm ci` を動かす。
7. `package.json` の `dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node` があり、どの版にも `^`・`~` が付いていない。ロックファイル `package-lock.json` がある。
8. `.gitignore` に `test-results/` と `node_modules/` の行がある。
9. この変更で `.github/` の下のファイルを足していない・変えていない。
10. `.ai/environment.md` に「`prepare.sh` は今のレポジトリになく」と「今の `check.sh` は文書の確認だけ」が残っておらず、§4.1 に `test-results/junit.xml` が書かれている。
11. `.ai/environment.md` §3.1・§3.2・§4.1 の「M0 で」の記述が、このチケットで作ったものと食い違わない: §3.1 の `engines` の主版が `package.json` と同じで、§3.2 の `dev-db.sh`・`.local/` と §4.1 の 3〜5 は M0 で足すものとして残り、作ったと書かれていない。
12. このチケットの「範囲」に、`roadmap.md` §4 の M0 の行のうち作るもの（Vitest を `check.sh` からつなぐ・`prepare.sh`）と、M0 の別のチケットに回すもの（使い捨ての PostgreSQL・`dev-db.sh`・時計・アダプタ）が書かれている。
13. `scripts/check.sh` の最初の段で、`node` のコマンドがあるかと、その主版が `package.json` の `engines.node` と合うかを確かめる。足りなければ、要る主版と「検証の環境に Node.js を入れる」ことが分かる文を出して、終了コード 0 以外で止まる（`.ai/retros.md` の変更 20261126-380a19 の節）。
14. `package-lock.json` を消した状態で `sh scripts/prepare.sh` と `sh scripts/check.sh` がどちらも終了コード 0 以外で終わる（ADR-0103 の D3）。
15. このチケットが `状態: done` のとき、`scripts/prepare.sh` を消した状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
16. TC-033 のテストを `test.skip` にした状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
17. `package.json` の `engines.node` の主版と、`.ai/environment.md` §3.1 の Node.js の行の主版が同じ。

## 残り
受け入れ確認を 1 行ずつ、今のファイルと照らした結果（満たす: 5・6・8・9・10・12。行はあるが動かして確かめていない: 13・14）。次が残るため `状態: open` のままにする。

- **7・11・17（と、それに依る 2〜4・15・16）**: `package.json` と `package-lock.json` がない。
  - 止まった段（ADR-0103 の D2）: 段 2（`package.json` と `package-lock.json` の作成）。その前の段 0（`node -v` で主版 26 と `npm` を確かめる）で、コマンドを動かせなかった。エラーの行: `Permission to use Bash has been denied`。
  - なぜ残るか: `node`・`npm` を動かせず、ロックファイルを作れない。ロックファイルは手で書かない（ADR-0103 の D2）。`package.json` だけを入れると、`check.sh` の最初の段が node がないとして失敗し、検証が通らない。
  - 片付く条件: マスターが主版 26 の Node.js と npm をジョブの環境に入れる（OQ-086 の決定。新しい OQ は立てない）。そのあと、次の順に進める:
    1. `package.json` を手で書く: `private`・`"type": "module"`・`"engines": {"node": "26.x"}`（主版は `.ai/environment.md` §3.1）。`dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node`。どの版も `^`・`~` を付けない固定の版で、実装の時点の安定版にし、`@types/node` は主版 26 のものにする `[assumed]`。
    2. ADR-0103 の D1 のコマンドを引数なしで 1 回動かす: `npm install --package-lock-only --ignore-scripts`。版が見つからないと出たら、`package.json` の版を直して同じコマンドを動かす。
    3. `sh scripts/prepare.sh` と `sh scripts/check.sh` を動かし、受け入れ確認 2〜17 を実際に確かめる（4・13〜16 は、失敗するはずの状態を作って確かめ、元に戻す）。`engines.node` と `.ai/environment.md` §3.1 の主版がそろっていることも確かめる（17）。
- **13・14（行はあるが動かして確かめていない）**: 行は `check.sh` の 12〜15 行目（node がないとき「node がない: 検証の環境に Node.js 26 を入れる（package.json の engines.node）」と出して終了コード 1）と `prepare.sh` の 12〜15 行目（`package-lock.json` がないとき ADR-0103 を示して終了コード 1）にある。`package.json` がないため、動かして確かめていない。
  - 片付く条件: 上の手順 3。
- **CI の定義**: このチケットの受け入れ確認ではない（ADR-0105 の D4）。段を足すのはマスターで、秘書は `package.json` を入れる前に伝える（ADR-0105 の D2、`.ai/environment.md` §5）。段があるかは YGO-070 の受け入れ確認 1 と `.ai/gaps.md` の G-079 で追う。
  段がないまま `package.json` を入れると、CI では `node_modules/` がないとして `check.sh` が失敗する（受け入れ確認 4 の形、ADR-0105 の D3）。`check.sh` に依存の取り込みを足して避けない。
- **1**: 上の 7・11・17 と、それに依る確認が片付くまで `open`。
