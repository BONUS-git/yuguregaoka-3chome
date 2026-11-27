# YGO-085 M1 の KeyProvider と偽の鍵
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行のアダプタのうち、M1 の TC が使う「KeyProvider の偽の鍵」を作る（ADR-0006・ADR-0021、`environment.md` §3.3）。YGO-074（reviews/0004 の R-070）で切った M0 の部品のチケット。YGO-074 の範囲を広げた理由は、YGO-074 の「範囲を広げた理由」の節。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-078 → YGO-075 → YGO-076 → YGO-065 → YGO-077 → YGO-080・YGO-081・YGO-082 → YGO-083・**YGO-085（このチケット）** → YGO-084 → YGO-071 で切る FR のチケット。
  - YGO-082（環境変数の読み込み）が `状態: done` であること（鍵の変数を `loadConfig` で読む）。

## 使う M1 の TC
メールアドレスの暗号化（`EMAIL_KEYRING`）と検索の HMAC（`EMAIL_HMAC_KEYRING`）、トークンの鍵付きハッシュ（`RESET_TOKEN_SIGNING_KEY`）、セッションの署名（`SESSION_SIGNING_KEY`）、流量の制限の HMAC（`RATE_LIMIT_HMAC_KEY`）に鍵を使う TC:
- TC-018・TC-019（登録の受け付け。`credentials` の暗号化の列・`auth_tokens.token_hash`・流量の制限）
- TC-020（メールの確認の完了。トークンの照合とログイン）
- TC-023（ログイン。メールアドレスの HMAC で引く）
- TC-001・TC-002（確認まで済ませた登録と `GET /me`。セッション）

## 範囲
- `src/keys.ts`:
  - KeyProvider の偽の鍵のアダプタ: 鍵の変数の値（`EXAMPLE_KEY_DO_NOT_USE:<用途>:<版>` などの偽の鍵の文字列）の SHA-256 から 32 バイトの鍵を作る（`environment.md` §3.3）。版付きの変数（`EMAIL_KEYRING`・`EMAIL_HMAC_KEYRING`）は、版の番号から鍵を引き、`*_CURRENT_VERSION` の版を今の鍵として返す。
  - 対象は M1 で使う鍵の変数すべて: `SESSION_SIGNING_KEY`・`RESET_TOKEN_SIGNING_KEY`・`RATE_LIMIT_HMAC_KEY`（web だけ）・`EMAIL_KEYRING`・`EMAIL_KEY_CURRENT_VERSION`（web・worker）・`EMAIL_HMAC_KEYRING`・`EMAIL_HMAC_KEY_CURRENT_VERSION`（web だけ）。プロセスの列は §8.1 のとおり。
  - 版付きの変数の値の書き方（版と偽の鍵の文字列の並べ方）は実装の時点で決め、その箇所と `environment.md` §8.1 の注記に `[assumed]` と書く。
- `src/config.ts` の `loadConfig` に、上の鍵の変数を自分の列だけ読む行を足す（YGO-082 の続き）。
- テストの準備のコードが偽の鍵の値を組み立てて渡す（`.env*` は使わない、`environment.md` §4.2）。

## 直さないところと理由
- 暗号化と HMAC の計算そのもの（AES-GCM・HMAC-SHA-256 など、どの列にどう使うか）: 使う FR のチケット（YGO-071 で切るもの）で行う `[assumed]`。
- `LETTER_KEYRING`（手紙の鍵）と鍵管理のサービスで包んだデータ鍵（本番）: M1 の TC が使わない。手紙の鍵は M2 のチケットで足す。
- 偽の鍵で `staging`・`production` に起動しないことの検査: M1 の TC はどれも確かめないため、M1 のチケットにしない。M2 で A-07 の (1) の TC とチケットを足す（`.ai/gaps.md` G-082）`[assumed]`。
- 部品だけのテスト: 足さない `[assumed]`。名前に TC-NNN のないテストは `check.sh` が失敗にする。鍵の使われ方は上の TC のテスト（YGO-071 で切る FR のチケット）が確かめる。
- 新しい OQ・要回答・ADR は 0 件（ADR-0006・ADR-0021 と `environment.md` §3.3 で決まっている。形は技術の細部で `[assumed]`）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-085 M1 の KeyProvider と偽の鍵`・`状態: done`・`M: M1`。
2. `src/keys.ts` が、鍵の変数の値の SHA-256 から 32 バイトの鍵を作り、`SESSION_SIGNING_KEY`・`RESET_TOKEN_SIGNING_KEY`・`RATE_LIMIT_HMAC_KEY`・`EMAIL_KEYRING`・`EMAIL_HMAC_KEYRING` の鍵を返す。版付きの変数は `*_CURRENT_VERSION` の版を今の鍵とする。
3. `src/config.ts` が、鍵の変数を `.ai/environment.md` §8.1 のプロセスの列のとおりに読む（worker は `SESSION_SIGNING_KEY`・`RESET_TOKEN_SIGNING_KEY`・`RATE_LIMIT_HMAC_KEY`・`EMAIL_HMAC_KEYRING` を読まない）。
4. レポジトリに本物の鍵がなく、鍵の値はどれも `EXAMPLE_` で始まる偽の値。
5. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで終了コード 0 で `check: ok` で終わり、`test-results/junit.xml` の名前に `TC-033` を含む `testcase` が passed のまま。
