# YGO-001 機能一覧と優先順位（.ai/features.md）
状態: open

## 目的
Goal g-a5d50c08 の受け入れ条件 2（`.ai/features.md` に機能一覧と優先順位がある）を満たす。

## 範囲
`.ai/requirements.md` の FR / NFR を元に `.ai/features.md` を新規作成する。中身は次のとおり。
- 機能一覧（郵便受け・朝夕の定時配達・朝刊と夕刊・町内掲示板・住所録など、構想にある軸ごと）
- 各機能が対応する要求 ID
- 優先順位: 最初に動かす最小の範囲（MVP）と、その後の段階
- 優先順位を付けた理由

`.ai/brief.md` と `.ai/requirements.md` は書き換えない。未確定のことは本文に注記するだけにする（`open-questions.md` は別のチケットで扱う）。

## 受け入れ確認
- `.ai/features.md` がある
- 機能一覧がある
- 最小範囲とその後の段階が分かれている
- 各機能から要求 ID をたどれる
- 変更はこのファイルと、チケットの状態を done にする更新だけ
- `scripts/check.sh` が通る
