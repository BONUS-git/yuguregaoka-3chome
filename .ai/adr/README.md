# ADR（設計判断の記録）

1 つの判断を 1 つのファイルに: `NNNN-<題>.md`（NNNN は 0001 からの連番）。

```markdown
# NNNN — <題>

- 状態: 提案 / 採用 / 置き換え（→ NNNN）
- 日付: YYYY-MM-DD

## 背景
## 決定
## 理由
## 代わりの案（選ばなかった理由）
## 影響
```

## 一覧

- [0001 — 内部 ID と住所を分ける](0001-internal-id-separate-from-address.md)
- [0002 — ログインしないだけでは空き家にしない](0002-vacancy-requires-explicit-deletion.md)
- [0003 — 住所録には相手の新しい住所を自動で表示しない](0003-no-auto-update-address-book-on-move.md)
- [0004 — 配達スケジュール・冪等性・文字数上限](0004-delivery-schedule-and-limits.md)
- [0005 — モデレーション方針](0005-moderation-policy.md)
- [0006 — 手紙はサーバー鍵で保存時に暗号化する](0006-letter-encryption-at-rest.md)
- [0007 — 新聞はテンプレートで決定的に組む](0007-newspaper-deterministic-template.md)
- [0008 — モジュラーモノリスと 2 プロセス構成](0008-modular-monolith-two-processes.md)
- [0009 — TypeScript・Fastify・React と Vite](0009-typescript-fastify-react.md)
- [0010 — PostgreSQL を DB とジョブキューの両方に使う](0010-postgresql-as-db-and-job-queue.md)
- [0011 — 組版エンジンは TSX を静的 HTML に描く](0011-newspaper-template-engine.md)
- [0012 — 想定規模](0012-assumed-scale.md)
- [0013 — 退去処理とデータ保持期間](0013-account-deletion-and-retention.md)
- [0014 — API は即時性と数値を返さない](0014-api-no-immediacy-no-counts.md)
- [0015 — API・DB・バッチの責務の境界](0015-api-db-batch-boundary.md)
- [0016 — 配達回は時刻の関門と見回りのジョブで進める](0016-delivery-run-pipeline-and-tick.md)
- [0017 — 配達は準備と公開の 2 段に分ける](0017-delivery-prepare-then-publish.md)
- [0018 — ログインはメールとパスワード。メールは暗号化して持ち検索用に HMAC を持つ](0018-authentication-email-password.md)
- [0019 — セッションはサーバー側に持つ。複数デバイスを許す。重要な操作では再認証する](0019-server-side-sessions-and-reauth.md)
- [0020 — ロールは住民とモデレーターの 2 つ。権限の規則表は 1 か所に持ち LLM は判定に関わらない](0020-staff-roles-and-permission-table.md)
- [0021 — 手紙の暗号鍵に版を付けて入れ替える。AAD に手紙の ID を含める](0021-encryption-key-versioning.md)
- [0022 — 段階は features.md の 3 つのまま。MVP は作る順に M0〜M6 に分け、各段階は受け入れ条件・見直し・マスターの確認で閉じる](0022-roadmap-stages-and-gates.md)
- [0023 — 休眠と空き家の再割り当ては段階 3。MVP の住所の候補は使われたことのない住所だけ](0023-dormancy-and-address-reuse-in-stage-3.md)
- [0024 — マッチングは恋愛のためのものではなく、興味のある人どうしが連絡を取る手段。個別の連絡先の共有は禁止する](0024-matching-not-romance-no-contact-sharing.md)
- [0025 — 配達完了の通知は、配達回の公開のあとに Web Push で 1 回送り、郵便の件数を含める](0025-delivery-notification-web-push-with-count.md)
- [0026 — クローズドな手紙も審査する。本文は LLM に渡さず、ルール表だけで照合し、復号できる場面を限る](0026-closed-letters-rule-only-moderation.md)
- [0027 — 未成年の利用を認め、年齢制限・特別な制限を置かない。生年月日・年齢は集めない](0027-minors-no-age-restriction.md)
- [0028 — 架空の街の地図は、1 枚の静的な画像として MVP（M1）で作る。API・DB・ジオデータは持たない](0028-town-map-static-image-in-mvp.md)
- [0029 — 商店・団体のアカウントは管理者（運用者の CLI）が作る。住民は商店・団体を開けない](0029-shop-and-group-accounts-created-by-operators.md)
- [0030 — 新規登録は開放式（招待なしで誰でも登録できる）。登録の入り口は既存の守りで守る](0030-open-registration.md)
- [0031 — 外部 LLM の費用の見積もりはロードマップに置き、サービスは秘書が暫定で選ぶ（Anthropic API の Haiku）。本番のアダプタは承認のあとに作る](0031-llm-service-provisional-selection-and-cost-estimate.md)
- [0032 — 違反した住民への処置の内容は、マスターが後で決める。決まるまで処置を実行する手段は作らない](0032-resident-sanctions-deferred-to-master.md)
- [0033 — メール送信は、テスト環境ではモックかローカルの SMTP を使う。本番のサービスはマスターの事前承認を得て選ぶ](0033-email-mock-or-local-smtp-in-test-production-by-approval.md)
- [0034 — 共有を禁止する「連絡先」は街の外の連絡先だけ。禁止はマッチングの中だけで、掲示板・手紙には及ばない](0034-contact-sharing-ban-outside-contacts-in-matching-only.md)
- [0035 — 新聞は全住民に定時に届け、通知も送る。手紙は午前・午後のランダムな時刻に届け、通知を新聞と手紙で分ける](0035-newspaper-for-all-letters-random-am-pm-separate-notifications.md)
- [0036 — 通報された手紙は、モデレーターが条件付きで 1 通だけ確かめてよい。住民を守る制限は、住民が自分で外せる設定にしない](0036-reported-letters-viewable-by-moderators-protections-not-self-removable.md)
- [0037 — 架空の街の地図は、全住民で共有する 1 枚の白黒の画像とする。印（知り合いの家・自分の住所・候補）とゲーム風の地図は今は作らない](0037-town-map-shared-monochrome-image.md)（印は ADR-0042 で置き換え）
- [0038 — 商店には実在の企業・個人のお店を迎えることを目指す。コミュニティ（団体）は住民が趣味などで作り、作ることに制約を置く](0038-shops-real-businesses-communities-by-residents.md)（商店の迎え方は ADR-0043 で決めた）
- [0039 — 新聞は一人 1 枚にせず、知り合いの数で分けた組ごとの版にする。知り合いのない組は興味で分ける。記事の文字は LLM が作り、組版はサーバーで決定的に行う](0039-newspaper-editions-by-group-and-interest-llm-text-server-typesetting.md)（ADR-0055 で置き換え）
- [0040 — 手紙は送るときにルール表に当てる。当たったら送った人に確認を頼むかを選んでもらい、頼んだ手紙をモデレーターが確かめる](0040-letters-checked-at-send-sender-confirms-moderator-reviews.md)
- [0041 — 年齢で守り方を変える。年齢は住民が設定した値をそのまま使い、確かめない。何を変えるかが決まるまで、年齢による違いと年齢の項目は作らない](0041-age-self-declared-protections-vary-by-age.md)（D1 は ADR-0047、D5 は ADR-0048 で置き換え）
- [0042 — 地図に印を付ける。自分の家と登録のときの候補は M1、知り合い（自分の住所録に入れた住民）の家は M2（手紙の知り合いの定義は ADR-0049。印を付けるエントリは ADR-0051）。土台の画像は全住民で同じまま、印は C1 が重ねる。空き家・入居の表示は OQ-079 の答えまで作らない](0042-town-map-marks-own-home-candidates-acquaintances.md)（D11 は ADR-0049 で書き直し。印を付けるエントリは ADR-0051 で決めた）
- [0043 — 商店とは契約を結び利用料を取る考え（MVP ではメモだけ）。架空の店を置いてよく、空いた区画には金額を載せない入居者募集の張り紙を出す。発信はお店の担当者が行い、出せるものは広さと料金のランクで変える（折込チラシが最高）。商店は実在の情報を出してよい](0043-shops-contract-fee-memo-fictional-shops-vacancy-posters-staff-post.md)（D2 の示し方と D7 は ADR-0050 で決めた）
- [0044 — MVP は全住民を知り合い 0 の組とする。新聞の知り合いは互いに住所録に入れた住民で、載せるのは知り合いの掲示板の投稿（手紙は載せない）。組 1・2 は住民ごとに組み、足りない分は興味の版か共通の版の記事で埋める。アップロードした画像は加工し、元の画像は持たない](0044-newspaper-acquaintance-groups-mutual-board-posts-per-resident-images-no-original.md)
- [0045 — 興味は、自分に届いた過去の新聞の検索から推し量って集める。検索語は残さず、当たった興味だけを持つ。住民には明るく開いた文で知らせ、個別の同意は取らない。推し量った興味を本人が見て消す仕組みは設けない](0045-interests-from-past-newspaper-search-notice-no-consent-no-view.md)（住民が止められないことは ADR-0053 で決めた）
- [0046 — 新聞の LLM の文に「AI が書いた文」の印を付けない（規約は確かめる）。住民の掲示板の投稿の本文は書き換えずにそのまま載せ、LLM が書くのは生成部分だけにし、LLM の文を住民本人の文に見せない](0046-newspaper-no-ai-label-posts-verbatim-llm-text-not-shown-as-residents.md)（ADR-0054 で置き換え）
- [0047 — 年齢による違いは作らない。手紙と掲示板で止める基準・使える機能は全員に同じにし、詐欺と事件の防止も全員に同じ共通のルールで行う。年齢の区切りは置かない](0047-no-age-based-differences-common-rules-for-all.md)（D5 は ADR-0048 で置き換え）
- [0048 — 年齢は登録で必須にし、あとから変えられない。年は登録の日から 1 年ごとに進む。ほかの住民には、本人から手紙を受け取った住民にだけ見せる](0048-age-required-immutable-advances-yearly-shown-to-letter-recipients.md)
- [0049 — 手紙は知り合いにだけ出せる。知り合いになるのは、互いに住所録に入れたとき（既定）と、掲示板で相手がオープンにしているとき。足されたことは相手に知らせない](0049-letters-only-to-acquaintances-mutual-add-or-board-open-requests-hidden.md)
- [0050 — 架空の店と入居者募集の張り紙は段階 3 から作る（MVP には作らない）。架空の店には「入居者募集」の張り紙を出して架空と分かるようにし、発信させず新聞にも載せない。新聞には運営の入居者募集の広告を出す](0050-fictional-shops-stage-3-vacancy-poster-no-posting-newspaper-tenant-ads.md)
- [0051 — 地図の知り合いの家の印は、自分の住所録のすべてのエントリに付ける。地図と新聞・手紙で「知り合い」の定義を分け、地図の印は `acquainted` で変えない](0051-town-map-acquaintance-marks-all-address-book-entries-definitions-split.md)
- [0052 — 開発とテストは手元に入れた PostgreSQL で動かし、`check.sh` は使い捨ての DB を起こす。IaC は OpenTofu で設計だけ書き、事業者は選ばない](0052-local-dev-and-check-env-opentofu-iac-design-only.md)
- [0053 — 過去の新聞の検索から興味を推し量ることを、住民は止められない。止める手段を作らず、知らせて推し量ることを検索の処理に組み込む](0053-inferred-interests-from-search-cannot-be-stopped.md)
- [0054 — 新聞の LLM の文に印を付けず、投稿の記事は見出しだけ書く](0054-newspaper-post-articles-llm-headline-only-no-summary.md)
- [0055 — 新聞は一人 1 枚にせず組ごとの版にする。知り合いのない組は興味で分け、ニュースは街の中と外から取る。記事の文字は LLM が作り、組版はサーバーで決定的に行う。投稿の記事は見出しだけで、本文の欄を持たない](0055-newspaper-editions-llm-text-server-typesetting-post-articles-headline-only.md)
