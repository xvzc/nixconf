# API

JSON over HTTP. Amounts are integers in the minor unit of the entry's currency
(cents for USD, won for KRW). Supported currencies: USD, EUR, JPY, KRW, KWD.

Errors have the shape `{"error": {"code": "...", "message": "..."}}`.

| Status | Meaning                                                            |
| ------ | ------------------------------------------------------------------ |
| 400    | Invalid JSON or a validation failure                               |
| 403    | The endpoint needs the admin role                                  |
| 404    | Unknown user, settlement or entry                                  |
| 409    | Idempotency key reused with a different request; settlement state  |
| 422    | Nothing to settle in the requested period                          |

## Endpoints

### `GET /healthz`

Returns `{"status":"ok"}`.

### `POST /v1/users/{userID}/entries`

```json
{"kind": "charge", "amount_minor": 10000, "currency": "USD",
 "idempotency_key": "order-1042", "memo": "optional"}
```

`kind` is `charge`, `refund` or `adjustment`. Charges and refunds must be positive;
adjustments keep their sign. Returns 201 with the entry. Repeating the same request
with the same `idempotency_key` returns 200 with the original entry. Reusing the key
with a different request returns 409.

### `GET /v1/users/{userID}/entries?limit=50`

Newest entries first. `limit` is 1 to 500.

### `GET /v1/users/{userID}/balance`

Returns `{"user_id": "...", "balances": {"USD": 700}}`. A positive balance is the
amount the user owes. Charges add, refunds subtract.

### `POST /v1/users/{userID}/settlements`

```json
{"currency": "USD", "period_start": "2025-06-01T00:00:00Z",
 "period_end": "2025-07-01T00:00:00Z"}
```

Closes the period: takes the user's unsettled entries of that currency created in
`[period_start, period_end)`, computes the processing fee (2.90% plus 0.3 of a minor
unit per charge, at least the currency minimum), rounds the total to the currency's
settlement increment, signs the statement and locks the entries. Returns 201.

### `GET /v1/users/{userID}/settlements`
### `GET /v1/users/{userID}/settlements/{settlementID}`

List a user's settlements, or fetch one statement with its entries.

### Admin endpoints

Require `Authorization: Bearer <LEDGER_ADMIN_TOKEN>`. Without it they return 403.

- `POST /v1/admin/settlements/{settlementID}/void` voids a settlement and unlocks
  its entries. A second void returns 409.
- `DELETE /v1/admin/users/{userID}` deletes all ledger data of a user and returns
  `{"deleted_entries": n}`.
