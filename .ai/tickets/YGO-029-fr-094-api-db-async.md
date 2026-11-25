# YGO-029 R-052 FR-094 が api・db・async に対応していない
状態: open
M: M1

## 目的
`.ai/reviews/0002-phase-evaluation-2026-11-25.md` の R-052（評価の ID E-006、中）を直す。
M1 の FR-094 は、未成年の利用を認め、登録に年齢制限・年齢確認・保護者の同意を置かないという要求である。これが api・db・async のどこにも出てこない。`.ai/gaps.md` の G-048 は「FR 列に足すだけ」としている。

## 範囲
- `.ai/api.md` §7 F-02 の `POST /api/v1/registrations` の行の FR / ADR 列に FR-094 を足す。年齢を確かめず制限もしないことの根拠として、ADR-0027 と ADR-0041 の D2 を指す。
- `.ai/db.md` §8（FR / NFR との対応）と `.ai/async.md` §9（FR / NFR との対応表）に、FR-094 で足す列もジョブもないことを書く。
- 直したことに合わせて、`.ai/gaps.md` の G-048 の行をそろえる。

## 直さないところと理由
- `requirements.md` の FR-094 の文: 決定（ADR-0027・ADR-0057）のとおりで、変えない。
- `.ai/status.md`: 秘書が書く。

## 受け入れ確認
1. `.ai/api.md` §7 の `POST /api/v1/registrations` の行の FR / ADR 列に `FR-094` と `ADR-0027` がある。
2. `.ai/db.md` §8 と `.ai/async.md` §9 のそれぞれに、FR-094 を挙げ、足すものがないと書いた文がある。
3. `.ai/gaps.md` の G-048 の行が、直したことと食い違っていない（点検の「M1 の FR で api・db・async に出ない」に FR-094 が残っていない）。
