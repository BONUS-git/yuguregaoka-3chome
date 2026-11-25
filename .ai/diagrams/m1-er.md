# M1 の ER 図

M1 で作る表と、そのあいだの関係。列の正本は `db.md` §2（`residents`・`credentials`・`addresses`・`tenancies`）と `security.md` §3.3（`sessions`）。M1 で使わない列（休眠・転送の列）は描かない。

- FR: FR-001, FR-002, FR-003, FR-008, FR-009, FR-092, FR-098, FR-100, FR-113, FR-127
- ADR: 0073, 0080, 0081, 0082, 0084
- 確かめた M: M1

```mermaid
erDiagram
    residents ||--|| credentials : "1 人に 1 行"
    residents ||--o{ sessions : "複数の端末"
    residents ||--o{ tenancies : "居住記録"
    addresses ||--o{ tenancies : "住んでいた住民"

    residents {
        uuid id PK "内部 ID（変えない、ADR-0082）"
        text nickname
        text bio
        smallint age_at_registration "0〜999・書き換えない"
        date age_base_date "書き換えない"
        smallint birthday_month "1〜12・書き換えない"
        smallint birthday_day "月日の CHECK・書き換えない"
        timestamptz last_login_at
        timestamptz created_at
    }
    credentials {
        uuid resident_id PK "FK → residents"
        bytea email_encrypted "AES-256-GCM"
        int email_key_version
        bytea email_hmac "UNIQUE（版と組で）"
        int email_hmac_key_version
        text password_hash "Argon2id"
        timestamptz email_verified_at "NULL = 確認待ち"
    }
    sessions {
        text session_id PK
        uuid resident_id FK
        timestamptz created_at
        timestamptz last_seen_at
        timestamptz expires_at
        timestamptz reauthenticated_at
        timestamptz invalidated_at "退去の受付だけ（M6）"
    }
    addresses {
        uuid id PK
        text address_text UK "例: 夕暮ヶ丘三丁目 2-5"
        text status "M1 は active だけ"
        timestamptz created_at
    }
    tenancies {
        uuid id PK
        uuid resident_id FK
        uuid address_id FK
        timestamptz started_at
        timestamptz ended_at "NULL = 居住中"
        bool is_current "UNIQUE(address_id) where is_current"
    }
```

## 読み方

- 街のすべての住所は C3 の住所のプールの静的な定義が持ち、`addresses` の行は初めて割り当てたときに作る（ADR-0084 の D15）。地図の表はない（ADR-0083 の D3）。
- `sessions` の表の定義は `db.md` §2 にまだない（`reviews/0001-design-review.md` の R-025）。列は `security.md` §3.3 の項目から描いた `[assumed]`。
