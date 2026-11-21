# YGO-010 設計の 10 文書のレビュー（.ai/reviews/0001-design-review.md）
状態: done

## 目的
目標 g-7fdbeaee の条件 1（設計の 10 の文書をすべて読んだレビューが `.ai/reviews/` にある（重大・中・軽微の区別つき））を満たします。

## 範囲
- 対象の 10 文書は、`CLAUDE.md` と `.ai/README.md` の記述にもとづいて列挙します。候補は `requirements.md`・`features.md`・`open-questions.md`・`architecture.md`・`db.md`・`api.md`・`async.md`・`security.md`・`roadmap.md`・`environment.md` です。`CLAUDE.md` や `.ai/README.md` の定義と違う場合は、そちらに従います。
- 各文書を通読し、次の点を洗い出します: 文書どうしの食い違い、ADR（`.ai/adr/`）との矛盾、未定義の用語、抜け。
- 指摘は `.ai/reviews/0001-design-review.md` に 1 件ずつ書きます（`.ai/reviews/` は新規に作ります）。各指摘には次を付けます。
  - 重大・中・軽微の区別
  - 根拠の箇所（ファイルと節。行番号があれば行番号も）
  - 直し方の案
  - マスターの判断が要るかどうか
- レビューの判断基準は `standards/review.md` に従います。
- 範囲外: このチケットでは指摘を直しません。直すのは別のチケットで行います。実装もしません。`.ai/brief.md` は書き換えません。
- 公開レポジトリのため、個人情報・認証情報・実在の人や団体を書きません。

## 受け入れ確認
- `.ai/reviews/0001-design-review.md` がある。
- 冒頭に、読んだ 10 文書の一覧がある。
- すべての指摘に、区別と根拠の箇所がある。
- 重大・中・軽微の件数の集計がある。
- `sh scripts/check.sh` が通る。
- 終えたら、同じ変更でこのチケットの状態を `done` にする。
