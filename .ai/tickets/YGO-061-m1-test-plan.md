# YGO-061 M1 の FR ごとのテスト項目書（.ai/tests/test-plan.md）
状態: open
M: M1

## 目的
目標の受け入れ条件 1（今の M の FR ごとに TC があり、そのテストが `scripts/check.sh` で動く）の前提として、M1 の FR すべてに TC を置く。

## 確かめた事実
- `.ai/tests/` はまだない。このチケットを実装する変更で `.ai/tests/test-plan.md` を新しく書く。
- `.ai/roadmap.md` §4 の `### 依存` の下の `- M1:` の行にある FR は 18 件:
  FR-001, FR-002, FR-003, FR-007, FR-008, FR-009, FR-010, FR-091, FR-092, FR-094, FR-098, FR-100, FR-103, FR-113, FR-114, FR-115, FR-124, FR-127。

## 範囲
- `.ai/roadmap.md` の `- M1:` の行にある FR をすべて読む。
- `.ai/tests/test-plan.md` を作り、表 `| TC | FR | 種類 | 確かめること |`（例 `| TC-001 | FR-001 | 単体 | … |`）に、FR ごとに TC を 1 つ以上置く。
  - 種類は `単体`・`結合` など。
  - TC は `.ai/requirements.md`・`.ai/api.md`・`.ai/db.md`・`.ai/async.md`・`.ai/security.md` の M1 にかかわる記述と ADR に基づく。
  - どの TC もネットワークなしで動かせるものにする（メールは ADR-0033 のモックかローカル SMTP）。
- 表の上に、テストの名前に TC-NNN を入れる決まり（例 `test_TC_001_…`）を書く。
- 地図 `.ai/INDEX.md` に `.ai/tests/test-plan.md` をバッククォートで足す。
- すでに `.ai/tests/test-plan.md` があれば、足りない FR の TC を足すことを範囲にする。

## 直さないところと理由
- テストのコードと `scripts/check.sh` からの実行: TC を置いたあとの別のチケットで扱う（項目書と実装を分ける）。
- `.ai/status.md`・`.github/workflows/check.yml`: 秘書が書くもので、ジョブは変えない。
- 新しい ADR・OQ・要回答は 0 件（決定の中身を変えない）。
- このチケットを切る変更では、チケットと `.ai/INDEX.md` のチケットの一覧の 1 行だけを足す `[assumed]`。
  `scripts/check.sh` は `.ai/` の下のファイルが `.ai/INDEX.md` に載っていないと失敗するため。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-061 M1 の FR ごとのテスト項目書（.ai/tests/test-plan.md）`・`状態: done`・`M: M1`。
2. `.ai/roadmap.md` の `- M1:` の行の FR が、どれも `.ai/tests/test-plan.md` の表の 2 列目に 1 回以上出ている。
3. 表の TC の ID が `TC-` と 3 桁で、重複しない。
4. 表の上に、テストの名前に TC-NNN を入れる決まり（例 `test_TC_001_…`）が書かれている `[assumed]`。
5. `.ai/INDEX.md` に `` `.ai/tests/test-plan.md` `` がバッククォートで載っている。
6. `sh scripts/check.sh` が `check: ok` で終わる `[assumed]`。
