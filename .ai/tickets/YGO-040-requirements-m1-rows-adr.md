# YGO-040 R-026 G-068 M1 の正本の要求を ADR の中身にそろえる
状態: done
M: M1

## 目的
条件 8 のために、レビューの指摘 R-026（中。ADR で決めたことが、`requirements.md` では「未確定」のまま）を片づける。M1 の行（FR-010・FR-092・FR-098・FR-100・NFR-013）は YGO-027（K-015）ですでに ADR の中身にそろえてある。このチケットはそれを確かめて閉じる。M1 の外に残る行は `gaps.md` の G-070（後回し）に送る。

## 仕分け
- `triage.md` の最新の回（仕分け 4）に、R-026 を扱う K-NNN はない。R-026 を扱っているのは `gaps.md` の G-068（暫定・M1、「チケットで済みと確かめて閉じるだけ」）で、題に G-068 を付けた。
- M の判定: `roadmap.md` §4 の `- M1:` の行に FR-010・FR-092・FR-098・FR-100 があるので、M1 にかかわる。
- R-026 のほかの行（FR-020・024・027・034・048・057・072・075・095、NFR-017・028〜031）と、ブロック・通報・送信の上限の FR は、M2〜M5・段階 3 の機能か、どの M の機能でもない取り決め（FR-095・NFR-031）で、M1 の FR と範囲にかからない。CLAUDE.md の「今の M にかからない中身は `gaps.md` に行を足す」に従い、G-070 に送った。

## 確かめた済みの箇所
- `requirements.md` の FR-010（ADR-0082 の D3・ADR-0087）・FR-092（ADR-0080 の D1〜D7・ADR-0087・ADR-0088）・FR-098（ADR-0090 の D1・D4〜D6・ADR-0089）・FR-100（ADR-0090 の D2・D3・ADR-0089）・NFR-013（ADR-0080・0090・0020・0088・0089）は、決めた中身と ADR の番号で書かれ、「未確定」「秘書が ADR に記録して決定する」「open-questions へ」の書き方がない。
- `scripts/check.sh` が、`roadmap.md` の `- M1:` の行の FR と NFR-013 の行に「秘書が ADR に記録して決定する」「未確定（open-questions」がないことを確かめている。

## 範囲
- `.ai/tickets/YGO-040-requirements-m1-rows-adr.md`: このチケットを作る。
- `.ai/gaps.md`: G-068 を「残りはない」に書き直し、出どころを `R-026（YGO-027・YGO-040）` にする。G-070（後回し・M2・出どころ R-026）を足し、行ごとの向かう M と決めた ADR、足す FR（送信の上限は M2・ブロックは M3・通報は M4）を書く。G-007 の「K-015 で FR を足したあとに」を「G-070 で FR を足したあとに」にする。
- `.ai/requirements.md`: FR-020・FR-024・FR-027・FR-048・FR-072・FR-075 の行の「（値は `reviews/0001-design-review.md` の R-026 で決める）」を「（ADR の値にそろえるのは `gaps.md` G-070）」にする。同じく G-070 に送った FR-034・FR-057・FR-095・NFR-017・NFR-028・NFR-029・NFR-030・NFR-031 の行の「（open-questions へ）」（FR-034 は「（時刻は open-questions へ）」、NFR-017 は「（方式は open-questions へ）」）も、`gaps.md` G-070 を指す書き方にする（open-questions.md に該当する未決の OQ はない）。値と区分の列は変えない。
- `.ai/INDEX.md`: チケットの一覧にこのチケットを足す。

## 直さないところと理由
- M1 の外の `requirements.md` の行の中身（値・ADR の番号・区分）: 今の M にかからないため、G-070 で各 M の最初の変更で直す。ブロック・通報・送信の上限の FR も同じ。
- `features.md` の F-08 と `mvp.md` の M3 の行の「R-026・R-031」: 出どころとしての参照で今も正しい。
- ADR: 決定を変えないので足さず、状態も変えない（0098 は作らない）。新しい要回答は 0 件。
- `open-questions.md`・`triage.md`・`reviews/`・`roadmap.md`・`status.md`: 変えない。
- テスト: 文書だけの変更で、M1 の行は `scripts/check.sh` がすでに確かめているので足さない。

## 受け入れ確認
1. `.ai/requirements.md` の FR-010・FR-092・FR-098・FR-100・NFR-013 の行に、ADR の番号（FR-010 は ADR-0082・0087、FR-092 は ADR-0080・0087・0088、FR-098・FR-100 は ADR-0090・0089、NFR-013 は ADR-0080・0090・0020・0088・0089）があり、「未確定」「秘書が ADR に記録して決定する」「open-questions へ」がない（差分はない）。
2. `scripts/check.sh` に、`roadmap.md` の `- M<n>: FR-` の行の FR と NFR-013 の行の未決の書き方を拒む確認がある（差分はない）。
3. `.ai/requirements.md` に「R-026 で決める」がなく、FR-020・FR-024・FR-027・FR-048・FR-072・FR-075 の 6 行に「`gaps.md` G-070」がある。FR-034・FR-057・FR-095・NFR-017・NFR-028・NFR-029・NFR-030・NFR-031 の行に「open-questions へ」がなく、「`gaps.md` G-070」がある。
4. `.ai/gaps.md` の G-068 の行が 5 列で、理由に「残りはない」と「M1 の外の行は G-070」、出どころに `R-026（YGO-027・YGO-040）` がある。
5. `.ai/gaps.md` の G-070 の行が 5 列で、仕分けが `後回し`、向かう M が `M2`、出どころが `R-026` で、理由に FR-020・024・027・034・048・057・072・075・095、NFR-017・028・029・030・031 とブロック・通報・送信の上限の FR の向かう M がある。G-070 が挙げる ADR（0003・0004・0005・0006・0007・0012・0035・0060）は、どれも状態が `置き換え` でない（FR-072・FR-075 は ADR-0060 を挙げ、`置き換え（→ 0060）` の ADR-0002 を挙げない）。
6. `.ai/gaps.md` の G-007 の理由に「G-070 で FR を足したあとに」があり、「K-015 で FR を足したあとに」がない。
7. `.ai/INDEX.md` のチケットの一覧に `.ai/tickets/YGO-040-requirements-m1-rows-adr.md` があり、そのファイルがある。
8. `.ai/adr/`・`.ai/open-questions.md`・`.ai/triage.md`・`.ai/reviews/`・`.ai/roadmap.md`・`.ai/status.md` に差分がなく、`sh scripts/check.sh` が `check: ok` を出す。
