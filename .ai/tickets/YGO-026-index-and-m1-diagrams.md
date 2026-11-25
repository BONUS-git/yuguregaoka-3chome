# YGO-026 R-049 図と地図（INDEX.md）が 1 つもない
状態: done
M: M1

## 目的
`.ai/reviews/0002-phase-evaluation-2026-11-25.md` の R-049（評価の ID E-003、重大）を直す。
`.ai/INDEX.md`（地図）と `.ai/diagrams/`（図）がない。このため段階の手順 1・3 が手つかずで、DLG-14 の読む順（地図 → 図 → 文書の節）が成り立っていない。

地図を作ること自体が「今決める」の K-003（`.ai/triage.md`）なので、ほかの K が残っていても先に作る。

## 範囲
- `.ai/INDEX.md` を作る。知りたいこと → 図 → 文書の節の表と、`.ai/` のすべてのファイル（直下の文書・ADR・レビュー・チケット・図と INDEX.md 自身）の一覧を、`.ai/` から始まるパスをバッククォートで書いて載せる。
- `.ai/diagrams/` に、M1 の機能（F-01・F-02・F-19）を対象にした次の図を Mermaid で、1 図 1 ファイルで置く。
  - ユースケース図（`m1-usecases.md`）
  - コンポーネント図（`m1-components.md`）
  - 主な流れのシーケンス図（`m1-registration-sequence.md`）・状態遷移図（`m1-address-account-states.md`）・ER 図（`m1-er.md`）
- 各図に `- FR:`・`- ADR:`・`- 確かめた M: M1` の行を書く。FR は `.ai/roadmap.md` §4 の `- M1:` の行から、ADR は状態が `採用` のものから取る。
- 図と食い違う文書を直す。
  - `.ai/features.md`: FR-007 を F-01 の FR の欄に足し、§7 の FR-007 を `F-01・F-16` にする（`roadmap.md` §4・`mvp.md` (b) は FR-007 を M1 の F-01 に置いている）。
  - `.ai/architecture.md` §2: C2 の「関係する F- / ADR」を `F-01〜F-09・F-19` にし、ADR-0080・0081・0082・0084 を足す（C2 の責務と §5 は住所の候補と入居の一覧を C2 に置いている）。
  - `.ai/architecture.md` §2: C9 の責務に、メールアドレスの暗号化の鍵（web・worker）と検索用 HMAC の鍵（web だけ）を足し、「関係する F- / ADR」を `F-01・F-02・F-04 / ADR-0006・ADR-0021・ADR-0080` にする（`m1-components.md` は C9 が C2 にメールアドレスの鍵を渡すと描き、`environment.md` §8.1・`security.md` §6 も同じ）。
  - `.ai/architecture.md` §2: C4 の責務に、確認と再設定のメールの送信（メールのアダプタ `MAIL_ADAPTER`。テストはモックかローカルの SMTP、ADR-0033。web から渡すジョブは G-049）を足し、「関係する F- / ADR」に F-01・F-02 と ADR-0033・ADR-0080 を足す（`m1-components.md`・`m1-registration-sequence.md` は C4 がメールを送ると描き、`environment.md` §8.1 も `MAIL_ADAPTER` を worker だけに置く）。
  - `.ai/README.md`: `INDEX.md`・`diagrams/`・`mvp.md`・`brief-map.md`・`triage.md`・`gaps.md`・`tickets/` の行を足す。
- 図を描いて見つけた設計の抜けを `.ai/gaps.md` に G-049 として足す（確認と再設定のメールを web から worker に渡すジョブが `async.md` にない。暫定・M1）。新しい OQ と ADR は足さない。

## 直さないところと理由
- M2 より先の機能の図: 今の M は M1 で、整合を求めるのは M1 の範囲だけ。
- ほかの K（K-004・K-010・K-014・K-015 など）: YGO-027 と仕分けが扱う。
- ADR-0027・ADR-0041 と ADR-0073・ADR-0057 の文の食い違い（FR-094）: YGO-029 が扱う。図はこの 2 つの ADR を指さない。
- `async.md` へのメールのジョブの追加: G-049 で M1 の実装の前に扱う。このチケットは図と地図だけ。
- `scripts/check.sh`・コード・依存: 変えない。
- `.ai/status.md`: 秘書が書く。

## 受け入れ確認
1. `.ai/diagrams/` に `m1-usecases.md`・`m1-components.md`・`m1-registration-sequence.md`・`m1-address-account-states.md`・`m1-er.md` の 5 つのファイルがある。ユースケース図とコンポーネント図は別のファイル。
2. 5 つのファイルのどれにも ```` ```mermaid ```` の区画が 1 つあり、`- FR:`・`- ADR:`・`- 確かめた M: M1` の 3 行がある。
3. 図の `- FR:` の行にある FR は、どれも `.ai/roadmap.md` §4 の `- M1:` の行にある。
4. 図の `- ADR:` の行にある ADR（0008・0010・0030・0033・0057・0060・0061・0062・0070・0073・0080・0081・0082・0083・0084）は、どれも `.ai/adr/` にあり、3 行目の状態が `- 状態: 採用` である。
5. `.ai/INDEX.md` がある。`.ai/` の下のすべてのファイル（142 件。`.ai/INDEX.md` 自身と `.ai/brief.md`・`.ai/status.md` を含む）が、`.ai/` から始まるパスとしてバッククォートの中で INDEX.md に載っていて、載っていないファイルは 0 件。
6. `.ai/features.md` の F-01 の FR の欄に FR-007 があり、§7 の FR-007 の列が `F-01・F-16` で始まる。
7. `.ai/architecture.md` §2 の C2 の行の「関係する F- / ADR」が `F-01〜F-09・F-19` で始まり、ADR-0080・ADR-0081・ADR-0082・ADR-0084 を含む。
8. `.ai/architecture.md` §2 の C9 の行の責務に、メールアドレスの暗号化の鍵と検索用 HMAC の鍵（web だけ）があり、「関係する F- / ADR」に F-01・F-02・ADR-0021・ADR-0080 がある。
9. `.ai/architecture.md` §2 の C4 の行の責務に、確認と再設定のメールの送信と `MAIL_ADAPTER` があり、「関係する F- / ADR」に F-01・F-02・ADR-0033・ADR-0080 がある。
10. `.ai/gaps.md` に G-049（暫定・M1）の行があり、出どころが図（`diagrams/m1-components.md`・`diagrams/m1-registration-sequence.md`）である。`.ai/open-questions.md` と `.ai/adr/` に、この変更で足したものはない。
11. `sh scripts/check.sh` が `check: ok` で通る。
