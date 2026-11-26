# YGO-068 G-077 デプロイしない前提の準備書を作る
状態: open
M: M1

## 目的
目標の受け入れ条件 1 を進める。M1 の達成の事実には「準備書（`.ai/deploy/readiness.md`）の『確かめた M』が M1」がある。しかし準備書がまだない（`.ai/gaps.md` G-077）。
デプロイはしない（NFR-071・NFR-072）。そのため準備書は、スタックの計画と IaC の設計がどこにあり、どこまで決まっているかを `environment.md` §5〜§10 を指して確かめる文書として作る。文書を足すだけの変更で、コードと依存は変えない。

## 確かめた事実（このチケットを切った時点）
- `.ai/deploy/` のディレクトリと `.ai/deploy/readiness.md` はない。
- `.ai/environment.md` の節: §5 CI の計画、§6.1〜§6.6（構成・大きさ・外への通信・プッシュサービス・バックアップと復元・監視とアラート）、§7.1〜§7.4（IaC の道具・ディレクトリとモジュール・状態と秘密・適用の手順）、§8.1〜§8.3（環境変数・保管と渡し方・鍵の入れ替え）、§9 費用の見積もり、§10.1〜§10.3（しないこと・未確定事項・対応表）。
- `.ai/environment.md` §10.2 の未確定事項は OQ-085・OQ-049・OQ-047・OQ-062・OQ-060・OQ-065 の 6 件。`.ai/open-questions.md` §2 の表では、どれも `持ち越し`。
- `.ai/environment.md` §7.4 は、適用の手順を「デプロイの準備で使う。今は使わない」とし、1 にマスターの承認（OQ-085・NFR-080）を置く。
- `.ai/roadmap.md` §9 は「デプロイはしない」とし、環境の計画の正本を `environment.md` とする。準備書には触れていない。
- `scripts/check.sh` の 140〜159 行目は、`.ai/` の下のファイルが `.ai/INDEX.md` に載っていないと失敗する。

## 依存
- 前提にするチケットはない。YGO-062（テストの土台）・YGO-065（住民と住所のスキーマ）が `open` のままでも始められる（Node.js と PostgreSQL がなくても書ける文書のため）。
- G-078（道具の主版の一覧を `environment.md` §3.1・§5 にまとめる）と G-079（CI の定義の `sh scripts/prepare.sh` の段）は、このチケットでは閉じない。準備書の「デプロイの前に残るもの」の節から G 番号で指すだけにする。

## 範囲
1. **`.ai/deploy/readiness.md` を新しく作る**。中身:
   - 1 行目の見出しの下に `- 確かめた M: M1` の行を 1 つだけ置く。
   - 「デプロイはしない」節: NFR-071・NFR-072 と `environment.md` §10.1 を指し、この文書は適用・契約・アカウントの作成をしないことを書く。
   - 表 `| 項目 | 正本 | 状態 |`: 次の行を置く。
     - `environment.md` の §5・§6.1〜§6.6・§7.1〜§7.4・§8.1〜§8.3・§9 を、それぞれ 1 行（状態は「設計済み」または「設計済み・値は OQ で持ち越し」）。
     - OQ-085・OQ-049・OQ-047・OQ-062・OQ-060・OQ-065 を、それぞれ 1 行（状態は `open-questions.md` §2 の表と同じ `持ち越し`、正本の列に決まる箇所の節）。
   - 「デプロイの前に残るもの」節: `environment.md` §7.4 の 1〜4 の順を番号で指し（手順を写さない）、G-078 と G-079 を G 番号で書く。
   - 事業者の名前・ホスト名・ドメイン・認証情報・アカウントの ID は書かない（CLAUDE.md の公開レポジトリ。`environment.md` と同じく事業者は未定のまま）。
2. **地図と案内に載せる**:
   - `.ai/INDEX.md`: 知りたいことの表に「デプロイの準備（デプロイしない前提）」の行を足し、文書の欄に `.ai/deploy/readiness.md`・`.ai/environment.md` §5〜§10・`.ai/roadmap.md` §9 を書く。文書の一覧に `.ai/deploy/readiness.md` の行を足す。
   - `.ai/README.md`: 文書の表に `deploy/readiness.md` の行を足す。
