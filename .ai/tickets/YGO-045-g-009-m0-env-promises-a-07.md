# YGO-045 G-009 M0 の環境の約束を A-07 に足す
状態: done
M: M1

## 目的
条件 10 のために、`gaps.md` の G-009（暫定・M1、出どころ R-033）を閉じる。
R-033（`reviews/0001-design-review.md`、区別: 軽微）は、M0 の環境の約束 4 つ（偽の鍵での起動の失敗・自分のものでない秘密での起動の失敗・`CLOCK_OFFSET`・外への接続の禁止）を確かめる受け入れ条件がなく、MVP を閉じるときに判定できないことを挙げた。直し方の案は「A-07 を広げるか、A-20 を足す」。
この変更は A-07 を広げる。`gaps.md` 冒頭の決まり（YGO-043）に従い、題に G-009 を 1 つ付けたこのチケットで 1 行を閉じる。

## 仕分け
- `triage.md` の最新の回は G-009 を「暫定・M1・A-07 に足すだけ」としている。K の順の指定はない。
- A-20 を足さずに A-07 を広げる `[assumed]`: A-07 はすでに秘密の読み分け（web は LLM の API キーを読まない）と外への接続の禁止（ローカルの SMTP はループバックだけ）を持っていて、4 つの約束は同じ「外の資源と秘密を間違えて使わない」の確かめ。受け入れ条件の数（19 項目）は変わらない。
- 約束の中身は `environment.md` と ADR-0052 にすでにあり、決定は変わらない。ADR は作らない。マスターに決めてもらうことはないので、新しい OQ・要回答は 0 件。

## 確かめた事実（直す前）
- `environment.md` §2: `staging`・`production` で偽の鍵（`EXAMPLE_` で始まる値）を見つけたら起動に失敗する。
- `environment.md` §3.2: `CLOCK_OFFSET` で時計をずらす。§8.1 の表の `CLOCK_OFFSET` の行: `staging`・`production` で設定されていたら起動に失敗。
- `environment.md` §4.2: テストの準備で、ループバックと Unix ソケットのほかへの接続を失敗させる。
- `environment.md` §8.1 の表の下: どちらのプロセスも自分の列にない秘密が設定されていたら起動に失敗する（web と worker の変数の名前つき）。ADR-0052 の D7 も両方のプロセスを書いている。
- `roadmap.md` §4 の M0 の行だけが「web は自分のものでない秘密があれば起動に失敗」と web だけを書いていて、食い違っていた。
- `roadmap.md` A-07 には 4 つの約束がなかった。

## 範囲
- このチケット。
- `.ai/roadmap.md`: §4 の A-07 の条件と確かめ方の列、§4 の M0 の行、§11 の NFR-058 の行。
- `.ai/gaps.md`: G-009 の行の理由と出どころの列だけ。
- `.ai/INDEX.md`: チケットの一覧にこのチケット、「環境・秘密・費用」の行に A-07。

## 直さないところと理由
- `environment.md`・ADR-0052・`security.md`: 約束の中身はすでに書かれていて、A-07 と食い違わない。
- `status.md`・`triage.md`・`reviews/`・`mvp.md`: 秘書・仕分けのジョブ・レビューが書く文書なので変えない。
- `scripts/check.sh`・テストのコード: 文書だけの変更。A-07 のテストは M0 の実装で書く。
- `INDEX.md` の「M1 の受け入れ条件」の行の範囲の書き方: G-009 とは別の論点なので、この変更では扱わない。

## 受け入れ確認
1. このチケットの 1〜3 行目が `# YGO-045 G-009 M0 の環境の約束を A-07 に足す`・`状態: done`・`M: M1`。題の G 番号は G-009 だけ。
2. `roadmap.md` §4 の A-07 の行の条件の列に「M0 の環境の約束（environment.md §2・§3.2・§4.2・§8.1、ADR-0052 の D1・D7）」と (1)〜(4) がある:
   - (1) `staging`・`production` で偽の鍵（`EXAMPLE_` で始まる値）なら起動に失敗。
   - (2) web・worker は自分の列にない秘密で起動に失敗し、web は `LLM_API_KEY`・`VAPID_PRIVATE_KEY`・`NEWS_SOURCE_CREDENTIALS`・`MAIL_SERVICE_CREDENTIALS`、worker は `SESSION_SIGNING_KEY`・`RESET_TOKEN_SIGNING_KEY`・`RATE_LIMIT_HMAC_KEY`・`EMAIL_HMAC_KEYRING` を挙げている。この名前は `environment.md` §8.1 の表の下の行と同じ。
   - (3) `staging`・`production` で `CLOCK_OFFSET` が設定されていたら起動に失敗。
   - (4) テストの準備がループバックと Unix ソケットのほかへの接続を失敗させる（例の宛先は偽の値の `192.0.2.1`・`smtp.example.invalid`）。
3. A-07 の確かめ方の列に、(1)〜(3) の設定の読み込みのテストと、(4) のテストの準備の接続の検査のテストがある。
4. `roadmap.md` §4 の M0 の行に「web・worker は自分の列にない秘密があれば起動に失敗」と「受け入れ条件は A-07」があり、「web は自分のものでない秘密」の文はない。
5. `roadmap.md` §11 の NFR-058 の行が `§4 M0・A-07（environment.md §3・§4・§8.1）`。
6. `roadmap.md` の A-01〜A-19 の数は変わらず、A-20 はない。
7. `gaps.md` の G-009 の行は 5 列のままで、向かう M が `M1`。理由の列に `YGO-045` と「残りはない」があり、出どころの列が `R-033（YGO-045）`。ほかの G 行に差分がない。
8. `INDEX.md` のチケットの一覧に `.ai/tickets/YGO-045-g-009-m0-env-promises-a-07.md` があり、「環境・秘密・費用」の行に `§4 A-07` がある。
9. `git status --short` に出るのはこの 4 ファイル（このチケット・`roadmap.md`・`gaps.md`・`INDEX.md`）だけ。`.ai/adr/` と `open-questions.md` に差分がない。
10. `sh scripts/check.sh` が `check: ok` で終わり、check:consolidation の「今の M（M1）の範囲の点検」が 17 件に減って G-009 が出ない。
