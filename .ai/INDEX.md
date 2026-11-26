# 地図（INDEX）

読む順（DLG-14）: 1. この地図 → 2. 図（`.ai/diagrams/`） → 3. 地図が指す文書の節だけ。
今の M は M1（住所・アカウント、F-01・F-02・F-19）。図は M1 の範囲で確かめてある。

## 知りたいこと → 図 → 文書の節

| 知りたいこと | 図 | 文書の節 |
|---|---|---|
| M1 で誰が何をできるか | `.ai/diagrams/m1-usecases.md` | `.ai/mvp.md` (a)・(b)、`.ai/roadmap.md` §4 の M1 の行、`.ai/features.md` §2 の F-01・F-02・F-19 |
| M1 で動くコンポーネントと呼び出し | `.ai/diagrams/m1-components.md` | `.ai/architecture.md` §2・§3・§5、`.ai/api.md` §2.5 |
| 地図で住所を選んで登録し、ログインするまで | `.ai/diagrams/m1-registration-sequence.md` | `.ai/api.md` §7 F-01・F-02・F-19、`.ai/security.md` §3.1〜§3.5 |
| 住所の状態・入居の読み方・確認とセッションの状態 | `.ai/diagrams/m1-address-account-states.md` | `.ai/db.md` §2 の `addresses`・§4 の状態遷移図、`.ai/security.md` §3.3・§3.4 |
| M1 の表と列 | `.ai/diagrams/m1-er.md` | `.ai/db.md` §2 の住民・住所、`.ai/security.md` §3.3 |
| 架空の街の地図（画像・印・入居の層） | `.ai/diagrams/m1-components.md`・`.ai/diagrams/m1-usecases.md` | `.ai/architecture.md` §2 の C1、`.ai/api.md` §7 F-19、ADR-0061・0083・0084 |
| 住所の列挙と探り（入居の一覧・プロフィールの 404・流量の制限） | `.ai/diagrams/m1-components.md` | `.ai/security.md` §3.5 の規則の表・§7 の T-05、`.ai/api.md` §7 F-01・F-19、`.ai/roadmap.md` A-12、ADR-0084 の D16・ADR-0088 |
| 年齢と誕生日 | `.ai/diagrams/m1-er.md`・`.ai/diagrams/m1-registration-sequence.md` | `.ai/db.md` §2 の `residents`、`.ai/api.md` §7 F-02、ADR-0093 |
| プロセスの分け方（web / worker）と C1〜C13 の置き場 | `.ai/diagrams/m1-components.md` | ADR-0100、`.ai/architecture.md` §1 の 1・§2 の「動くプロセス」の列 |
| M1 の FR の一覧 | — | `.ai/roadmap.md` §4 の「今の M の範囲」、`.ai/mvp.md` (b) |
| M の分け方と、手紙の一続きが通る M・中心の体験の全体がそろう M | — | `.ai/roadmap.md` §4 の段階、ADR-0099・ADR-0097、`.ai/gaps.md` G-069 |
| 要回答で止まる M・FR があるか | — | `.ai/roadmap.md` §8、ADR-0099 の D6、`.ai/open-questions.md` §2（一覧） |
| M1 の受け入れ条件 | — | `.ai/roadmap.md` §4 の受け入れ条件（A-01〜A-18） |
| M1 の FR ごとのテスト項目（TC） | — | `.ai/tests/test-plan.md`、`.ai/roadmap.md` §4 の受け入れ条件、`.ai/async.md` §7 のテスト、`.ai/environment.md` §4 |
| 要求の原文と区分 | — | `.ai/brief.md`、`.ai/brief-map.md`、`.ai/requirements.md` §3・§4 |
| ジョブ・定時の処理 | — | `.ai/async.md` §2・§3（配達回の状態と J0、ADR-0094）・§4（審査キューの一意と持ち越し、ADR-0095）・§4（M1 で使うのは J14 の確認が済まない登録と数えの行の削除と、J18 の確認と再設定のメール、ADR-0087・0102） |
| 確認と再設定のメールを web から worker に渡す（J18） | `.ai/diagrams/m1-registration-sequence.md`・`.ai/diagrams/m1-components.md` | `.ai/async.md` §2 の J18 の行・§4 J18・§5・§6、`.ai/db.md` §2 の `auth_tokens`（送る前のトークンと前のアドレスの列）、`.ai/api.md` §2.4・§7 F-02、`.ai/environment.md` §8.1、ADR-0033・0087・0090 の D7・0102 の D7 |
| 使用中のメールアドレスで登録したときの応答と知らせ | `.ai/diagrams/m1-registration-sequence.md`（使用中のメールアドレスの分岐） | `.ai/api.md` §7 F-02 の `POST /api/v1/registrations`・認証の経路、`.ai/async.md` §4 J18（`registration_attempt_notice`）、`.ai/security.md` §3.1、ADR-0080 の D4・0087 の D5・0102 の D8 |
| 認証の表（セッション・ロール・確認と再設定のトークン・TOTP の秘密）・流量の制限の値・確認が済まない登録の期限 | `.ai/diagrams/m1-er.md`・`.ai/diagrams/m1-address-account-states.md` | `.ai/db.md` §2 の `credentials`・`sessions`・`auth_tokens`・`staff_roles`・`rate_limit_buckets`、`.ai/security.md` §2.1・§3.1・§3.4（確かめる順番）・§3.5 の規則の表、`.ai/api.md` §5 の 429・§7 F-06、ADR-0087・0088・0090・0102 |
| 退去と保持期間で消すもの（J7・J14 の正本の表） | — | ADR-0091 の退去の表と保持期間の表、`.ai/security.md` §2.4、`.ai/async.md` J7・J14、`.ai/db.md` §4 |
| リストアのあとの消し直し（消去の控えと `erasure.replay`） | — | ADR-0096、`.ai/async.md` §4 `erasure.replay`、`.ai/db.md` §2 の `erasure_log`・§6、`.ai/environment.md` §6.5、`.ai/gaps.md` G-055 |
| マスターに聞くこと・決まったこと | — | `.ai/open-questions.md` §2（一覧）・§3（要回答） |
| 持ち越し・仕分け | — | `.ai/gaps.md`（冒頭: 今の M の行を 1 行 1 チケットで閉じる決まり）、`.ai/triage.md` |
| 進み具合・振り返り | — | `.ai/status.md`、`.ai/retros.md` |
| 環境・秘密・費用 | — | `.ai/environment.md` §3・§4・§8、`.ai/roadmap.md` §9・§4 A-07（M0 の環境の約束の受け入れ条件） |

