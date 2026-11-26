# 0101 — 認証の表と、送る前のトークンと前のアドレス

- 状態: 置き換え（→ 0102）
- 日付: 2026-11-26

ADR-0089 を丸ごと置き換える。ADR-0089 の決定（`sessions` の D1・`staff_roles` の D2・TOTP の秘密の D3・`rate_limit_buckets` の D4・退去と消し方の D5・`auth_tokens` の D6）は、今の状態に書き直してこの ADR に同じ番号で移した。
新しく決めたのは、確認と再設定のメールを worker の J18 `mail.send`（`async.md` §4 J18）が送るために、送る前のリンクのトークンと、メールアドレスの変更が済んだときの前のアドレスを、`auth_tokens` の列に暗号化して置くこと（D7）。`reviews/0003-phase-evaluation-2026-11-26.md` の R-060（YGO-051）による。
ADR-0020（ロールの表か列か）・ADR-0080 の D2（確認と再設定のトークンの保存先の表を R-025 で決める）・ADR-0090 の D1・D6・D7（`sessions`・TOTP の秘密・変更中の新しいメールアドレスの置き場と、前のアドレスへの知らせ）・ADR-0088（数えの表）が指す表の定義を、この ADR で決める。それらの決定の中身は変えない。

## 背景

`security.md` §3.3・§3.5・§4.1 は、セッション・数え・ロールの付与の記録に持つ項目を挙げていたが、`db.md` §2 に表がなかった。
M1 の受け入れ（`roadmap.md` A-11〜A-13）は、セッションの無効化・再認証の時刻・流量の制限・退去での行の消し方を DB で直接確かめるので、表と列の名前がないとテストが書けない。

メールを送るのは worker（`environment.md` §8.1 の `MAIL_ADAPTER` は worker だけ）で、web は要求と同じトランザクションで J18 を積む。リンクにはトークンの平文が要るが、`auth_tokens.token_hash` は web だけが持つ `RESET_TOKEN_SIGNING_KEY` の HMAC（D6）で、worker はトークンを作ることも、ハッシュから戻すこともできない。
また ADR-0090 の D7 は、メールアドレスの変更の確認が済んだら前のアドレスに知らせると決めている。確認が済むと `credentials` は新しいアドレスになるので、前のアドレスは DB のどこにも残らない。ジョブのペイロードは ID だけにする（`security.md` T-03、`db.md` §6）ので、どちらの値も worker に渡す置き場が要る。

## 決定

1. **D1 `sessions`**: 1 つのログインに 1 行。
   - `id` UUID PK（一覧で見せる識別子。Cookie の値とは別、ADR-0090 の D3）
   - `token_hash` bytea NOT NULL UNIQUE（Cookie のセッション ID の SHA-256。セッション ID の平文は DB に持たない）
   - `resident_id` UUID NOT NULL FK→residents（既定の NO ACTION、ADR-0091 の D9）
   - `created_at`・`last_seen_at`・`expires_at` timestamptz NOT NULL。`expires_at` は `least(created_at + 90 日, last_seen_at + 30 日)`（ADR-0090 の D1）で、`last_seen_at` を書くときに一緒に書く。`last_seen_at` は前に書いた時刻から 1 時間を過ぎた要求のときだけ書く `[assumed]`（要求のたびの UPDATE を避ける）
   - `reauthenticated_at` timestamptz NOT NULL（ログインと再認証の時刻、ADR-0090 の D5）
   - `second_factor_at` timestamptz NULL（二要素認証を済ませた時刻、ADR-0090 の D6。NULL = 済ませていない）
   - `invalidated_at` timestamptz NULL（退去の受付だけが書く、ADR-0090 の D4）
   - 索引: (`resident_id`)（一覧・すべて消す・J7）と (`expires_at`)（J14）。
   - IP アドレスと端末の情報の列は置かない（ADR-0090 の D3）。
2. **D2 `staff_roles`**: ロールの付与の記録（ADR-0020 の「`staff_roles` テーブルか `residents` の列か」は表にする）。
   - PK (`resident_id`, `role`)。`resident_id` UUID FK→residents（既定）。
   - `role` text NOT NULL CHECK(`role IN ('moderator')`)。住民（`resident`）のロールは行を持たない（登録した住民はみな住民）。
   - `granted_at` timestamptz NOT NULL・`granted_by` text NOT NULL（付与した運用者の CLI の作業者の識別子。住民の ID ではない）。
   - 付与は運用者の CLI が行を入れ、剥奪は行を消す。API・C2 のどの経路も、この表に書かない（ADR-0020）。
