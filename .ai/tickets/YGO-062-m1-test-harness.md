# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の機能を実装するチケットが、それぞれ TC のテストを足すだけで済むように、テストを動かす土台を先に作る。

## 確かめた事実
- ある（このチケットで作った）:
  - `scripts/check.sh`: 最初の段で Node.js とロックファイルを確かめ（`package.json` があるときだけ）、文書の確認のあと Vitest を `npx --no-install vitest run` で動かし、`test-results/junit.xml` を確かめる（`package.json` があるときだけ）。このチケットが `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する。
  - `scripts/prepare.sh`: `npm ci --no-audit --no-fund` だけを動かす。`package.json` がなければ終了コード 0、`package-lock.json` がなければ 1、`npm` がなければ 1。
  - `vitest.config.ts`（報告は `default` と `junit`、出力は `test-results/junit.xml`）・`src/app.ts`（`buildApp()`）・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`（名前は `TC-033 …` で始まる。`skip`・`todo` でない）。
  - `.gitignore` の `test-results/` と `node_modules/` の行。
- ない: `package.json`・`package-lock.json`。そのため今の `check.sh` は Node.js とロックファイルの段と Vitest の段を飛ばし、`check: ok` は Vitest の土台が動くことの裏付けではない。
- `.github/` はない。CI の設定は秘書の `.github/workflows/check.yml` で、足すのはマスター（CLAUDE.md・`.ai/environment.md` §5・§10.1）。
- 秘書の CI が `check.sh` の前に `prepare.sh` を動かすかどうかは、このレポジトリからは確かめられない。CLAUDE.md は「push のたびに `scripts/check.sh` を動かす」とだけ書き、`prepare.sh` には触れていない。`.github/workflows/check.yml` はこのレポジトリにない。
- ADR-0009: TypeScript・Fastify・Vitest。
- ADR-0052 の D3・`.ai/environment.md` §3.2・§4.1・§5: `prepare.sh` は npm の依存だけを入れ（`npm ci`）、OS の道具は入れない。CI は `prepare.sh` → `check.sh` の順に動かす。
- `.ai/roadmap.md` §4 の M0 の行: M0 の内容に「Vitest を `check.sh` からつなぐ」があり、ほかに 2 プロセス（web / worker）の骨組み・PostgreSQL とキュー・C3 の空の形・時刻を外から差し替えられる時計・アダプタ・`scripts/dev-db.sh`・`check.sh` の使い捨ての PostgreSQL・`APP_ENV` と環境変数の読み込みがある。
  `.ai/environment.md` §3.1（`engines` を M0 で書く）・§3.2（`prepare.sh` を M0 で作る）・§4.1（M0 で `check.sh` を広げる）も、この土台を M0 のものとしている。
- `.ai/tests/test-plan.md`: テストの名前の頭に `TC-NNN …` を書く決まりがある。TC-033（FR-092、単体）は「ルートの一覧に OAuth と WebAuthn の経路がない」。M1 の TC のうち、DB も FR の機能もなしで確かめられるのはこれだけ。
  ファイルの名前は `test_TC_001_…` の形にする決まりもある。
- ADR-0103: D1 最初のロックファイルは依存を変える変更の中で `npm install --package-lock-only --ignore-scripts` を 1 回試して作り、`package.json` と同じ変更に入れる。D2 作れなければロックファイルを手で書かず、止まった段とエラーの行をここに書き、それまでの段のファイルを出す。D3 `prepare.sh` はロックファイルを作らない。
- **止まった段（ADR-0103 の D2）**: 段 2 の `package.json` とロックファイルの作成。このジョブで `command -v node npm` を動かそうとすると、コマンドを動かすこと自体が許されず（`Permission to use Bash has been denied`）、node と npm があるかも確かめられなかった。そのため D1 のコマンド（`npm install --package-lock-only --ignore-scripts`）も `sh scripts/prepare.sh` も `sh scripts/check.sh` も、このジョブでは動かしていない。
- **残っている重大の指摘 R3-F1**（4ca88b22 の見直し）: 片付いていない。段 2 の `package.json` と `package-lock.json` がなく、Vitest の段が一度も動いていない。node と npm のない環境では、この 2 つを作れない（ロックファイルは手で書かない。ADR-0103 の D2）。片付ける条件は、主版 26 の node と npm がある環境で、下の手順の 1〜3 を進めること。
  - そのため `package.json` と `package-lock.json` はこの変更に入れない。ロックファイルは手で書かない（D2）。`package.json` だけを入れると、`check.sh` が最初の段で node がないとして失敗し、検証が通らない。
  - 前提: OQ-086 の決定のとおり、主版 26 の Node.js（npm を含む）を秘書の実装のジョブ・検証・CI の環境に入れるのはマスター。新しい OQ は立てない。
  - 残るのは段 2 と受け入れ確認だけ。node（主版 26）と npm があり、D1 のコマンド・`prepare.sh`・`check.sh` を動かせる環境で、次の順に進める:
    1. `package.json` を手で書く: `private`・`"type": "module"`・`"engines": {"node": "26.x"}`（主版は `.ai/environment.md` §3.1）。`dependencies` に `fastify`（実行時に要る）、`devDependencies` に `vitest`・`typescript`・`@types/node`（テストと型だけに要る）。どの版も `^`・`~` を付けない固定の版にする。版は、実装の時点の安定版で、`@types/node` は主版 26 のものにする `[assumed]`。
    2. ADR-0103 の D1 のコマンドを引数なしで 1 回動かす: `npm install --package-lock-only --ignore-scripts`。パッケージの名前を引数に付けない（`package.json` を書き換えず、依存の種類を変えないため）。版が見つからないと出たら、`package.json` の版を直して同じコマンドを動かす。
    3. `sh scripts/prepare.sh` と `sh scripts/check.sh` を動かし、受け入れ確認 1〜17 を実際に確かめる（4・13〜16 は、失敗するはずの状態を作って確かめ、元に戻す）。すべて通ってから `状態: done` にし、`check.sh` をもう一度動かす。
    - `engines.node` を書いたら `.ai/environment.md` §3.1 の Node.js の行と主版がそろっていることを確かめる（受け入れ確認 17）。
