# YGO-049 G-013 ADR-0008 を置き換え、C5 のルール表の共有と C11〜C13 の置き場を書く
状態: done
M: M1

## 目的
条件 10 のために、`gaps.md` の G-013（暫定・M1、出どころ R-037）を閉じる。
R-037（`reviews/0001-design-review.md`、区別: 軽微、マスターの判断: 不要）は、ADR-0008 が C5 を worker だけに置いたままで、手紙の照合が web の投函に移ったことと、C11〜C13 を worker に足したことが書かれていないことを挙げた。
`gaps.md` 冒頭の決まり（YGO-043）に従い、題に G-013 を 1 つ付けたこのチケットで 1 行を閉じる。

## 仕分け
- `triage.md` は K の順を指定していない。
- 参照を足すだけでは済ませない。ADR-0008 の決定（C5 は worker だけ）は ADR-0069・ADR-0070 の D3 で一部が変わっており、状態の行に注記を重ねることは決まりで禁じられている。そこで ADR-0008 の生きている決定と新しい決定をまとめた ADR-0100 を作り、ADR-0008 を丸ごと置き換える（YGO-041 の 0007→0098、YGO-042 の 0022→0099 と同じやり方）。
- マスターに決めてもらうことはなく、M1 も止めないので、新しい OQ・要回答は 0 件。

## 確かめた事実（直す前）
- `adr/0008` の決定は、C5 モデレーションを worker プロセスで動くものに入れ、web には入れていない。C11〜C13 の記述はない。
- `architecture.md` §2 の C5 の行の「動くプロセス」は `worker（ルール表は web / worker で共有）`。C2 の行は投函のときの 2 段の照合（ADR-0069）と、ほかの書き込みの `reject` の段（ADR-0070 の D3）を web で行う。C11・C12・C13 の行の「動くプロセス」は `worker`。
- 今の決定として ADR-0008 を指していたのは、`architecture.md` §1 の 1、`api.md` §1 の 3 と §2.5、`async.md` の関連 ADR と §1 の 1、`environment.md` §3 の web と worker の行、`roadmap.md` §4 の M0 の行、`diagrams/m1-components.md` の ADR の行。

## 範囲
- このチケット。
- 新規 `.ai/adr/0100-modular-monolith-process-placement.md`（決定 1〜5。ADR-0008 の理由と代わりの案を移し、代わりの案に「照合を worker だけに置く」を足す）。
- `.ai/adr/0008-modular-monolith-two-processes.md`: 状態の行だけ。
- `.ai/adr/README.md`: 0008 の行の末尾と、0100 の行。
- `.ai/architecture.md`（§1 の 1、C5 の行の ADR）・`.ai/api.md`（:25・:108）・`.ai/async.md`（関連 ADR・§1 の 1）・`.ai/environment.md`（:65・:66）・`.ai/roadmap.md`（M0 の行・「MVP で依存する ADR」）・`.ai/diagrams/m1-components.md`（ADR の行）: ADR-0008 の参照を ADR-0100 にする。
- ADR の範囲から置き換え済みの 0008 を除き、0100 を足す: `.ai/roadmap.md` §3 の表の MVP の行（`ADR-0002〜0007・ADR-0009〜0012・ADR-0100`）と §4 の「MVP で依存する ADR」（`0002〜0007・0009〜0012`）、`.ai/environment.md` 6 行目の根拠（`0009〜0012` と末尾の `0100`）。
- `.ai/architecture.md` §2 の C13 の行の ADR の列・`.ai/security.md` の J17 の行と T-19 の行: C13 の根拠を、置き換え済みの ADR-0039 から ADR-0100 の決定の 3 と同じ ADR-0055（D6）にする。
- `.ai/INDEX.md`: 知りたいことの表に 1 行、ADR とチケットの一覧に 1 行ずつ。
- `.ai/gaps.md`: G-013 の行の理由と出どころの列だけ。

