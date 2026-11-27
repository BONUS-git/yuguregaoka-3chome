# YGO-082 M1 の環境変数の読み込みと MAIL_ADAPTER の選択
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「`APP_ENV` と環境変数の読み込み」のうち、M1 の TC（TC-020）が使う「worker の `MAIL_ADAPTER` の選択」までを作る。YGO-074（reviews/0004 の R-070）で切った M0 の部品のチケット。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-078 → YGO-075 → YGO-076 → YGO-065 → YGO-077 → YGO-080・YGO-081・**YGO-082（このチケット）** → YGO-083・YGO-085 → YGO-084 → YGO-071 で切る FR のチケット。
- このチケットは、ほかの M0 の部品のチケットを待たない。YGO-083（モックのメールのアダプタ）と YGO-085（KeyProvider の偽の鍵）が、このチケットを待つ。

## 使う M1 の TC
- TC-020（FR-091、API）: J18 がモックのメールのアダプタで送り、テストがそのアダプタの受けたトークンを使う。worker のメールのアダプタは `MAIL_ADAPTER` で選ぶ（`async.md` §4 J18、`environment.md` §8.1）。

## 範囲
- `src/config.ts` の `loadConfig(kind: 'web' | 'worker', env)`（`env` は既定で `process.env`。テストは値を渡す）`[assumed]`:
  - `.ai/environment.md` §8.1 の、そのプロセスの列にある変数のうち `APP_ENV`・`DATABASE_URL`・`MAIL_ADAPTER`（worker だけ）・`CLOCK_OFFSET` だけを読み、型の付いた設定を返す。鍵の変数は YGO-085 が足す。ほかの変数は使うチケットで足す。
  - `MAIL_ADAPTER` が `mock` か `smtp_local` でなければ、理由を出して失敗する（起動に失敗）。設定されていなければ `mock`（§8.1 の開発・テストの値）`[assumed]`。
  - `APP_ENV` は §2 の環境の名前のどれかでなければ失敗する。
- `.ai/environment.md` §8.1 の表のあとの注記に、読み込みの正本が `src/config.ts` で、M1 で読む変数が上のものと YGO-085 の鍵の変数であることを書く。

## 直さないところと理由
- `APP_ENV` の起動の検査（`staging`・`production` で偽の鍵か `CLOCK_OFFSET` があれば失敗）と、自分の列にない秘密で起動に失敗すること: M1 の TC はどれも確かめないため、M1 のチケットにしない。M2 で TC とチケットを足す（`.ai/gaps.md` G-082）`[assumed]`（YGO-062・YGO-065 の「直さないところと理由」と同じ）。
- `CLOCK_OFFSET` で時計をずらすこと: 読むだけで使わない（時計は YGO-080。ずらす使い方は M1 の TC が使わない）`[assumed]`。
- アダプタの中身: YGO-083。worker に組むこと: YGO-084。
- 部品だけのテスト: 足さない `[assumed]`。名前に TC-NNN のないテストは `check.sh` が失敗にする。選択は TC-020 のテスト（YGO-071 で切る FR のチケット）が確かめる。
- 新しい OQ・要回答・ADR は 0 件（変数は `environment.md` §8.1。形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-082 M1 の環境変数の読み込みと MAIL_ADAPTER の選択`・`状態: done`・`M: M1`。
2. `src/config.ts` に `loadConfig` があり、`APP_ENV`・`DATABASE_URL`・`MAIL_ADAPTER`・`CLOCK_OFFSET` を読む。`MAIL_ADAPTER` を web では読まない。
3. `MAIL_ADAPTER` が `mock`・`smtp_local` のどちらでもないときに失敗する行が `src/config.ts` にある。
4. `.ai/environment.md` §8.1 に、読み込みの正本が `src/config.ts` であることが書かれている。
5. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed のまま。
