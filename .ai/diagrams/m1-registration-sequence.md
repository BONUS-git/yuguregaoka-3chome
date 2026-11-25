# M1 の主な流れ: 地図で住所を選んで登録し、確かめてログインする（シーケンス図）

M1 の中心の一続き（候補と入居を見る → 地図で選ぶ → 登録 → メールの確認 → ログイン → 地図で自分の家を見る）。経路と状態コードは `api.md` §7 F-01・F-02・F-19。

- FR: FR-001, FR-002, FR-007, FR-010, FR-091, FR-092, FR-098, FR-103, FR-113, FR-114, FR-115, FR-124, FR-127
- ADR: 0030, 0062, 0070, 0073, 0080, 0082, 0083, 0084, 0087, 0088, 0089, 0090
- 確かめた M: M1

```mermaid
sequenceDiagram
    actor V as 訪問者
    participant C1 as C1 Web クライアント
    participant C2 as C2 API（web）
    participant C3 as C3 居住者と住所
    participant C7 as C7 PostgreSQL
    participant C4 as C4 worker（メールのアダプタ）

    V->>C1: 登録の画面を開く
    C1->>C2: GET /api/v1/addresses/candidates（認証なし）
    C2->>C3: 使われたことのない住所から候補を選ぶ（ADR-0062）
    C2-->>C1: 200 候補
    C1->>C2: GET /api/v1/addresses/occupancy（認証なし）
    C2->>C7: SELECT address_text, status IN ('active','dormant') FROM addresses
    C2->>C3: プールの定義と突き合わせ、番・号の順に並べる
    C2-->>C1: 200 住所と occupied だけ（件数なし）
    C1-->>V: 共有の地図に候補の印・空き家の印・入居の層を重ねる
    V->>C1: 候補の印か空き家の印を押す（または一覧から選ぶ）<br/>年齢・誕生日・メールアドレス・パスワードを入れる
    C1-->>V: 「年齢と誕生日はあとから変えられません」を示して確かめる
    C1->>C2: POST /api/v1/registrations（address・age・birthday・email・password）
    C2->>C7: 流量の制限を別のトランザクションで先に数える（rate_limit_buckets。IP ごとに 3 回／1 時間・10 回／1 日。超えたら 429、ADR-0088）
    C2->>C2: 形式・絵文字・age 0〜999・birthday MM-DD を検証（違えば 400）
    alt プールの静的な定義にない住所
        C2-->>C1: 400 validation_failed
    else 行のある住所・同時の登録に負けた
        C2->>C3: 住所を割り当てる（候補かどうかは確かめない）
        C3->>C7: 同じ住所・同じメールアドレスの、確認が済まず 24 時間を過ぎた登録を先に消す（ADR-0087 の D5）<br/>INSERT addresses が address_text の UNIQUE に当たる → ロールバック
        C2-->>C1: 409 conflict
        C1-->>V: 決まった文を出し、選択を外して候補と入居の一覧を取り直す
    else 割り当てられる
        C2->>C3: 住所を割り当てる（候補かどうかは確かめない）
        C3->>C7: 1 つのトランザクションで、同じ住所・同じメールアドレスの期限切れの登録を消し（ADR-0087 の D5）、residents・credentials・addresses（active）・tenancies を作る
        C2--)C4: 確認のメールを送る（渡し方は未設計、gaps.md G-049）
        C2-->>C1: 201
    end
    C4-->>V: 確認のメール（M1 はモック）
    V->>C1: 確認のリンクを開く
    C1->>C2: POST /api/v1/email-verifications（token）
    C2->>C7: credentials.email_verified_at を書く
    C2-->>C1: 204（違う・切れた（登録から 24 時間）・使ったトークンは 400 token_invalid）
    V->>C1: ログインする
    C1->>C2: POST /api/v1/sessions（email・password）
    C2->>C7: 流量の制限を数える（メールアドレスごとに 10 回／15 分・IP ごとに 50 回／15 分、ADR-0088）<br/>sessions の行を作る（token_hash・reauthenticated_at・expires_at、ADR-0089 の D1）
    C2-->>C1: 200 と Cookie（確認が済んでいなければパスワードの誤りと同じ 401）
    C1->>C2: GET /api/v1/me
    C2->>C3: 今の年齢を誕生日の回数で時計から計算する
    C2-->>C1: 200 住所・ニックネーム・age・birthday
    C1-->>V: 地図の窓の中心に自分の家の印を出す
```

## 読み方

- 確認が済まない登録が住所を押さえる期限と、確認のリンクの期限は、どちらも登録から 24 時間（ADR-0087、OQ-046 → 決定）。送り直しても延びない。期限を過ぎた登録は J14 が行ごと消す。
- 流量の制限の値と対象の経路は `security.md` §3.5 の表（ADR-0088）。
- 登録の画面が呼ぶ API は候補と入居の一覧の 2 つだけ。地図の画面は `me`・候補・入居の一覧と、M2 から住所録を呼ぶ（ADR-0084 の D4・D5）。
