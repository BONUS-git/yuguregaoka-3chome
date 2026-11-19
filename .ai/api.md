# API 設計方針

- 状態: 草案
- 日付: 2026-11-19
- 根拠: brief・requirements・features・architecture・db
- チケット: YGO-005
- 関連 ADR: 0001〜0015・0025

---

## §1 原則

1. **即時性を持ち込まない**（P-1、FR-014、FR-030）[explicit]
   - WebSocket、SSE、ロングポーリングは作らない。
   - 「新着があるか」を問い合わせるエンドポイントも作らない。
   - 住民がアプリを開いたときに郵便受けを取りに行く形にする。
   - 配達完了の通知（OQ-002 → 決定、ADR-0025）は、配達回の公開のあとに worker（J15）が送る。API からは通知を送らない。
     API が受けるのは、通知の購読の登録と削除だけ（§7 F-05）。

2. **数値の評価を返さない**（P-2、FR-017、FR-038、FR-044、FR-055）[explicit]
   - 返さないもの: 既読フラグ、未読件数、総件数、閲覧数、反応数、住所録への登録数、1 日の上限の残り回数。
   - 配達完了の通知に載せる郵便の件数は、通知の中身にだけ載せる。API の応答には載せない（ADR-0025 の D5）。

3. **同期で返すのは「受け付けた」まで**（ADR-0004、ADR-0008）[explicit]
   - 配達・審査・組版は worker が定時に行う。API は受付の状態（pending / awaiting_review）まで。

4. **外から見える識別子は住所文字列のみ**（ADR-0001、db.md §3）[inferred]
   - 内部の UUID や `registered_tenancy_id` はレスポンスに含めない。

5. **API の経路で LLM を呼ばない**（NFR-011）[explicit]
   - 認可やポリシーの判断に LLM を使わない。

---

## §2 API・DB・バッチの責務の分け方

### §2.1 3 者の責務の表

| | 行うこと | 行わないこと |
|---|---|---|
| **API（web、C2 → C3）** | 認証、認可（本人のものか・ロール）、入力の検証（JSON Schema）、上限の確認（2,000 字・1,000 字・1 日 20 通・1 日 5 件）、受付の状態での保存、配達済みの物の読み出し、手紙の復号（本人に返すときだけ）、すぐに実行するジョブの投入（ID だけを同じトランザクションで積む） | 配達、審査、LLM の呼び出し、組版、画像の加工、時刻で決まる状態の変更、配達先の決定（転送・差し戻し・ブロックによる抑止）、物理削除の実行 |
| **DB（C7）** | 正本、一意の制約（配達・組版の冪等性）、外部キー、状態の値の制約、ジョブのキュー | 業務ロジックをトリガーやストアドプロシージャに置くこと [assumed]。理由: C3 に集めてテストしやすくするため（NFR-061） |
| **バッチ（worker、C4 → C3）** | JST の cron で動く処理（締め切り、審査、組版、配達、休眠の判定、保持期間による削除）と、すぐに実行するジョブ（退去時の消去、組み直し） | HTTP の受け付け、住民の権限での操作（システムの権限で動く） |

### §2.2 状態を誰が動かすかの表

db.md §4 の状態遷移に合わせる。

| 対象 | API が動かす | worker が動かす |
|---|---|---|
| `letters` | `pending` | `scheduled`、`delivered`、`blocked`、`suppressed`、`returned` |
| `board_posts` | `awaiting_review`、本人または管理者による `deleted` | `approved`、`rejected`、`published` |
| `mailbox_items` | `deleted_at`（FR-099） | 作成 |
| `delivery_runs` | `pending` の行の作成のみ | それ以降のすべての遷移 |
| `newspapers`、`newspaper_items`、`moderation_queue` | — | すべて |
| `reports` | 作成、管理者の操作による `closed` / `dismissed` | — |
| `moderation_actions` | 管理者の操作で作成 | — |
| `addresses.status` | 登録時の `active`、ログイン時の `dormant → active`（段階 3） | `dormant`、`vacant_*`（MVP は J7 の `vacant_deleted` だけ。ほかは段階 3、ADR-0023） |
| `residents` | `deleted_at`（退去の受付） | 物理削除 |