3. **D3 TOTP の秘密**: `credentials` に 4 列を足す。別の表は作らない。
   - `totp_secret_encrypted` bytea NULL（AES-256-GCM。鍵はメールアドレスと同じ鍵輪 `EMAIL_KEYRING`、AAD は `resident_id` と用途 `totp` を合わせたもの）
   - `totp_key_version` int NULL（暗号化した鍵の版）
   - `totp_enabled_at` timestamptz NULL（有効にした時刻。NULL で秘密があれば、登録したがまだ有効にしていない、ADR-0090 の D6）
   - `totp_last_step` bigint NULL（最後に通したコードの時間の刻み。同じ刻みか前の刻みのコードを通さず、使い回しを拒む `[assumed]`）
   - CHECK: `totp_secret_encrypted` と `totp_key_version` は、どちらも NULL か、どちらも値がある。`totp_enabled_at` は秘密があるときだけ値を持てる。
   - 作り直しと解除（運用者の CLI）は 4 列を NULL にする。
4. **D4 `rate_limit_buckets`**: 流量の制限の数え（ADR-0088）。
   - PK (`key`, `window_start`)。`key` bytea（ADR-0088 の D3 の HMAC）、`window_start` timestamptz。
   - `count` int NOT NULL、`updated_at` timestamptz NOT NULL。
   - 住民を指す外部キーを持たない（`key` から住民は引けない）。J14 が `window_start < now() - interval '1 day'` の行を消す（いちばん長い窓が 1 日）。退去の J7 では消さない。
5. **D5 退去と消し方**:
   - `sessions`: 今のまま（受付で `invalidated_at`、J7 の手順 0 で行をすべて消して `erasure_log` に記録、ADR-0091 の D8）。
   - `staff_roles`: J7 の手順 5 で、その住民の行を消す（`erasure_log` には記録しない）。
   - TOTP の列: `credentials` の行と一緒に J7 の手順 0 で消える。
   - `keys.reencrypt` の `kind: 'email'` は、同じ行の `totp_secret_encrypted` も、`totp_key_version = from_version` の行を今の版に暗号化し直す。
   - `auth_tokens`: J7 の手順 0 で、`credentials` の前にその住民の行をすべて消し、`erasure_log` に記録する（ADR-0091 の D8）。期限を過ぎた行は J14 が消す（ADR-0091 の D14）。D7 の列は行と一緒に消える。
6. **D6 `auth_tokens`**: メールの確認・パスワードの再設定・メールアドレスの変更の確認のトークン（ADR-0080 の D2・D6・D7、ADR-0090 の D7）。1 回の発行に 1 行。ADR-0080 の D2 が「保存先の表の定義は R-025 で決める」と送っていた表。
   - `id` UUID PK。
   - `token_hash` bytea NOT NULL UNIQUE（`HMAC-SHA-256(RESET_TOKEN_SIGNING_KEY, トークン)`。トークンは推測できない 32 バイトの乱数で、メールのリンクにだけ載せる。平文は DB・ログに持たない）。
   - `resident_id` UUID NOT NULL FK→residents（既定、ADR-0091 の D9）。
   - `purpose` text NOT NULL CHECK(`purpose IN ('email_verification', 'password_reset', 'email_change')`)。
   - `new_email_encrypted` bytea NULL・`new_email_key_version` int NULL（`email_change` のときだけ値を持つ。確かめる前の新しいメールアドレスを、メールアドレスと同じ鍵輪 `EMAIL_KEYRING` で暗号化する。AAD は `resident_id` と用途 `email_change`）。CHECK: `purpose = 'email_change'` のときだけ、2 列どちらにも値がある。
   - `created_at`・`expires_at` timestamptz NOT NULL、`used_at` timestamptz NULL。
   - `expires_at`: `email_verification` は `credentials.created_at + 24 時間`（ADR-0087 の D2。送り直しで作る行も同じ時刻）、`password_reset` は発行から 30 分（ADR-0080 の D2）、`email_change` は発行から 24 時間 `[assumed]`。
   - 確かめは `token_hash` で引き、`purpose` が経路に合い、`used_at IS NULL` かつ `expires_at > now()` の行だけを通す（どれに外れても 400 `token_invalid`）。通したら同じトランザクションで `used_at` を書く。
   - 同じ住民・同じ `purpose` の新しい行を作るときは、同じトランザクションでまだ使っていない前の行を消す `[assumed]`（有効なトークンを 1 つにする）。
   - 索引: (`resident_id`)（J7・前の行を消す）と (`expires_at`)（J14）。
   - `keys.reencrypt` の `kind: 'email'` は、`new_email_key_version = from_version` の行の `new_email_encrypted` も暗号化し直す。
