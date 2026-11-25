# 0089 — セッション・役割・流量の表と TOTP の秘密の置き場

- 状態: 採用
- 日付: 2026-11-25

`db.md` §2 に `sessions`・`staff_roles`・`rate_limit_buckets`・`auth_tokens` の表と、TOTP の秘密の置き場を定義する（K-014、`triage.md` 仕分け 3。`reviews/0001-design-review.md` の R-025）。
ADR-0020（ロールの表か列か）・ADR-0080 の D2（確認と再設定のトークンの保存先の表を R-025 で決める）・ADR-0090 の D1・D6・D7（`sessions`・TOTP の秘密・変更中の新しいメールアドレスの置き場）・ADR-0088（数えの表）が指す表の定義を、この ADR で決める。それらの決定の中身は変えない。

## 背景

`security.md` §3.3・§3.5・§4.1 は、セッション・数え・ロールの付与の記録に持つ項目を挙げていたが、`db.md` §2 に表がなかった。
M1 の受け入れ（`roadmap.md` A-11〜A-13）は、セッションの無効化・再認証の時刻・流量の制限・退去での行の消し方を DB で直接確かめるので、表と列の名前がないとテストが書けない。

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
   - `auth_tokens`: J7 の手順 0 で、`credentials` の前にその住民の行をすべて消し、`erasure_log` に記録する（ADR-0091 の D8）。期限を過ぎた行は J14 が消す（ADR-0091 の D14）。
6. **D6 `auth_tokens`**: メールの確認・パスワードの再設定・メールアドレスの変更の確認のトークン（ADR-0080 の D2・D6・D7、ADR-0090 の D7）。1 回の発行に 1 行。ADR-0080 の D2 が「保存先の表の定義は R-025 で決める」と送っていた表で、R-025（K-014）のこの ADR で決める。
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

## 理由

- **セッション ID のハッシュだけを持つ**: DB やバックアップが漏れても、そのままセッションを乗っ取れない。等値で引ければ足りるので、遅いハッシュは要らない（セッション ID は推測できない乱数）。
- **一覧の `id` を別の列にする**: 一覧の応答・ログから Cookie の値に戻れない（ADR-0090 の代わりの案）。
- **`expires_at` を 1 列にする**: J14 と認証の確かめが 1 つの比較で済み、ADR-0091 の保持期間の条件（`expires_at < now()`）をそのまま使える。
- **ロールを表にする**: ロールの付与の記録（`granted_at`・`granted_by`）を `residents` に持たせると、ほとんどの住民で NULL の列が増える。ロールを足すときも行を足すだけで済む（ADR-0020 の「将来の追加の余地」）。
- **TOTP の秘密を `credentials` に置く**: 退去で J7 の手順 0 が最初に消す範囲と、鍵の入れ替えで暗号化し直す範囲を 1 つの表にまとめる、という `credentials` を分けた理由（`db.md` §2）にそのまま当たる。J7 の手順 0 も `keys.reencrypt` の対象の表も変わらない。
- **メールアドレスと同じ鍵輪**: 秘密の数を増やさない。AAD に用途を入れるので、メールアドレスの暗号文と取り替えても復号できない。
- **トークンを 1 つの表にまとめ、鍵付きのハッシュで持つ（D6）**: 3 つの用途は持つ列も確かめ方も同じで、違うのは期限だけ。`RESET_TOKEN_SIGNING_KEY` を鍵にした HMAC にすれば、DB だけが漏れてもリンクの値を確かめられず、鍵を別に持つ意味がある。変更中の新しいメールアドレスを `credentials` に置くと、確かめる前の値が今のアドレスと同じ行に並び、取り消しと期限の扱いが `credentials` に入る。
- **数えの表に外部キーを持たせない**: 数えは認証の前にも書き、IP やメールアドレスも主体にするので、住民に結び付けない。1 日で消えるので退去で消す必要もない。

## 代わりの案（選ばなかった理由）

- **`residents.role` の列**: 付与の記録の列が住民の表に増える。ロールが 2 つ以上の住民を表せない。不採用。
- **TOTP の秘密を別の表（`second_factors`）に置く**: J7 の手順 0 と `keys.reencrypt` の対象が増える。モデレーターは少なく、列が NULL の行が多くても困らない。不採用。
- **セッション ID の平文を PK にする**: DB の読み取りでセッションを乗っ取れる。不採用。
- **数えをメモリに持つ**: web を 2 台以上にすると数えが分かれ、再起動で消える。不採用。

## 影響

- `db.md`: §2 に 4 つの表と `credentials` の 4 列、住民を指す外部キーの表に `sessions`・`staff_roles`・`auth_tokens` の行、§4 のライフサイクル表に `staff_roles`・`rate_limit_buckets`・`auth_tokens`、§9 の OQ-031 の行。
- 退去と保持期間の表（正本）: ADR-0091（D8・D13・D14）。
- `security.md`: §2.1・§3.3・§3.5・§4.1。
- `async.md`: J7 の手順 5、J14 の対象、`keys.reencrypt` の対象。
- `environment.md`: §8.1 の `EMAIL_KEYRING`、§8.3 の再暗号化の範囲。
- 図: `diagrams/m1-er.md`・`diagrams/m1-components.md`。
- `requirements.md`: FR-098（`sessions`・TOTP の列）・FR-100（`sessions`）・NFR-013（`staff_roles`・TOTP の列・`rate_limit_buckets`）の行の根拠。
