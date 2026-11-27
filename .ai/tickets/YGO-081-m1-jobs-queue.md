# YGO-081 M1 の jobs のキュー（pg-boss）
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「pg-boss 相当のキュー」のうち、M1 の TC（TC-017・TC-019）が使う「積むこと」を作る。YGO-074（reviews/0004 の R-070）で切った M0 の部品のチケット。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-078 → YGO-075 → YGO-076 → YGO-065 → YGO-077 → YGO-080・**YGO-081（このチケット）**・YGO-082 → YGO-083・YGO-085 → YGO-084 → YGO-071 で切る FR のチケット。
  - YGO-076 が `状態: done` であること（キューは PostgreSQL の上に作り、`check.sh` の使い捨ての PostgreSQL とひな型の DB を使う）。
  - YGO-075 が `状態: done` であること（依存を足す変更でロックファイルを直す根拠は ADR-0106 の D1）。

## 使う M1 の TC
- TC-017（FR-010、ジョブ）: J14 を積んで動かす。
- TC-019（FR-091、結合）: 登録の 201 のあと J18 が 1 つ積まれ、400・409・429 では積まれない（登録のトランザクションの中で積む）。

## 範囲
- `pg-boss` を `dependencies` に固定の版（`^`・`~` なし、実装の時点の安定版）で足し、同じ変更で ADR-0106 の D1 のコマンドでロックファイルを直す。作れなければ ADR-0106 の D2 のとおり、止まった段とエラーの行をこのチケットに書く。
- `src/queue.ts`:
  - キューの名前の定数: M1 で使う `retention.purge`（J14）と `mail.send`（J18）`[assumed]`。ほかのジョブの名前は使う M のチケットで足す。
  - `async.md` §5 の J14・J18 の行の設定（`retryLimit`・`retryBackoff`・`retryDelay`・`expireInSeconds`・`singletonKey`）を、ジョブごとの既定として持つ。
  - `enqueue(db, name, data, options)`: 呼び出し側のトランザクションの中で積む（pg-boss の `db` の差し込みを使い、呼び出し側の接続で `INSERT` する）`[assumed]`。トランザクションが巻き戻れば、ジョブも残らない。
  - pg-boss の表の作り方: pg-boss の起動（`start`）が作る表をそのまま使う `[assumed]`。ひな型の DB に作るか、テストのファイルごとに作るかは、実装の時点で `check.sh` の時間が短いほうに決め、その箇所に `[assumed]` と書く。
- `.ai/async.md` §5 の前置きに、キューの名前と設定の正本が `src/queue.ts` であることを書く。

## 直さないところと理由
- ジョブを取り出して動かすこと（worker）: YGO-084。
- J14・J18 のハンドラの中身: YGO-071 で切る FR のチケット。
- M1 で使わないジョブ（J0〜J13・J15〜J17 など）の名前と設定: 使う M のチケットで足す。
- 部品だけのテスト: 足さない `[assumed]`。名前に TC-NNN のないテストは `check.sh` が失敗にする。積むことは TC-017・TC-019 のテスト（YGO-071 で切る FR のチケット）が確かめる。
- 新しい OQ・要回答・ADR は 0 件（pg-boss は `roadmap.md` §4 の M0 の行と `async.md` §5。形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-081 M1 の jobs のキュー（pg-boss）`・`状態: done`・`M: M1`。
2. `package.json` の `dependencies` に `pg-boss` があり、版に `^`・`~` がない。`package-lock.json` に `pg-boss` の名前がある。
3. `src/queue.ts` に `retention.purge`・`mail.send` の名前と、`async.md` §5 の J14・J18 の行と同じ値の設定がある。
4. `src/queue.ts` の `enqueue` が、呼び出し側の DB の接続（トランザクション）を引数に取る。
5. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed のまま。
