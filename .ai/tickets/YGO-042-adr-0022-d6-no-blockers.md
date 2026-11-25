# YGO-042 G-006 要回答で止まるものがないことを ADR に書く
状態: done
M: M1

## 目的
`gaps.md` の G-006（仕分け `暫定`・向かう M `M1`・出どころ `reviews/0001-design-review.md` の R-030）を済ませる。
ADR-0022 の D6 は「止まる」ものを経緯の注記で書いており、OQ-081・OQ-086 の答えのあとの状態がなかった。
両方とも決定（OQ-081 は ADR-0065・ADR-0066、OQ-086 は ADR-0052 の D3・ADR-0068）で、`open-questions.md` に状態が `要回答` の行はなく、`roadmap.md` §8 も「段階が依存する要回答はない」。
D6 に注記を重ねることは CLAUDE.md が禁じるので、ADR-0022 の生きている決定（D1〜D5）と今の状態の D6 をまとめた ADR-0099 で丸ごと置き換える（ADR-0098 が ADR-0007 を置き換えたのと同じ形）。
新しい要回答は 0 件。マスターの判断は要らない（`.ai/` の文書だけで直せる）。

## 範囲
- `.ai/adr/0099-stages-m0-m6-gates-no-blocking-oqs.md`（新規）: D1〜D6（番号は ADR-0022 と同じ）。D3 は ADR-0098 の D2、D6 は今の状態だけ。
- `.ai/adr/0022-roadmap-stages-and-gates.md`: 状態を `置き換え（→ 0099）`。本文は変えない。
- `.ai/adr/README.md`: 0022 の行の末尾に `（ADR-0099 で置き換え）`、0099 の行。
- `.ai/adr/0097-milestones-keep-m0-m6-m1-address-account.md`: 冒頭・D1・D2 の参照を ADR-0099 に。
- `.ai/roadmap.md`: 冒頭の関連 ADR、§1 の 1・2・4、§4 の段階の文、MVP で依存する ADR。
- `.ai/features.md` §1: 参照を ADR-0099 に。
- `.ai/INDEX.md`: M の分け方の行の参照、要回答で止まるものの行、ADR-0099・このチケット。
- `.ai/gaps.md`: G-006 の行。

## 直さないところと理由
- `mvp.md` の ADR-0022 の参照: 秘書が書く文書（ADR-0098 のときと同じ）。D の番号が同じなので ADR-0099 として読む。
- `status.md`・`triage.md`: マスターの指示と CLAUDE.md で変えない。
- `open-questions.md` の表の ADR の欄と、ADR-0024・0033・0035・0038・0043・0050 の ADR-0022（決定 6 など）の参照: 書いた時点の記録（YGO-025 と同じ扱い）。D の番号が同じなので ADR-0099 として読める。
- `roadmap.md` §8: すでに今の状態（要回答の項目はない）を書いている。
- `reviews/`・前のチケット・図（段階と M の図はない）・`scripts/check.sh`: 確かめるのは文書だけ。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-042 G-006 要回答で止まるものがないことを ADR に書く`・`状態: done`・`M: M1` で、題の G-NNN は G-006 だけ。
2. `.ai/adr/0099-stages-m0-m6-gates-no-blocking-oqs.md` の 3 行目が `- 状態: 採用`、題（`段階は 3 つ、MVP は M0〜M6、要回答で止めない`）が 40 字以内で、決定に 1〜6 がある。D6 に「今、要回答で止まるものはない」と、OQ-081（ADR-0065・ADR-0066、M4・M2 は止まらない）・OQ-086（ADR-0052 の D3・ADR-0068、M0 は止まらない）が書かれ、ADR-0022 の D6 に残っていた決定（F-17 のコミュニティの部分は止まらず OQ-057 は S3-2 の前に決める・架空の店と張り紙（OQ-067、ADR-0050）と入居者募集の広告（OQ-083）は S3-2 から作り MVP に作らない・OQ-084 は S3-2 の前に決める）も書かれ、「更新:」の注記がない。D3 が ADR-0098 の D2 を指す。
3. `.ai/adr/0022-roadmap-stages-and-gates.md` の 3 行目が `- 状態: 置き換え（→ 0099）`。
4. `.ai/adr/README.md` に 0099 の行があり、0022 の行の末尾が `（ADR-0099 で置き換え）`。
5. ADR-0097 に「ADR-0022 は置き換えず」がなく、冒頭・D1・D2 の参照が ADR-0099。
6. `roadmap.md` の §1 の 1・2・4 と §4 の段階の文が ADR-0099 を指し、冒頭の関連 ADR と「MVP で依存する ADR」に 0099 がある。`features.md` §1 が ADR-0099 を指す。
7. `INDEX.md` に ADR-0099・YGO-042・「要回答で止まる M・FR があるか」の行があり、載せたパスがすべてある。`gaps.md` の G-006 の行は 5 列で、出どころが `R-030（YGO-042）`。
8. `open-questions.md` に新しい OQ と `要回答` の行がない。`mvp.md`・`status.md`・`triage.md`・`standards/`・CLAUDE.md は変えていない。`sh scripts/check.sh` が通る。
