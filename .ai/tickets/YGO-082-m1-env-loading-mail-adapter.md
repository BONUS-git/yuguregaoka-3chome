# YGO-082 M1 の環境変数の読み込みと MAIL_ADAPTER の選択
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「`APP_ENV` と環境変数の読み込み」のうち、M1 の TC が使う「環境変数の読み込みと `MAIL_ADAPTER` の選択」を作る。YGO-074 で切った M0 の部品のチケットの 1 枚。
使う M1 の TC: TC-020（J18 がモックのメールのアダプタに送る。アダプタは worker の `MAIL_ADAPTER` で選ぶ、`async.md` §4 J18・`environment.md` §8.1）。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-062 → YGO-075 と YGO-078（並んで進む）→ YGO-076 → YGO-065 → **YGO-082（このチケット）**。YGO-065 が `状態: done` であること。
- 部品どうしの順: YGO-080・YGO-082・YGO-086 → YGO-081・YGO-083・YGO-085 → YGO-084。このチケットは先頭の組で、ほかの部品のチケットを待たない。YGO-083・YGO-085 がこのチケットを待つ。

## 範囲
- 環境変数の読み込み（`src/config.ts` など）`[assumed]`: web と worker がそれぞれ自分の列の変数（`environment.md` §8.1）を読み、型のある設定の値にする。テストは環境変数を書き換えずに設定の値を渡せる。
- `MAIL_ADAPTER`（worker）: `mock`／`smtp_local` だけを受け付け、設定がなければ `mock`。ほかの値は、変数の名前と受け付ける値を出して起動に失敗する。
- `smtp_local` のアダプタはまだないため、`smtp_local` を選ぶと「`smtp_local` のアダプタはまだない」と理由を出して起動に失敗する `[assumed]`。
- 部品だけを確かめる TC は `.ai/tests/test-plan.md` にないため、このチケットはテストを足さない `[assumed]`。使う FR のチケット（YGO-071 で切る）の TC-020 で確かめる。

## 直さないところと理由
- `APP_ENV` の起動の検査（`staging`・`production` で偽の鍵か `CLOCK_OFFSET` があれば起動に失敗）と、自分の列にない秘密での起動の失敗: M1 の TC はどれも確かめないため、M1 のチケットにしない。使う TC のチケットを切るときに扱う。
- ローカルの SMTP のアダプタ（ADR-0033）: M1 の TC が使わないため、使う TC のチケットを切るときに扱う。
- モックのメールのアダプタ: YGO-083。鍵の変数の読み込みを使う KeyProvider: YGO-085。
- 新しい OQ・要回答・ADR は 0 件。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-082 M1 の環境変数の読み込みと MAIL_ADAPTER の選択`・`状態: done`・`M: M1`。
2. YGO-062・YGO-078・YGO-065 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
4. `MAIL_ADAPTER` の受け付ける値が `mock`・`smtp_local` だけで、既定が `mock`。ほかの値と `smtp_local` で、理由を出して起動に失敗する行がある。
5. 読み込みが web と worker で分かれ、それぞれ `environment.md` §8.1 の自分の列の変数だけを読む。
