# YGO-022 ブリーフの節ごとの対応（.ai/brief-map.md）
状態: done
M: M1

## 目的
条件 2 を進めるため、`.ai/brief.md` の見出しのすべてを、`.ai/features.md` の F の番号か「入れない」に対応させる表を `.ai/brief-map.md` に書きます。
根拠は `features.md` §2・§3・`roadmap.md` §4・`mvp.md` で、新しい決定は作りません。M1 を止める新しい要回答はありません。

- 2 列目は F の番号で書き、複数あるときは「・」でつなぐ（`[assumed]`）。
- 1 列目の見出しは `#` を除いた本文をそのまま使う（`[assumed]`）。

## 範囲
- `.ai/brief-map.md`（新規）: 冒頭（日付・チケット・根拠）と、見出し 14 件の表、F-02 の `[inferred]` の段落。
- `.ai/mvp.md` (d) の `## 4. 設計・開発ルール` の行: brief-map と同じく「入れない」にする。
- このチケット。

## 直さないところと理由
- ほかの設計の文書（`features.md`・`roadmap.md`・`requirements.md`・ADR など）: 段階の決まりで、MVP がマスターに確かめられるまで `mvp.md`・`open-questions.md`・`brief-map.md` のほかは変えない。
- `open-questions.md`: 新しい要回答がないため変えない。
- `INDEX.md`: まだない。地図に載せるのは `INDEX.md` を作る変更で行う。
- `scripts/check.sh`: この変更の範囲の外。既存のループが新しい文書が空でないことを確かめる。
- `status.md`: 秘書が書く。
- テストのコード: 足さない。実装がまだなく、確かめるのは文書だけ。

## 受け入れ確認
1. `sed -n 1,3p .ai/tickets/YGO-022-brief-map.md` が、題・`状態: done`・`M: M1` の 3 行を出す。
2. `.ai/brief-map.md` の表に、`.ai/brief.md` の見出しが漏れなく 1 行ずつある。次が何も出さない:
   `grep -E '^#+ ' .ai/brief.md | sed -E 's/^#+ //' | while IFS= read -r h; do n=$(grep -cF "| $h |" .ai/brief-map.md); [ "$n" = 1 ] || echo "NG: $h ($n)"; done`
3. 各行の 2 列目は `^(入れない|F-[0-9]{2}(・F-[0-9]{2})*)$` に合う。
4. brief-map に出てくる F の番号は、どれも `features.md` に `^| F-NN |` の行がある。
5. 「入れない」の行には、理由の列が書かれている（空のものがない）。
6. `mvp.md` (d) のバッククォートの見出しが、どれも `brief.md` にある（`grep -Fxq`）。`## 4. 設計・開発ルール` の行が「入れない」を含む。
7. `git status --porcelain` に出るのは `brief-map.md`・`mvp.md`・このチケットの 3 つだけで、`sh scripts/check.sh` が `check: ok` を出す（ネットワークなし）。
