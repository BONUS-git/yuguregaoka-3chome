# YGO-080 M1 の差し替えられる時計
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「時刻を外から差し替えられる時計」のうち、M1 の TC（TC-016・TC-017）が使う部分を作る。YGO-074（reviews/0004 の R-070）で切った M0 の部品のチケットの 1 枚目。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること（時計を使う TC は Vitest で動くため）。
- YGO-065 のあとに並べる。依存の順: YGO-078 → YGO-075 → YGO-076 → YGO-065 → YGO-077 → **YGO-080（このチケット）**・YGO-081・YGO-082 → YGO-083・YGO-085 → YGO-084 → YGO-071 で切る FR のチケット。
- このチケットは、ほかの M0 の部品のチケット（YGO-081〜YGO-085）を待たない。

## 使う M1 の TC
- TC-016（FR-010、API）: 時計を差し替え、確認が済まない登録の住所は 23 時間 59 分では 409、24 時間を過ぎると 201。
- TC-017（FR-010、ジョブ）: J14 が期限切れの確認が済まない登録を消す（時計を進めて動かす）。
- このほか、M1 の後の FR のチケット（YGO-071 の範囲の 7 より後）の TC-037（FR-098、セッションの期限）も時計を差し替える。

## 範囲
- `src/clock.ts`:
  - 型 `Clock`（`now(): Date` だけ）`[assumed]`。
  - 実時間の時計（`systemClock`。`Date.now()` を使う）。
  - テスト用の `fixedClock(start: Date)`。返す時計は `advance(ms)` で進められる `[assumed]`。
  - `CLOCK_OFFSET` は読まない（環境変数の読み込みは YGO-082。`CLOCK_OFFSET` で時計をずらす開発の使い方は、M1 の TC が使わないため、このチケットに入れない `[assumed]`）。
- `src/app.ts` の `buildApp()` に、引数 `{ clock?: Clock }` を足す。渡さなければ実時間の時計。経路から時計を引けるようにする（Fastify の `decorate` で `app.clock`）`[assumed]`。TC-033 のテストは直さずに通る。
- 時刻で決まる DB の条件（期限・24 時間など）は、SQL の `now()` を使わず、時計の値を引数で渡す `[assumed]`（差し替えた時計が DB の条件にも効くようにするため）。
- `.ai/environment.md` §3.3 の時計の行に、`src/clock.ts`・`buildApp({ clock })` と、時刻で決まる DB の条件は SQL の `now()` を使わず時計の値を渡すことを書く。後の M のジョブ（J4・J5・J6 など）の条件は、そのジョブを作る M のチケットで同じ形に書き直すことも書く `[assumed]`。
- 正本の `.ai/async.md` §4 の M1 の条件を、時計の値（`$now`）で書き直す（`environment.md` §3.3 と食い違わないように）:
  - J14 の表の「メールの確認が済まない登録」: `credentials.created_at < $now - interval '24 hours'`。
  - J14 の表の `auth_tokens`（期限切れ）: `expires_at < $now`。
  - J14 の表の `rate_limit_buckets`: `window_start < $now - interval '1 day'`。
  - J18 の手順 2: `expires_at <= $now`。
  - J14 の節に、`$now` は worker がジョブの始めに時計から 1 回だけ引き、同じジョブの条件すべてに渡すと 1 文足す `[assumed]`。
  - J14 のほかの行（`sessions` の行など、J14 のうち M6 で作る対象）と、M2 以降のジョブの `now()` は、それを作る M のチケットで直す（M1 の TC が使わないため）`[assumed]`。
- 同じ M1 の条件を書く `.ai/db.md` §2 と §4 の保持の表を、`async.md` §4 と同じ時計の値（`$now`）で書き直す（`now()` を残すと、正本どうしが食い違う）:
  - `sessions` の認証の確かめ（§2 の `sessions` の節。ログインの TC が使う）: `expires_at > $now`。
  - `auth_tokens` の確かめ（§2 の `auth_tokens` の節。TC-020 などが使う）: `expires_at > $now`。
  - `auth_tokens` の索引の文の J14 の条件: `expires_at < $now`。
  - `rate_limit_buckets` の節の J14 の条件: `window_start < $now - interval '1 day'`。
  - 期限切れの登録を引く条件（§2 の確認が済まない登録の段落）: `created_at < $now - interval '24 hours'`。
  - §4 の保持の表の `auth_tokens` の行（`expires_at < $now`）と `rate_limit_buckets` の行（`window_start < $now - interval '1 day'`）。
  - `db.md` のほかの `now()`（`sessions` の保持の行・`tenancies` の保持の行・`delivery_runs` の列・`reports` の列など、M1 より後の M か J14 の M6 の対象）は、それを作る M のチケットで直す `[assumed]`。

## 直さないところと理由
- 部品だけのテスト: 足さない `[assumed]`。`.ai/tests/test-plan.md` の決まりでテストの名前には表の TC の番号が要り、名前に TC-NNN のないテストは `check.sh` が失敗にする。時計の動きは、それを使う TC-016・TC-017 のテスト（YGO-071 で切る FR のチケット）が確かめる。
- worker に時計を渡すこと: YGO-084。
- `CLOCK_OFFSET` と `APP_ENV` の起動の検査: M1 の TC はどれも確かめないため、M1 のチケットにしない。M2 で TC とチケットを足す（`.ai/gaps.md` G-082）`[assumed]`。
- 新しい OQ・要回答・ADR は 0 件（形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-080 M1 の差し替えられる時計`・`状態: done`・`M: M1`。
2. `src/clock.ts` に `Clock` の型・実時間の時計・`fixedClock` があり、`fixedClock` の時計に `advance` がある。
3. `src/app.ts` の `buildApp` が `{ clock }` を受け取り、渡さなければ実時間の時計を使う。
4. `.ai/environment.md` §3.3 の時計の行に、`src/clock.ts` と、SQL の `now()` を使わず時計の値を渡すことが書かれている。
5. `.ai/async.md` §4 の J14 の表の「メールの確認が済まない登録」・`auth_tokens`（期限切れ）・`rate_limit_buckets` の 3 行と J18 の手順 2 の条件が、`now()` ではなく `$now` で書かれ、J14 の節に `$now` を時計から引くことが書かれている。`environment.md` §3.3 の時計の行と食い違わない。
6. `.ai/db.md` の M1 の条件（§2 の `sessions` と `auth_tokens` の確かめ・`auth_tokens` の索引の文の J14・`rate_limit_buckets` の節の J14・期限切れの登録を引く条件、§4 の保持の表の `auth_tokens` と `rate_limit_buckets` の行）のどれも `now()` を使わず `$now` で書かれ、`async.md` §4 の同じ条件と食い違わない。
7. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed（`skipped`・`failure`・`error` の要素がない）のまま。
