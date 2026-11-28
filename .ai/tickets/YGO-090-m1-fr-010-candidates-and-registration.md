# YGO-090 M1 FR-010 候補の取得と使われたことのない住所の登録
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。YGO-071 の範囲の 2（FR-010 の候補の取得と使われたことのない住所の登録）。
`GET /api/v1/addresses/candidates` と `POST /api/v1/registrations` の住所を押さえる流れを作る（`api.md` §5、ADR-0082 の D3）。

## 依存
- 全体の順（`.ai/roadmap.md` §4「M1 の FR のチケット」）: 各チケットは、表の「前に要るチケット」に書いたチケットだけを待つ。
- 前に要るチケット（どれも `状態: done` になるのを待つ）:
  - YGO-062（テストの土台）
  - YGO-103（`addresses`・`tenancies` の 2 表）
  - YGO-077（6 表のチケット。1 回の登録が `residents`・`credentials` も同じトランザクションで書く）
  - YGO-082（環境変数の読み込み）・YGO-085（KeyProvider の偽の鍵。`credentials` のメールアドレスの暗号化と HMAC）
  - YGO-089（住所のプール）
- 1 回の登録が 4 表を同じトランザクションで書くので、スキーマの YGO-103 のほかに YGO-077・YGO-082・YGO-085 に依存する。
- 待つもの:
  - YGO-078（`package.json` とロックファイル）。YGO-078 は YGO-088（実装のジョブで `node`・`npm` を動かす権限）を待つ。
  - 秘書の CI の定義（`check.yml`）の `prepare.sh` の段（ADR-0109 の D2・G-079）。CI が緑になるのはそのあと。このチケットの `done` は、`sh scripts/check.sh` がネットワークなしで通ることで決める `[assumed]`。

## 範囲
- `GET /api/v1/addresses/candidates`: 認証なし。プールの住所のうち `addresses` に行のない住所から 2 件以上を返し、件数の項目を持たない。
- `POST /api/v1/registrations` の住所を押さえるところ: プールにあり `addresses` に行がない住所なら、1 つのトランザクションで `residents`・`credentials`・`addresses`（active）・`tenancies`（is_current）を書いて 201。`addresses` に行のある住所は 409（`conflict`）で何も作らない。409 の本文は 1 つの定数から作る（TC-015 が TC-006 の 409 と同じであることを確かめるため）`[assumed]`。
- パスワードのハッシュ（Argon2id）は Node.js の組み込みの `node:crypto` を使い、依存を足さない `[assumed]`。その関数がないと分かったら、このチケットを止め、依存を足すチケットを別に切る（ADR-0106）。
- TC-013・TC-014・TC-015 のテスト。

## 直さないところ
- 空き家を候補から除くこと（FR-007）: YGO-091。
- 期限切れの確認が済まない登録の扱い: YGO-092。
- `auth_tokens` の行・J18 を積むこと・201 の本文の形・流量の制限（FR-091）: YGO-093・YGO-094。
- 同時の登録の 409（TC-006、FR-003）と、`age`・`birthday`・`interests` の検査の TC（FR-113 の TC-045〜TC-049、FR-127 の TC-063〜TC-065）: このチケットの後に、その FR のチケットとして切る。経路はこれらの項目を `api.md` §5 のとおり受け取って保存する。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-090 M1 FR-010 候補の取得と使われたことのない住所の登録`・`状態: done`・`M: M1`。
2. TC-013・TC-014・TC-015 のテストがあり、`sh scripts/check.sh` が通る（JUnit XML に `skipped` がない）。
3. どのテストもネットワークなしで動く。
