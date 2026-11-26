# YGO-057 G-065 確認が済まない登録が住所を押さえる期限を確かめて閉じる
状態: done
M: M1

## 目的
条件 10 のために、`gaps.md` の G-065（暫定・M1、出どころ OQ-046（YGO-027））を閉じる。
G-065 は、登録の住所の押さえ方（`triage.md` 仕分け 3 の K-004）を挙げた。中身は YGO-027 で ADR-0087 に決まり（24 時間 `[assumed]`、OQ-046 → 決定）、文書も直っている。行の理由の列の「残りは G-050・G-051」は、G-050 が YGO-053、G-051 が YGO-056 で閉じている。足りないのは題に G-065 を持つチケットだけ。
`gaps.md` 冒頭の決まりに従い、題に G-065 を 1 つ付けたこのチケットで 1 行を閉じる。

## 仕分け
- `triage.md` の G-065 の行（仕分け 6）は「残りは G-050・G-051 だけ。その 2 行が閉じたあとに確かめのチケットで閉じる」と順を指定している。YGO-053・YGO-056 はどちらも done なので、この順に従う。
- 決定の中身は変えないので、ADR を足したり置き換えたりしない。マスターに決めてもらうことはなく、新しい OQ・要回答は 0 件。

## 確かめた事実
- ADR-0087 の状態の行は `- 状態: 採用`。決定は D1（`credentials.created_at` から 24 時間 `[assumed]`）・D2（確認のリンクも同じ時刻に切れ、送り直しで延びない）・D3（期限後のログインは 401）・D4（J14 が行ごと消す順）・D5（登録し直しで先に消す）・D6（候補に戻る）・D7（最長約 48 時間を受け入れる）。
- ADR-0087 が指す ADR-0030・ADR-0062・ADR-0080・ADR-0082・ADR-0084・ADR-0088・ADR-0090・ADR-0091・ADR-0102 の状態の行は、どれも `- 状態: 採用`。
- `open-questions.md`: 一覧の表の OQ-046 の行が `決定`、§4 の `### OQ-046` の節に決定（2026-11-25、K-004）がある。OQ-007・OQ-089 の「決めていないこと」は「なし」で、ADR-0087 を指す。
- `api.md`: §2.4 の手順 3（確認は登録から 24 時間、ADR-0087）、§7 F-02 の `POST /api/v1/email-verifications`・`POST /api/v1/email-verification-requests` の行と認証の経路の段落（登録から 24 時間、ADR-0087、OQ-046 → 決定）、§9 の認証の方式の項（OQ-046 → 決定、ADR-0087）。
- `db.md`: §2 の `credentials.email_verified_at`・`auth_tokens.expires_at` の行と「確認が済まない登録の期限」の段落（ADR-0087）、§4 のライフサイクルの表の `residents`・`credentials`・`addresses`・`resident_interests` の行（24 時間、ADR-0087 の D4〜D6）。
- `async.md`: §2 の段階の段落（J14 は M1 で確認が済まない登録の対象を作る、ADR-0087）、§4 J18 の送り直しの行と冪等の項（ADR-0087 の D2・D4・D5）、§9 の FR-092 の行。
- `security.md`: §3.1 の「確認が済まない登録の期限」の項、§4.2 の表の「住所を登録の前に押さえる」の行、§8 の OQ-046 の行（決定、ADR-0087）。
- `roadmap.md` §7 の FR-114・FR-010 の行に「登録から 24 時間（OQ-046 → 決定、ADR-0087）で M1 に入り、A-12 で確かめる」がある。
- `requirements.md`: FR-010 と FR-092 の行に 24 時間と ADR-0087（OQ-046 → 決定）がある。
- 図: `diagrams/m1-address-account-states.md`（24 時間を過ぎた登録を行ごと消す遷移）、`diagrams/m1-registration-sequence.md`（期限切れの登録を先に消す、ADR-0087 の D5）、`diagrams/m1-er.md`（`email_verified_at` の注と消す順、ADR-0087 の D4）。
- `INDEX.md` の 27 行目（認証の表・確認が済まない登録の期限）が ADR-0087 を指す。
- `mvp.md` の 58 行目は「24 時間（ADR-0087、OQ-046 → 決定）」で、3 行目の状態の行は `状態: 確認済み（2026-11-25、マスターが確かめた）`。

