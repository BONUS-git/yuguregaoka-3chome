# YGO-069 G-078 マスターに伝える道具の主版を 1 つの一覧にまとめる
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。`.ai/gaps.md` で向かう M が M1 の行のうち、題で指すチケットがまだない最も若い行が G-078 で、このチケットはそれを閉じる。
道具の主版はもう決まっている（Node.js 26 `[assumed]`・PostgreSQL 18 `[assumed]`）が、書いてある場所が分かれている。秘書が 1 回でマスターに伝えられるよう、伝える道具と主版の一覧を `environment.md` §5 の 1 か所にまとめる。主版を新しく決めない、文書のまとめの変更である（仕分け 10 で暫定・あとで変えても安い）。

## 確かめた事実（このチケットを切った時点）
- `.ai/gaps.md` の G-078 は `暫定`・`M1`、出どころは「仕分け 10・YGO-065 の依存の節・OQ-086」。
- `.ai/environment.md` §3.1 の Node.js の行は主版 26 `[assumed]`（`engines.node` に `26.x`、YGO-062）。PostgreSQL の行は「サーバーの主版を 1 つに決めて（M0）」とだけあり、主版の数字がない。
- `.ai/environment.md` §5 は、伝える道具（Node.js の `engines.node`・PostgreSQL の主版・IaC の前の `tofu`）と CI の定義の `sh scripts/prepare.sh` の段（G-079）を、表ではなく文の中に書いている。
- PostgreSQL の主版 18 を決めているのは YGO-065（`状態: open`）の依存の節で、そこに「このチケットで決める」とある。
- `.ai/environment.md` §4.1 の 1 と 4 は、秘書が主版を伝えることをそれぞれの文の中で書いている。
- G-079 の閉じる条件は「CI の定義に `sh scripts/prepare.sh` の段が `sh scripts/check.sh` の前にある（YGO-062 の受け入れ確認 18）」。G-079 の行と `environment.md` §5 は、G-078 の一覧にこの段を入れるとしている。
- レポジトリに `package.json` はまだない（`engines.node` は YGO-062 の実装で書く）。
- `scripts/check.sh` は、`.ai/` の下のファイルが `.ai/INDEX.md` に載っていないと失敗する。

## 依存
- 前提にするチケットはない。YGO-062・YGO-065 が `open` のままでも始められる（主版を変えず、文書をまとめるだけのため）。
- 道具を入れるのはマスター（OQ-086 → 決定）。新しい OQ は立てない。

## 範囲
1. **`.ai/environment.md` §5 に一覧の表を足す**。見出しは `| 道具・段 | 主版・形 | 入れる場所 | 根拠 | 伝える時 |`。行は次の 7 つ:
   - Node.js（主版 26 `[assumed]`、`engines.node` の `26.x`。YGO-062・ADR-0009）
   - npm（Node.js に付くもの。ロックファイルで依存を固定。ADR-0103）
   - `initdb`（主版 18 `[assumed]`。ADR-0010・YGO-065）
   - `pg_ctl`（主版 18 `[assumed]`）
   - `psql`（主版 18 `[assumed]`）
   - CI の定義の `sh scripts/prepare.sh` の段（`sh scripts/check.sh` の前。ADR-0104 の D2・G-079）
   - `tofu`（IaC のコードを書く前に伝える。ADR-0052）
   入れる場所の列は「CI の実行の環境・秘書のジョブの環境（マスターが入れる。OQ-086 → 決定）」の形で、事業者の名前やイメージの名前は書かない。§5 の文の中の道具の並び（「秘書は Node.js（`engines.node`）と PostgreSQL の主版と、IaC の前に `tofu` を伝える」と、G-078 の一覧に段を入れるという文）は、この表を指す 1 文にする。
2. **`.ai/environment.md` §3.1 の PostgreSQL の行**に主版 18 `[assumed]` を書き、§5 の一覧を指す。
3. **`.ai/environment.md` §4.1 の 1・4** の「秘書は … 主版を伝える」は、主版の数字を重ねて書かず、§5 の一覧を指す形にそろえる。
4. **YGO-065 の依存の節**の「このチケットで決める」を、主版 18 は `environment.md` §5 の一覧にあることを指す形に直す（主版の数字は変えない）。範囲と受け入れ確認の §3.1 の PostgreSQL の行を書く項目は、§3.1 に主版がすでにあることに合わせて、`check.sh` の確かめだけを書く形にそろえる。
5. **`.ai/gaps.md` の G-078 を閉じる**: 閉じた G-077 の行と同じ書き方にする（状態の列 `暫定`・M の列 `M1` は変えない）。内容の列を「YGO-069 で、道具の主版の一覧を `environment.md` §5 の表にまとめ、§3.1 の PostgreSQL の行に 18 を書き、YGO-065 の依存の節はその一覧を指す形にした。残りはない」の形にし、出どころの列の末尾に `（YGO-069）` を足す。G-079 は開いたまま、「G-078 で … 作るときは」の文だけを「`environment.md` §5 の一覧にこの段の行がある」の形にそろえる（閉じる条件は変えない）。
6. **`.ai/INDEX.md` の「環境・秘密・費用」の行**に、伝える道具の主版の一覧は §5 の表であることを足す。
7. **食い違う 2 つの文書を同じ変更で直す**（どちらも今の時点で範囲 1・2 と食い違っている）:
   - `.ai/triage.md` の G-078 の行: 「`environment.md` §3.1 の PostgreSQL の行には YGO-065 で書く」は範囲 2（YGO-069 で書く）と両立しないので、「§3.1 の PostgreSQL の行に 18 を書く（YGO-069）」の形に直す。「`environment.md` §3.1・§5 の 1 か所にまとめ」は「`environment.md` §5 の表にまとめ」の形に直す。
   - `.ai/deploy/readiness.md` の G-078 の箇条: 「`environment.md` §3.1・§5 の 1 か所にまとめる」を、`environment.md` §5 の表にまとめる形（G-078 は YGO-069 で閉じた）に直す。

