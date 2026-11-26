# YGO-066 K-019 CI は prepare.sh のあとに check.sh を動かす
状態: done
M: M1

## 目的
仕分け 10 回目（`.ai/triage.md`）の「今決める」K-019 を決める。
CI で依存をどこで取り込むかが、CLAUDE.md（決まった形の CI は `sh scripts/check.sh` を動かす）と `environment.md` §5（`prepare.sh` → `check.sh`）・§4.1 の 6（`node_modules/` がなければ失敗）で食い違っていた。
候補 (3)（CI は `prepare.sh` → `check.sh`。`prepare.sh` の段を足すのはマスター）を ADR-0104 に決め、`environment.md` と YGO-062 をそろえる。

仕分け 10 回目の「今決める」は K-019 の 1 件だけ（G-077・G-078 は暫定）で、仕分けの指定する順とも食い違わない。

## 確かめた事実
- K-019 を指す文書は `.ai/triage.md` だけで、決定先の ADR とチケットはなかった。
- アプリは `fastify`（ADR-0009）を、M1 のスキーマのテスト（YGO-065）は `pg` を、キューは pg-boss を使う。Node.js に PostgreSQL のクライアントは組み込まれていないので、候補 (2)（テストを依存なしにする）は ADR-0009 の置き換えなしには成り立たない。
- 今の `scripts/check.sh` は `package.json` があるとき `node_modules/` がなければ「先に sh scripts/prepare.sh を動かす」と出して失敗し、`prepare.sh` も `npm ci` も呼ばない。これは ADR-0104 の D3 のとおりで、コードは変えない。
- `.github/` はなく、CI の定義はジョブの変更の外（CLAUDE.md）。足すのはマスターで、道具を入れるのをマスターとした OQ-086 の決定と同じ扱いにするため、新しい OQ は立てない。伝えたことと段があるかは `.ai/gaps.md` の G-079 で追う。
- YGO-065 は ADR-0104 を作る予定と書いていた（ロックファイルの例外の置き換え）。この変更が 0104 を使うため、YGO-065 の予定を ADR-0105 に直す。

## 範囲
- 新規 `.ai/adr/0104-ci-runs-prepare-then-check.md`（状態: 採用）。D1 CI は `prepare.sh` → `check.sh` の順、M1 のテストは Vitest と npm の依存。D2 秘書は `package.json` を入れる変更の前に `prepare.sh` の段を足すことをマスターに伝える（足すのはマスター）。D3 `check.sh` は `prepare.sh` も `npm ci` も呼ばない。
- `.ai/environment.md` の関連 ADR の行・§4.1 の 6・§5 に ADR-0104 とマスターに伝えることを書く。
- `.ai/tickets/YGO-062-m1-test-harness.md` の確かめた事実・「前提:」の行・新しい ADR の行・「残り」の 18 を ADR-0104 に合わせる（状態は `open` のまま、受け入れ確認 18 の文は変えない）。
- `.ai/tickets/YGO-065-m1-resident-address-schema.md` の予定の ADR の番号を 0104 から 0105 に直す。
- `.ai/gaps.md` に G-079（CI の定義に `prepare.sh` の段がまだない。向かう M: M1、出どころ: K-019・ADR-0104 の D2）を足し、YGO-062 の「残り」の 18・ADR-0104 の D2・`environment.md` §5 から指す。
- `.ai/adr/README.md`・`.ai/INDEX.md`（ADR の行・チケットの行・「環境・秘密・費用」の行）・`.ai/triage.md`（10 回目の K-019 の行と表の下）。

## 直さないところと理由
- **`scripts/`・コード・依存**: 今の `check.sh` が D3 のとおり動くため変えない。
- **`.github/`・CLAUDE.md・`standards/`**: ジョブの変更の外。CI の段を足すのはマスター（D2）。
- **`open-questions.md`・`roadmap.md`・`retros.md`**: 新しい OQ は 0 件。新しい失敗はない。`gaps.md` は G-079 を足すだけで、G-077・G-078 は暫定のまま。
- **`.ai/status.md`**: 秘書が書くため変えない。

## 受け入れ確認
1. このチケットの 1 行目が `# YGO-066 K-019 CI は prepare.sh のあとに check.sh を動かす`、2 行目が `状態: done`、3 行目が `M: M1`。
2. `.ai/adr/0104-ci-runs-prepare-then-check.md` があり、3 行目が `- 状態: 採用`、1 行目の題「CI は prepare.sh のあとに check.sh を動かす」が 40 字以内。
3. ADR-0104 の決定に D1（CI は `sh scripts/prepare.sh` → `sh scripts/check.sh` の順）・D2（段を足すのはマスターで、秘書が `package.json` を入れる変更の前に伝える）・D3（`check.sh` は `prepare.sh` も `npm ci` も呼ばない）があり、代わりの案に「テストを依存なしにする」「`check.sh` が `prepare.sh` を呼ぶ」「`node_modules/` をコミットする」の 3 つがある。
4. `.ai/environment.md` の §4.1 の 6 と §5 に `ADR-0104` があり、§5 に秘書がマスターに `prepare.sh` の段を足すことを伝えると書かれている。
5. YGO-062 の 2 行目が `状態: open` のままで、受け入れ確認 18 の文が「`.github/workflows/` の下に CI の定義があり、`sh scripts/prepare.sh` → `sh scripts/check.sh` の順に動かす」で始まり、「残り」の 18 に `ADR-0104 の D2` がある。
6. YGO-065 に `ADR-0104`・`→ 0104` の文字列がなく、予定の ADR が `ADR-0105`・`置き換え（→ 0105）` と書かれている。
7. `.ai/INDEX.md` に `` `.ai/adr/0104-ci-runs-prepare-then-check.md` — 採用 `` の行とこのチケットの行があり、「環境・秘密・費用」の行に `ADR-0104` がある。`.ai/adr/README.md` に ADR-0104 の行がある。
8. `.ai/triage.md` の 10 回目の K-019 の行に `ADR-0104` があり、表の下に「今決める: 0 件（すべて決定済み）」と `K-019 → ADR-0104（採用）・YGO-066（状態: done）` がある。
9. `.ai/gaps.md` に G-079 の行があり、向かう M が `M1`、出どころに `K-019` と `ADR-0104 の D2` があり、閉じる条件に `sh scripts/prepare.sh` の段があることが書かれ、G-078 の一覧にこの段を入れると書かれている。YGO-062 の「残り」の 18・ADR-0104 の D2・`environment.md` §5 に `G-079` がある。
10. この変更は `scripts/`・`.github/`・`.ai/status.md`・`.ai/open-questions.md` を変えておらず、`sh scripts/check.sh` が `check: ok` で終わる。
