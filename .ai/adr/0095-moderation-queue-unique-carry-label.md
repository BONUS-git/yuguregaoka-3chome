# 0095 — 審査キューは投稿と回で一意にし、持ち越しでラベルを継ぐ

- 状態: 採用
- 日付: 2026-11-25

`reviews/0001-design-review.md` の R-013、`triage.md` 仕分け 3 の K-007（YGO-033）。
R-013 のマスターの判断は「不要」で、すべて秘書の判断 `[assumed]`。ADR-0094（J1 の `WHERE NOT EXISTS`）と ADR-0091（審査キューの 1 年の保持）の決定は変えず、足すだけ。

## 背景

`moderation_queue`（掲示板の投稿の審査キュー）には一意制約がなく、J1 のやり直しで同じ投稿の行が重なりうる。
ADR-0094 の D8 で J1 の挿入を `WHERE NOT EXISTS` にしたが、DB の側の守りはない。
審査が打ち切りまでに決まらない投稿と `review` の投稿は次の配達回に持ち越され、移し先の回の J1 が新しい行を入れる。
新しい行はラベルを持たないので、J2 が LLM を呼び直し、持ち越しのたびに費用を払う。
前の回の行は `processed_at` が NULL のまま残り、J14 の条件（`processed_at < now() - 1 year`）に当たらないので消えない。

## 決定

- **D1 一意制約**: `moderation_queue` に `UNIQUE(content_kind, content_id, delivery_run_id)` を足す [assumed]。1 つの投稿は 1 つの配達回に 1 行だけ。
  J1 の挿入は ADR-0094 の D8 のまま `INSERT … SELECT … WHERE NOT EXISTS` で、制約は DB の側の守り（競り合いで重なった挿入は制約違反で失敗し、J1 の再試行で `WHERE NOT EXISTS` に弾かれる）。
- **D2 前の回の行を閉じる**: 投稿を次の配達回に移すトランザクション（J2 の打ち切りの持ち越しと J6 の手順 3）で、
  同じ投稿の前の回の行のうち `processed_at IS NULL` のものに `processed_at = now()` を書く [assumed]。
  `policy_decision` は NULL のまま残し、`processed_at` があって `policy_decision` が NULL の行を「持ち越した行」とする。
  モデレーターの人の審査（`approved` / `rejected`）は、投稿の今の配達回の行（`delivery_run_id = board_posts.delivery_run_id`）に `policy_decision`（`approved` / `blocked`）と `processed_at` を書き、持ち越した行は変えない [assumed]。
  今の配達回の行がまだない（移した直後で移し先の回の J1 が動いていない）ときは、同じトランザクションで D3 のとおり `llm_label` を写した行を入れてから書く（D1 の UNIQUE で J1 の行と重ならず、J1 は `WHERE NOT EXISTS` で入れない）。
- **D3 ラベルを写す**: 移し先の回の J1 は、行を入れるときに、同じ投稿の前の行のうちいちばん新しい行の `llm_label` だけを写す [assumed]。
  `policy_decision`・`matched_rule_id`・`rule_version` は写さず、J2 がその回のルール表で当て直す（ADR-0005 の順序のまま。ラベルがあれば LLM を呼ばない）。
  前の行の `llm_label` が NULL（LLM が失敗した・打ち切りまでに呼べなかった）なら NULL のままにし、移し先の回の J2 が LLM を呼ぶ。
- **D4 保持の起点**: `moderation_queue` に `created_at`（行を入れた時刻）を足す。J14 は `coalesce(processed_at, created_at) < now() - interval '1 year'` の行を消す [assumed]。
  1 年の期間は ADR-0091 のまま。`processed_at` が NULL のまま残った行（D2 の閉じ忘れなど）も、入れてから 1 年で消える。
- **D5 管理画面の一覧**: `GET /api/v1/admin/moderation-queue` は、`board_posts.status = 'awaiting_review'` の投稿ごとに、同じ `content_kind`・`content_id` の行のうちいちばん新しい行（`created_at` が最大）を、閉じた（`processed_at` がある）行かどうかによらず 1 行だけ返す [assumed]。
  同じ投稿は一覧に 1 回だけ出る。J2 が持ち越した直後で移し先の回の J1 がまだ動いていない間も、前の回の行で一覧に出つづける（移し先の回の J1 を待たない）。

## 理由

- 一意の単位を (投稿, 配達回) にすると、持ち越しの記録（どの回で決まらなかったか）が残り、同じ回の重なりだけを弾ける。
- ラベルは本文から決まり、本文は持ち越しで変わらないので写してよい。判定はルール表の版で変わりうるので、回ごとに当て直す。
- 保持の起点に `created_at` を足すと、`processed_at` を書きそこねた行も必ず期限が来る。

## 代わりの案

**`UNIQUE(content_kind, content_id)` にして、持ち越しでは行の `delivery_run_id` を書き換える**: 行が 1 つで済むが、どの回で決まらなかったかの記録が消え、J3 の「審査が済んだ」（回の `processed_at` が NULL の行がない）を回ごとに見られなくなる。不採用。

**ラベルを写さず、持ち越しのたびに LLM を呼ぶ**: R-013 の費用の二重払いが残る。不採用。

**判定も写す**: ルール表を改めたあとに持ち越した投稿が古い版の判定のまま公開される。不採用。

## 影響

- `db.md` §2 の `moderation_queue`（`created_at`・UNIQUE・`llm_label`・`processed_at` の説明）・§5 の保持の表・§7 の冪等性の表
- `async.md` §2 の J1 の行・§4 の J1（出力・冪等性）・J2（打ち切りの持ち越し）・J6（手順 3）・J14 の対象の表・§6「審査が間に合わない」・§7 のテスト「審査キューの一意と持ち越し」
- `roadmap.md` A-04 のケースの数
- `api.md` の `GET /api/v1/admin/moderation-queue` の行
- `gaps.md` G-054（M4）: 審査の打ち切りより前に J2 の再試行が尽きたとき、審査待ちの投稿を次の回に移すジョブ
