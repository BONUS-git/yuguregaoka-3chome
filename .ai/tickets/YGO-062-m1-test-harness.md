# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の機能を実装するチケットが、それぞれ TC のテストを足すだけで済むように、テストを動かす土台を先に作る。
CI の定義（`.github/workflows/`）があり `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かすことの確かめは、このチケットに入れない。
同じ中身は YGO-070 の受け入れ確認 1 が確かめる（ADR-0105 の D4）。CI が緑かは M1 の達成の確認で見る。

## 確かめた事実
- ある:
  - `scripts/check.sh`: 最初の段で Node.js とロックファイルを確かめ（`package.json` があるときだけ。`node` がなければ「node がない: 検証の環境に Node.js <主版> を入れる（package.json の engines.node）」と出して終了コード 1）、文書の確認のあと Vitest を `npx --no-install vitest run` で動かし、`test-results/junit.xml` を確かめる（`package.json` があるときだけ）。このチケットが `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する。ネットワークを使うコマンドはない。
  - `scripts/prepare.sh`: `npm ci --no-audit --no-fund` だけを動かす。`package.json` がなければ終了コード 0、`package-lock.json` がなければ 1、`npm` がなければ 1。
  - `vitest.config.ts`（報告は `default` と `junit`、出力は `test-results/junit.xml`）・`src/app.ts`（`buildApp()`）・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`（名前は `TC-033 …` で始まる。`skip`・`todo` でない）。
  - `.gitignore` の `node_modules/`（7 行目）と `test-results/`（13 行目）の行。
- ない: `package.json`・`package-lock.json`。そのため今の `check.sh` は Node.js とロックファイルの段と Vitest の段を飛ばし、`check: ok` は Vitest の土台が動くことの裏付けではない。
- ジョブの環境（変更 20261127-edc14e の時点）: `node -v` は `v26.13.1`（主版 26、`engines.node` の `26.x` と合う）。`npm` のコマンド（`npm -v`・`npm install --package-lock-only --ignore-scripts`）と `sh scripts/prepare.sh` は、ジョブの権限で拒まれて動かない（エラーの行は「確かめた結果」の節）。動かせたのは `node -v` と `sh scripts/check.sh` だけ。
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
使い捨ての PostgreSQL（`.ai/environment.md` §4.1 の 4・5、§4.4）は YGO-076 に回す。
M0 の残り（`scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み）は M0 の別のチケットに回す（「直さないところ」）。
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
    §4.1 の 4〜5（使い捨ての PostgreSQL・ひな型のデータベース）は、YGO-076 で足すものとして残す。
    §4.1 の 3（型の検査と lint）は、M1 の TC が依存しないため M1 のチケットにせず、`.ai/environment.md` §4.1 の 3 として残す `[assumed]`（M1 の TC はどれも型の検査と lint の結果を確かめない）。
  - §3.1 の `engines` の行は、`package.json` に書いた主版と食い違わないようにする。§3.2 の 2 以降（`dev-db.sh`・`.local/`）は M0 の別のチケットで作るものとして残す。
- 地図 `.ai/INDEX.md` と食い違うところがあれば同じ変更で直す（`.ai/` の外のファイルは地図に載せない）。