## 図（`.ai/diagrams/`）

| ファイル | 種類 | 確かめた M |
|---|---|---|
| `.ai/diagrams/m1-usecases.md` | ユースケース図 | M1 |
| `.ai/diagrams/m1-components.md` | コンポーネント図 | M1 |
| `.ai/diagrams/m1-registration-sequence.md` | シーケンス図（主な流れ） | M1 |
| `.ai/diagrams/m1-address-account-states.md` | 状態遷移図 | M1 |
| `.ai/diagrams/m1-er.md` | ER 図 | M1 |

## テスト（`.ai/tests/`）

- `.ai/tests/test-plan.md` — M1 の FR ごとのテスト項目書（TC-001〜TC-065。テストの名前に TC-NNN を入れる）

## 文書（`.ai/` の直下）

| ファイル | 中身 |
|---|---|
| `.ai/INDEX.md` | この地図 |
| `.ai/README.md` | `.ai/` の文書の一覧と段階 |
| `.ai/brief.md` | マスターの構想の原文（変えない） |
| `.ai/brief-map.md` | ブリーフの対応 |
| `.ai/requirements.md` | 要求仕様（FR・NFR） |
| `.ai/features.md` | 機能一覧と優先順位・FR 逆引き |
| `.ai/mvp.md` | MVP の定義 |
| `.ai/roadmap.md` | ロードマップ・M・受け入れ条件 |
| `.ai/architecture.md` | アーキテクチャ（C1〜C13） |
| `.ai/db.md` | DB 設計 |
| `.ai/api.md` | API 設計 |
| `.ai/async.md` | 非同期処理（J0〜J18） |
| `.ai/security.md` | セキュリティ設計 |
| `.ai/environment.md` | 開発・検証環境 |
| `.ai/open-questions.md` | 未確定事項（OQ） |
| `.ai/gaps.md` | 持ち越し（G） |
| `.ai/triage.md` | 仕分け（K） |
| `.ai/retros.md` | 振り返り |
| `.ai/status.md` | 進捗の写し（秘書が書く） |

