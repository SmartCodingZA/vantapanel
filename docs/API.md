# vantapanel REST API

Programmatic account management over HTTP, authenticated by bearer token.

## Base URL & auth

The API is served on the **user-panel vhost** (which has no HTTP Basic-Auth):

```
https://cp.<your-domain>/?api=<resource>
```

Authenticate every request with a token issued in **WHM → API Tokens**:

```
Authorization: Bearer vp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

If your client/proxy strips `Authorization`, you may instead send `X-Api-Key: <token>`.

Tokens are shown **once** at creation and stored only as a SHA-256 hash. They carry scopes, can
expire, and can be revoked at any time. All mutating calls are written to the WHM **Audit Log**.

Responses are JSON. Success is `{"ok":true, ...}`; errors are `{"ok":false,"error":"<code>", ...}`
with an appropriate HTTP status.

## Scopes

| Scope              | Allows                                                            |
|--------------------|------------------------------------------------------------------|
| `accounts:read`    | list and view accounts                                           |
| `accounts:write`   | create accounts, suspend/unsuspend, set password, set/clear plan |
| `accounts:delete`  | terminate accounts (and drop their databases)                    |

A call missing the required scope returns **403 `insufficient_scope`**.

## Endpoints

### Verify a token — `GET ?api=ping` (no scope)
```bash
curl -H "Authorization: Bearer $TOK" "https://cp.example.com/?api=ping"
# {"ok":true,"token":"provisioning-bot","scopes":["accounts:read",...],"expires":null,"time":"…"}
```

### List accounts — `GET ?api=accounts` · `accounts:read`
```bash
curl -H "Authorization: Bearer $TOK" "https://cp.example.com/?api=accounts"
# {"ok":true,"count":2,"accounts":[{"username":"cust12","domain":"cust12.com","status":"active",
#   "plan":null,"created_at":"…","databases":1,"domains":2}, …]}
```

### View one account — `GET ?api=account&user=NAME` · `accounts:read`
```bash
curl -H "Authorization: Bearer $TOK" "https://cp.example.com/?api=account&user=cust12"
# {"ok":true,"account":{"username":"cust12","domain":"cust12.com","status":"active","plan":null,
#   "created_at":"…","domains":[{"domain":"…","type":"main","docroot":"…"}],"databases":["cust12_db"]}}
```

### Create an account — `POST ?api=accounts` · `accounts:write`
Body (JSON): `username` (3–16 chars, `[a-z][a-z0-9]{2,15}`), `domain` (required),
`password` (optional — generated and returned if omitted), `plan` (optional).
```bash
curl -X POST -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
     -d '{"username":"cust12","domain":"cust12.com"}' \
     "https://cp.example.com/?api=accounts"
# 201 {"ok":true,"username":"cust12","domain":"cust12.com","plan":null,
#      "panel":"https://cp.example.com","password":"<generated-if-omitted>"}
```
Validation errors return **422 `validation_failed`** with an `errors` array.

### Suspend / unsuspend — `POST ?api=account&action=suspend|unsuspend` · `accounts:write`
```bash
curl -X POST -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
     -d '{"user":"cust12"}' "https://cp.example.com/?api=account&action=suspend"
# {"ok":true,"user":"cust12","status":"suspended"}
```

### Set password — `POST ?api=account&action=password` · `accounts:write`
Omit `password` to have one generated and returned; if supplied it must be ≥ 8 chars.
```bash
curl -X POST -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
     -d '{"user":"cust12"}' "https://cp.example.com/?api=account&action=password"
# {"ok":true,"user":"cust12","password_changed":true,"password":"<generated>"}
```

### Set / clear plan — `POST ?api=account&action=plan` · `accounts:write`
Empty `plan` clears it.
```bash
curl -X POST -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
     -d '{"user":"cust12","plan":"starter"}' "https://cp.example.com/?api=account&action=plan"
# {"ok":true,"user":"cust12","plan":"starter"}
```

### Terminate — `DELETE ?api=account&user=NAME` · `accounts:delete`
Also drops the account's databases. `POST ?api=account&action=terminate` with `{"user":"…"}` is
equivalent for clients that can't send DELETE.
```bash
curl -X DELETE -H "Authorization: Bearer $TOK" "https://cp.example.com/?api=account&user=cust12"
# {"ok":true,"user":"cust12","terminated":true}
```

## Error codes

| HTTP | error                  | meaning                                            |
|------|------------------------|----------------------------------------------------|
| 401  | `missing_token`        | no bearer token sent                               |
| 401  | `invalid_token`        | token unknown or revoked                           |
| 401  | `token_expired`        | token past its expiry                              |
| 403  | `insufficient_scope`   | token lacks the required scope                     |
| 404  | `account_not_found`    | no such account                                    |
| 404  | `unknown_endpoint`     | unrecognised `?api=` resource                      |
| 405  | `method_not_allowed`   | wrong HTTP method for the resource                 |
| 422  | `validation_failed`    | bad input (see `errors`)                           |
| 422  | `missing_user` / `unknown_action` / `password_too_short` | malformed request    |
| 502  | `provisioning_failed` / `worker_failed` | the privileged worker could not complete the action |

## Notes

- Account operations run through the same privileged worker as the WHM UI, so protected system
  users/databases are refused regardless of the token.
- Generated passwords are returned **once** in the create/password responses — there is no way to
  retrieve them later.
- Tokens record `last_used_at` / `last_used_ip` on each successful authentication.