7. **D7 J18 が送るまでの値**: `auth_tokens` に次の 4 列を足す。別の表は作らない `[assumed]`。
   - `mail_token_encrypted` bytea NULL・`mail_token_key_version` int NULL: リンクに載せるトークン（D6 の 32 バイトの乱数）を AES-256-GCM で暗号化した値と鍵の版。鍵輪は `EMAIL_KEYRING`、AAD は `id` と用途 `auth_token_mail`。API が行を作るのと同じトランザクションで書き、同じトランザクションで J18（`kind` は `purpose` と同じ）を積む。J18 が送ったあと（使った・期限を過ぎたトークンで送らないと決めたときも）NULL にする。
   - `old_email_encrypted` bytea NULL・`old_email_key_version` int NULL: `email_change` の確認（`POST /api/v1/email-verifications`）が通ったとき、`credentials` を新しいアドレスに書き換えるのと同じトランザクションで、前のアドレスを暗号化して書く（鍵輪は `EMAIL_KEYRING`、AAD は `id` と用途 `email_change_notice`）。同じトランザクションで J18（`kind = email_change_notice`）を積む。J18 が送ったあと NULL にする。
   - CHECK: 2 列の組はどちらも NULL か、どちらも値がある。`old_email_*` は `purpose = 'email_change'` かつ `used_at IS NOT NULL` の行だけが持てる。
   - J18 のペイロードは `{kind, auth_token_id}` だけ。トークン・メールアドレスの平文と暗号文をペイロードに入れない。
   - 退去と保持期間は `auth_tokens` の行のまま（ADR-0091 の退去の表と保持期間の表の `auth_tokens` の行、D8・D14）。4 列は行と一緒に消え、CASCADE も新しい消す手順も使わない。J14 が `expires_at < now()` の行を消すと、送れずに残った値も消える。
   - `keys.reencrypt` の `kind: 'email'` は、`mail_token_key_version`・`old_email_key_version` が `from_version` の行の値も暗号化し直す。
   - 確認の期限が近い `email_change` で前のアドレスへの知らせが送れないまま J14 が行を消したときは、知らせは送らずに終わる（J18 の再試行は約 15 分で尽き、J14 は 1 日に 1 回なので、まれ）`[assumed]`。

## 理由

- **セッション ID のハッシュだけを持つ**: DB やバックアップが漏れても、そのままセッションを乗っ取れない。等値で引ければ足りるので、遅いハッシュは要らない（セッション ID は推測できない乱数）。
- **一覧の `id` を別の列にする**: 一覧の応答・ログから Cookie の値に戻れない（ADR-0090 の代わりの案）。
- **`expires_at` を 1 列にする**: J14 と認証の確かめが 1 つの比較で済み、ADR-0091 の保持期間の条件（`expires_at < now()`）をそのまま使える。
- **ロールを表にする**: ロールの付与の記録（`granted_at`・`granted_by`）を `residents` に持たせると、ほとんどの住民で NULL の列が増える。ロールを足すときも行を足すだけで済む（ADR-0020 の「将来の追加の余地」）。
- **TOTP の秘密を `credentials` に置く**: 退去で J7 の手順 0 が最初に消す範囲と、鍵の入れ替えで暗号化し直す範囲を 1 つの表にまとめる、という `credentials` を分けた理由（`db.md` §2）にそのまま当たる。
- **メールアドレスと同じ鍵輪**: 秘密の数を増やさない。AAD に行の ID と用途を入れるので、ほかの暗号文と取り替えても復号できない。
- **トークンを 1 つの表にまとめ、鍵付きのハッシュで持つ（D6）**: 3 つの用途は持つ列も確かめ方も同じで、違うのは期限だけ。`RESET_TOKEN_SIGNING_KEY` を鍵にした HMAC にすれば、DB だけが漏れてもリンクの値を確かめられず、鍵を別に持つ意味がある。変更中の新しいメールアドレスを `credentials` に置くと、確かめる前の値が今のアドレスと同じ行に並び、取り消しと期限の扱いが `credentials` に入る。
- **送る前のトークンを `EMAIL_KEYRING` で暗号化して置く（D7）**: メールを送る側は、どの作り方でもトークンの平文を一度は持つ。暗号化して置けば、DB だけが漏れてもリンクは作れない（D6 の前提はこの場合も保たれる）。DB と `EMAIL_KEYRING` がともに漏れると、まだ送っていないトークンからリンクを作れる。これは D6 の前提を弱めるが、その範囲は送る前の行だけに限る: 値は J18 が送れば数秒で NULL になり、送れなくても `expires_at`（最長 24 時間）のあとの J14 で消える。送ったトークンは平文も暗号文も残らず、`RESET_TOKEN_SIGNING_KEY` がなければ確かめられないまま。同じ漏れで、すべての住民のメールアドレスと TOTP の秘密がすでに読めるので、増える危険は限られる。トークンの行を要求と同じトランザクションで作れるので、前のトークンの削除・登録との原子性・24 時間の期限（ADR-0087）を web の 1 か所で決められる。
- **前のアドレスを同じ行に置く（D7）**: 知らせは確認のトークンの使用と 1 対 1 で、トークンの行は期限まで残る（D6）。同じ行に置けば、退去（J7 の手順 0）と保持期間（J14）の消し方が `auth_tokens` の行のままで済み、ADR-0091 の表を変えない。
- **数えの表に外部キーを持たせない**: 数えは認証の前にも書き、IP やメールアドレスも主体にするので、住民に結び付けない。1 日で消えるので退去で消す必要もない。

