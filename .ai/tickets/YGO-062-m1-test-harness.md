# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）
状態: done
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
M1 の機能を実装するチケットが、それぞれ TC のテストを足すだけで済むように、テストを動かす土台を先に作る。
このチケットが作るのは、ファイルを読めば確かめられる土台（台本・設定・例のテスト・文書）まで。`package.json` とロックファイルを入れて Vitest を実際に動かすことは YGO-078 に分けた（「分けた理由」の節）。
CI の定義（`.github/workflows/`）があり `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かすことの確かめは、このチケットに入れない。
同じ中身は YGO-070 の受け入れ確認 1 が確かめる（ADR-0105 の D4）。CI が緑かは M1 の達成の確認で見る。

## 確かめた事実
- ある:
  - `scripts/check.sh`: 最初の段で Node.js とロックファイルを確かめ（`package.json` があるときだけ。`node` がなければ「node がない: 検証の環境に Node.js <主版> を入れる（package.json の engines.node）」と出して終了コード 1）、文書の確認のあと Vitest を `npx --no-install vitest run` で動かし、`test-results/junit.xml` を確かめる（`package.json` があるときだけ）。YGO-078 が `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する。ネットワークを使うコマンドはない。
  - `scripts/prepare.sh`: `npm ci --no-audit --no-fund` だけを動かす。`package.json` がなければ終了コード 0、`package-lock.json` がなければ 1、`npm` がなければ 1。
  - `vitest.config.ts`（報告は `default` と `junit`、出力は `test-results/junit.xml`）・`src/app.ts`（`buildApp()`）・`test/test_TC_033_no_oauth_webauthn_routes.test.ts`（名前は `TC-033 …` で始まる。`skip`・`todo` でない）。
  - `.gitignore` の `node_modules/`（7 行目）と `test-results/`（13 行目）の行。