### §2.3 締め切りの境目

- API は共有の関数 `nextDeliveryRun(now)` で配達回 ID を決める。
- `delivery_runs` の行がなければ `INSERT … ON CONFLICT DO NOTHING`（`status=pending`）で作る。
- 同じトランザクションの中でその行を `FOR SHARE` で読み、`pending` でなければ次の便の配達回にする。
- 締め切り処理は `status=running` に更新するので、共有ロックの解放を待つ。こうして、締め切った配達回に書き込みが紛れ込まないようにする [inferred]。詳しくは async.md に引き継ぐ。

### §2.4 同期でやること・非同期でやることの流れ

**F-04 手紙の投函**
1. API: 宛先住所の形式と存在を確認する
2. API: 本文を暗号化し、`pending` 状態で `letters` に保存する。同じトランザクションで `nextDeliveryRun` を呼び `delivery_runs` 行を冪等に作る（§2.3）
3. API: `202` と `{id, delivery_run_id}` を返す
4. worker: 締め切り時刻に `scheduled` → 配達時刻に `delivered` / `suppressed` / `returned` / `blocked` に遷移させる

**F-07 掲示板の投稿**
1. API: 本文（1,000 字以内）を検証し、`awaiting_review` 状態で `board_posts` に保存する
2. API: `202` と `{id}` を返す
3. worker: 締め切り処理でモデレーション → `approved` / `rejected` → 配達時に `published`

**退去（DELETE /me）**
1. API: `residents.deleted_at` を設定、セッションを無効化、`account.erase` ジョブを同一トランザクションで積む
2. API: `202` を返す
3. worker: `account.erase` ジョブを受け取り、ADR-0013 の表に従い消去・組み直しを行う

### §2.5 コードの置き場所

- ルートのハンドラは薄くする: 解析 → 認証 → C3 のサービスを呼ぶ → エラーの対応付け。
- 本人のものかの確認と、クエリを本人の分に絞ること（`WHERE owner_id = $me` など）は、C3 のサービスの関数で必ず行う。
- worker も同じ C3 を使う（ADR-0008）。

---

## §3 API の形

- HTTPS と JSON、資源ごとの区切り、接頭辞は `/api/v1` [assumed]。
- スキーマは Fastify の JSON Schema で、型はクライアントと共有する（ADR-0009）。

**時刻**
- ISO 8601 の `+09:00` で返し、JST だけに対応する（OQ-034、NFR-048）。
- メッセージは日本語のみ（NFR-047）。
- 受取人に見せるのは「書いた時刻」ではなく配達回（例: `2026-11-19-morning`）[inferred]。

**キャッシュ**
- 住民の情報には `Cache-Control: no-store` を付ける。

---

## §4 認証と権限の確認の位置

- 認証は Fastify の preHandler で行う。方式はメールアドレス＋パスワード（ADR-0018、OQ-028 は決定）。
  セッションはサーバー側に持ち、複数の端末で同時に持てる（ADR-0019、OQ-036 は決定）。詳細は security.md §3。
- 認証なしで呼べるのは次の 3 つだけ（NFR-014）: 住所の候補、登録、ログイン。
- 本人のものかの確認は C3 で行う。本人のものでないときや存在しないときは `404` を返し、存在するかどうかを明かさない [inferred]。
- `/api/v1/admin/*` はロールで確認する。ロールは住民とモデレーターの 2 つで、admin 経路はモデレーターだけが呼べる（ADR-0020、security.md §4、OQ-031 は決定）。`403` を返すのは admin 経路のときだけ。
- ブロックの判断は API ではしない。送った人にブロックを気づかれないよう、送信は受け付け、配達のときに `suppressed` にする（db.md §3）。
  - architecture.md C2 の「ブロック」は「ブロックの登録を受け付けること」と読む。§10 で文言の整理を提案する。

---

## §5 エラーの形

```json
{ "error": { "code": "...", "message": "日本語のメッセージ", "details": {} } }
```

| 状態コード | code |
|---|---|
| 400 | `validation_failed`、`body_too_long` |
| 401 | `unauthenticated` |
| 403 | `forbidden`（admin 経路のみ） |
| 404 | `not_found` |
| 409 | `conflict`（住所を選ぶときの競合など） |
| 429 | `daily_limit_reached`（残りの数は返さない） |
| 500 | `internal` |
| 503 | `unavailable` |