## 代わりの案（選ばなかった理由）

- **`residents.role` の列**: 付与の記録の列が住民の表に増える。ロールが 2 つ以上の住民を表せない。不採用。
- **TOTP の秘密を別の表（`second_factors`）に置く**: J7 の手順 0 と `keys.reencrypt` の対象が増える。モデレーターは少なく、列が NULL の行が多くても困らない。不採用。
- **セッション ID の平文を PK にする**: DB の読み取りでセッションを乗っ取れる。不採用。
- **数えをメモリに持つ**: web を 2 台以上にすると数えが分かれ、再起動で消える。不採用。
- **worker に `RESET_TOKEN_SIGNING_KEY` を持たせ、トークンを worker が作る（復号できる値を DB に置かない）**: 鍵を持つのが web と worker の両方になり、「web だけが持つ」の分け方がなくなる（worker が漏れれば、DB に書ける者がどの住民の有効なトークンも作れる）。トークンの行を要求のトランザクションで作れなくなり、前のトークンの削除・登録との原子性・期限の判定が worker に移って、要求が巻き戻ったあとにトークンだけ残る順序を考える必要が出る。前のアドレスへの知らせの置き場の問題も残る。不採用。
- **暗号化したトークンや前のアドレスをジョブのペイロードに入れる**: ペイロードは ID だけにする決まり（`security.md` T-03）に反し、値が `jobs` と pg-boss の保存期間のあいだ残って、送ったあとに消せない。不採用。
- **別の表（`auth_token_mails`）に置き、`auth_tokens` の削除に CASCADE でつける**: 外部キーを CASCADE にしない方針（ADR-0091 の D8・D9）の例外になり、退去の表と保持期間の表に行が増える。CASCADE にしないなら J7 の手順 0・J14・前のトークンの削除のすべてに手順が増える。列なら行と一緒に消えるので、どちらも要らない。不採用。
- **ID と別の鍵からトークンを導く（web と worker が導く鍵を持つ）**: 漏れたときの範囲は `EMAIL_KEYRING` と同じで、秘密が 1 つ増える。送ったあとも鍵がある限り導けるので、送ったら消す、ができない。不採用。

## 影響

- `db.md`: §2 に 4 つの表と `credentials` の 4 列、`auth_tokens` の D7 の 4 列、住民を指す外部キーの表に `sessions`・`staff_roles`・`auth_tokens` の行、§4 のライフサイクル表に `staff_roles`・`rate_limit_buckets`・`auth_tokens`、§6 の J18 のペイロード、§9 の OQ-031 の行。
- 退去と保持期間の表（正本）: ADR-0091（D8・D13・D14）。D7 の列は `auth_tokens` の行のまま。
- `security.md`: §2.1・§2.5・§3.3・§3.5・§4.1。
- `async.md`: J7 の手順 5、J14 の対象、J18、`keys.reencrypt` の対象。
- `api.md`: §2.4 の F-02 の流れ、§7 F-02 の登録・送り直し・再設定の依頼・メールアドレスの変更の要求と確認。
- `environment.md`: §8.1 の `EMAIL_KEYRING`、§8.3 の再暗号化の範囲。
- 図: `diagrams/m1-er.md`・`diagrams/m1-components.md`・`diagrams/m1-registration-sequence.md`。
- `requirements.md`: FR-098（`sessions`・TOTP の列）・FR-100（`sessions`）・NFR-013（`staff_roles`・TOTP の列・`rate_limit_buckets`）の行の根拠。