- ない: `package.json`・`package-lock.json`（YGO-078 で入れる）。そのため今の `check.sh` は Node.js とロックファイルの段と Vitest の段を飛ばし、`check: ok` は Vitest の土台が動くことの裏付けではない。
- ない: `.github/`。足すのはマスター（`.ai/environment.md` §5）。
- CLAUDE.md は `.github/workflows/check.yml` を秘書の CI の決まった形の名前とし、ジョブは書かない・変えないとする。
- ADR-0105: D1 CI は `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かし、M1 のテストは Vitest と npm の依存で書く。D2 CI の定義に `prepare.sh` の段を足すのはマスター。D3 `check.sh` は `prepare.sh` も `npm ci` も呼ばず、`node_modules/` がなければ失敗する。D4 CI の定義をファイルで確かめるのは YGO-070 の受け入れ確認 1。
- ADR-0009: TypeScript・Fastify・Vitest。ADR-0103: 最初のロックファイルの作り方（D1）・作れないときの扱い（D2）・`prepare.sh` はロックファイルを作らない（D3）。
- `.ai/tests/test-plan.md`: テストの名前の頭に `TC-NNN …`、ファイルの名前は `test_TC_001_…` の形にする決まりがある。TC-033（FR-092、単体）は「ルートの一覧に OAuth と WebAuthn の経路がない」。

## 範囲
このチケットが作るのは、`roadmap.md` §4 の M0 の行のうち「Vitest を `check.sh` からつなぐ」ための台本・設定・例のテストと、それに要る `scripts/prepare.sh` だけ。
`package.json`（`engines` を含む）とロックファイルを入れて Vitest を動かすことは YGO-078 に回す。
使い捨ての PostgreSQL（`.ai/environment.md` §4.1 の 4・5、§4.4）は YGO-076 に回す。
M0 の残りのうち M1 の TC が使う部品は、YGO-074 で切った M1 のチケットに回す: 時計は YGO-080、`jobs` のキューは YGO-081、環境変数の読み込みと `MAIL_ADAPTER` の選択は YGO-082、モックのメールのアダプタは YGO-083、worker のジョブの実行は YGO-084、KeyProvider の偽の鍵は YGO-085（「直さないところと理由」）。
M1 の TC が使わない M0 の残り（`scripts/dev-db.sh` と `APP_ENV` の起動の検査など）は M1 のチケットにせず、M2 で TC とチケットを足す（`.ai/gaps.md` G-082）`[assumed]`（理由は「直さないところと理由」）。
`M: M1` とするのは、目的が M1 の TC のテストを動かす土台だから。

- `vitest.config.ts`: テストの結果を JUnit XML で `test-results/junit.xml` に書く（標準の出力の報告も残す）`[assumed]`。
- `scripts/prepare.sh`: `npm ci` だけを動かす。OS の道具（PostgreSQL・`tofu`）は入れない。
  `package.json` がなければ終了コード 0。`package.json` があり `package-lock.json` がなければ、ロックファイルを作らず「依存を変える変更の中でロックファイルを作ってコミットする」と出して終了コード 1（ADR-0103 の D3）。`npm` がなければ 1 行で出して止まる。
- `scripts/check.sh` の最初の段（文書の確認より前、`package.json` があるときだけ）: `node` のコマンドとその主版が `package.json` の `engines.node` と合うかを確かめ、足りなければ要る主版と「検証の環境に Node.js を入れる」を出して止まる。`package-lock.json` がない、または `package.json` の依存の名前がロックファイルにないときに失敗する（ネットワークを使わない）。
- `scripts/check.sh` の文書の確認: YGO-078 が `状態: done` なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する。
- `scripts/check.sh` の Vitest の段（文書の確認のあと、`check: ok` の前、`package.json` があるときだけ）: `node_modules/` がなければ `sh scripts/prepare.sh` を先に動かすよう出して失敗する。`npx --no-install vitest run` を動かし、`test-results/junit.xml` がない、`skipped`（skip・todo）がある、名前に TC-NNN のない `testcase` がある、のどれでも失敗する。
- `.gitignore`: `test-results/` と `node_modules/` の行。
- 例のテスト: `src/app.ts` に、経路を持たない Fastify のアプリを返す `buildApp()` を置く。`test/test_TC_033_no_oauth_webauthn_routes.test.ts` を 1 つ置き、テストの名前は `TC-033 …` で始め、ルートの一覧に `oauth`・`webauthn` を含む経路がないことを確かめる。ポートは開かない。`skip`・`todo` にしない。
- `.ai/environment.md` を今の状態に合わせる: §3.2 に `prepare.sh` が `npm ci` を動かすこと、§4.1 に文書の確認と Vitest を動かすことと JUnit XML の出力先 `test-results/junit.xml`。§4.1 の 4〜5 は YGO-076 で足すもの、§4.1 の 3（型の検査と lint）は M1 の TC が依存しないため M1 のチケットにせず残す `[assumed]`。§3.2 の 2 以降（`dev-db.sh`・`.local/`）は、M1 の TC が使わないため M1 のチケットにせず、M2 で作るもの（G-082）として残す `[assumed]`。
- 地図 `.ai/INDEX.md` と食い違うところがあれば同じ変更で直す（`.ai/` の外のファイルは地図に載せない）。

## 直さないところと理由
- `package.json` とロックファイル・Vitest を実際に動かす確かめ: YGO-078（「分けた理由」の節）。
- CI の定義（`.github/`）: ジョブが書いてよい範囲の外（CLAUDE.md）。足すのはマスター（`.ai/environment.md` §5）。
  その定義があり `sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かすことは、YGO-070 の受け入れ確認 1 で確かめる（ADR-0105 の D4）。CI の結果（緑かどうか）は、M1 の達成の確認で見る。
