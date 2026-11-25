# YGO-036 振り返りの見出しを点検に当たらない書き方にする
状態: done
M: M1

## 目的
条件 9 のために、`.ai/retros.md` の 2026-11-22（R-007）の見出しを書き換える。今の見出しは、秘書の点検 `check:consolidation` が「他の文書への変更提案」の節として数える書き方になっている。意味は保ったまま、点検に当たらない書き方にする。

## K の選び方
`triage.md` 仕分け 4（最新の回）の「今決める」は K-017 の 1 件だけ。K-017 は YGO-035（done、ADR-0097）で決まっているので、この変更では K を決めない（マスターの指示のとおり、条件 9 を進める）。

## 範囲
- `.ai/retros.md` の 5 行目の見出しだけ。
- `.ai/INDEX.md` のチケットの一覧に、このチケットを載せる。

## 直さないところと理由
- `retros.md` の本文: 経緯の振り返りの中身で、節の見出しではない。
- `reviews/0001-design-review.md` の R-007 と YGO-017 の題: レビューとチケットの記録で、点検の外にある。
- `triage.md`・`status.md`: 指示と CLAUDE.md で変えない。
- ADR・OQ・gaps: 決定を変えないので足さない（新しい要回答は 0 件）。

## 受け入れ確認
- `.ai/retros.md` の 5 行目が `## 2026-11-22 — 範囲の外の文書の直しを後の変更に回し、そろえ直しを積み残した（R-007）` になっている。
- `grep -n "^#.*提案" .ai/retros.md` が何も返さない。
- `grep -rn "^#.*提案" .ai --exclude-dir=reviews --exclude-dir=tickets` が何も返さない。
- `retros.md` の 2026-11-22（R-007）の節で、問題・根本原因・気づけなかった理由・再発防止の本文が変わっていない。
- `.ai/INDEX.md` の「チケット（`.ai/tickets/`）」の節に `.ai/tickets/YGO-036-retro-heading-wording.md` がある。
- `sh scripts/check.sh` が `check: ok` を出す。
