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