## 直さないところと理由
- ADR-0009・0015・0052 の本文にある ADR-0008 の参照: 書いた時点の記録として残す（YGO-042 と同じ扱い）。
- `roadmap.md` 7 行目の関連 ADR の一覧（0100 がまだない）と、`api.md`・`db.md` の冒頭の関連 ADR・`architecture.md` の冒頭の根拠の `0001〜0012`: 冒頭の関連 ADR の一覧の整理として G-017 で扱う。
- `architecture.md` §1 の 1 などの `[explicit]` の付け方: G-014 で扱う。
- `status.md`・`mvp.md`・`triage.md`・`open-questions.md`・`scripts/check.sh`: 秘書・仕分けのジョブが書く文書か、この変更でかからない。文書だけの変更で、テストは足さない。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-049 G-013 ADR-0008 を置き換え、C5 のルール表の共有と C11〜C13 の置き場を書く`・`状態: done`・`M: M1`。題の G 番号は G-013 だけ。
2. `adr/0100-modular-monolith-process-placement.md` の 1 行目が `# 0100 — モジュラーモノリスと 2 プロセス、ルール表は共有`（題は 40 字まで）、3 行目が `- 状態: 採用`。冒頭に「ADR-0008 を丸ごと置き換える」と R-037・G-013（YGO-049）がある。
3. ADR-0100 の決定の 2 に、web で使う C5 はルール表だけで、用途が投函のときの照合（ADR-0069）と `reject` の段（ADR-0070 の D3）であり、LLM の分類器を渡さない（ADR-0072）ことが書かれている。決定の 3 に、C5 の審査・C6・C11・C12・C13 が worker で動き、ジョブを実行するのは worker だけと書かれている。
4. ADR-0100 の代わりの案に「照合を worker だけに置く」があり、不採用の理由に ADR-0069 の 422 が書かれている。
5. `adr/0008-modular-monolith-two-processes.md` の 3 行目が `- 状態: 置き換え（→ 0100）` で、ほかの行は変わっていない。
6. `adr/README.md` の 0008 の行の末尾が `（ADR-0100 で置き換え）`、最後の行が 0100 の行。
7. `architecture.md` §1 の 1・C5 の行、`api.md` §1 の 3・§2.5、`async.md` の関連 ADR・§1 の 1、`environment.md` の web と worker の行、`roadmap.md` の M0 の行と「MVP で依存する ADR」、`diagrams/m1-components.md` の ADR の行が ADR-0100 を指し、ADR-0008 を指していない。`roadmap.md` §4 の「MVP で依存する ADR」の範囲が `0002〜0007・0009〜0012` で同じ行に `0100` があり、§3 の表の MVP の行に `ADR-0002〜0007・ADR-0009〜0012・ADR-0100` がある。`environment.md` 6 行目の根拠が `0009〜0012` で末尾に `0100` があり、`0008` を含まない。
8. `INDEX.md` の知りたいことの表に「プロセスの分け方（web / worker）と C1〜C13 の置き場」の行があり、ADR の一覧に `.ai/adr/0100-modular-monolith-process-placement.md`、チケットの一覧に `.ai/tickets/YGO-049-g-013-adr-0100-process-placement.md` がある。
9. `gaps.md` の G-013 の行は 5 列で、向かう M は `M1`。理由の列に `YGO-049` と「残りはない」があり、出どころの列は `R-037（YGO-049）`。ほかの G の行には差分がない。
10. `architecture.md` §2 の C13 の行の ADR の列が `F-06 / ADR-0055` で、`security.md` の J17（`external_news_items`）の行が `ADR-0055 の D6・ADR-0070 の D6`、T-19 の行が `ADR-0055 の D6` を指し、どれも ADR-0039 を指していない。
11. 新しい OQ・要回答は 0 件（`open-questions.md` に差分がない）。
12. `sh scripts/check.sh` が `check: ok` で終わり、check:consolidation の「今の M（M1）の範囲の点検」が 13 件に減って G-013 が出ない。