スタックトレース、内部 UUID、`registered_tenancy_id` は返さない。

---

## §6 ページング

- カーソル方式。`?cursor=&limit=`、limit は既定 20・最大 50 [assumed]。
- 応答は `{ items, next_cursor }` で、総件数は返さない。
- 並びは決定的にし、人気の順は使わない。
  - 郵便受け: 配達回の新しい順 → 新聞 → 手紙 → id
  - 掲示板: 掲載された配達回の新しい順 → `created_at` → id
- 1 日の上限の数え方: JST の暦日ごとに数え、住民ごとに `pg_advisory_xact_lock` で直列にする [assumed]。

---

## §7 MVP の機能ごとのエンドポイントの概略（F-01〜F-09）

### F-01 架空の住所・プロフィール

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/addresses/candidates` | 住所の候補（OQ-022）。MVP では使われたことのない住所だけを返す。空き家の再割り当ては段階 3（ADR-0023） | 200 | FR-002, FR-003 |
| `GET` | `/api/v1/profiles/{address}` | 住所・ニックネーム・自己紹介だけを返す。空き家も存在しない住所も 404 | 200, 404 | FR-008 |

### F-02 アカウント

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `POST` | `/api/v1/registrations` | 住所の選択と認証情報の登録。認証情報は security.md で決める。開放式（OQ-007 の暫定） | 201 | FR-001, ADR-0001 |
| `POST` | `/api/v1/sessions` | ログイン | 200 | FR-011 |
| `DELETE` | `/api/v1/sessions/current` | ログアウト | 204 | — |
| `GET` | `/api/v1/me` | 自分のプロフィールを返す | 200 | FR-008 |
| `PATCH` | `/api/v1/me` | ニックネーム・自己紹介を更新する | 200 | FR-009 |
| `DELETE` | `/api/v1/me` | 退去を受け付ける（§2.4 参照） | 202 | FR-093, ADR-0013 |

### F-03 郵便受け

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/mailbox` | 配達済みのものだけ、削除したものを除いて返す | 200 | FR-030 |
| `GET` | `/api/v1/mailbox/items/{id}` | 手紙は復号して返す。既読は記録しない | 200, 404 | FR-014, FR-017 |
| `DELETE` | `/api/v1/mailbox/items/{id}` | 郵便受けから削除する | 204 | FR-099 |

### F-04 個人宛の手紙

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `POST` | `/api/v1/letters` | 本文（2,000 字以内）と宛先を受け付け、`pending` で保存する。返すのは `{id, delivery_run_id}` | 202 | FR-011, FR-012, ADR-0004 |
| `GET` | `/api/v1/letters/sent` | 送信済み一覧（投函済み / 配達済み / 差し戻し） | 200 | FR-018 |
| `GET` | `/api/v1/letters/sent/{id}` | 送信済み手紙の詳細 | 200, 404 | FR-018 |

宛先の確認は住所の形式と存在まで。住んでいるか・転送するかは配達のときに決める。  
`suppressed` は「配達済み」として見せる。`blocked` の見せ方は §9 に書く。

### F-05 配達スケジュール

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/delivery-schedule` | ADR-0004 の固定の時刻表と次の便を返す | 200 | FR-021, ADR-0004 |

配達・組版を起こすエンドポイントは作らない（admin 用も作らない）。

**配達完了の通知の購読**（ADR-0025、FR-028・FR-102）

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/notifications/public-key` | VAPID の公開鍵を返す | 200 | FR-102, ADR-0025 |
| `PUT` | `/api/v1/me/push-subscription` | 今のセッションの購読を登録・更新する（`endpoint`・`keys.p256dh`・`keys.auth`）。`endpoint` が ADR-0025 の D6 の検査で外れたら 400（`validation_failed`） | 204, 400 | FR-102, ADR-0025 |
| `DELETE` | `/api/v1/me/push-subscription` | 今のセッションの購読を消す | 204 | FR-102, ADR-0025 |

