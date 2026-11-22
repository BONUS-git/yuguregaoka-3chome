# YGO-018 R-008 J7 の手順が足りず、住民の行の削除が外部キーで止まる
状態: done

## 目的
条件 2 を進めるため、`.ai/reviews/0001-design-review.md` の R-008（区別: 中、マスターの判断: 不要）を直します。
指摘にある 4 つの処理のうち、「本人の郵便受けの行を消す」は、すでに `async.md` J7 の手順 8 にあります。残りの 3 つ（差出人を NULL にする・投稿者を NULL にする・居住記録を終わらせる）を J7 に足します。
あわせて、指摘の根拠にあり、退去のあとも住民を指したまま残る `images.uploader_id`・`moderation_actions.moderator_id`・`reports.reporter_id` も J7 で NULL にします。
外部キーごとの ON DELETE を `db.md` §2 に書きます（指摘の直し方の案のとおり）。

ADR-0079 の退去の表と保持期間の表が変わるので、ADR-0079 の D1〜D8 をそのまま引き継ぎ、D9〜D12 を足した ADR-0085 を作り、ADR-0079 を丸ごと置き換えます。
居住記録の削除が実際に起きるようになるので、退去から 1 年の起点（`tenancies.resident_erased_at`）と、J14 が居住記録を消すときに `registered_tenancy_id` を NULL にすること（D12）も同じ変更で決めます。
新しい決定はどれも技術と設計の細部なので `[assumed]` で決めました。マスターの判断が要る点はなく、`open-questions.md` に問いは足しません。

## 範囲
- `.ai/adr/0085-account-erase-clears-all-resident-references.md`（新規）: ADR-0079 の D1〜D8 と、D9（住民を指す外部キー）・D10（居住記録を終わらせ、退去の時刻 `resident_erased_at` を起点に 1 年で消す）・D11（住民を指す 6 つの列を NULL にする）・D12（J14 が居住記録を消すとき、それを指す `registered_tenancy_id` を先に NULL にする）。退去の表・保持期間の表・理由・代わりの案・影響。
- `.ai/adr/0079-account-erase-credentials-and-sessions-first.md`: 状態の行だけを `置き換え（→ 0085）` にする。
- `.ai/adr/README.md`: 0079 の行に「（ADR-0085 で置き換え）」を付け、0085 の行を足す。
- `.ai/async.md`: J7 の出力と手順 7〜10・冪等性・失敗とやり直し。J4 の新聞の項に J7 の手順 7 の注。J14 の `tenancies` の条件と消し方（D10・D12）。
- `.ai/db.md`: §2 の末尾に節「住民を指す外部キー」。`tenancies`（`resident_erased_at` と J14 の消し方）・`address_book.registered_tenancy_id`・`letter_recipients.registered_tenancy_id`・`letters.sender_id`・`board_posts.author_id`・`reports.reporter_id`・`moderation_actions.moderator_id`・`images.uploader_id` の列の説明。§3 の振り分けの表（`registered_tenancy_id` が NULL のときの差し戻し）。§4 の居住記録・手紙・掲示板投稿・モデレーター操作・通報・画像の行。§5 の 2・3・4。
- `.ai/security.md`: §2.4 に退去時の処理の 6。
- `.ai/roadmap.md`: A-13 に住民を指す行の確かめ。関連 ADR・M0 の表・「MVP で依存する ADR」・S2-3 の ADR の番号。
- `adr/`・`reviews/`・`tickets/` を除く `.ai/*.md` の `ADR-0079` を `ADR-0085` に付け替える（D の番号は同じ。102 か所）。`api.md`・`async.md`・`db.md`・`security.md`・`environment.md` の冒頭の ADR の一覧の 0079 も 0085 にする。
- `.ai/retros.md`: R-005・R-008 の節。

## 直さないところと理由
- `erasure_log` に J7 の手順 9 の UPDATE を記録するか: R-014 の範囲。ADR-0085 の D11 は「記録しない（範囲は R-014）」とした。
- 掲示板の `rejected`・`deleted` の行の消し方: R-016 の範囲。
- `sessions` の表の定義: R-025 の範囲。
- 差出人と投稿者の住所の文字列: R-029 の範囲。
- J7 の `singletonKey`・J8 の入力: R-046 の範囲。
- ほかの ADR の中の ADR-0079 の記述: 決めたときの記録なので変えない。
- `.ai/` の外のファイル、`status.md`（レポジトリにまだない。実装はまだなく、文書だけの変更）。テストは足さない。

