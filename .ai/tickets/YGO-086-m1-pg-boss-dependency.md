# YGO-086 M1 の pg-boss を依存に足す
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の TC のテストがすべて `scripts/check.sh` で通り、CI が緑）を進める。
`roadmap.md` §4 の M0 の行の「PostgreSQL と pg-boss 相当のキュー」のうち、キューの道具（pg-boss、ADR-0010・`async.md` §1）を依存に足す。YGO-074 で切った M0 の部品のチケットの 1 枚（道具の追加。積む口の実装は YGO-081）。
使う M1 の TC: TC-017・TC-019（YGO-081 の積む口と YGO-084 の worker のジョブの実行を通して使う）。

## 依存
- YGO-062（M1 のテストの土台）と YGO-078（`package.json` とロックファイル）の両方が `状態: done` であること。
- YGO-065 のあとに並べる。依存の順: YGO-062 → YGO-075 と YGO-078（並んで進む）→ YGO-076 → YGO-065 → **YGO-086（このチケット）**。YGO-065 が `状態: done` であること。
- 部品どうしの順: YGO-080・YGO-082・YGO-086 → YGO-081・YGO-083・YGO-085 → YGO-084。このチケットは先頭の組で、ほかの部品のチケットを待たない。YGO-081 がこのチケットを待つ。

## 範囲
- pg-boss を固定の版（範囲の記号なし）で `package.json` の依存に足し、同じ変更で `package-lock.json` を直す（ADR-0106）。`scripts/prepare.sh` で入る形にする。
- 版は、`environment.md` §5.1 の Node.js と PostgreSQL の主版で動くもの `[assumed]`。
- 部品だけを確かめる TC は `.ai/tests/test-plan.md` にないため、このチケットはテストを足さない `[assumed]`。

## 直さないところと理由
- ジョブを積む口とキューの表の用意: YGO-081。
- worker がジョブを取って動かすこと: YGO-084。
- 新しい OQ・要回答・ADR は 0 件（キューの道具は ADR-0010 で決まっている）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-086 M1 の pg-boss を依存に足す`・`状態: done`・`M: M1`。
2. YGO-062・YGO-078・YGO-065 のチケットの 2 行目が `状態: done`。
3. `sh scripts/prepare.sh` のあと `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
4. `package.json` の依存に pg-boss が固定の版（範囲の記号なし）であり、`package-lock.json` にその名前と同じ版がある。
5. この変更で `src/` にキューを使うコードを足していない（積む口は YGO-081）。