- 応答には郵便の件数を含めない。認証と CSRF 対策は他のエンドポイントと同じ（security.md §3）。
- 1 セッションに購読は 1 つ。他のセッション・他の住民の購読は扱えない（security.md §4.2）。
- ログアウト（`DELETE /api/v1/sessions/current`）・セッションの無効化・退去では、そのセッションの購読も同じトランザクションで消す（ADR-0019）。

### F-06 朝刊・夕刊

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/newspapers/{id}` | 紙面の情報（休刊の印を含む） | 200, 404 | FR-031, ADR-0007 |
| `GET` | `/api/v1/newspapers/{id}/page` | web が認証してから C8 の HTML を中継する [assumed] | 200, 404 | FR-033 |

MVP では、自分の郵便受けに届いた紙面だけを見られる（バックナンバーの F-12 は段階 2）。

### F-07 町内掲示板

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/board` | `published` の投稿だけを返す | 200 | FR-041, FR-042 |
| `GET` | `/api/v1/board/posts/{id}` | `published` の投稿の詳細 | 200, 404 | FR-042 |
| `POST` | `/api/v1/board/posts` | 本文（1,000 字以内）を受け付け、`awaiting_review` で保存する | 202 | FR-043, ADR-0004 |
| `GET` | `/api/v1/me/board-posts` | 本人に見せる状態（掲載待ち / 掲載済み / 掲載見送り） | 200 | FR-044 |
| `DELETE` | `/api/v1/board/posts/{id}` | 投稿を削除する（本人または管理者） | 204 | FR-050 |

### F-08 通報・ブロック・モデレーション

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `POST` | `/api/v1/reports` | 通報を受け付ける（通報した人に処理状態は返さない） | 202 | FR-076, FR-079 |
| `POST` | `/api/v1/blocks` | ブロックを登録する | 201 | FR-068 |
| `GET` | `/api/v1/blocks` | 自分のブロックリストを返す | 200 | FR-068 |
| `DELETE` | `/api/v1/blocks/{id}` | ブロックを解除する | 204 | FR-068 |
| `GET` | `/api/v1/admin/reports` | 通報一覧（admin のみ） | 200 | FR-077, FR-078 |
| `POST` | `/api/v1/admin/reports/{id}/actions` | 通報に対する操作（approve / reject / dismiss） | 200 | FR-077 |
| `GET` | `/api/v1/admin/moderation-queue` | `review` ラベルの審査キュー（admin のみ） | 200 | FR-080, ADR-0005 |

### F-09 住所録

| メソッド | パス | 要約 | 状態コード | FR / ADR |
|---|---|---|---|---|
| `GET` | `/api/v1/address-book` | 自分の住所録を返す（`?q=` で本文内検索） | 200 | FR-059, FR-051 |
| `POST` | `/api/v1/address-book` | エントリを追加する | 201 | FR-051 |
| `PATCH` | `/api/v1/address-book/{id}` | メモの変更と、手で住所を直すこと（ADR-0003）。住所を直すときは `registered_tenancy_id` をそのときの居住記録に取り直す | 200 | FR-056, FR-057, ADR-0003 |
| `DELETE` | `/api/v1/address-book/{id}` | エントリを削除する | 204 | FR-053 |

### 段階 2 以降（F-10〜F-18）

この文書の範囲外。MVP のパスの形を広げる。

---

## §8 作らない API

| 経路 / 機能 | 理由 |
|---|---|
| WebSocket・SSE・ロングポーリング | P-1 に反する |
| 新着の件数・未読件数 | P-2 に反する（FR-017） |
| 既読フラグの操作・記録 | FR-017 に反する |
| 総件数（ページングの `total`） | P-2 に反し、カーソル方式で不要 |
| いいね・反応 | P-2 に反する（FR-038） |
| 誰が自分を住所録に登録しているか | FR-058（意図的に開示しない） |
| 配達・組版を今すぐ起こす操作 | ADR-0004 の定時配達に反する |
| 通知を今すぐ送る・試しに送る操作 | 通知は配達回の公開のあとに worker が 1 回だけ送る（ADR-0025 の D2） |
| LLM の判断をそのまま返す経路 | NFR-011 に反する |

---

## §9 未確定事項