## 直さないところと理由
- CI の定義（`.github/`）: ジョブが書いてよい範囲の外（CLAUDE.md は `check.yml` を秘書の決まった形の名前とし、ジョブは書かない・変えないとする）。足すのはマスター（`.ai/environment.md` §5）。
  その定義があり `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かすことは、YGO-070 の受け入れ確認 1 で確かめる（ADR-0105 の D4）。
  CI の結果（緑かどうか）は、M1 の達成の確認で見る。
- 前提: この土台は、CI が `prepare.sh` → `check.sh` の順に動かす形（ADR-0105 の D1）であることを前提にする。CI が `check.sh` だけを動かすと、`node_modules/` がなく `check.sh` は失敗する（受け入れ確認 4、ADR-0105 の D3）。
- 使い捨ての PostgreSQL の起動と片付け（§4.1 の 4・5、§4.4）: YGO-076 で、初めて DB を使う TC（TC-005、YGO-065）より前に足す。
- `scripts/dev-db.sh`・時計・アダプタ・2 プロセスの骨組み・キュー・`APP_ENV` と環境変数の読み込み（`roadmap.md` §4 の M0 の行の残り）: M0 の別のチケットで足す。
- 型の検査と lint（§4.1 の 3）: このチケットでは足さない。M1 の TC が依存しないため、M1 のチケットにもしない `[assumed]`。
- M1 の FR の機能の実装: 別のチケットで 1 つずつ。
- `.ai/status.md`: 秘書が書くもので、ジョブは変えない。
- 新しい OQ・要回答は 0 件（道具は ADR-0009 と ADR-0052、ロックファイルは ADR-0103、CI の順と `prepare.sh` の段を足す人は ADR-0105、Node.js を入れるのは OQ-086 で決まっている。版や設定の細部は `[assumed]`）。
- 新しい ADR は 0 件。ADR-0105 を丸ごと置き換える ADR（`.ai/gaps.md` の G-081 の予定）は、このチケットが `状態: done` になったあと、題に G-081 を付けた別のチケットで作る（「残り」の「このチケットの外に分けるもの」）。

## 受け入れ確認
CI の定義（`.github/workflows/`）の項目は入れない。CI の定義はジョブが書かない・変えないファイルで（CLAUDE.md）、ここに入れると実装の変更で `done` にできないため。受け持つのは YGO-070 の受け入れ確認 1（ADR-0105 の D4）。

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
11. `.ai/environment.md` §3.1・§3.2・§4.1 の「M0 で」の記述が、このチケットで作ったものと食い違わない: §3.1 の `engines` の主版が `package.json` と同じで、§3.2 の `dev-db.sh`・`.local/` は M0 で足すもの、§4.1 の 4〜5 は YGO-076 で足すもの、§4.1 の 3 は M1 のチケットにしないものとして残り、作ったと書かれていない。
12. このチケットの「範囲」に、`roadmap.md` §4 の M0 の行のうち作るもの（Vitest を `check.sh` からつなぐ・`prepare.sh`）と、YGO-076 に回すもの（使い捨ての PostgreSQL）と、M0 の別のチケットに回すもの（`dev-db.sh`・時計・アダプタ）が書かれている。
13. `scripts/check.sh` の最初の段で、`node` のコマンドがあるかと、その主版が `package.json` の `engines.node` と合うかを確かめる。足りなければ、要る主版と「検証の環境に Node.js を入れる」ことが分かる文を出して、終了コード 0 以外で止まる（`.ai/retros.md` の変更 20261126-380a19 の節）。
14. `package-lock.json` を消した状態で `sh scripts/prepare.sh` と `sh scripts/check.sh` がどちらも終了コード 0 以外で終わる（ADR-0103 の D3）。
15. このチケットが `状態: done` のとき、`scripts/prepare.sh` を消した状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
16. TC-033 のテストを `test.skip` にした状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
17. `package.json` の `engines.node` の主版と、`.ai/environment.md` §3.1 の Node.js の行の主版が同じ。

## 残り
満たさない受け入れ確認が残るため `状態: open` のままにする。項目ごとの結果は末尾の「確かめた結果」の節。

- YGO-070・YGO-075・YGO-076 を待つ受け入れ確認はない。未了はどれも `.ai/gaps.md` の G-080（ジョブの環境で npm が動くこと）を待つ。
- CI の段は待たない: `package.json` に頼る未了の項目（2〜4・7・11・13〜17）は、CI の定義の `sh scripts/prepare.sh` の段（G-079）ができるのを待たない。ADR-0105 の D2 が決めるのは、秘書が `package.json` を入れる前に、その段を足すことをマスターに「伝える」ことで、段ができるまで `package.json` を入れないとはしていない。`.ai/environment.md` §5.1 の表のこの段の行の「伝える時」の列（`package.json` を入れる前）も、伝える時期を書いたもので同じ意味。受け入れ確認はどれも手元で `prepare.sh` → `check.sh` を動かして確かめ、CI の定義の確かめと CI が緑かはこのチケットに入れない（ADR-0105 の D4。緑かは M1 の達成の確認で見る）。
- 止まった段（ADR-0103 の D2）: 段 0 の npm の半分（`npm -v` で npm 11 を確かめる）と段 2（D1 のコマンド）。`node -v` は `v26.13.1` で通った。npm のコマンドはどれも、ジョブの権限で拒まれた（エラーの行は「確かめた結果」の節。変更 20261127-edc14e の時点）。
- この変更の時点の `sh scripts/check.sh`: 終了コード 0・`check: ok`。`package.json` がないため 1 の段（9〜44 行目）と 6 の段（171〜184 行目）は動かず、TC-NNN の名前・`test-results/` の JUnit XML・skip 0 件は確かめられていない（`test-results/` はできない）。
- `package.json` も入れない: ロックファイルは手で書けず（ADR-0103 の D2）、`package.json` だけを入れると `check.sh` の最初の段（21〜24 行目）が `package-lock.json` がないとして失敗し、それ以降の変更がマージできなくなる。
- 前提（秘書がジョブの実行の設定で `npm` のコマンドと `sh scripts/prepare.sh` を許すこと。`.ai/environment.md` §5 の「ジョブがコマンドを動かす権限」・G-080）が済むまで、このチケットの残りを閉じる指示をもう一度出さない。node は動くが npm を動かす権限がなく、出し直しても同じ結果になる。権限のあとで `npm --version` が npm がないと出たときだけ、道具の用意（マスター、OQ-086 → 決定、§5.1 の表の npm（ジョブ）の行）を待つ。
- 重なるところ: CI の定義の `prepare.sh` の段は YGO-070、`package.json` がないときにテストを飛ばす問題は YGO-072、使い捨ての PostgreSQL は YGO-076、依存を足すたびにロックファイルを直す決定は YGO-075 で扱う。
- なぜ残るか: ロックファイルは手で書かない（ADR-0103 の D2）。`package.json` だけを入れると、`check.sh` の最初の段がロックファイルがないとして失敗し、検証が通らない。
- 片付く条件: ジョブが npm のコマンドと `sh scripts/prepare.sh` を動かせ（権限は秘書のジョブの実行の設定、G-080）、`npm --version` が主版 11 を返す（npm がなければ道具の用意はマスター、OQ-086 の決定。新しい OQ は立てない）。秘書は `package.json` を入れる前に、CI の定義に `prepare.sh` の段を足すことをマスターに伝える（ADR-0105 の D2。段があるかは YGO-070 の受け入れ確認 1 と `.ai/gaps.md` の G-079 で追う）。そのあと、次の順に進める:
  1. `package.json` を手で書く: `private`・`"type": "module"`・`"engines": {"node": "26.x"}`（主版は `.ai/environment.md` §3.1）。`dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node`。どの版も `^`・`~` を付けない固定の版で、実装の時点の安定版にし、`@types/node` は主版 26 のものにする `[assumed]`。
  2. ADR-0103 の D1 のコマンドを引数なしで 1 回動かす: `npm install --package-lock-only --ignore-scripts`。版が見つからないと出たら、`package.json` の版を直して同じコマンドを動かす。
  3. `sh scripts/prepare.sh` → `sh scripts/check.sh` を動かし、受け入れ確認 2・3 を確かめる。`engines.node` と `.ai/environment.md` §3.1 の主版がそろっていることを確かめる（11・17）。
  4. 失敗するはずの状態を作って確かめ、そのたびに元に戻す: `node_modules/` を消す（4）、`engines.node` を別の主版にする（13）、`package-lock.json` を消す（14）、状態を `done` にして `scripts/prepare.sh` を消す（15）、TC-033 を `test.skip` にする（16）。
  5. すべて確かめたら `状態: done` にして、この節を消す。
- このチケットの外に分けるもの: ADR-0105 の置き換え・YGO-070 の取り下げ・G-079 の閉じる条件の書き換え（`.ai/gaps.md` の G-081 の予定）は、このチケットの変更に入れない。このチケットの範囲には道具の追加（`package.json`・依存・ロックファイル）が入っており、ADR の置き換えも入れると 2 つの種類の作業を 1 つの変更が負うため。このチケットが `状態: done` になったあと、題に G-081 を付けた別のチケットで行う。そのチケットは、このチケットが done になった次の変更で切る（今は始められず、待つだけのチケットになるため、今は切らない）。

## 確かめた結果
受け入れ確認を 1 項目ずつ、今のファイルと照らした結果（変更 20261127-edc14e の時点）。結果は「済み」か「未了」だけを書く。行が書いてあっても、動かして確かめていない項目は「未了」とする。

| 番号 | 結果 | 確かめたところ | 待つ先 |
|---|---|---|---|
| 1 | 未了 | このファイルの 1・3 行目は合う。2 行目が `状態: open`（ほかの未了が片付くまで） | G-080 |
| 2 | 未了 | `package.json` がなく、`check.sh` の 171 行目の段が Vitest を動かさない。`sh scripts/prepare.sh` はジョブの権限で拒まれ動かせない。`sh scripts/check.sh` は終了コード 0・`check: ok` だが `test-results/` はできない | G-080 |
| 3 | 未了 | 2 と同じ（XML ができない） | G-080 |
| 4 | 未了 | `check.sh` の 172 行目に、`node_modules/` がなければ `prepare.sh` を動かすよう出して終了コード 1 の行がある。171 行目の `package.json` の条件の中にあり、動かして確かめていない | G-080 |
| 5 | 済み | `check.sh` の全行にネットワークを使うコマンドがなく、174 行目が `npx --no-install vitest run` | — |
| 6 | 済み | `prepare.sh` の 20 行目が `npm ci --no-audit --no-fund` | — |
| 7 | 未了 | `package.json`・`package-lock.json` がない。D1 のコマンド `npm install --package-lock-only --ignore-scripts` はジョブの権限で拒まれた | G-080 |
| 8 | 済み | `.gitignore` の 7 行目 `node_modules/`・13 行目 `test-results/` | — |
| 9 | 済み | この変更は `.github/` に触れていない（レポジトリに `.github/` がない） | — |
| 10 | 済み | `.ai/environment.md` に 2 つの文がなく（検索で 0 件）、§4.1 の 6（112 行目）に `test-results/junit.xml` がある | — |
| 11 | 未了 | §3.1（46 行目）の主版 26 と比べる `package.json` がない | G-080 |
| 12 | 済み | このチケットの「範囲」の節（31〜34 行目） | — |
| 13 | 未了 | `check.sh` の 9〜20 行目に行がある（node がないとき 12〜15 行目、主版が違うとき 17〜20 行目で終了コード 1）。ジョブの `node -v` は `v26.13.1`。`package.json` がないので段が動かず、確かめていない | G-080 |
| 14 | 未了 | `prepare.sh` の 12〜15 行目と `check.sh` の 21〜24 行目に行がある（`package-lock.json` がないとき ADR-0103 を示して終了コード 1）。動かして確かめていない | G-080 |
| 15 | 未了 | `check.sh` の 161〜167 行目に行がある（`状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗）。動かして確かめていない | G-080 |
| 16 | 未了 | `check.sh` の 178〜181 行目に行がある（XML に `<skipped` があれば失敗）。動かして確かめていない | G-080 |
| 17 | 未了 | `package.json` がない | G-080 |

- 動かしたコマンドと結果: `sh scripts/check.sh` → 終了コード 0・`check: ok`。`node -v` → `v26.13.1`。
  `npm -v`・`npm install --package-lock-only --ignore-scripts`・`sh scripts/prepare.sh` → どれも動かず、エラーの行は
  `Permission to use Bash has been denied because Claude Code is running in don't ask mode.`
- YGO-070・YGO-072・YGO-076 と範囲が重なる受け入れ確認はない（CI の定義の項目は初めから入れていない）。未了の項目はどれも npm が動けば 1 回の変更に収まるので、YGO-062 の範囲から外さない。