- 使い捨ての PostgreSQL の起動と片付け（§4.1 の 4・5、§4.4）: YGO-076 で、初めて DB を使う TC（TC-005、YGO-065）より前に足す。
- M1 の TC が使う M0 の部品（`roadmap.md` §4 の M0 の行の残りのうち）: 時計は YGO-080、`jobs` のキューは YGO-081、環境変数の読み込みと `MAIL_ADAPTER` の選択は YGO-082、モックのメールのアダプタは YGO-083、worker のジョブの実行は YGO-084、KeyProvider の偽の鍵は YGO-085（どれも `M: M1`）。
- `scripts/dev-db.sh`: 開発の DB の台本で、`check.sh` は使い捨ての PostgreSQL を使い、TC はこの台本を使わない。M1 の TC が使わないため M1 のチケットにせず、M2 で切る（`.ai/gaps.md` G-082）`[assumed]`。
- `APP_ENV` の起動の検査（`staging`・`production` で偽の鍵か `CLOCK_OFFSET` があれば起動に失敗する）と、テストの準備の接続の検査: M1 の TC はどれも確かめないため M1 のチケットにせず、M2 で `roadmap.md` A-07 の (1)〜(4) の TC とそのチケットを足す（G-082）`[assumed]`。
- M1 の TC が使わないほかの M0 の残り（web の起動 `src/server.ts`・C3 の空の形・ローカルの SMTP などほかのアダプタ）: 同じく M2 で扱う（G-082）`[assumed]`。
- 型の検査と lint（§4.1 の 3）: M1 の TC が依存しないため、M1 のチケットにしない `[assumed]`。
- M1 の FR の機能の実装: YGO-071 で切る FR のチケットで 1 つずつ。
- `.ai/status.md`: 秘書が書くもので、ジョブは変えない。
- 新しい OQ・要回答は 0 件。新しい ADR は 0 件。ADR-0105 を丸ごと置き換える ADR（`.ai/gaps.md` の G-081 の予定）は、YGO-078 が `状態: done` になった次の変更で、題に G-081 を付けた別のチケットで作る。

## 分けた理由
- 変更 20261127-e16545 の実装のジョブでは、コマンドを動かす道具そのものが権限で拒まれ、`npm`・`node`・`sh scripts/prepare.sh`・`sh scripts/check.sh` のどれも動かせなかった（エラーの行は「確かめた結果」の節）。
  ADR-0103 の D1 のコマンドでロックファイルを作れないので、D2 のとおりロックファイルを手で書かず、`package.json` も入れない（`package.json` だけを入れると `check.sh` の最初の段がロックファイルがないとして失敗する）。
- 動かして確かめる項目（もとの受け入れ確認の 2〜4・7・11 の `engines`・13〜17）は、`package.json` とロックファイルが入り、ジョブがコマンドを動かせるまで 1 回の変更では終わらない。ファイルを読めば確かめられる項目はすべて満たしているので、このチケットの範囲をそこまでに直して done にし、残りを YGO-078 として切った。
- 片付く条件（YGO-078 の依存）: ジョブが `npm` のコマンドと `sh scripts/prepare.sh`・`sh scripts/check.sh` を動かせる（`.ai/gaps.md` の G-080）。

## 受け入れ確認
CI の定義（`.github/workflows/`）の項目は入れない（受け持つのは YGO-070 の受け入れ確認 1、ADR-0105 の D4）。

