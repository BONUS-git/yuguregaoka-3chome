# M1 のコンポーネント図（F-01・F-02・F-19）

M1 で動くコンポーネントと、そのあいだの呼び出し。ID は `architecture.md` §2 の C1〜C13 と同じ。M1 で使わない C4 のジョブ・C5〜C13 の大半は描かない（全体の図は `architecture.md` §3）。

- FR: FR-001, FR-002, FR-003, FR-007, FR-010, FR-091, FR-092, FR-098, FR-100, FR-103, FR-113, FR-114, FR-115, FR-124, FR-127
- ADR: 0010, 0033, 0061, 0062, 0070, 0080, 0082, 0083, 0084, 0087, 0088, 0089, 0090, 0093, 0100
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
        C4["C4 worker<br/>メールのアダプタ（MAIL_ADAPTER）<br/>J14: 確認が済まない 24 時間を過ぎた登録と<br/>1 日たった数えの行を消す"]
        Mail["モックのメール / ローカルの SMTP<br/>（宛先はループバックだけ）"]
    end

    C7[("C7 PostgreSQL<br/>residents・credentials・sessions・staff_roles<br/>rate_limit_buckets・addresses・tenancies・jobs")]

    C1 -->|"HTTPS / JSON<br/>GET addresses/candidates・occupancy<br/>POST registrations・sessions など"| C2
    C2 --> C3w
    C2 --> C5r
    C2 --> C9
    C3w --> C7
    C2 -->|"credentials・sessions・rate_limit_buckets"| C7
    C4 -->|"J14 の削除"| C7
    C2 -. "メールを渡すジョブ（未設計、gaps.md G-049）" .-> C7
    C7 -. "jobs" .-> C4
    C4 --> Mail
```

## 読み方

- 地図の画像・配置の定義は C1 の静的なファイルで、地図のための API は入居の一覧だけ。DB の地図の表と、座標を返す経路はない（ADR-0083 の D3）。
- C2 は登録の住所が候補かどうかを確かめない。プールにない住所は 400、C3 が割り当てられない住所は 409（ADR-0082 の D3）。
- 点線の経路（web が確認と再設定のメールを worker に渡す）は `async.md` にジョブがない。M1 の実装の前に決める（`gaps.md` G-049）。