## ADR（`.ai/adr/`）

各行の末尾は状態（各ファイルの 3 行目と同じ）。`置き換え（→ NNNN）` のものは、矢印の先を読む。

- `.ai/adr/README.md`
- `.ai/adr/0001-internal-id-separate-from-address.md` — 置き換え（→ 0082）
- `.ai/adr/0002-vacancy-requires-explicit-deletion.md` — 置き換え（→ 0060）
- `.ai/adr/0003-no-auto-update-address-book-on-move.md` — 採用
- `.ai/adr/0004-delivery-schedule-and-limits.md` — 採用
- `.ai/adr/0005-moderation-policy.md` — 採用
- `.ai/adr/0006-letter-encryption-at-rest.md` — 採用
- `.ai/adr/0007-newspaper-deterministic-template.md` — 置き換え（→ 0098）
- `.ai/adr/0008-modular-monolith-two-processes.md` — 置き換え（→ 0100）
- `.ai/adr/0009-typescript-fastify-react.md` — 採用
- `.ai/adr/0010-postgresql-as-db-and-job-queue.md` — 採用
- `.ai/adr/0011-newspaper-template-engine.md` — 採用
- `.ai/adr/0012-assumed-scale.md` — 採用
- `.ai/adr/0013-account-deletion-and-retention.md` — 置き換え（→ 0075）
- `.ai/adr/0014-api-no-immediacy-no-counts.md` — 採用
- `.ai/adr/0015-api-db-batch-boundary.md` — 採用
- `.ai/adr/0016-delivery-run-pipeline-and-tick.md` — 置き換え（→ 0092）
- `.ai/adr/0017-delivery-prepare-then-publish.md` — 採用
- `.ai/adr/0018-authentication-email-password.md` — 置き換え（→ 0080）
- `.ai/adr/0019-server-side-sessions-and-reauth.md` — 置き換え（→ 0081）
- `.ai/adr/0020-staff-roles-and-permission-table.md` — 採用
- `.ai/adr/0021-encryption-key-versioning.md` — 採用
- `.ai/adr/0022-roadmap-stages-and-gates.md` — 置き換え（→ 0099）
- `.ai/adr/0023-dormancy-and-address-reuse-in-stage-3.md` — 置き換え（→ 0062）
- `.ai/adr/0024-matching-not-romance-no-contact-sharing.md` — 採用
- `.ai/adr/0025-delivery-notification-web-push-with-count.md` — 置き換え（→ 0076）
- `.ai/adr/0026-closed-letters-rule-only-moderation.md` — 置き換え（→ 0072）
- `.ai/adr/0027-minors-no-age-restriction.md` — 採用
- `.ai/adr/0028-town-map-static-image-in-mvp.md` — 置き換え（→ 0058）
- `.ai/adr/0029-shop-and-group-accounts-created-by-operators.md` — 置き換え（→ 0067）
- `.ai/adr/0030-open-registration.md` — 採用
- `.ai/adr/0031-llm-service-provisional-selection-and-cost-estimate.md` — 置き換え（→ 0086）
- `.ai/adr/0032-resident-sanctions-deferred-to-master.md` — 採用
- `.ai/adr/0033-email-mock-or-local-smtp-in-test-production-by-approval.md` — 採用
- `.ai/adr/0034-contact-sharing-ban-outside-contacts-in-matching-only.md` — 置き換え（→ 0071）
- `.ai/adr/0035-newspaper-for-all-letters-random-am-pm-separate-notifications.md` — 採用
- `.ai/adr/0036-reported-letters-viewable-by-moderators-protections-not-self-removable.md` — 置き換え（→ 0078）
- `.ai/adr/0037-town-map-shared-monochrome-image.md` — 置き換え（→ 0061）
- `.ai/adr/0038-shops-real-businesses-communities-by-residents.md` — 採用
- `.ai/adr/0039-newspaper-editions-by-group-and-interest-llm-text-server-typesetting.md` — 置き換え（→ 0055）
- `.ai/adr/0040-letters-checked-at-send-sender-confirms-moderator-reviews.md` — 置き換え（→ 0056）
- `.ai/adr/0041-age-self-declared-protections-vary-by-age.md` — 採用
- `.ai/adr/0042-town-map-marks-own-home-candidates-acquaintances.md` — 置き換え（→ 0059）
- `.ai/adr/0043-shops-contract-fee-memo-fictional-shops-vacancy-posters-staff-post.md` — 採用
- `.ai/adr/0044-newspaper-acquaintance-groups-mutual-board-posts-per-resident-images-no-original.md` — 置き換え（→ 0074）
- `.ai/adr/0045-interests-from-past-newspaper-search-notice-no-consent-no-view.md` — 採用
- `.ai/adr/0046-newspaper-no-ai-label-posts-verbatim-llm-text-not-shown-as-residents.md` — 置き換え（→ 0054）
- `.ai/adr/0047-no-age-based-differences-common-rules-for-all.md` — 置き換え（→ 0057）
- `.ai/adr/0048-age-required-immutable-advances-yearly-shown-to-letter-recipients.md` — 置き換え（→ 0073）
- `.ai/adr/0049-letters-only-to-acquaintances-mutual-add-or-board-open-requests-hidden.md` — 置き換え（→ 0065）
- `.ai/adr/0050-fictional-shops-stage-3-vacancy-poster-no-posting-newspaper-tenant-ads.md` — 採用
- `.ai/adr/0051-town-map-acquaintance-marks-all-address-book-entries-definitions-split.md` — 採用
- `.ai/adr/0052-local-dev-and-check-env-opentofu-iac-design-only.md` — 採用
- `.ai/adr/0053-inferred-interests-from-search-cannot-be-stopped.md` — 採用
- `.ai/adr/0054-newspaper-post-articles-llm-headline-only-no-summary.md` — 採用
- `.ai/adr/0055-newspaper-editions-llm-text-server-typesetting-post-articles-headline-only.md` — 採用
- `.ai/adr/0056-letters-reject-tier-and-review-tier.md` — 置き換え（→ 0069）
- `.ai/adr/0057-no-age-differences-same-rules-for-all.md` — 採用
- `.ai/adr/0058-town-map-static-image-occupancy-route-only.md` — 置き換え（→ 0063）
- `.ai/adr/0059-town-map-marks-and-public-occupancy.md` — 置き換え（→ 0064）
- `.ai/adr/0060-dormant-stays-occupied-no-expiry-until-oq-088.md` — 採用
- `.ai/adr/0061-town-map-shared-monochrome-base-image.md` — 採用
- `.ai/adr/0062-stage-3-dormancy-reuse-expiry-by-oq-088.md` — 採用
- `.ai/adr/0063-town-map-static-image-candidate-marks-selectable.md` — 置き換え（→ 0083）
- `.ai/adr/0064-town-map-candidate-marks-selectable-public-occupancy.md` — 置き換え（→ 0084）
- `.ai/adr/0065-letters-acquaintances-only-board-open-per-post.md` — 採用
- `.ai/adr/0066-address-book-adds-stopped-when-not-mutual.md` — 採用
- `.ai/adr/0067-shop-accounts-created-by-operator-cli-only.md` — 採用
- `.ai/adr/0068-clean-up-tools-after-use.md` — 採用
- `.ai/adr/0069-letters-reject-and-review-tiers-real-info.md` — 採用
- `.ai/adr/0070-reject-tier-and-no-emoji-for-all-writes.md` — 採用
- `.ai/adr/0071-outside-contacts-banned-in-all-writes.md` — 採用
- `.ai/adr/0072-closed-letters-reviewed-no-llm-limited-decryption.md` — 採用
- `.ai/adr/0073-age-and-birthday-required-immutable.md` — 置き換え（→ 0093）
- `.ai/adr/0074-newspaper-acquaintance-editions-posts-and-birthdays.md` — 採用
- `.ai/adr/0075-account-deletion-and-retention-keep-delivery-runs.md` — 置き換え（→ 0077）
- `.ai/adr/0076-delivery-notification-web-push-retention-30-days.md` — 採用
- `.ai/adr/0077-letters-purged-after-settling-or-recipient-deletion.md` — 置き換え（→ 0079）
- `.ai/adr/0078-letter-reports-by-recipients-only.md` — 採用
- `.ai/adr/0079-account-erase-credentials-and-sessions-first.md` — 置き換え（→ 0085）
- `.ai/adr/0080-authentication-email-password-api-v1.md` — 採用
- `.ai/adr/0081-server-side-sessions-reauth-api.md` — 置き換え（→ 0090）
- `.ai/adr/0082-internal-id-address-from-candidates-or-vacant.md` — 採用
- `.ai/adr/0083-town-map-static-image-candidate-and-vacant-marks-selectable.md` — 採用
- `.ai/adr/0084-town-map-candidate-and-vacant-marks-selectable-public-occupancy.md` — 採用
- `.ai/adr/0085-account-erase-clears-all-resident-references.md` — 置き換え（→ 0091）
- `.ai/adr/0086-llm-provisional-selection-names-and-prices-published.md` — 採用
- `.ai/adr/0087-unverified-registration-holds-address-24h.md` — 採用
- `.ai/adr/0088-rate-limit-defaults-and-target-routes.md` — 採用
- `.ai/adr/0089-auth-tables-sessions-roles-rate-limits-totp.md` — 置き換え（→ 0101）
- `.ai/adr/0090-server-side-sessions-reauth-rate-limit-order.md` — 採用
- `.ai/adr/0091-erase-and-retention-cover-auth-tables.md` — 採用
- `.ai/adr/0092-delivery-runs-tick-and-failed-runs.md` — 置き換え（→ 0094）
- `.ai/adr/0093-age-birthday-immutable-shown-for-done-runs.md` — 採用
- `.ai/adr/0094-delivery-runs-tick-and-close-retry.md` — 採用
- `.ai/adr/0095-moderation-queue-unique-carry-label.md` — 採用
- `.ai/adr/0096-erasure-replay-redo-erase-from-markers.md` — 採用
- `.ai/adr/0097-milestones-keep-m0-m6-m1-address-account.md` — 採用
- `.ai/adr/0098-newspaper-deterministic-typesetting-holiday.md` — 採用
- `.ai/adr/0099-stages-m0-m6-gates-no-blocking-oqs.md` — 採用
- `.ai/adr/0100-modular-monolith-process-placement.md` — 採用
- `.ai/adr/0101-auth-tables-and-pending-mail-values.md` — 置き換え（→ 0102）
- `.ai/adr/0102-auth-tables-mail-and-registered-email.md` — 採用

