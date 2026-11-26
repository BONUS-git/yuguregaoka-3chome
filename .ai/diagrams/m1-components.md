# M1 のコンポーネント図（F-01・F-02・F-19）

M1 で動くコンポーネントと、そのあいだの呼び出し。ID は `architecture.md` §2 の C1〜C13 と同じ。M1 で使わない C4 のジョブ・C5〜C13 の大半は描かない（全体の図は `architecture.md` §3）。

- FR: FR-001, FR-002, FR-003, FR-007, FR-010, FR-091, FR-092, FR-098, FR-100, FR-103, FR-113, FR-114, FR-115, FR-124, FR-127
- ADR: 0010, 0033, 0061, 0062, 0070, 0080, 0082, 0083, 0084, 0087, 0088, 0090, 0093, 0100, 0101
- 確かめた M: M1

```mermaid
flowchart TB
    subgraph Browser["ブラウザ"]
        C1["C1 Web クライアント（React SPA）<br/>登録の画面・ログイン・プロフィール<br/>地図: 共有の白黒の SVG（img）<br/>＋ 印の層（自分の家・候補・空き家）<br/>＋ 入居の層・配置の定義と関数"]
    end

    subgraph Web["web プロセス"]
        C2["C2 API（Fastify）<br/>認証なし: 候補・入居の一覧・登録・ログイン<br/>メールの確認・送り直し・再設定<br/>認証あり: me・セッション・再認証・<br/>パスワードとメールアドレスの変更<br/>絵文字は 400・流量の制限は 429"]
        C3w["C3 居住者と住所のサブモジュール<br/>住所のプールの静的な定義<br/>入居の読み方・割り当て（409）<br/>今の年齢の計算（時計）"]
        C5r["C3 モデレーションのサブモジュール<br/>絵文字の検査（全ての入力で同じ関数）"]
        C9["C9 KeyProvider<br/>メールアドレスと TOTP の秘密の暗号化の鍵<br/>メールアドレスと流量の制限の HMAC の鍵<br/>（ローカルは偽の鍵）"]
    end

    subgraph Worker["worker プロセス"]
        C4["C4 worker<br/>J18 mail.send: 確認と再設定のメール・<br/>メールアドレスの変更の知らせ<br/>（メールのアダプタ MAIL_ADAPTER）<br/>J14: 確認が済まない 24 時間を過ぎた登録と<br/>1 日たった数えの行を消す"]
        Mail["モックのメール / ローカルの SMTP<br/>（宛先はループバックだけ）"]
    end

    C7[("C7 PostgreSQL<br/>residents・credentials・sessions・staff_roles<br/>auth_tokens<br/>rate_limit_buckets・addresses・tenancies・jobs")]

    C1 -->|"HTTPS / JSON<br/>GET addresses/candidates・occupancy<br/>POST registrations・sessions など"| C2
    C2 --> C3w
    C2 --> C5r
    C2 --> C9
    C3w --> C7
    C2 -->|"credentials・sessions・rate_limit_buckets"| C7
    C4 -->|"J14 の削除・J18 が送った値の列を NULL にする"| C7
    C2 -. "J18 mail.send を同じトランザクションで積む" .-> C7
    C7 -. "jobs（J18 mail.send）" .-> C4
    C4 --> Mail
```

## 読み方

- 地図の画像・配置の定義は C1 の静的なファイルで、地図のための API は入居の一覧だけ。DB の地図の表と、座標を返す経路はない（ADR-0083 の D3）。
- C2 は登録の住所が候補かどうかを確かめない。プールにない住所は 400、C3 が割り当てられない住所は 409（ADR-0082 の D3）。
- 点線の経路（web が確認と再設定のメールを worker に渡す）は J18 `mail.send`（`async.md` §2 の J18 の行・§4 J18）。web が登録・送り直し・再設定の依頼・メールアドレスの変更の要求と確認と同じトランザクションで `jobs` に積み、ペイロードは `{kind, auth_token_id}` だけ（`security.md` T-03）。トークンと前のアドレスは `auth_tokens` の列に `EMAIL_KEYRING` で暗号化して置き、worker が復号して送る（ADR-0101 の D7。`RESET_TOKEN_SIGNING_KEY` は web だけ、`environment.md` §8.1）。
