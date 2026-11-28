# YGO-085 M1 の KeyProvider の偽の鍵
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「アダプタ（KeyProvider の偽の鍵 …）」のうち、M1 の経路とジョブが使う鍵を作る。YGO-074 で切った M0 の部品のチケットの 1 枚（YGO-074 の範囲の 6 枚目。理由は YGO-074 の範囲）。
使う M1 の TC: TC-018・TC-019・TC-020・TC-023・TC-001（メールアドレスの暗号化と検索の HMAC。J18 も `EMAIL_KEYRING` で復号する、`async.md` §4 J18・`environment.md` §8.1）。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-103 のあとに並べる。依存の順: YGO-062 → YGO-075 と YGO-078（並んで進む）→ YGO-076 → YGO-103 → **YGO-085（このチケット）**。YGO-103 が `状態: done` であること。
- 部品どうしの順: YGO-080・YGO-082・YGO-086 → YGO-081・YGO-083・YGO-085 → YGO-084。このチケットは YGO-082（環境変数の読み込み）の `状態: done` を待つ。YGO-084 がこのチケットを待つ（J18 が `EMAIL_KEYRING` で復号するため）。

## 範囲
- KeyProvider（C9、ADR-0006・ADR-0021）の偽の鍵のアダプタ（`src/adapters/keys/` など）`[assumed]`: 鍵の変数の文字列 `EXAMPLE_KEY_DO_NOT_USE:<用途>:<版>` の SHA-256 から、版ごとの 32 バイトの鍵を作る（`environment.md` §3.3）。
- 対象は M1 の経路とジョブが使う鍵: `EMAIL_KEYRING`・`EMAIL_KEY_CURRENT_VERSION`（web・worker）と `EMAIL_HMAC_KEYRING`・`EMAIL_HMAC_KEY_CURRENT_VERSION`（web）。鍵の変数は YGO-082 の読み込みで読む。
- テストで使う値は偽の値（`environment.md` §4.2）。
- 部品だけを確かめる TC は `.ai/tests/test-plan.md` にないため、このチケットはテストを足さない `[assumed]`。使う FR のチケット（YGO-094・YGO-097・YGO-095・YGO-098）の TC-018・TC-019・TC-020・TC-023・TC-001 で確かめる。

## 直さないところと理由
- `LETTER_KEYRING`・`LETTER_KEY_CURRENT_VERSION`: 手紙は M2 で扱う。
- `SESSION_SIGNING_KEY`・`RESET_TOKEN_SIGNING_KEY`・`RATE_LIMIT_HMAC_KEY`: 版のない 1 つの鍵で KeyProvider を通さないため、使う FR のチケットが YGO-082 の読み込みで読む `[assumed]`。
- 本番の鍵管理で包んだデータ鍵（`environment.md` §8.3）と `keys.reencrypt`: 本番のアダプタと M6。
- `APP_ENV` の起動の検査（`staging`・`production` で偽の鍵なら起動に失敗）: M1 の TC が確かめないため、使う TC のチケットを切るときに扱う。
- 新しい OQ・要回答・ADR は 0 件。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-085 M1 の KeyProvider の偽の鍵`・`状態: done`・`M: M1`。
2. YGO-062・YGO-078・YGO-103・YGO-082 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
4. 偽の鍵のアダプタが、`EXAMPLE_KEY_DO_NOT_USE:<用途>:<版>` の SHA-256 から版ごとの 32 バイトの鍵を返し、`EMAIL_KEYRING` と `EMAIL_HMAC_KEYRING` の版を引ける。
5. `LETTER_KEYRING` を読むコードがない。
