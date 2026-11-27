# 0105 — CI の定義の確かめは YGO-070 が受け持つ

- 状態: 採用
- 日付: 2026-11-27

仕分け 10 回目の K-019 と仕分け 11 回目（`.ai/triage.md`）による。出どころは `environment.md` §4.1・§5・CLAUDE.md の作り方の節と、YGO-062 の実装の変更 20261126-e939ca・20261126-d657d2（どちらも、YGO-062 が `.github/workflows/` の CI の定義を求めていたため範囲の外とされた）。
ADR-0052（手元で再現できる環境、`check.sh` はネットワークなし）・ADR-0009（TypeScript・Fastify・Vitest）・ADR-0103（最初のロックファイル）の決定は変えない。

## 背景

CLAUDE.md は、秘書の決まった形の CI（`.github/workflows/check.yml`）が `scripts/check.sh` を push のたびに動かすとだけ書き、`prepare.sh` に触れていない。ジョブは `.github/` を書かない・変えない。
`environment.md` §5 は CI を `sh scripts/prepare.sh`（`npm ci`）→ `sh scripts/check.sh` の順とし、§4.1 の 6 は `node_modules/` がなければ `check.sh` を失敗させる。
CI が `check.sh` だけを動かすと、`package.json` を入れたあとは `node_modules/` がなく `check.sh` が失敗し、M1 のすべてのテストの土台（YGO-062）が CI で緑にならない。
テストの土台のチケット（YGO-062）に CI の定義があることの確かめを入れると、ジョブが変えられないファイルに依って、そのチケットを実装の変更で `done` にできない。

## 決定

- **D1 CI は `prepare.sh` → `check.sh` の順に動かす**: CI の定義は、レポジトリを取り出したあと `sh scripts/prepare.sh` を動かし、そのあと `sh scripts/check.sh` を動かす。M1 のテストは Vitest と npm の依存（ADR-0009）で書き、依存なしの形にはしない。
- **D2 `prepare.sh` の段を足すのはマスター**: CI の定義はジョブの変更の外（CLAUDE.md・NFR-091）。秘書は、`package.json` を入れる変更（YGO-078 の実装）の前に、CI の定義に `sh scripts/prepare.sh` の段を `sh scripts/check.sh` の前に足すことをマスターに伝える。新しい OQ は立てない（道具を入れるのをマスターとした OQ-086 の決定と同じ扱い）。段があるまでは `.ai/gaps.md` の G-079 で追う。
- **D3 `check.sh` は依存を取り込まない**: `scripts/check.sh` は `prepare.sh` も `npm ci` も呼ばない。`node_modules/` がなければ、`sh scripts/prepare.sh` を先に動かすよう出して失敗する（`environment.md` §4.1 の 6。飛ばさない）。
- **D4 CI の定義の確かめは YGO-070 に置く**: CI の定義（`.github/workflows/` の下）に `sh scripts/prepare.sh` の段が `sh scripts/check.sh` の前にあることをファイルで確かめるのは、YGO-070 の受け入れ確認 1 が受け持つ。YGO-062・YGO-078 の受け入れ確認には入れない。CI が緑かは M1 の達成の確認で見る。G-079 は YGO-070 の受け入れ確認 1 で閉じる。

## 理由

- アプリは `fastify`（ADR-0009）を使い、M1 のスキーマのテスト（YGO-065）は PostgreSQL のドライバ `pg` を、キューは pg-boss を使う。Node.js には PostgreSQL のクライアントが組み込まれていないので、テストを依存なしにするには ADR-0009 の置き換えが要り、テストの道具だけを依存なしにしても `check.sh` は `node_modules/` を要る。
- 依存の取り込みを `prepare.sh` の 1 か所に置けば、CI でネットワークを使う段がそこだけになり（`environment.md` §5）、`check.sh` はネットワークなしのまま（NFR-063・CLAUDE.md）。
- `check.sh` が `node_modules/` のないときに失敗すれば、CI に `prepare.sh` の段がないことが CI の結果ですぐに分かる。
- D4: YGO-062・YGO-078 が作るもの（`check.sh` の段・`package.json`・ロックファイル）は、ジョブが作れて手元で確かめられる。CI の定義はマスターが足すもので、ジョブには作れない。確かめを別のチケットに分けると、YGO-062・YGO-078 はジョブの範囲だけで `done` にでき、CI の定義はマスターが段を足したあとに YGO-070 で確かめられる。

## 代わりの案（選ばなかった理由）

- **M1 のテストを依存なしにする（Node.js の組み込みのテストと JUnit の出力）**: `fastify` と `pg` が要るため、テストの道具を変えても `node_modules/` は要る。依存をすべてなくすには ADR-0009 の置き換えが要り、出戻りが大きい。
- **`check.sh` が `node_modules/` のないときに `prepare.sh` を呼ぶ**: `check.sh` がネットワークを使うことになり、CLAUDE.md（`sh scripts/check.sh` はネットワークなしで通ること）・`environment.md` §5・NFR-063 に反する。
- **`node_modules/` をコミットする**: 依存の中身（OS ごとのバイナリを含む）を公開レポジトリに入れることになり、大きく、ロックファイルで固定する ADR-0052 の形とも合わない。
- **CI の定義の確かめを YGO-062 に残す**: YGO-062 の実装の変更が、ジョブの変えられない `.github/` に依って範囲の外とされ、M1 のテストの土台が進まない。

## 影響

- `environment.md` §4.1 の 6 と §5 に、この ADR と、秘書がマスターに伝えることを書く。
- `.ai/gaps.md` の G-079（向かう M: M1）は、閉じる条件を YGO-070 の受け入れ確認 1 とする。
- YGO-062 の受け入れ確認から CI の定義の確かめ（もとの 18）を外す。YGO-070 の受け入れ確認 1 に「CI が緑かは M1 の達成の確認で見る」を書く。
- `scripts/` は変えない。今の `check.sh` は D3 のとおり動く。