- **受け入れ確認の今の状態**（ファイルを読んで突き合わせた。このジョブではコマンドを動かせず、`check.sh` の結果は秘書の検証で確かめる）:
  - ファイルの事実で満たす: 5（`check.sh` にネットワークのコマンドがなく `npx --no-install vitest run`）・6（`prepare.sh` が `npm ci`）・8（`.gitignore` の 13 行目と 7 行目）・9（`.github/` はない）・10（`.ai/environment.md` に 2 つの語がなく、§4.1 の 6 に `test-results/junit.xml`）・12（「範囲」の節）。
  - 確かめる行は `check.sh`・`prepare.sh` にあるが、`package.json` がないため動かして確かめていない: 13〜16。
  - 満たさない: 1（2 行目が `open`）・2・3（Vitest が動かない）・4（`package.json` がないと Vitest の段に入らない）・7・11・17（`package.json` がない）。§3.1 の主版は 26 に決めてあり、`package.json` を `26.x` で書けば 11・17 はそろう。
  - ワークフローのファイルがないため、この変更では確かめられない: CI が緑になることと、CI が `prepare.sh` → `check.sh` の順に動かすこと（指示の確かめる点。受け入れ確認 1〜17 には入れていない）。理由: CI の設定は秘書の `.github/workflows/check.yml` で、ジョブは書かず、足すのはマスター（CLAUDE.md・NFR-091・`.ai/environment.md` §5）。ファイルがない間は、マージのあとでも CI は動かない。

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
- `.gitignore`: `test-results/` の行を足す（`node_modules/` の行はすでにある）。
- 例のテスト（TC の名前の決まりの例）:
  - `src/app.ts` に、経路を持たない Fastify のアプリを返す `buildApp()` を置く。
  - `test/test_TC_033_no_oauth_webauthn_routes.test.ts` を 1 つ足す（`test-plan.md` のファイルの名前の決まり）。テストの名前は `TC-033 …` で始め、
    `buildApp()` のルートの一覧（`printRoutes()` など）に `oauth`・`webauthn` を含む経路がないことを確かめる。ポートは開かない。
  - `skip`・`todo` にしない。
- `.ai/environment.md` を今の状態に合わせて書き直す:
  - §3.2 の「`prepare.sh` は今のレポジトリになく、依存を足す M0 で作る」を消し、`prepare.sh` が `npm ci` を動かすことを書く。
  - §4.1 の「今の `check.sh` は文書の確認だけ」を、文書の確認と Vitest を動かすことに書き直し、JUnit XML の出力先 `test-results/junit.xml` を足す。§4.1 の 1（Node.js の確かめ）は作ったものとして書く。
    §4.1 の 3〜5（型の検査と lint・使い捨ての PostgreSQL・ひな型のデータベース）は、M0 の別のチケットで足すものとして残す。
  - §3.1 の `engines` の行は、`package.json` に書いた主版と食い違わないようにする。§3.2 の 2 以降（`dev-db.sh`・`.local/`）は M0 の別のチケットで作るものとして残す。
- 地図 `.ai/INDEX.md` と食い違うところがあれば同じ変更で直す（`.ai/` の外のファイルは地図に載せない）。

## 直さないところと理由
- CI の workflow（`.github/`）: CLAUDE.md・`.ai/environment.md` §5・§10.1 のとおり、CI の設定はジョブが書かない（秘書の `check.yml`、足すのはマスター）。
  CI の形（`prepare.sh` → `check.sh`）は §5 の計画のまま。
- 前提: この土台は、CI が `prepare.sh` → `check.sh` の順に動かす形であることを前提にする。CI が `check.sh` だけを動かすと、`node_modules/` がなく `check.sh` は失敗する（受け入れ確認 4）。
  CI の形を決めるのは秘書かマスターで、ジョブは確かめも変えもできないため、OQ にせず前提として書く。
  CI がその形になるまで、「CI が緑」はこのチケットの受け入れ確認に入れない（受け入れ確認は `check.sh` をローカルで動かした結果とファイルの中身だけ）。
  CI のワークフローのファイルはこのレポジトリになく（`.github/` は変更禁止）、ジョブはその中身も確かめられない。マスターが `.ai/environment.md` §5 の形で `.github/workflows/check.yml` を足したあとに、秘書が CI の緑と `prepare.sh` → `check.sh` の順を確かめる。
- 使い捨ての PostgreSQL の起動と片付け（§4.1 の 4・5、§4.4）: `roadmap.md` §4 の M0 の別のチケットで、初めて DB を使う TC より前に足す。
- `scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み（`roadmap.md` §4 の M0 の行の残り）: M0 の別のチケットで足す。
- 型の検査と lint（§4.1 の 3）: このチケットでは足さない。
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
