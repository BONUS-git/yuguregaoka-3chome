# YGO-016 R-006 認証のエンドポイントが API に足りない
状態: done

## 目的
`.ai/reviews/0001-design-review.md` の R-006 の指摘を直します。ADR-0018・ADR-0019 と `security.md` §3 が決めた認証の流れ（メールの確認・パスワードの再設定・再認証・セッションの一覧と取り消し・パスワードとメールアドレスの変更・モデレーターの二要素認証・強制ログアウト）の経路が `api.md` §7 F-02 になく、§4 の認証なしの一覧と §5 のエラーの符号にも足りませんでした。`DELETE /api/v1/me` にも再認証の条件とエラーの符号がなく、`security.md` §9 と ADR-0018・ADR-0019 の「影響」の `/auth/*` は今の `/api/v1` の名前と合っていませんでした。
経路の名前を決め直し、強制ログアウトの方法（`invalidated_at` ではなく行を消す）を変えるので、ADR-0018 の生きている決定と新しい決定をまとめた ADR-0080 と、ADR-0019 の生きている決定と新しい決定をまとめた ADR-0081 を作り、古い 2 つを丸ごと置き換えます。
マスターの判断は要りません（レビューの「マスターの判断: 不要」。技術と設計の細部で、どれも `[assumed]`）。`open-questions.md` に新しい問いは足しません。メールの確認のリンクの期限は、既存の OQ-046（持ち越し、暫定は置かない）の内容に論点 (3) として足し、「答えで変わる箇所」に ADR-0080 の D2 を書きます。

## 範囲
- `.ai/adr/0080-authentication-email-password-api-v1.md`（新規、題「ログインはメールとパスワード、認証の経路は /api/v1」）: ADR-0018 の決定を D1〜D3 に引き継ぎ、D4 認証なしの 6 つの経路、D5 ログイン、D6 メールの確認、D7 パスワードの再設定を決める。
- `.ai/adr/0081-server-side-sessions-reauth-api.md`（新規、題「セッションはサーバー側、再認証とセッションの API」）: ADR-0019 の決定を D1・D2・D5 に引き継ぎ、D3 セッションの一覧と取り消し、D4 無効にする方法と強制ログアウト、D5 再認証の経路と 6 つの対象、D6 モデレーターの二要素認証、D7 パスワードとメールアドレスの変更（メールアドレスの変更は流量の制限の対象）を決める。
- `.ai/adr/0018-…`・`.ai/adr/0019-…`: 状態の行だけを `置き換え（→ 0080）`・`置き換え（→ 0081）` に。`.ai/adr/README.md` の一覧。
- `.ai/api.md`: 冒頭の関連 ADR、§2.4 の退去の 1、§4、§5、§7 F-02（表と「認証の経路」）、F-05 の購読、F-08 の admin の経路、§8、§9、§11。
- `.ai/security.md`: 冒頭の関連 ADR、§2.1 のセッション情報の行、§3.1〜§3.6、§4.1、§4.2（セッションの表とロール・管理操作の 2 行）、§6.1・T-11・§8・§10 の参照、§9 の api.md への提案 1・2（経路を今の名前にして「→ 済み」）、§9 の db.md への提案 2 の `sessions` の列の一覧（二要素認証を済ませた時刻と一覧で見せる識別子を足す。型と名前は R-025）。
- `.ai/db.md`: 冒頭の関連 ADR、§2 の参照と `push_subscriptions.session_id` の説明、§4 の `sessions` の行。
- `.ai/roadmap.md`: 冒頭の関連 ADR、M1 の含めるものと ADR の欄、A-10 の ADR、A-13 の再認証の確かめ、「MVP で依存する ADR」。
- `.ai/architecture.md`・`.ai/features.md`・`.ai/open-questions.md`: `ADR-0018`・`ADR-0019` の参照を `ADR-0080`・`ADR-0081` に。`open-questions.md` の OQ-046 に論点 (3) リンクの期限と答えで変わる箇所。

## 直さないところと理由
- `sessions`・TOTP の秘密・確認と再設定のトークンの保存先の表の定義（列の型と名前。`db.md` §2）: R-025 で扱う。`security.md` §9 の db.md への提案 2 は、列の一覧を ADR-0081 の D1 に合わせるだけにする。
- FR-092・FR-100 の「未確定」の書き方: R-026 で扱う。
- 各文書の「他の文書への変更提案（別チケット）」の節のまとめ直し: R-007 で扱う。`security.md` §9 の api.md への提案 1・2 に「→ 済み」を付けることだけ行う。
- ほかの ADR（0025・0030・0032・0076・0079 など）の中の ADR-0018・ADR-0019 の参照: それぞれの決定の記録なので変えない。
- `reviews/` のファイル、ほかの指摘（R-007 以降と、R-001〜R-005 の見直しで残った点）。
- `.ai/status.md` はレポジトリにまだないので作らない（実装はまだなく、文書だけの変更）。
- コード・テスト・検証の手順・依存は変えない。