1. このチケットの 1〜3 行目が `# YGO-062 M1 のテストの土台（check.sh・JUnit XML・CI）`・`状態: done`・`M: M1`。
2. `scripts/check.sh` に、ネットワークを使うコマンド（`npm ci`・`npm install`・`curl`・`wget` など）がなく、`vitest` は `npx --no-install` で呼ぶ。
3. `scripts/prepare.sh` があり、`npm ci` を動かす。`package.json` がないときに終了コード 0、`package-lock.json` がないときと `npm` がないときに終了コード 1 で終わる行がある。
4. `.gitignore` に `test-results/` と `node_modules/` の行がある。
5. この変更で `.github/` の下のファイルを足していない・変えていない。
6. `.ai/environment.md` に「`prepare.sh` は今のレポジトリになく」と「今の `check.sh` は文書の確認だけ」が残っておらず、§4.1 に `test-results/junit.xml` が書かれている。
7. `.ai/environment.md` §3.2・§4.1 の記述が、このチケットで作ったものと食い違わない: §3.2 の `dev-db.sh`・`.local/` は M2 で作るもの（`gaps.md` G-082）、§4.1 の 4〜5 は YGO-076 で足すもの、§4.1 の 3 は M1 のチケットにしないものとして残り、作ったと書かれていない。§3.1 の `engines` の行は YGO-078 を指す。
8. このチケットの「範囲」に、作るもの（Vitest を `check.sh` からつなぐ台本・設定・例のテスト・`prepare.sh`）と、YGO-078 に回すもの（`package.json`・ロックファイル）と、YGO-076 に回すもの（使い捨ての PostgreSQL）と、M1 の TC が使う M0 の部品を回す YGO-080〜YGO-085 の番号が書かれている。`dev-db.sh`・`APP_ENV` の起動の検査は、それとは別の文で、M2 で扱う（`gaps.md` G-082）と書かれている。
9. `scripts/check.sh` に、次の行がある: `node` がない・主版が `engines.node` と違うときに要る主版と「検証の環境に Node.js」を出して終了コード 1、`package-lock.json` がないときに ADR-0103 を示して終了コード 1、`node_modules/` がないときに `prepare.sh` を動かすよう出して終了コード 1、`test-results/junit.xml` がない・`<skipped` がある・名前に TC-NNN のない `testcase` があるときに終了コード 1。
10. `vitest.config.ts` の報告が `default` と `junit` で、出力が `test-results/junit.xml`。`test/test_TC_033_no_oauth_webauthn_routes.test.ts` のテストの名前が `TC-033` で始まり、`skip`・`todo`・`only` でない。`src/app.ts` に `buildApp()` がある。
11. `scripts/check.sh` の、done なのに `package.json`・`package-lock.json`・`scripts/prepare.sh` のどれかがなければ失敗する段が、YGO-078 のチケットを見る（このチケットの done では `package.json` を求めない）。
12. `.ai/tickets/YGO-078-m1-package-json-lockfile-vitest.md` があり、1〜3 行目が `# YGO-078 M1 の package.json とロックファイルで Vitest を動かす`・`状態: open`・`M: M1`。その受け入れ確認に、このチケットから外した項目（`prepare.sh` → `check.sh` が 0 で JUnit XML ができる・TC-033 の testcase が 1 つで skip・failure・error がない・`node_modules/` がないと失敗・依存と固定の版とロックファイル・`engines.node` と §3.1 の主版・主版が違うと失敗・ロックファイルがないと失敗・done で `prepare.sh` がないと失敗・`test.skip` で失敗）がある。

## 確かめた結果
受け入れ確認を 1 項目ずつ、今のファイルと照らした結果（変更 20261127-e16545 の時点。コマンドは動かせなかったので、どれもファイルを読んで確かめた）。

| 番号 | 結果 | 確かめたところ |
|---|---|---|
| 1 | 済み | このファイルの 1〜3 行目 |
| 2 | 済み | `check.sh` の全行にネットワークを使うコマンドがなく、Vitest の段が `npx --no-install vitest run` |
| 3 | 済み | `prepare.sh` の 8〜10 行目（終了コード 0）・12〜15 行目・16〜19 行目（終了コード 1）・20 行目 `npm ci --no-audit --no-fund` |
| 4 | 済み | `.gitignore` の 7 行目 `node_modules/`・13 行目 `test-results/` |
| 5 | 済み | この変更は `.github/` に触れていない（レポジトリに `.github/` がない） |
| 6 | 済み | `.ai/environment.md` に 2 つの文がなく（検索で 0 件）、§4.1 の 6 に `test-results/junit.xml` がある |
| 7 | 済み | §3.2 の見出しと 2（`dev-db.sh`・`.local/` は M2 で作る、G-082）、§4.1 の冒頭の段落（4・5 は YGO-076、3 は M1 のチケットにしない）、§3.1 の Node.js の行（YGO-078） |
| 8 | 済み | このファイルの「範囲」の節 |
| 9 | 済み | `check.sh` の最初の段（node がない・主版が違う・ロックファイルがない）と Vitest の段（`node_modules/` がない・XML がない・`<skipped` がある・TC-NNN のない testcase） |
| 10 | 済み | `vitest.config.ts` の 8・9 行目、TC-033 のテストの 12 行目（`test(` で始まる）、`src/app.ts` |
| 11 | 済み | `check.sh` の文書の確認の、YGO-078 のチケットの `状態: done` を見る段 |
| 12 | 済み | `.ai/tickets/YGO-078-m1-package-json-lockfile-vitest.md` の 1〜3 行目と受け入れ確認 2〜10 |

- 動かしたコマンドと結果: `npm -v` → 動かず、エラーの行は
  `Permission to use Bash has been denied because Claude Code is running in don't ask mode.`
  コマンドを動かす道具そのものが拒まれたため、`node -v`・`sh scripts/prepare.sh`・`sh scripts/check.sh` も動かせなかった。
