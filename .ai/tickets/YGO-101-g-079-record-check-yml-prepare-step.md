# YGO-101 G-079 秘書の check.yml の prepare.sh の段を確かめて記録する
状態: open
M: M1
種類: 指摘の対応

## 目的
`.ai/gaps.md` の G-079 を追う（ADR-0109 の D4・D6）。CI の定義（`.github/workflows/check.yml`）は秘書の CI の決まった形で、秘書が入れる（ADR-0109 の D2）。
秘書が `check.yml` を入れたあと、`sh scripts/prepare.sh` の段が `sh scripts/check.sh` の段より前にあることを読んで確かめ、確かめた事実を記録し、段がないことを前提にした文書を今の状態に書き直す。
ジョブが作るもの（確かめた事実の記録と、文書の今の状態の書き直し）があるので、ADR-0109 の D6 によりチケットにする（`.ai/gaps.md` の冒頭の例外は、ジョブが作るものが何もない行だけ。ADR-0109 の D7）。

## 依存
- 秘書が、プロジェクトに決まった形の `.github/workflows/check.yml` を入れていること（ADR-0109 の D2）。入るまで、このチケットの実装の変更は出さない。
- このチケットは `.github/` を書かない・変えない（CLAUDE.md・NFR-091）。読むだけにする。CI の定義に段があることは、このチケットの受け入れ確認に入れない（ADR-0109 の D4）。受け入れ確認は、読んだ結果の記録と文書の書き直しだけを見る。
- 読んだ結果、決まった形に `sh scripts/prepare.sh` の段がなければ、G-079 の行を閉じず、段がないという確かめた事実を G-079 の行・`environment.md` §5・準備書に書き、段を足すことを秘書に伝える（ADR-0109 の D2。マスターへの要回答にはしない）。そのときは `状態: open` のまま残す `[assumed]`。

## 範囲
- `.github/workflows/check.yml` を読み、`sh scripts/prepare.sh` の行と `sh scripts/check.sh` の行の有無と順を確かめる。
- `.ai/gaps.md` の G-079 の行を、確かめた事実（読んだファイルと行の順）に書き直す。段が前にあれば行を閉じ（理由の列に「残りはない」、出どころの列に `（YGO-101）`）、なければ閉じない。
- `.ai/environment.md` §5 の「段があるまでは `.ai/gaps.md` の G-079 で追う」などの、段がないことを前提にした文を、確かめた事実に書き直す。
- 準備書 `.ai/deploy/readiness.md` §4 の G-079 の箇条を、確かめた事実に書き直す（閉じたなら閉じたことと番号だけを残す）。
- `.ai/roadmap.md` の依存の順の段落の「CI が緑になるのは…`prepare.sh` の段が入ったあと」の文を、確かめた事実に合わせる。

## 直さないところ
- `.github/`（読むだけ）・`scripts/`・`standards/`・`.ai/status.md`・`.ai/triage.md`。
- CI が緑かの確かめ: M1 の達成の確認で見る（ADR-0109 の D4）。
- `package.json` とロックファイル: YGO-078。

## 受け入れ確認
1. このチケットの 1〜4 行目が `# YGO-101 G-079 秘書の check.yml の prepare.sh の段を確かめて記録する`・`状態: done`・`M: M1`・`種類: 指摘の対応`。
2. `.ai/gaps.md` の G-079 の行の理由の列に、`check.yml` を読んで確かめた事実（`sh scripts/prepare.sh` の行が `sh scripts/check.sh` の行より前にある）と「残りはない」があり、出どころの列に `（YGO-101）` がある。
3. `.ai/environment.md` §5 に「段があるまでは」で始まる、段がないことを前提にした今の状態の文がない。
4. 準備書 `.ai/deploy/readiness.md` §4 の G-079 の箇条に、段がないことを前提にした今の状態の文（「足す」「伝える」）がない。
5. 変更したファイルに `.github/`・`scripts/`・`.ai/status.md` が入っていない。
6. `sh scripts/check.sh` が通る。

## 変更の説明
秘書の決まった形の `check.yml` に `prepare.sh` の段があることを確かめて記録し、G-079 を閉じた（ADR-0109 の D4・D6）。
