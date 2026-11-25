# YGO-041 R-027 OQ-020 の決定を ADR-0055 の記事の文字は LLM にそろえる（G-005）
状態: done
M: M1

## 目的
条件 8 のために、レビューの指摘 R-027（中。`open-questions.md` の OQ-020 の決定が「LLM による文章生成は行わない」のままで、FR-111（記事の文字は LLM が作る）と食い違って読める）を片づける。OQ-020 の決定・理由・ADR を、今の新聞の決定（ADR-0055 の D7・D8）に書き直す。OQ-020 が挙げる ADR-0007 にも経緯の注記と「まとめ」を書く文が残っていたので、ADR-0098 で丸ごと置き換える。

## 仕分け
- `triage.md` の最新の回（仕分け 4）の「今決める」は K-017 だけで、YGO-035（ADR-0097）で済んでいる。R-027 を扱う K-NNN はないので、題に K を書かない。K の順に外れることもない。
- R-027 を扱っているのは `gaps.md` の G-005（暫定・M1）。
- M の判定: 関係する要求（FR-033・FR-036・FR-037・FR-111）は `roadmap.md` の `- M1:` の行になく、新聞（F-06）は M5。それでも M1 とするのは、持ち越し G-005 の向かう M が M1 で、文書の直しだけで済むため（YGO-040 と同じ扱い）。
- マスターの判断: R-027 は「不要」。新しい要回答は 0 件。

## 直し方の案との違い
- 案が挙げる ADR-0039 は `置き換え（→ 0055）` なので、ADR-0055 を挙げる。
- CLAUDE.md の「文書は今の状態に書き直す」に従い、「（ADR-0039 で置き換え）」のような経緯の注記は足さず、決定の文を今の状態に書き直す。
- ADR-0007 は注記を重ねず、生きている決定（テンプレートでの決定的な組版・組版の失敗は休刊・LLM の失敗では休刊にしない・全住民に版を届ける・紙面の構成の案）を今の決定に合わせて新しい ADR-0098 にまとめ、ADR-0007 を丸ごと置き換える（見直し 1 回目の R1-F1）。ADR-0098 は投稿の「まとめ」を書かない（ADR-0055 の D7・ADR-0054 の D9）。

## 範囲
- `.ai/adr/0098-newspaper-deterministic-typesetting-holiday.md`（新規）: D1〜D5。ADR の README の一覧と `.ai/INDEX.md` の ADR の一覧に載せる。
- `.ai/adr/0007-newspaper-deterministic-template.md`: 状態の行を `置き換え（→ 0098）` の 1 行にする（本文は変えない）。README の一覧に「（ADR-0098 で置き換え）」。
- `.ai/open-questions.md` の `### OQ-020`: 決定を「組版はテンプレートで決定的。記事の文字は LLM が作って `newspaper_articles` に保存し、組版（J3・J8）は保存した文字から決定的に行い、やり直しで LLM を呼ばない（ADR-0055 の D7）。LLM の失敗・検査に外れた出力では決まった形で組み、休刊にしない（ADR-0055 の D8）」に書き直す。理由を冪等性（FR-037・NFR-022）と NFR-063 にする。ADR の欄を ADR-0098 と ADR-0055 にする。関連に FR-111 を足す。
- `.ai/open-questions.md` §2 の一覧の OQ-020 の行に FR-111 を足す（状態 `決定` は変えない）。D-004 の行を `決定済み（ADR-0098・ADR-0055）` にする。`### OQ-021` の ADR の欄を ADR-0098 にする（休刊の決定は ADR-0098 の D2）。
- 今の決定の ADR-0007 の参照を ADR-0098 に直す: `requirements.md` の FR-036・NFR-030、`architecture.md` の C6 と §5 の休刊、`async.md` の休刊の扱い・スキップした回・FR-037 の対応、`db.md` の `is_holiday`、`api.md` の `GET /api/v1/newspapers/{id}`、`environment.md` の紙面の組み直し、`roadmap.md` の M3・M5 の行。同じ箇所の ADR-0039 の参照（`architecture.md` §5・`api.md`・`roadmap.md` M5）は ADR-0055 にする。
- `.ai/gaps.md` の G-005: YGO-041 でそろえたこと・ADR-0098 での置き換えと「残りはない」を書き、出どころを `R-027（YGO-041）` にする。
- `.ai/INDEX.md`: チケットの一覧にこのチケットを足す。

