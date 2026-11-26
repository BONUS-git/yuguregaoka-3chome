# YGO-051 R-060 登録の確認メールを送るジョブが async.md にない
状態: done
M: M1

## 目的
`reviews/0003-phase-evaluation-2026-11-26.md` の R-060（区別: 中、評価の ID: E-014）を直す。
M1 の登録（F-02）は、メールの確認が済むまで住所を押さえる（ADR-0087）。ところが、web から worker（`MAIL_ADAPTER` を持つのは worker だけ、`environment.md` §8.1）に確認・送り直し・再設定・メールアドレスの変更の確認のメールを渡すジョブが `async.md` にない。M1 の登録のシーケンス（`diagrams/m1-registration-sequence.md`）とコンポーネント図（`diagrams/m1-components.md`）は、この受け渡しを「未設計（`gaps.md` G-049）」としている。
このチケットで、そのジョブを `async.md` に設計し、図と `api.md` からジョブを指すようにして、G-049 を閉じる。

## 範囲
- `.ai/async.md`
  - §2 のジョブの一覧に、メールを送るジョブの行を足す（名前・契機・ペイロード・出力）。
  - §4 に、そのジョブの詳細の節を足す。積む契機は、登録・確認の送り直し・再設定の依頼・メールアドレスの変更の要求を処理するのと同じトランザクションで `jobs` に積むこと。
  - ペイロードは、確認・再設定のトークンの平文とメールアドレスの平文を持たない（`security.md` T-03）。どの値から宛先と本文を組み立てるかを書く。
  - §5（pg-boss の設定）に再試行と期限、§6（失敗・遅れ・止まったときの一覧）にメールを送れなかったときの行を足す。
  - §9（FR / NFR との対応表）に、このジョブと FR-092 の対応を足す。
- `.ai/diagrams/m1-registration-sequence.md`: 42 行目の「渡し方は未設計、gaps.md G-049」を、ジョブの名前と `async.md` の節に置き換える。
- `.ai/diagrams/m1-components.md`: 36 行目の点線の経路のラベルと 45 行目の注記を、ジョブの名前に置き換える。
- `.ai/diagrams/m1-usecases.md`: 53 行目の「ジョブは `async.md` にまだない（G-049）」を、ジョブの名前に置き換える。
- `.ai/api.md` §7 F-02: 登録・送り直し・再設定の依頼・メールアドレスの変更の行から、このジョブを指す。
- `.ai/gaps.md`: G-049 の行の理由と出どころの列（閉じたことと `YGO-051`）。
- `.ai/INDEX.md`: `reviews/0003-phase-evaluation-2026-11-26.md`・このチケット・YGO-052 を載せる（0003 とチケットを足した変更は `reviews/`・`tickets/`・`open-questions.md` だけを変える決まりだったため、地図にまだない）。
- 設計の細部（ジョブの名前・再試行の回数など）は妥当な既定を自分で決め、その箇所に `[assumed]` を書く。前の決定を変えないなら ADR は作らない。
- 範囲に足したもの（DLG-02）: `auth_tokens.token_hash` は web だけが持つ鍵の HMAC なので、worker はリンクのトークンを作れない。また ADR-0090 の D7 の前のアドレスへの知らせは、確認が済むと前のアドレスの置き場がない。送る前のトークンと前のアドレスを `EMAIL_KEYRING` で暗号化して `auth_tokens` の列（`mail_token_*`・`old_email_*`）に置き、J18 に `kind = email_change_notice` を足した。`auth_tokens` の定義と守りの前提（D6）にかかるので、ADR-0089 を丸ごと置き換える ADR-0101 を足し（D7 に決定・理由・代わりの案）、ADR-0089 の状態を置き換えにした。別の表にせず列にしたので、退去と保持期間は ADR-0091 の `auth_tokens` の行のままで、CASCADE の例外を作らない。同じ変更で `db.md`・`diagrams/m1-er.md`・`security.md` §2.1・§2.5・§3.4、`environment.md` §8.1（`EMAIL_KEYRING`・`PUBLIC_BASE_URL`）・§8.3、`architecture.md` §2 の C4、`roadmap.md` §4 の M1 の行、`api.md` §2.1・§2.4、`requirements.md` の根拠の ADR の番号と、ADR-0087 の D4・ADR-0088・ADR-0090・ADR-0091 が表の定義として指す先（D 番号は同じ）を ADR-0101 にそろえた（範囲を変えない参照の直し。`gaps.md` は G-049 の行だけを変え、ほかの行の ADR-0089 の参照は変えていない）。`scripts/check.sh` に、M1 の図に「未設計」がないことと、シーケンス図のジョブが `async.md` §2 にあることの確かめを足した。

## 直さないところ
- 使用中のメールアドレスで登録したときの応答（G-051）: YGO-052 で扱う。このチケットは、その知らせも同じジョブで送れるよう、ジョブの種類を足せる形にしておくだけ。
- 本番のメール送信サービスの選び方（OQ-049、持ち越し）: M1 はモックのアダプタのまま。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-051 R-060 登録の確認メールを送るジョブが async.md にない`・`状態: done`・`M: M1`。
2. `async.md` §2 のジョブの一覧に、確認と再設定のメールを送るジョブの行が 1 つある。§4 にそのジョブの節があり、積む契機に「同じトランザクション」と、登録・送り直し・再設定の依頼・メールアドレスの変更の 4 つが書かれている。
3. そのジョブのペイロードの欄に、トークンの平文とメールアドレスの平文を含めないことと `T-03` がある。
4. `async.md` §5 にそのジョブの再試行の行があり、§6 にメールを送れなかったときの行があり、§9 にそのジョブと FR-092 の行がある。
5. `diagrams/m1-registration-sequence.md`・`diagrams/m1-components.md`・`diagrams/m1-usecases.md` に「未設計」と `G-049` の文字がなく、ジョブの名前がある。
6. `api.md` §7 F-02 の登録・送り直し・再設定の依頼・メールアドレスの変更の行に、ジョブの名前がある。
7. `gaps.md` の G-049 の行の理由の列に `YGO-051` と「残りはない」がある。ほかの G 行に差分がない。
8. `INDEX.md` に `reviews/0003-phase-evaluation-2026-11-26.md`・`tickets/YGO-051-r-060-registration-mail-job.md`・`tickets/YGO-052-r-061-registered-email-response.md` がある。
