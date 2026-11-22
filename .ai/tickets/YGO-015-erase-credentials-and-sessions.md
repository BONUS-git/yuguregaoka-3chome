# YGO-015 R-005 退去の J7 が、認証情報とセッションを消さない
状態: done

## 目的
`.ai/reviews/0001-design-review.md` の R-005 の指摘を直します。`async.md` §4 J7（`account.erase`）の手順に `credentials`・`sessions` を消す手順がなく、メールの暗号化した値・HMAC・パスワードのハッシュ・セッションの行が退去のあとも残っていました。この 2 つの表は `residents` を外部キーで指すので、最後の手順の `residents` の削除も止まります。
あわせて、退去でのセッションの扱いが `security.md` §2.1 では「消去」、§2.4・§3.3・`api.md` §2.4 では「無効化」と食い違っていました。
退去の表の正本の ADR-0077 にセッションの行と消す順番を足すことになるので、ADR-0077 の生きている決定（退去の表・長期不在・保持期間・D1〜D6・配達回を消さないこと・新聞の組み直し）と新しい決定（D7・D8）をまとめた ADR-0079 を作り、ADR-0077 を置き換えます。
マスターの判断は要らない（レビューの「マスターの判断: 不要」。技術と設計の細部で `[assumed]`）ので、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/adr/0079-account-erase-credentials-and-sessions-first.md`（新規、題「退去で認証情報とセッションを最初に消す」）: ADR-0077 の決定を D1〜D6 の番号を変えずに引き継ぎ、退去の表に `credentials`・`sessions` の行を置き、次を決める。
  - D7 退去の受付（API、1 つのトランザクション）: `deleted_at` を付け、有効なセッションをすべて無効にし（`invalidated_at`）、その購読を消し、J7 を積む。
  - D8 J7 の手順 0（1 つのトランザクション）: `push_subscriptions` の残り（とそれを指す `delivery_notifications`）→ `sessions` の行すべて → `credentials` の行の順に消し、`sessions` と `credentials` の行を `erasure_log` に記録する。
- `.ai/adr/0077-letters-purged-after-settling-or-recipient-deletion.md`: 状態を `置き換え（→ 0079）`。
- `.ai/adr/README.md`: 0077 の行に「ADR-0079 で置き換え」、0079 の行。
- `.ai/async.md` §4 J7: 出力、手順 0、手順 6（送った記録の残りだけ）、冪等性。J14 の対象の表に期限切れの `sessions` の行（消す担い手を J14 にする `[assumed]`）、J15 の送る相手の行。
- `.ai/security.md`: §2.1 のメールアドレス・パスワード・セッション情報の行、§2.4 の 2〜4、§3.3、§9 の async.md への提案 1 を「→ 済み」。
- `.ai/db.md`: §2 `credentials` の前文、通知の前文、§4 の `credentials` の行と `sessions` の行、§5 の 1。
- `.ai/api.md` §2.4 の退去の 1 と 3。
- `.ai/roadmap.md`: A-13 の認証情報とセッションの確かめ、冒頭の関連 ADR の 0077 と 0079。
- `adr/`・`reviews/`・`tickets/` を除く `.ai/*.md`: `ADR-0077` の参照を `ADR-0079` に、冒頭の関連 ADR・根拠・「MVP で依存する ADR」の 0077 を 0079 に（D の番号は同じなので「ADR-0077 の D3」のような参照もそのまま正しい）。
- 直さないところと理由
  - `sessions` の表の定義（`security.md` §9 の db.md への提案 2）: R-025 で扱う。
  - ADR-0013・ADR-0075・ADR-0078 などの中の ADR-0077 や認証情報の記述: それぞれの決定の記録で、ADR-0079 は ADR-0077 の決定を同じ番号で引き継いでいるので変えない。
  - J7 のほかの外部キー（R-008）、ほかの指摘、各文書の「他の文書への変更提案（別チケット）」の節のまとめ直し（R-007。`security.md` §9 の async.md への提案 1 に「済み」を付けることだけ行う）、FR / NFR の対応表には手を付けない。
  - コード・テスト・検証の手順・依存は変えない。

## 受け入れ確認
- `.ai/adr/0079-account-erase-credentials-and-sessions-first.md` の題が「0079 — 退去で認証情報とセッションを最初に消す」、状態の行が `採用` で、冒頭に「ADR-0077 を丸ごと置き換える」とある。退去の表に「認証情報（`credentials` の行）」と「セッション（`sessions` の行）」の行があり、`erasure_log` に記録するとある。D1〜D6 があり、D7 に `invalidated_at`・同じトランザクション・購読を消すこと・J7 を積むことがある。D8 に `push_subscriptions` → `sessions` → `credentials` の順と `erasure_log` の `table_name`（`sessions`・`credentials`）がある。
- `.ai/adr/0077-letters-purged-after-settling-or-recipient-deletion.md` の状態の行が `置き換え（→ 0079）`。`.ai/adr/README.md` の 0077 の行に「ADR-0079 で置き換え」があり、0079 の行がある。
- `.ai/async.md` §4 J7 の処理の順序に手順 0 があり、`push_subscriptions`・`sessions`・`credentials` を消す 3 つの小手順と `erasure_log` への記録がある。手順 6 は `delivery_notifications` の残りだけを消す。出力に `credentials`・`sessions`・`residents` を `erasure_log` に記録するとある。冪等性に手順 0 の行がある。
- `.ai/async.md` §4 J14 の対象の表に `sessions`（期限切れ）の行があり、条件に `expires_at < now()` と、同じトランザクションで `delivery_notifications` → `push_subscriptions` → `sessions` の順に消すことがある。J15 の送る相手の行に「期限切れのセッションの購読には送らない」と「J14 が期限切れのセッションの行と一緒に消す」がある。
- `.ai/security.md` §2.1 のセッション情報の行に「ログアウトでは API が消去」と、有効期限切れでは J14 が `expires_at < now()` の行を `push_subscriptions` と `delivery_notifications` を先に消してから削除することと、退去では「受付で無効にし（`invalidated_at`）」「J7 の最初の手順ですべて消す」がある（`invalidated_at` は退去の受付だけに書く）。§2.4 の 2 に `sessions.invalidated_at`、4 に `credentials`・セッションの行すべて・`erasure_log` と ADR-0079 の D8 がある。§3.3 に「即時に無効にする」と ADR-0079 の D8 がある。§9 の async.md への提案 1 の下に「→ 済み」がある。
- `.ai/db.md` §2 `credentials` の前文に「J7 の手順 0」と `erasure_log` がある。§4 の表に `sessions` の行があり、保つ欄に「退去の受付では `invalidated_at`」、消す欄に「ログアウトでは API が削除」と、有効期限切れでは J14 が `expires_at < now()` の行を `push_subscriptions` と `delivery_notifications` を先に消してから削除することと、「J7 の手順 0」と `erasure_log` がある。ADR-0079 の保持期間の表で `credentials` と `sessions` が別の行になり、`sessions` は「有効期限切れ・ログアウトまで」と、同じ J14 の削除の書き方がある。ADR-0079 の D8 の 2 に「期限が切れて次の J14 を待っている行も含む」とある。§5 の 1 に `sessions`・`credentials`・`erasure_log` と ADR-0079 の D7・D8 がある。
- `.ai/api.md` §2.4 の退去の 1 に `sessions.invalidated_at` と ADR-0079 の D7、3 に `credentials` と ADR-0079 の D8 がある。
- `.ai/roadmap.md` の A-13 に、`credentials` と `sessions` に行がないことと、`erasure_log` に `credentials`・`sessions`・`residents` の 3 つの表の行があることの確かめがある。冒頭の関連 ADR に 0079 がある。
- `.ai/` の文書（`adr/`・`reviews/`・`tickets/` を除く）に `ADR-0077` の語がない。
- `.ai/open-questions.md` に新しい OQ がない（表の行の数が変更の前と同じ）。
- `sh scripts/check.sh` が `check: ok` で終わる。
