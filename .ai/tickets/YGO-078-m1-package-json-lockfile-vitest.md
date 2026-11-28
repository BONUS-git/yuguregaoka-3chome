# YGO-078 G-082 M1 の package.json とロックファイルで Vitest を動かす
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
YGO-062 が作ったテストの土台（`scripts/prepare.sh`・`check.sh` の Node.js とロックファイルの段と Vitest の段・`vitest.config.ts`・TC-033 のテスト）に、
`package.json` とロックファイルを入れて、`check.sh` から Vitest を実際に動かし、JUnit XML を `test-results/junit.xml` に書かせる。
YGO-062 から分けた理由は、YGO-062 の「分けた理由」の節に書いた（ADR-0106 の D2）。
`.ai/gaps.md` の G-082（YGO-078 の出し直しと R-074 の書き直し）も、ADR-0109 の D8・D11 によりこのチケットで追う。

## 依存
- YGO-062（`.ai/tickets/YGO-062-m1-test-harness.md`）が `状態: done`。
- 実装のジョブで次が許されていること: Bash・`node -v`・`npm --version`・`npm_config_cache` を付けた `npm install --package-lock-only --ignore-scripts`・`sh scripts/prepare.sh`・`sh scripts/check.sh`（`.ai/environment.md` §5 の「ジョブがコマンドを動かす権限」・`.ai/gaps.md` の G-080）。
- CI の定義（秘書の `check.yml`）の `sh scripts/prepare.sh` の段は秘書が置く（ADR-0109 の D2・G-079）。このチケットは段ができるのを待たない。

## 確かめた事実（変更 20261127-19ab3d の時点）
- 前提: YGO-062 は `状態: done`。YGO-065 は YGO-073 で分けられ（`addresses`・`tenancies` と TC-005）、このチケットは依存しない。このチケットが YGO-072・YGO-080 の依存で、逆ではない。
- develop（32eaab4）に `package.json`・`package-lock.json` はない（ファイルの一覧で確かめた）。前の 5 回の変更（20261127-5812ca・20261127-54c015・20261127-6b7da1・20261127-19e8fa（34c1427）・20261127-e33c31（31d9315））が変えたのは `.ai/` の文書と `scripts/prepare.sh`・`scripts/check.sh` の注記だけで、どれも実装のジョブで Bash が拒まれて止まった記録だった。`prepare.sh` にはロックファイルを作るコマンドと ADR-0106 の D1・D2 を指す注記があり、`scripts/` に置き換え済みの ADR-0103 の参照は残っていない。
- 受け入れ確認ごとの状態（この変更の実装のジョブで確かめたことだけで数える）: 済みは 11（`.github/` は変えていない）だけ。4・7・8・9・10 は、確かめる `check.sh`・`prepare.sh`・TC-033 のテストはあるが、この変更ではどれも動かせておらず未確認。1・2・3・5・6・12 は残り。レポジトリの外で試した結果は、レポジトリから再現できないので、どの受け入れ確認の確かめにも数えない。
- ある（ファイルの一覧で確かめた）: `scripts/check.sh`・`scripts/prepare.sh`・`vitest.config.ts`・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`。
- ない: `package.json`・`package-lock.json`。そのため `check.sh` の Node.js とロックファイルの段と Vitest の段は動かず、`test-results/` はできない。
- 入れる予定の版（実装の時点で `npm view` で確かめ直す。まだ確かめた値ではない）: `dependencies` に fastify 5.12.8、`devDependencies` に @types/node 26.6.11・typescript 7.0.2・vitest 5.1.2、`engines.node` は `26.x`。

## 止まっている理由（変更 20261127-19ab3d の時点）
- 止まった段（ADR-0106 の D2）: ロックファイルの作成。実装のジョブではコマンドを動かす道具（Bash）が拒まれる。この変更の実装のジョブでは、見直しの 1 回目・2 回目のあとの出し直しでも、最初の呼び出し（`git log`・`git status`・`node -v`・`npm --version` を動かすコマンド）で拒まれ、`npm`・`node`・`sh scripts/prepare.sh`・`sh scripts/check.sh` のどれも動かせなかった。出たエラーの行: `Permission to use Bash has been denied because Claude Code is running in don't ask mode.`。同じ段で止まったのは 6 回目（20261127-5812ca・20261127-54c015・20261127-6b7da1・20261127-19e8fa・20261127-e33c31・この変更）。指示の計画によれば、どの回も計画の段階では npm が動いた。
- ロックファイルは手で書かない（範囲・ADR-0106 の D1）ため、`package.json` も入れず、状態は `open` のまま。
- 外の用意がないと満たせない確認: 2・3（`prepare.sh` と Vitest が動かない）・5（ロックファイルを作れない）・4・7・8・9・10（`package.json` がないと段が動かない）・6・12（入れたあとの状態に書き直す相手がない）・1（ほかが満たせない）。
- 要る外の用意（2 つ）: 31d9315 の見直しの指摘（重大 R3-F1 と中）の本文をジョブの指示に入れる（下の「31d9315 の見直しの指摘」の節）。秘書が実装のジョブの設定で、Bash・`node -v`・`npm --version`・`npm_config_cache` を付けた `npm install --package-lock-only --ignore-scripts`・`sh scripts/prepare.sh`・`sh scripts/check.sh` を許す（G-080）。計画の段階で許されていても、実装の段階で許されていなければ同じところで止まる。許されるまで、このチケットを実装のジョブに出し直しても変更は進まない（G-082）。
- 許されたら: 範囲のとおりに `package.json` を書き（`name: "yuguregaoka"`・`version: "0.0.0"` を足す `[assumed]`。書かないとロックファイルの `name` に作業のディレクトリの名前が入る）、ロックファイルを作り、受け入れ確認を 1 つずつ確かめる。