## 受け入れ確認
- `.ai/adr/0080-authentication-email-password-api-v1.md` の 1 行目が `# 0080 — ログインはメールとパスワード、認証の経路は /api/v1`、状態の行が `採用` で、冒頭に「ADR-0018 を丸ごと置き換える」とある。D4 の表に `POST /api/v1/registrations`・`/api/v1/sessions`・`/api/v1/email-verifications`・`/api/v1/email-verification-requests`・`/api/v1/password-reset-requests`・`/api/v1/password-resets` の 6 行がある。D7 に「その住民のセッションの行をすべて消す」がある。D2 に OQ-046 がある。
- `.ai/adr/0081-server-side-sessions-reauth-api.md` の 1 行目が `# 0081 — セッションはサーバー側、再認証とセッションの API`、状態の行が `採用` で、冒頭に「ADR-0019 を丸ごと置き換える」とある。D3 に `GET /api/v1/sessions`・`DELETE /api/v1/sessions/{id}` と「Cookie の値とは別の識別子」、D4 に「`invalidated_at` を付けるのは、退去の受付（`DELETE /api/v1/me`）だけ」と「強制ログアウトは運用者の CLI だけ」、D5 に `POST /api/v1/sessions/current/reauthentication`・`reauthentication_failed`・`reauthentication_required` と 6 つの操作、D6 に `second_factor_required`・403・`POST /api/v1/me/second-factor` と `…/confirmation`・運用者の CLI の作り直しと解除がある。D7 に「メールアドレスの変更は流量の制限の対象で、超えたら 429 `rate_limited`」がある。
- `.ai/security.md` §3.5 の流量の制限の一覧と `.ai/api.md` §5 の 429 `rate_limited` の説明に「メールアドレスの変更」がある。`.ai/api.md` §7 F-02 の `PUT /api/v1/me/email` の行の状態コードが `202, 400, 401, 429`。
- `.ai/adr/0018-authentication-email-password.md` の状態の行が `- 状態: 置き換え（→ 0080）`、`.ai/adr/0019-server-side-sessions-and-reauth.md` の状態の行が `- 状態: 置き換え（→ 0081）` で、どちらもほかの行は変わっていない。`.ai/adr/README.md` の 0018・0019 の行に「ADR-0080 で置き換え」「ADR-0081 で置き換え」があり、0080・0081 の行がある。
- `.ai/api.md` §4 に「認証なしで呼べるのは次の 9 つだけ」と、4 つの確認・再設定の経路がある。§5 の 400 に `token_invalid`、401 に `second_factor_required`・`reauthentication_required`・`reauthentication_failed` がある。§7 F-02 の表に `/api/v1/email-verifications`・`/api/v1/email-verification-requests`・`GET /api/v1/sessions`・`DELETE /api/v1/sessions/{id}`・`/api/v1/sessions/current/reauthentication`・`/api/v1/password-reset-requests`・`/api/v1/password-resets`・`PUT /api/v1/me/password`・`PUT /api/v1/me/email`・`/api/v1/me/second-factor`・`/api/v1/me/second-factor/confirmation` の行があり、`DELETE /api/v1/me` の行に 401（`reauthentication_required`）がある。§8 に強制ログアウトの経路と二要素認証の作り直し・解除の経路の行がある。§11 の NFR-004 が「9 つに限定」。
- `.ai/security.md` §3.4 に 6 つの操作の経路と `reauthentication_required`・`reauthentication_failed` がある。§3.3 に「`invalidated_at` を付けるのは退去の受付だけ」と強制ログアウトは運用者の CLI だけとある。§4.1 に `second_factor_required` と admin の経路の 403 がある。§9 の api.md への提案 1・2 の経路が `/api/v1` の名前で、それぞれの下に「→ 済み」がある。§9 の db.md への提案 2 の `sessions` の列に「二要素認証を済ませた時刻」「一覧で見せる識別子（Cookie の値とは別」と「型と名前は R-025 で決める」がある。
- `.ai/db.md` §4 の `sessions` の行に「`invalidated_at` を付けるのは退去の受付だけ」と、強制ログアウトと二要素認証の解除では運用者の CLI が行を削除することがあり、`push_subscriptions.session_id` の説明に ADR-0081 の D4 がある。
- `.ai/roadmap.md` の A-13 に `reauthentication_required` と `reauthentication_failed` の確かめがあり、冒頭の関連 ADR に 0080・0081 がある。
- `grep -n "ADR-0018\|ADR-0019\|adr/0018\|adr/0019" .ai/*.md` と `grep -n "/auth/" .ai/*.md` が何も出さない。
- `.ai/open-questions.md` の OQ の一覧の表の行の数が変更の前と同じ（新しい OQ がない）。OQ-046 の内容に「(3) 確認のメールのリンクの期限」があり、扱いが「暫定は置かない」のままで、OQ-046 の本文に `[assumed]` がない。「答えで変わる箇所」に ADR-0080 の D2 がある。
- `sh scripts/check.sh` が `check: ok` で終わる。
