# M1 の住所と認証の状態遷移図

M1 で起きる住所（`addresses.status`）の遷移と、入居の一覧での読み方、アカウントの確認とセッションの状態。全体の住所の遷移は `db.md` §4 の状態遷移図。

- FR: FR-001, FR-007, FR-010, FR-092, FR-098, FR-100, FR-115
- ADR: 0060, 0062, 0080, 0082, 0084, 0087, 0089, 0090
- 確かめた M: M1

```mermaid
stateDiagram-v2
    state "住所（M1）" as Addr {
        unused: 使われたことのない住所（addresses に行がない）<br/>候補に出る・入居の一覧で空き家
        active: active（入居）
        unused --> active : 登録の割り当て（INSERT。UNIQUE に当たれば 409、ADR-0082 の D3）
        active --> unused : 確認が済まないまま 24 時間を過ぎた登録を J14 か登録の要求が行ごと消す（ADR-0087）
        note right of active
            M1 で起きるのはこの 2 つの遷移だけ。
            active → vacant_deleted は M6（退去）、
            休眠・転送・空き家の再割り当ては段階 3（ADR-0062）。
            vacant_* の住所は候補に戻さない（FR-007）
        end note
    }

    state "アカウントとセッション（M1）" as Acct {
        unverified: 確認待ち（email_verified_at が NULL）<br/>ログインは 401 unauthenticated
        verified: 確認済み
        session: セッションあり（sessions の行）
        reauthed: 再認証が新しい（reauthenticated_at が 10 分以内）
        [*] --> unverified : POST /registrations が 201
        unverified --> verified : 登録から 24 時間以内の POST /email-verifications が 204
        unverified --> [*] : 24 時間を過ぎて J14 か登録の要求が行ごと消す（ADR-0087）
        verified --> session : POST /sessions が 200
        session --> reauthed : ログイン直後・POST /sessions/current/reauthentication
        reauthed --> session : 10 分を過ぎる
        session --> verified : ログアウト・取り消し・再設定の完了・期限切れで行を消す
        reauthed --> verified : 同上
    }
```

## 読み方

- 入居の一覧は `active`・`dormant` を入居、行がない住所と `vacant_*` を空き家と読む（ADR-0084 の D13）。M1 で出るのは行がない住所と `active` だけ。
- パスワード・メールアドレスの変更は再認証が新しいときだけ受ける（ADR-0090 の D5）。パスワードの変更は今のセッションのほかの行を消す（ADR-0090 の D4）。
- 確認待ちの登録が住所を押さえるのは登録（`credentials.created_at`）から 24 時間で、確認のリンクも同じ時刻に切れる（ADR-0087）。期限を過ぎてから J14 が消すまでの間（最長で登録から約 48 時間）、住所は `active` のままで入居と出る。
- セッションの列（`token_hash`・`reauthenticated_at`・`second_factor_at`・`invalidated_at`・`expires_at`）は `db.md` §2 の `sessions`（ADR-0089 の D1）。
