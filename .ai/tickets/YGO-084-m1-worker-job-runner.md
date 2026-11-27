# YGO-084 M1 の worker のジョブの実行
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「2 プロセス（web / worker）の骨組み」のうち、M1 の TC（TC-017・TC-020）が使う「worker が `jobs` から J14・J18 を取ってハンドラを動かす部分」を作る（ADR-0100）。YGO-074（reviews/0004 の R-070）で切った M0 の部品のチケット。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-078 → YGO-075 → YGO-076 → YGO-065 → YGO-077 → YGO-080・YGO-081・YGO-082 → YGO-083・YGO-085 → **YGO-084（このチケット）** → YGO-071 で切る FR のチケット。
  - YGO-080（時計）・YGO-081（`jobs` のキュー）・YGO-083（モックのメールのアダプタ）が `状態: done` であること。

## 使う M1 の TC
- TC-017（FR-010、ジョブ）: worker が J14 を動かす（時計を進めて）。
- TC-020（FR-091、API）: worker が J18 をモックのメールのアダプタで動かす。

## 範囲
- `src/worker.ts`（`environment.md` §3.2 のエントリポイント）: `loadConfig('worker')`（YGO-082）・時計（YGO-080）・`selectMailAdapter`（YGO-083）・pg-boss（YGO-081）を組み、`src/jobs/handlers.ts` の対応表のハンドラを pg-boss に登録する。
  - J14 `retention.purge` の毎日のスケジュールを登録する（`async.md` §2 の J14 の行は「毎日（配達窓を外した時間帯）」で時刻を決めていないため、配達窓を外した時刻を実装の時点で決め、その箇所と `async.md` §2 の J14 の行に `[assumed]` と書く）。
  - 組み立てを `buildWorker({ config, clock, mail, db })` に分け、`src/worker.ts` は実環境の値を渡すだけにする `[assumed]`（テストが差し替えた時計とモックを渡せるようにする）。
- `src/jobs/handlers.ts`: キューの名前（`src/queue.ts`）→ ハンドラの対応表。このチケットでは表の形だけを置き、中身（J14・J18 のハンドラ）は FR のチケットが足す。ハンドラは `{ db, clock, mail }` を受け取る `[assumed]`。
- `test/helpers/` に `runQueuedJobs`: テストの中で、積まれているジョブを取り出して対応表のハンドラで 1 回ずつ動かし、積まれた分がなくなったら返す `[assumed]`（worker のプロセスを起こさずにジョブの TC を動かすため）。
- `package.json` の `scripts` に `dev:worker`（`environment.md` §3.2）を足す。

## 直さないところと理由
- J14・J18 のハンドラの中身: YGO-071 で切る FR のチケット（TC-017 は 3、TC-020 は 6）。
- web の起動（`src/server.ts`・`dev:web`）・C3 の 8 サブモジュールの空の形・M1 で使わないジョブの登録: M1 の TC はどれも使わないため、M1 のチケットにしない。M2 で扱う（`.ai/gaps.md` G-082。M1 で使わないジョブの登録は、そのジョブを作る M のチケット）`[assumed]`（YGO-062・YGO-065 の「直さないところと理由」と同じ）。
- 部品だけのテスト: 足さない `[assumed]`。名前に TC-NNN のないテストは `check.sh` が失敗にする。ジョブの実行は TC-017・TC-020 のテスト（YGO-071 で切る FR のチケット）が確かめる。
- 新しい OQ・要回答・ADR は 0 件（2 プロセスは ADR-0100、設定は `async.md` §5。形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-084 M1 の worker のジョブの実行`・`状態: done`・`M: M1`。
2. `src/worker.ts` が、設定・時計・メールのアダプタ・pg-boss を組み、`src/jobs/handlers.ts` の対応表を登録する。J14 の毎日のスケジュールを登録する行がある。
3. `src/jobs/handlers.ts` があり、キューの名前を `src/queue.ts` から引く。
4. `test/helpers/` に `runQueuedJobs` があり、ポートを開かず、ネットワークを使わない。
5. `package.json` の `scripts` に `dev:worker` がある。
6. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed のまま。