## 31d9315 の見直しの指摘（変更 20261127-19ab3d の時点）
- 出どころ: YGO-078 の最後のマージ 31d9315（変更 20261127-e33c31）の見直し。この変更の指示が「最後の見直しで R3-F1 が残った」と書き、YGO-078 を対象にしたマージの最後が 31d9315 であることから決めた。`git log` はこの変更の実装のジョブで動かせず、ログでは確かめていない。
- 重大 R3-F1: 未解決。本文はレポジトリにも指示にもない。この変更の指示は「チケットの本文と実際のファイル（`package.json`・ロックファイル・`check.sh`）の食い違いだと考えられる」と書いているだけで、これは指示からの推測であり、見直しの原文で確かめた中身ではない。閉じるのは、`package.json` とロックファイルを入れ、このチケットの本文を実際のファイルに合わせる変更。
- 中の指摘: 本文はレポジトリにも指示にもない。未解決。

## 範囲
- `package.json` を手で書く: `private: true`・`"type": "module"`・`"engines": {"node": "26.x"}`（主版は `.ai/environment.md` §3.1）。
  `dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node`。どの版も `^`・`~` を付けない固定の版で、実装の時点の安定版にし、`@types/node` は主版 26 のものにする `[assumed]`。`author`・`repository`・`license` は書かない `[assumed]`。