3. **`scripts/check.sh` に段を足す**: `.ai/deploy/readiness.md` があるなら、`- 確かめた M: M1` の行がちょうど 1 つあることを確かめ、なければ理由を出して終了コード 0 以外で止まる（ネットワークを使わない）。
4. **G-077 を閉じる**: `.ai/gaps.md` の G-077 の行を、閉じた G-048 の行と同じ書き方にする（状態の列 `暫定`・M の列 `M1` は変えない）。内容の列を「YGO-068 で、準備書 `.ai/deploy/readiness.md` を作り（`- 確かめた M: M1`）、`INDEX.md` に載せた。残りはない」の形に書き直し、出どころの列の末尾に `（YGO-068）` を足す。
5. **食い違う文書を同じ変更で直す**:
   - `.ai/roadmap.md` §9 の最初の箇条に、準備書 `.ai/deploy/readiness.md` が確かめの入り口であることを 1 文で足す。
   - `.ai/environment.md` §10.2 の未確定事項の表と準備書の OQ の行が食い違うなら、`open-questions.md` §2 を正本として両方をそろえる。
   - ほかに `environment.md`・`roadmap.md`・`architecture.md` で準備書と食い違う記述を見つけたら、同じ変更で今の状態に書き直す。

## 直さないところと理由
- `environment.md` §3.1・§5 の道具の主版の一覧: G-078 のチケットで作る。
- CI の定義（`.github/`）: ジョブは書かない（CLAUDE.md）。G-079 はマスターが段を足すまで残る。
- `infra/` の IaC のコード: ADR-0052 の D5 で書かない。
- `.ai/status.md`: 秘書が書く（CLAUDE.md）。
- 新しい ADR・OQ・要回答: 0 件。準備書は既存の決定を指すだけで、新しい決定をしない。

## 受け入れ確認
1. `.ai/deploy/readiness.md` があり、`grep -cxF -- '- 確かめた M: M1' .ai/deploy/readiness.md` が `1` を返す。
2. `.ai/deploy/readiness.md` に NFR-071 と NFR-072 と `environment.md` §10.1 の参照が書かれている。
3. `.ai/deploy/readiness.md` の表に、`environment.md` の §5・§6.1・§6.2・§6.3・§6.4・§6.5・§6.6・§7.1・§7.2・§7.3・§7.4・§8.1・§8.2・§8.3・§9 の行がそれぞれある。
4. `.ai/deploy/readiness.md` の表に、OQ-085・OQ-049・OQ-047・OQ-062・OQ-060・OQ-065 の行がそれぞれあり、状態の列がどれも `.ai/open-questions.md` §2 の表のその OQ の状態（`持ち越し`）と同じ文字列である。
5. `.ai/deploy/readiness.md` の「デプロイの前に残るもの」節に、`environment.md` §7.4 の参照と、G-078・G-079 の G 番号が書かれている。
6. `.ai/deploy/readiness.md` に、事業者の名前・ホスト名・ドメイン・認証情報・アカウントの ID が書かれていない（`environment.md` §6.3 と同じく、送り先は役割の名前で書かれている）。
7. `.ai/INDEX.md` の知りたいことの表に「デプロイの準備」の行があり、その行に `.ai/deploy/readiness.md` が書かれている。文書の一覧にも `.ai/deploy/readiness.md` がある。
8. `.ai/README.md` の文書の表に `deploy/readiness.md` の行がある。
9. `scripts/check.sh` に、`.ai/deploy/readiness.md` の `- 確かめた M: M1` の行を確かめる段がある。その行を消した状態で `sh scripts/check.sh` を動かすと、終了コード 0 以外で止まり、準備書の名前を含む理由を出す（確かめたあと元に戻す）。
10. `.ai/gaps.md` の G-077 の行の内容の列が `YGO-068 で` で始まり `残りはない` で終わり、出どころの列に `（YGO-068）` がある。G-078・G-079 の行は変わっていない。
11. `.ai/roadmap.md` §9 に `.ai/deploy/readiness.md` の参照がある。`.ai/environment.md` §10.2 の表の OQ の並びと、準備書の表の OQ の並びが同じ 6 件である。
12. `git diff --stat` の変更のファイルに `.ai/status.md`・`.github/` の下・`standards/` の下が入っていない。新しい ADR・OQ のファイルや行が足されていない。
13. `sh scripts/check.sh` がネットワークなしで `check: ok` で終わる。