## 直さないところと理由
- ほかの ADR の本文の ADR-0007 の参照（ADR-0011・0016・0022・0035・0039・0044〜0046・0054・0092・0094）: 決定の記録で、ADR-0007 の決定は ADR-0098 に同じ中身で移っているため、読み替えで足りる。
- `open-questions.md` の OQ-042・OQ-051・OQ-058・OQ-061 の行と本文の ADR-0007: その答えのときに直した文書の記録。
- `mvp.md` の ADR-0007 の参照: ジョブは `mvp.md` を変えない。ADR-0098 の影響に、その参照を ADR-0098 として読むことを書いた。
- FR-036 の ADR-0039 の参照・FR-037・FR-111 の古い ADR の参照: R-041・G-017 の範囲。
- OQ-020 の見出しの「（未確定）」: G-012 の範囲。
- `triage.md`・`reviews/`・`status.md`・`mvp.md`: 変えない。
- テスト: 文書だけの変更で足さない。

## 受け入れ確認
- `.ai/open-questions.md` の `### OQ-020` の節に「LLM による文章生成は行わない」「もとは」の文がない。
- その節の決定に「記事の文字」「`newspaper_articles` に保存」「保存した文字から決定的」「LLM を呼ばない」「休刊にしない」があり、ADR-0055 の D7・D8 を挙げている。
- その節の ADR の欄は 0098 と 0055 だけで、0007・0039 がない。ADR-0055 と ADR-0098 の状態の行は `採用`。
- `.ai/adr/0007-newspaper-deterministic-template.md` の状態の行は `- 状態: 置き換え（→ 0098）` の 1 行だけ。
- `.ai/adr/0098-newspaper-deterministic-typesetting-holiday.md` の題は 40 字以内で、決定に「まとめ」を書く文がなく、D1 は ADR-0055 の D7、D2 は休刊と ADR-0035 の D11、D3 は ADR-0055 の D8 を挙げている。経緯の注記（「もとは」「で置き換え）」）がない。
- `.ai/adr/README.md` と `.ai/INDEX.md` に ADR-0098 がある。
- `requirements.md`・`architecture.md`・`async.md`・`db.md`・`api.md`・`environment.md`・`roadmap.md` に「ADR-0007」がない。
- `.ai/open-questions.md` の `### OQ-021` の ADR の欄は `[0098-newspaper-deterministic-typesetting-holiday](.ai/adr/0098-newspaper-deterministic-typesetting-holiday.md)` の 1 つだけで、0007 がない。
- `.ai/adr/0098-newspaper-deterministic-typesetting-holiday.md` の影響の節の `open-questions.md` の項に OQ-021 がある。
- `.ai/open-questions.md` の `### OQ-020` の節の関連と §2 の一覧の OQ-020 の行に FR-111 があり、一覧の状態は `決定`。D-004 の行は ADR-0098・ADR-0055。
- `.ai/gaps.md` の G-005 の行が 5 列で、理由に YGO-041・ADR-0098 と「残りはない」、出どころに `R-027（YGO-041）` がある。
- `.ai/INDEX.md` のチケットの一覧に `.ai/tickets/YGO-041-oq-020-llm-text-adr-0055.md` がある。
- `.ai/triage.md`・`.ai/reviews/`・`.ai/mvp.md`・`.ai/status.md` に差分がない。
- `sh scripts/check.sh` が `check: ok` を出す。