## 範囲
- このチケット。
- `.ai/gaps.md`: G-065 の行の理由と出どころの列だけ。理由の列の「残りは G-050・G-051。チケットで済みと確かめて閉じるだけ」を、G-050・G-051 を閉じたチケットと YGO-057 で確かめたことと「残りはない」に置き換え、出どころの列を `OQ-046（YGO-027・YGO-057）` にする（G-048 と同じ形）`[assumed]`。
- `.ai/INDEX.md`: チケットの一覧に 1 行。

## 直さないところと理由
- `api.md`・`db.md`・`async.md`・`security.md`・`roadmap.md`・`requirements.md`・`diagrams/`・`open-questions.md`: 期限の設計はそろっていて、直すところがない。
- ADR-0030・ADR-0080・ADR-0082・ADR-0084 の本文: 「OQ-046 で決める」と書いたままだが、ADR-0087 の影響の節が「本文は変えない」と決めている。
- 各文書の冒頭の「関連 ADR」の一覧に残る置き換えた ADR の番号: 住所の押さえ方の参照ではなく、この変更の「1 つのことだけ」の外なので直さない `[assumed]`。
- `status.md`・`mvp.md`・`triage.md`・`scripts/check.sh`: 秘書・仕分けのジョブが書く文書か、この変更でかからない。文書だけの変更で、テストは足さない。
- G-068: 次の変更で扱う（「1 つのことだけ」の指示）。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-057 G-065 確認が済まない登録が住所を押さえる期限を確かめて閉じる`・`状態: done`・`M: M1`。題の G 番号は G-065 だけで、R 番号はない。
2. ADR-0087 の状態の行が `- 状態: 採用` で、決定に D1〜D7 があり、D1 に `credentials.created_at` から 24 時間 `[assumed]` が書かれている。
3. ADR-0030・ADR-0062・ADR-0080・ADR-0082・ADR-0084・ADR-0088・ADR-0090・ADR-0091・ADR-0102 の状態の行が `- 状態: 採用`。
4. `open-questions.md` の一覧の表の OQ-046 の行が `決定`。
5. `api.md` §7 F-02 の認証の経路の段落に「登録（`credentials.created_at`）から 24 時間（ADR-0087、OQ-046 → 決定）」がある。
6. `db.md` §2 に「**確認が済まない登録の期限**（ADR-0087。OQ-046 → 決定、2026-11-25）」の段落があり、§4 の `addresses` の行に ADR-0087 の D4〜D6 がある。
7. `async.md` §2 の段階の段落に、J14 が M1 で確認が済まない登録（ADR-0087）を対象にすることが書かれている。
8. `security.md` §3.1 に「**確認が済まない登録の期限**（ADR-0087、OQ-046 → 決定）」の項があり、§8 の OQ-046 の行が「決定（2026-11-25、ADR-0087。…）」。
9. `requirements.md` の FR-010・FR-092 の行と `roadmap.md` §7 の FR-114・FR-010 の行に 24 時間と ADR-0087 がある。
10. `diagrams/m1-address-account-states.md`・`diagrams/m1-registration-sequence.md`・`diagrams/m1-er.md` に 24 時間と ADR-0087 があり、`INDEX.md` 27 行目が ADR-0087 を指す。
11. `gaps.md` の G-065 の行は 5 列で、向かう M は `M1`。理由の列に `YGO-053`・`YGO-056`・`YGO-057` と「残りはない」があり、出どころの列が `OQ-046（YGO-027・YGO-057）`。ほかの G の行に差分がない。
12. `INDEX.md` のチケットの一覧に `.ai/tickets/YGO-057-g-065-unverified-hold-24h-confirmed.md` がある。
13. `mvp.md` の 3 行目が `状態: 確認済み（2026-11-25、マスターが確かめた）` のままで、`adr/`・`open-questions.md`・`api.md`・`async.md`・`db.md`・`security.md`・`roadmap.md`・`requirements.md`・`diagrams/`・`mvp.md`・`status.md`・`triage.md` に差分がない（新しい ADR・OQ・要回答は 0 件）。
14. `sh scripts/check.sh` が `check: ok` で終わり、check:consolidation の「今の M（M1）の範囲の点検」に G-065 が出ない。
