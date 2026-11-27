# YGO-083 M1 のモックのメールのアダプタ
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行のアダプタのうち、M1 の TC（TC-020）が使う「モックのメール」を作る（ADR-0033、`environment.md` §3.3）。YGO-074（reviews/0004 の R-070）で切った M0 の部品のチケット。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-078 → YGO-075 → YGO-076 → YGO-065 → YGO-077 → YGO-080・YGO-081・YGO-082 → **YGO-083（このチケット）**・YGO-085 → YGO-084 → YGO-071 で切る FR のチケット。
  - YGO-082（環境変数の読み込みと `MAIL_ADAPTER` の選択）が `状態: done` であること（アダプタは設定の `MAIL_ADAPTER` で選ぶ）。

## 使う M1 の TC
- TC-020（FR-091、API）: モックのメールのアダプタが受けたリンクのトークンで `POST /api/v1/email-verifications` が 204。

## 範囲
- `src/mail/`:
  - 型 `MailAdapter`（`send(message): Promise<void>`。`message` は宛先・題・本文）`[assumed]`。
  - モックのアダプタ: 送った文面を順に記録し、テストが記録を読めて消せる（`sent()`・`clear()`）`[assumed]`。外へ何も送らない。
  - `selectMailAdapter(config)`: 設定の `MAIL_ADAPTER` が `mock` ならモックを返す。`smtp_local` は未実装として理由を出して失敗する `[assumed]`（M1 の TC が使わないため。ADR-0033 の D4 のとおり受け入れ条件はモックで確かめる）。
- `.ai/environment.md` §3.3 のメールの行に、モックの置き場 `src/mail/` と、`smtp_local` は M2 で TC とチケットを足して作ること（`.ai/gaps.md` G-082）を書く。

## 直さないところと理由
- ローカルの SMTP のアダプタ（宛先はループバックだけ、ADR-0033）: M1 の TC はどれも使わないため、M1 のチケットにしない。M2 で TC とチケットを足して作る（`.ai/gaps.md` G-082）`[assumed]`。
- J18 のハンドラ（文面を組んで送る）: YGO-071 で切る FR のチケット。worker に組むこと: YGO-084。
- 部品だけのテスト: 足さない `[assumed]`。名前に TC-NNN のないテストは `check.sh` が失敗にする。アダプタは TC-020 のテスト（YGO-071 で切る FR のチケット）が確かめる。
- 新しい OQ・要回答・ADR は 0 件（ADR-0033 で決まっている。形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-083 M1 のモックのメールのアダプタ`・`状態: done`・`M: M1`。
2. `src/mail/` に `MailAdapter` の型・送った文面を記録するモック・`selectMailAdapter` がある。モックにネットワークを使う呼び出しがない。
3. `selectMailAdapter` が `mock` でモックを返し、`smtp_local` では理由を出して失敗する。
4. `.ai/environment.md` §3.3 のメールの行に `src/mail/` が書かれている。
5. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed のまま。
