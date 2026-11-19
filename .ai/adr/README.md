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