## 直さないところと理由
- 主版の数字（Node.js 26・PostgreSQL 18）: 決まっている暫定で、このチケットはまとめるだけ。
- `scripts/`・`.github/`: CI の定義はジョブの変更の外（CLAUDE.md）。G-079 はマスターが段を足すまで残る。
- `.ai/status.md`: 秘書が書く（CLAUDE.md）。
- 新しい ADR・OQ・要回答: 0 件（主版を新しく決めない。道具を入れる人は OQ-086 で決まっている）。

## 受け入れ確認
1. `.ai/environment.md` §5 に、見出しが `| 道具・段 | 主版・形 | 入れる場所 | 根拠 | 伝える時 |` の表があり、Node.js・npm・`initdb`・`pg_ctl`・`psql`・`sh scripts/prepare.sh` の段・`tofu` の 7 行がある。
2. その表の Node.js の行に `26` と `[assumed]`、`initdb`・`pg_ctl`・`psql` の行にそれぞれ `18` と `[assumed]` が書かれている。
3. `.ai/environment.md` §3.1 の PostgreSQL の行に `18` と `[assumed]` があり、Node.js の行の主版 26 とあわせて、§5 の表の主版と同じ数字である。
4. `.ai/environment.md` §5 の箇条の文に、「秘書は Node.js（`engines.node`）と PostgreSQL の主版と、IaC の前に `tofu` を伝える」の並びが残っておらず、表を指す文がある。§5 の 2 つ目の箇条に「G-078 の一覧（§3.1・§5）」と「作るときは」が残っておらず、`sh scripts/prepare.sh` の段は §5 の表の行として指されている。§4.1 の 1・4 に主版の数字（26・18）が書かれていない。
5. `.ai/tickets/YGO-065-m1-resident-address-schema.md` の依存の節に「このチケットで決める」が残っておらず、`environment.md` §5 の参照がある。主版は 18 のまま。
6. `.ai/gaps.md` の G-078 の行の内容の列が `YGO-069 で` で始まり `残りはない` で終わり、出どころの列に `（YGO-069）` がある。G-079 の行の「閉じる条件:」から後ろの文（CI の定義に `sh scripts/prepare.sh` の段が `sh scripts/check.sh` の前にある、YGO-062 の受け入れ確認 18）は変わっていない。
7. `.ai/INDEX.md` の「環境・秘密・費用」の行に、§5 の一覧の参照がある。
8. `.ai/triage.md` の G-078 の行に「YGO-065 で書く」と「§3.1・§5 の 1 か所」が残っておらず、`environment.md` §5 の表を指す文がある。
9. `.ai/deploy/readiness.md` の G-078 の箇条に「§3.1・§5 の 1 か所」が残っておらず、`environment.md` §5 の表を指している。
10. `git diff --stat` の変更のファイルに `scripts/` の下・`.github/` の下・`standards/` の下・`.ai/status.md` が入っていない。新しい ADR のファイルと OQ の行が足されていない。
11. 変更したファイルに、事業者の名前・ホスト名・認証情報・アカウントの ID・絶対パスが書かれていない。
12. `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。

## このジョブで残したもの
- 範囲 4（YGO-065 の依存の節）と範囲 7 の前半（`.ai/triage.md` の G-078 の行）は行っていない。マスターの指示が「YGO-065 に触れない」「`triage.md` は変えない」で、`triage.md` は秘書の仕分けのジョブが書く（CLAUDE.md）ため。受け入れ確認 5・8 は満たしていない。
- 受け入れ確認 6 の「`残りはない` で終わる」は満たしていない。`.ai/gaps.md` の G-078 は内容の列を `YGO-069 で` で始め、残り（YGO-065 の依存の節のそろえ・`triage.md` の G-078 の行のそろえ）を書いた。
- 一覧は §5 の小見出し `### §5.1 マスターに伝える道具の一覧` に置いた（`[assumed]`）。受け入れ確認 1・2・3・4・7・9 の「§5 の表」は、この §5.1 の表を指す。
- 残りは `.ai/gaps.md` の G-078 で追う。そのため、このチケットは `状態: open` のままにしている。
