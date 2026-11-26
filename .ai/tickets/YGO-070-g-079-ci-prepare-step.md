# YGO-070 G-079 CI の定義で prepare.sh の段を check.sh の前に置く
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。`.ai/gaps.md` で向かう M が M1 の行のうち、題で指すチケットがまだない行は G-079 だけで、このチケットはそれを追う。
CI の定義が ADR-0104 の D1（CI は `sh scripts/prepare.sh` のあとに `sh scripts/check.sh` を動かす）を満たし、G-079 を閉じられるようにする。

## 確かめた事実（このチケットを切った時点）
- `.ai/gaps.md` の G-079 は `暫定`・`M1`。出どころは「仕分け 10 の K-019・仕分け 11・ADR-0104 の D2」。閉じる条件は「CI の定義に `sh scripts/prepare.sh` の段が `sh scripts/check.sh` の前にある（YGO-062 の受け入れ確認 18）」。
- レポジトリに `.github/` と `package.json` はまだない。
- ADR-0104 の状態は `採用`。
- `.ai/environment.md` §5 の文に、秘書が YGO-062 の実装の前にこの段を足すことをマスターに伝え、段があるまでは G-079 で追うことが書かれている。§5.1 の表に「CI の定義の `sh scripts/prepare.sh` の段」の行があり、伝える時は「`package.json` を入れる前（YGO-062 の実装の前）」。
- `.ai/deploy/readiness.md` に G-079 の箇条がある。
- `.ai/triage.md` の G-079 の行（仕分け 11）は、決めることは残っておらず、新しい OQ は立てないとしている。

## 依存
- マスターが CI の定義に段を足すこと（ADR-0104 の D2）。秘書は YGO-062 の実装の前にそれを伝える。
- 新しい OQ・要回答は立てない（道具を入れるのをマスターとした OQ-086 → 決定と同じ扱い）。
- 閉じる条件は、ファイルで確かめられる事実（受け入れ確認 1）だけにする。

## 範囲（段が入ったあとに `.ai/` だけを直す）
1. CI の定義を読み、段の順を確かめる。ジョブは `.github/` を書かない（CLAUDE.md）。
2. `.ai/gaps.md` の G-079 を、閉じた G-077・G-078 と同じ書き方で閉じる（状態の列 `暫定`・M の列 `M1` は変えない）。内容の列は `YGO-070 で` で始めて `残りはない` で終え、出どころの列の末尾に `（YGO-070）` を足す。
3. `.ai/environment.md` §5・§5.1 と `.ai/deploy/readiness.md` の「段がまだない」前提の書き方を、段がある今の状態に直す。
4. YGO-062 の受け入れ確認 18 の文は変えない。

## 直さないところと理由
- `.github/`・`scripts/`・`standards/`: CI の定義と標準はジョブの変更の外（CLAUDE.md）。
- `.ai/status.md`: 秘書が書く（CLAUDE.md）。
- ADR-0104: 決定は変わらない。新しい ADR・OQ は 0 件。
- このチケットを切る変更では `.ai/gaps.md` も直さない（段はまだない）。

## 受け入れ確認
1. `.github/workflows/` の下に CI の定義のファイルがあり、`sh scripts/prepare.sh` の行が `sh scripts/check.sh` の行より前にある。
2. `.ai/gaps.md` の G-079 の行の内容の列が `YGO-070 で` で始まり `残りはない` で終わる。出どころの列に `（YGO-070）` があり、向かう M の列は `M1` のまま。
3. `.ai/environment.md` §5 と `.ai/deploy/readiness.md` の G-079 の箇所に「段があるまでは」などの、段がまだない前提の書き方が残っていない。§5.1 の表に `sh scripts/prepare.sh` の段の行がある。
4. ADR-0104 の状態の行が `- 状態: 採用` のまま。YGO-062 の受け入れ確認 18 の文が変わっていない。
5. `git diff --stat` に `.github/`・`scripts/`・`standards/`・`.ai/status.md` が入っていない。新しい ADR のファイルと OQ の行もない。
6. 変更したファイルに、事業者の名前・ホスト名・認証情報・アカウントの ID・絶対パスが書かれていない。
7. `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