## レビュー（`.ai/reviews/`）

- `.ai/reviews/0001-design-review.md` — 設計のレビュー（R-001〜）
- `.ai/reviews/0002-phase-evaluation-2026-11-25.md` — 段階の評価（2026-11-25）
- `.ai/reviews/0003-phase-evaluation-2026-11-26.md` — 段階の評価（2026-11-26、R-060〜R-064）

## チケット（`.ai/tickets/`）

- `.ai/tickets/YGO-001-features.md`
- `.ai/tickets/YGO-002-open-questions.md`
- `.ai/tickets/YGO-003-architecture.md`
- `.ai/tickets/YGO-004-db.md`
- `.ai/tickets/YGO-005-api.md`
- `.ai/tickets/YGO-006-async.md`
- `.ai/tickets/YGO-007-security.md`
- `.ai/tickets/YGO-008-roadmap.md`
- `.ai/tickets/YGO-009-environment.md`
- `.ai/tickets/YGO-010-design-review.md`
- `.ai/tickets/YGO-011-vacancy-definition.md`
- `.ai/tickets/YGO-012-keep-delivery-runs.md`
- `.ai/tickets/YGO-013-purge-settled-letters.md`
- `.ai/tickets/YGO-014-letter-reports-recipients-only.md`
- `.ai/tickets/YGO-015-erase-credentials-and-sessions.md`
- `.ai/tickets/YGO-016-auth-endpoints.md`
- `.ai/tickets/YGO-017-remove-cross-doc-proposals.md`
- `.ai/tickets/YGO-018-erase-all-resident-references.md`
- `.ai/tickets/YGO-019-write-delivery-run-finished-at.md`
- `.ai/tickets/YGO-020-prepared-at-and-carry-over.md`
- `.ai/tickets/YGO-021-mvp-definition.md`
- `.ai/tickets/YGO-022-brief-map.md`
- `.ai/tickets/YGO-023-vendor-names-redaction.md`
- `.ai/tickets/YGO-024-m1-scope-line.md`
- `.ai/tickets/YGO-025-vendor-names-published.md`
- `.ai/tickets/YGO-026-index-and-m1-diagrams.md`
- `.ai/tickets/YGO-027-m1-k-items.md`
- `.ai/tickets/YGO-028-mvp-status-confirmed.md`
- `.ai/tickets/YGO-029-fr-094-api-db-async.md`
- `.ai/tickets/YGO-030-oq-092-vendor-names-precedence.md`
- `.ai/tickets/YGO-031-delivery-run-failed.md`
- `.ai/tickets/YGO-032-close-retry-pending-letters.md`
- `.ai/tickets/YGO-033-moderation-queue-unique.md`
- `.ai/tickets/YGO-034-erasure-replay-redo.md`
- `.ai/tickets/YGO-035-milestone-split.md`
- `.ai/tickets/YGO-036-retro-heading-wording.md`
- `.ai/tickets/YGO-037-profile-probe-t05.md`
- `.ai/tickets/YGO-038-general-rate-limit-routes.md`
- `.ai/tickets/YGO-039-totp-secret-collected-items.md`
- `.ai/tickets/YGO-040-requirements-rows-adr.md`
- `.ai/tickets/YGO-041-oq-020-llm-text-adr-0055.md`
- `.ai/tickets/YGO-042-adr-0022-d6-no-blockers.md`
- `.ai/tickets/YGO-043-m1-gaps-ticket-per-row.md`
- `.ai/tickets/YGO-044-r-055-vendor-names-precedence-confirmed.md`
- `.ai/tickets/YGO-045-g-009-m0-env-promises-a-07.md`
- `.ai/tickets/YGO-046-g-010-d-rows-decision-adr.md`
- `.ai/tickets/YGO-047-g-011-req-5-1-points-to-oq.md`
- `.ai/tickets/YGO-048-g-012-oq-headings-match-table.md`
- `.ai/tickets/YGO-049-g-013-adr-0100-process-placement.md`
- `.ai/tickets/YGO-050-g-014-architecture-inferred-tags.md`
- `.ai/tickets/YGO-051-r-060-registration-mail-job.md`
- `.ai/tickets/YGO-052-r-061-registered-email-response.md`
- `.ai/tickets/YGO-053-r-062-mvp-stale-adr-refs.md`
- `.ai/tickets/YGO-054-g-048-fr-094-mapping-confirmed.md`
- `.ai/tickets/YGO-055-g-049-mail-job-confirmed.md`
- `.ai/tickets/YGO-056-g-051-registered-email-201-confirmed.md`
- `.ai/tickets/YGO-057-g-065-unverified-hold-24h-confirmed.md`
- `.ai/tickets/YGO-058-g-068-requirements-adr-aligned-confirmed.md`
- `.ai/tickets/YGO-059-index-complete-no-broken-links.md`
- `.ai/tickets/YGO-060-diagrams-fr-adr-m-lines.md`
- `.ai/tickets/YGO-061-m1-test-plan.md`
- `.ai/tickets/YGO-062-m1-test-harness.md`