## 受け入れ確認
1. `.ai/adr/0085-account-erase-clears-all-resident-references.md` の 1 行目が `# 0085 — 退去で住民を指す行をすべて消すか外す`、状態の行が `- 状態: 採用` で、冒頭に「ADR-0079 を丸ごと置き換える」がある。D1〜D12 の見出しがある。
2. ADR-0085 の D9 に、`address_book_daily_counts.owner_id` を除き既定（NO ACTION）にすることと、`tenancies.resident_id`・`moderation_actions.moderator_id`・`images.uploader_id` を NULL 可にすることがある。D10 に `tenancies.resident_erased_at` と `UPDATE tenancies SET resident_id = NULL, resident_erased_at = now() WHERE resident_id = $1` と `resident_erased_at < now() - interval '1 year'` がある。D12 に、J14 が居住記録を消すトランザクションで先に `address_book.registered_tenancy_id`・`letter_recipients.registered_tenancy_id` を NULL にすることがある。保持期間の表の `tenancies` の行が `resident_erased_at` を起点にしている。D11 に 6 つの列（`letters.sender_id`・`board_posts.author_id`・`reports.reporter_id`・`moderation_actions.moderator_id`・`images.uploader_id`・`tenancies.resident_id`）と「`erasure_log` には記録しない」の旨と R-014 がある。
3. ADR-0085 の退去の表に、通報・モデレーター操作・画像・住所録の追加の数え・掲示板の投稿の投稿者の行がある。
4. `.ai/adr/0079-account-erase-credentials-and-sessions-first.md` の状態の行が `- 状態: 置き換え（→ 0085）` の 1 行だけ。`.ai/adr/README.md` の 0079 の行に「（ADR-0085 で置き換え）」、最後の行に 0085 の行がある。
5. `async.md` J7 の手順 7 に「`addresses.status` を `vacant_deleted` に変更し」と `is_current` を false にすることが 1 つのトランザクションとして書かれ、手順 9 に 6 つの列を NULL にすることが、手順 10 に「`residents` を物理削除し、`erasure_log` に記録する」がある。失敗とやり直しに、J4 と同時に動いて手順 10 が失敗したときに再試行の手順 8 が行を消すことがある。
6. `async.md` J4 の新聞の項に「J7 の手順 7」があり、J14 の `tenancies` の行の条件が `resident_erased_at < now() - interval '1 year'` で、同じ行に `address_book.registered_tenancy_id` と `letter_recipients.registered_tenancy_id` を先に NULL にすること（ADR-0085 の D12）がある。J7 の手順 9 の `tenancies.resident_id` の項に `resident_erased_at` を書く UPDATE がある。§8 に `tenancies` を指す外部キーの行がない（`grep -n "tenancies\` を指す外部キー" .ai/async.md` が何も出さない）。`grep -rn "ended_at < now" .ai --exclude-dir=reviews --exclude-dir=tickets` が何も出さない。
6a. `db.md` §2 `tenancies` に `resident_erased_at` timestamptz NULL の列と、J14 が先に `registered_tenancy_id` を NULL にする段落がある。§3 の振り分けの表に「宛先の `registered_tenancy_id` が NULL」→ 差し戻しの行がある。`roadmap.md` の A-13 に、前の行の `ended_at` が退去より 1 年以上前の住民で退去の直後の J14 のあとも行が残ることと、住所録から指された居住記録が 366 日目の J14 で失敗せずに消え `registered_tenancy_id` が NULL になることの確かめがある。
7. `db.md` §2 の末尾（§3 の前）に `### 住民を指す外部キー（ADR-0085 の D9）` の節があり、表に `sessions` を除いて 16 の列が書かれている（`grep -c "FK→residents" .ai/db.md` が 16）。`tenancies.resident_id`・`moderation_actions.moderator_id`・`images.uploader_id` の列が `FK→residents NULL`。
8. `security.md` §2.4 の退去時の処理に 6 があり、J7 の手順 7〜9 と ADR-0085 の D9・D11 を指す。
9. `roadmap.md` の A-13 に、`resident_id` が NULL の居住記録、`letters.sender_id` などの列が NULL であること、J7 のあとの J4 で新聞の行ができないこと、366 日目の J14 で居住記録の行がないことの確かめがある。`roadmap.md` の関連 ADR に `0085（0079 を置き換え。` がある。
10. `grep -rn "ADR-0079" .ai --exclude-dir=adr --exclude-dir=reviews --exclude-dir=tickets` が何も出さない。
11. `grep -rn "変更[提]案\|別[チ]ケット" .ai --exclude-dir=reviews --exclude-dir=tickets` の結果が変更の前と同じ（`open-questions.md` の :497・:1326、`adr/0036` の :17・:28・:72・:79、`adr/0078` の :16・:72）。
12. `open-questions.md` §2 の表の `| OQ-NNN |` の行が 90 で、変更の前と同じ。`.ai/adr/` に `0086-*` がない。
13. `.ai/retros.md` に R-005・R-008 の見出しと、問題・根本原因・気づけなかった理由・再発防止の 4 項がある。
14. `sh scripts/check.sh` が `check: ok` で終わる。