- ロックファイル: ADR-0106 の D1 のコマンド `npm install --package-lock-only --ignore-scripts` を引数なしで 1 回動かして作る（手で書かない）。npm のキャッシュがホームの下に書けないジョブでは `npm_config_cache` に一時ディレクトリを渡す `[assumed]`。できたファイルに絶対パスと非公開のレジストリの URL がないことを確かめる。作れなければ ADR-0106 の D2 のとおり、止まった段とエラーの行をこのチケットに書き、`package.json` も入れない。
- `sh scripts/prepare.sh` → `sh scripts/check.sh` を動かし、下の受け入れ確認を 1 つずつ確かめる。失敗するはずの状態は、確かめたら元に戻す。
- `.ai/environment.md`（§3.1 の `engines` の行・§5 の「ジョブがコマンドを動かす権限」・「マスターが用意するもの」の表の npm（ジョブ）の待つチケット）と `.ai/gaps.md` の G-080 を、入れたあとの状態に書き直す。
- R-074（G-082）: このチケットを次に出す変更で、「31d9315 の見直しの指摘」の節の推測の部分を消し、指示に渡された見直しの原文だけを書く `[assumed]`。
- `.ai/gaps.md` の G-082 の行を、閉じる条件（G-080 が閉じ、このチケットが `状態: done`）を満たした変更で閉じる（理由の列に済んだことと「残りはない」、出どころの列に `（YGO-078）`）。

## 直さないところと理由
- CI の定義（`.github/`）: ジョブが書いてよい範囲の外（CLAUDE.md）。CI の定義に `prepare.sh` の段があることは、どのチケットの受け入れ確認にも入れず `.ai/gaps.md` の G-079 で追う（ADR-0109 の D4）。CI が緑かは M1 の達成の確認で見る。
- `package.json` がないときにテストを飛ばす問題: YGO-072。
- 使い捨ての PostgreSQL: YGO-076。依存を足すたびにロックファイルを直す決定: ADR-0106（YGO-075）。
- `.ai/status.md`: 秘書が書く。
- 新しい OQ・新しい ADR は 0 件（ロックファイルは ADR-0106、CI の順は ADR-0109、道具の用意は OQ-086 の決定で決まっている）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-078 G-082 M1 の package.json とロックファイルで Vitest を動かす`・`状態: done`・`M: M1`。
2. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` が終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` ができる。
3. その XML に、名前に `TC-033` を含む `testcase` がちょうど 1 つあり、その中に `skipped`・`failure`・`error` の要素がない。
4. `node_modules/` がない状態で `sh scripts/check.sh` を動かすと、終了コードが 0 でなく、`prepare.sh` を動かすよう出す。
5. `package.json` の `dependencies` に `fastify`、`devDependencies` に `vitest`・`typescript`・`@types/node` があり、どの版にも `^`・`~` が付いていない。`package-lock.json` があり、中に絶対パス（`"/` で始まる値）と `registry.npmjs.org` 以外のレジストリの URL がない。
6. `package.json` の `engines.node` の主版と、`.ai/environment.md` §3.1 の Node.js の行の主版が同じ。
7. `package.json` の `engines.node` を別の主版にした状態で `sh scripts/check.sh` が終了コード 0 以外で終わり、要る主版と「検証の環境に Node.js」を含む文を出す。
8. `package-lock.json` を消した状態で `sh scripts/prepare.sh` と `sh scripts/check.sh` がどちらも終了コード 0 以外で終わる（ADR-0106 の D3）。
9. このチケットが `状態: done` のとき、`scripts/prepare.sh` を消した状態で `sh scripts/check.sh` が終了コード 0 以外で終わる（YGO-072 のあとは、チケットの名前に依らない G-083 の段が同じ事実を確かめる）。
10. TC-033 のテストを `test.skip` にした状態で `sh scripts/check.sh` が終了コード 0 以外で終わる。
11. この変更で `.github/` の下のファイルを足していない・変えていない。
12. `.ai/environment.md` の「マスターが用意するもの」の表の npm（ジョブ）の行の待つチケットが `—` で、§5 の「ジョブがコマンドを動かす権限」に、ジョブで npm が拒まれているという文が残っていない。`.ai/gaps.md` の G-080 の行が閉じた形（残りはない）になっている。
13. このチケットの「31d9315 の見直しの指摘」の節に、「指示からの推測」「と考えられる」という推測の文がなく、書かれている指摘の中身は指示に渡された見直しの原文だけである（R-074）。
14. `.ai/gaps.md` の G-082 の行の理由の列に「残りはない」があり、出どころの列に `（YGO-078）` がある。