- **締め切り直前の書き込みの扱いの詳細**: 競合状態の正確な手順は async.md に引き継ぐ。
- **掲載済み投稿を本人が削除したときの組み直し**: ADR-0013 と同じ組み直しジョブを使う予定 [assumed]。
- **投函の取り消し API を作るか**: 範囲外。別チケットで検討する。
- **`returned`・`blocked` を送った人にどう知らせるか**: `blocked` を「配達済み」と同じに見せると送った人が気づけない。別の表示（例: 差し戻し）にするかは別チケットで決める。
- **一般的な流量の制限と CSRF 対策**: security.md に引き継ぐ。
- **管理者のロール定義**: OQ-031 は決定（住民とモデレーターの 2 つ、付与は運用者 CLI のみ、ADR-0020・security.md §4）。
- **認証の方式**: OQ-028 は決定（メールアドレス＋パスワード、ADR-0018・security.md §3）。
- **複数の端末のセッション管理**: OQ-036 は決定（複数の端末で持てる、ADR-0019・security.md §3.3）。
- **プッシュ通知**: OQ-002 は決定（配達完了の通知を Web Push で送り、郵便の件数を含める。ADR-0025・§7 F-05）。
  何を数えるか・0 通の便で送るか・件数のほかの中身は OQ-042（要回答）の暫定（手紙だけ・0 通には送らない・便と件数だけ）。

---

## §10 他の文書への変更提案（別チケット）

1. **db.md §4 `delivery_runs` のライフサイクル表**: 作成のタイミングを「締め切り処理時」→「API による pending 行の冪等な作成、または締め切り処理」に直す（§2.3 参照）。

2. **db.md §2 `letters`**: `sender_address_text`（投函時点の住所文字列）カラムを追加する。
   理由: 送った人が引っ越したあと、受け取った人に新しい住所が見えてしまわないようにするため（ADR-0003 の考え方）。

3. **db.md §2 `board_posts`**: `author_address_text`（投稿時点の住所文字列）カラムを追加する（同じ理由）。

4. **db.md §2 `blocks`**: ブロックした時点の住所文字列を足す（同じ理由）。

5. **architecture.md C2**: 「ブロック」の確認はブロックの登録の受け付けのことで、送信のときにはブロックの判断をしないと明記する。

6. **open-questions.md OQ-034**: 担当の文書として api.md §3 を参照するよう追記する。

---

## §11 FR / NFR との対応表

| FR / NFR | 対応する設計 |
|---|---|
| FR-008 | §7 F-01 `GET /profiles/{address}` |
| FR-011〜014 | §7 F-03 / F-04 |
| FR-017 | §8（既読・未読件数を返さない） |
| FR-018 | §7 F-04 `GET /letters/sent` |
| FR-021 | §7 F-05 `GET /delivery-schedule` |
| FR-028 | §1 原則 1・2・§7 F-05 通知の購読（送るのは worker、async.md J15） |
| FR-030 | §8（リアルタイム経路なし）・§7 F-03 |
| FR-038 | §8（いいね・反応なし） |
| FR-041〜044 | §7 F-07 |
| FR-050 | §7 F-07 `DELETE /board/posts/{id}` |
| FR-051〜057, FR-059 | §7 F-09 |
| FR-058 | §8（誰が住所録に登録しているかを返さない） |
| FR-068 | §7 F-08 ブロック |
| FR-076〜080 | §7 F-08 通報・モデレーション |
| FR-091〜093 | §7 F-02 `DELETE /me`・§2.4 退去の流れ |
| FR-099 | §7 F-03 `DELETE /mailbox/items/{id}` |
| FR-102 | §7 F-05 `PUT` / `DELETE /me/push-subscription`・`GET /notifications/public-key` |
| NFR-004 | §4（認証なし経路を 3 つに限定） |
| NFR-006 | §5（エラーに内部情報を返さない） |
| NFR-011 | §1 原則 5・§8 |
| NFR-014 | §4（認証の preHandler） |
| NFR-047 | §3（メッセージは日本語のみ） |
| NFR-048 | §3（時刻は JST の ISO 8601） |
| NFR-051 | §2（API・DB・バッチの責務の分け方） |
| NFR-055 | ADR-0014（シンプルな形を選ぶ理由） |
| NFR-061 | §2.1（業務ロジックを DB のトリガーに置かない） |
