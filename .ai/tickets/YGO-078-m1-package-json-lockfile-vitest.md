# YGO-078 M1 の package.json とロックファイルで Vitest を動かす
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
YGO-062 が作ったテストの土台（`scripts/prepare.sh`・`check.sh` の Node.js とロックファイルの段と Vitest の段・`vitest.config.ts`・TC-033 のテスト）に、
`package.json` とロックファイルを入れて、`check.sh` から Vitest を実際に動かし、JUnit XML を `test-results/junit.xml` に書かせる。
YGO-062 から分けた理由は、YGO-062 の「分けた理由」の節に書いた（ADR-0103 の D2）。

## 依存
- YGO-062（`.ai/tickets/YGO-062-m1-test-harness.md`）が `状態: done`。
- ジョブが `npm` のコマンド（`npm --version`・`npm install --package-lock-only --ignore-scripts`）と `sh scripts/prepare.sh`・`sh scripts/check.sh` を動かせること（`.ai/environment.md` §5 の「ジョブがコマンドを動かす権限」・`.ai/gaps.md` の G-080）。
- 秘書は、このチケットの実装（`package.json` を入れる変更）の前に、CI の定義に `sh scripts/prepare.sh` の段を `sh scripts/check.sh` の前に足すことをマスターに伝える（ADR-0105 の D2・G-079）。段ができるのは待たない。

## 確かめた事実（変更 20261127-e16545 の時点）
- ある: `scripts/check.sh`（`package.json` があるときだけ動く Node.js とロックファイルの段、`package.json` があるときだけ動く Vitest の段、このチケットが `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する段）・`scripts/prepare.sh`・`vitest.config.ts`・`src/app.ts`・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`・`.gitignore` の `node_modules/` と `test-results/` の行。
- ない: `package.json`・`package-lock.json`。そのため `check.sh` の Node.js とロックファイルの段と Vitest の段は動かず、`test-results/` はできない。
- ジョブの環境: 変更 20261127-edc14e では `node -v` が `v26.13.1` で、npm のコマンドは権限で拒まれた。変更 20261127-e16545 の実装のジョブでは、コマンドを動かす道具そのものが権限で拒まれ、`node -v`・`npm -v`・`sh scripts/check.sh` のどれも動かなかった（同じ変更の計画の段階では `npm -v` が `11.20.0` を返し、既定の npm のキャッシュには書けず、`npm_config_cache` に一時ディレクトリを渡すとレジストリに届いた）。

## 範囲
- `package.json` を手で書く: `private: true`・`"type": "module"`・`"engines": {"node": "26.x"}`（主版は `.ai/environment.md` §3.1）。
  `dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node`。どの版も `^`・`~` を付けない固定の版で、実装の時点の安定版にし、`@types/node` は主版 26 のものにする `[assumed]`。`author`・`repository`・`license` は書かない `[assumed]`。
- ロックファイル: ADR-0103 の D1 のコマンド `npm install --package-lock-only --ignore-scripts` を引数なしで 1 回動かして作る（手で書かない）。npm のキャッシュがホームの下に書けないジョブでは `npm_config_cache` に一時ディレクトリを渡す `[assumed]`。できたファイルに絶対パスと非公開のレジストリの URL がないことを確かめる。作れなければ ADR-0103 の D2 のとおり、止まった段とエラーの行をこのチケットに書き、`package.json` も入れない。
- `sh scripts/prepare.sh` → `sh scripts/check.sh` を動かし、下の受け入れ確認を 1 つずつ確かめる。失敗するはずの状態は、確かめたら元に戻す。
- `.ai/environment.md`（§3.1 の `engines` の行・§5 の「ジョブがコマンドを動かす権限」・「マスターが用意するもの」の表の npm（ジョブ）の待つチケット）と `.ai/gaps.md` の G-080 を、入れたあとの状態に書き直す。

## 直さないところと理由
- CI の定義（`.github/`）: ジョブが書いてよい範囲の外（CLAUDE.md）。CI の定義に `prepare.sh` の段があることの確かめは YGO-070 の受け入れ確認 1（ADR-0105 の D4）。CI が緑かは M1 の達成の確認で見る。
- `package.json` がないときにテストを飛ばす問題: YGO-072。
- 使い捨ての PostgreSQL: YGO-076。依存を足すたびにロックファイルを直す決定: YGO-075。
- `.ai/status.md`: 秘書が書く。
- 新しい OQ・新しい ADR は 0 件（ロックファイルは ADR-0103、CI の順は ADR-0105、道具の用意は OQ-086 の決定で決まっている）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-078 M1 の package.json とロックファイルで Vitest を動かす`・`状態: done`・`M: M1`。
2. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` が終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` ができる。
3. その XML に、名前に `TC-033` を含む `testcase` がちょうど 1 つあり、その中に `skipped`・`failure`・`error` の要素がない。
4. `node_modules/` がない状態で `sh scripts/check.sh` を動かすと、終了コードが 0 でなく、`prepare.sh` を動かすよう出す。
5. `package.json` の `dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node` があり、どの版にも `^`・`~` が付いていない。`package-lock.json` があり、中に絶対パス（`"/` で始まる値）と `registry.npmjs.org` 以外のレジストリの URL がない。
6. `package.json` の `engines.node` の主版と、`.ai/environment.md` §3.1 の Node.js の行の主版が同じ。
7. `package.json` の `engines.node` を別の主版にした状態で `sh scripts/check.sh` が終了コード 0 以外で終わり、要る主版と「検証の環境に Node.js」を含む文を出す。
8. `package-lock.json` を消した状態で `sh scripts/prepare.sh` と `sh scripts/check.sh` がどちらも終了コード 0 以外で終わる（ADR-0103 の D3）。
9. このチケットが `状態: done` のとき、`scripts/prepare.sh` を消した状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
10. TC-033 のテストを `test.skip` にした状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
11. この変更で `.github/` の下のファイルを足していない・変えていない。
12. `.ai/environment.md` の「マスターが用意するもの」の表の npm（ジョブ）の行の待つチケットが `—` で、§5 の「ジョブがコマンドを動かす権限」に、ジョブで npm が拒まれているという文が残っていない。`.ai/gaps.md` の G-080 の行が閉じた形（残りはない）になっている。
