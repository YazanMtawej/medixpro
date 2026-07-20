# MedixPro — Booking Payments & Sham Cash Integration

Patients pay a **booking fee** (a configurable percentage of the doctor's
consultation receipt) through **Sham Cash** to request an appointment. The money
goes to the **MedixPro Sham Cash agent account**, and MedixPro settles each
doctor monthly for the visits they actually completed.

---

## 1. Business rules (as configured)

| Rule | Value |
|---|---|
| Booking fee | `PLATFORM_FEE_RATE` × doctor's receipt (default **20%**) |
| Receipt (full visit price) | Per-doctor, set at **registration**, editable later (`Profile.receipt_amount`) |
| Currency | **SYP** (`currencyId = 2`) |
| Who gets the money | MedixPro's Sham Cash **agent account** (not the doctor directly) |
| Doctor picks | The patient selects a **specific doctor** before paying |
| Auto-refund | Doctor **rejects** the request, or doctor **cancels** the appointment |
| Expired bill | No charge occurred → nothing to refund; the pending request is discarded |
| Monthly payout to doctor | Σ booking-fee of the doctor's **completed, paid, non-refunded** visits |
| Payout disbursement | **Manual** — admin reviews and records the transfer (the E-Pay API has no third-party payout endpoint) |

---

## 2. Architecture

All cryptography and the Sham Cash `secretKey` live **server-side only**. The
Flutter app never sees the key; it only opens the `paymentUrl` and polls status.

```
Patient (Flutter)                Django backend                 Sham Cash
     │  POST payments/book/           │                              │
     │ ─────────────────────────────► │  createBill (JWE) ─────────► │
     │                                │ ◄───────────── paymentUrl    │
     │ ◄──── payment_url ─────────────│                              │
     │  open paymentUrl (url_launcher)──────────────────────────────►│  (checkout)
     │  poll payments/<id>/status/    │                              │
     │                                │ ◄── webhook (JWE, Paid) ──────│
     │                                │  reveal request to doctor     │
```

### Backend — `payments/` app
| File | Responsibility |
|---|---|
| `shamcash.py` | Direct **JWE (AES-GCM 256)** encrypt/decrypt + the 4 endpoints (createBill, getBillInfo, refundBill, getTransactions) |
| `models.py` | `Payment`, `PayoutSettlement`, `WebhookEvent` |
| `services.py` | Booking, webhook processing, refunds, payout aggregation |
| `views.py` / `urls.py` | HTTP endpoints (below) |
| `management/commands/compute_payouts.py` | Build monthly settlements from the CLI |

### Frontend — `lib/features/payments/`
| File | Responsibility |
|---|---|
| `data/payments_datasource.dart` | `getDoctors()`, `book()`, `paymentStatus()` |
| `presentation/booking_payment_flow.dart` | Launches checkout, polls status, shows result dialog |

Booking UI lives in the existing `patient_requests_page.dart` "New Request" tab
(now a doctor picker + "Book & Pay"). Doctor registration collects the receipt
in `register_page.dart`.

---

## 3. HTTP endpoints (all under `/api/v1/`)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET`  | `doctors/` | patient | List bookable doctors + receipt + computed booking fee |
| `POST` | `payments/book/` | patient | Create request + Sham Cash bill; returns `payment_url` |
| `GET`  | `payments/<id>/status/` | patient (owner) | Poll payment status (fallback reconcile after 10 min) |
| `POST` | `payments/webhook/shamcash/` | none (JWE-authenticated) | Sham Cash callback (Paid/Expired) |
| `GET`  | `payments/redirect/` | none | Browser landing page after checkout |
| `GET`  | `payments/payouts/?year=&month=` | admin | Build + list monthly settlements |
| `POST` | `payments/payouts/` | admin | Mark a settlement paid (`settlement_id`, `paid_reference`) |

---

## 4. Configuration (env vars)

Set in the environment (defaults shown; the dev credentials are baked in as
fallbacks for local testing only):

```bash
SHAMCASH_BASE_URL=https://dev.shamlogix.tech/services
SHAMCASH_AGENT_KEY=JKAWASLaflka1351FLPG
SHAMCASH_SECRET_KEY=fuQMtK4kd7PcpNgWzLjFlogoIXNBw2TG6O4BHgsxt8o=   # Base64 of 32 bytes
SHAMCASH_CURRENCY_ID=2         # 2 = SYP
PLATFORM_FEE_RATE=0.20         # 20%
PUBLIC_BASE_URL=https://<public-host>   # MUST be reachable by Sham Cash for the webhook
```

> **Rotate `SHAMCASH_SECRET_KEY` for production** and keep it only in server-side
> env/secret storage — it authorises the whole agent account.

### ⚠️ Deployment gotcha — the webhook needs a public URL
`PUBLIC_BASE_URL` is used to build `callbackUrl`/`redirectUrl`. On `localhost`,
Sham Cash cannot deliver the webhook, so a paid bill won't be confirmed until the
fallback `getBillInfo` reconcile fires (~10 min after creation). For local
end-to-end testing, expose the backend with a tunnel (e.g. `ngrok http 8000`) and
set `PUBLIC_BASE_URL` to the tunnel URL.

### ⚠️ Gateway gotcha — User-Agent
The Sham Cash gateway's WAF returns **HTTP 403 "banned permanently"** for the
default `python-requests` User-Agent. The client sends a custom
`User-Agent: MedixPro-Agent/1.0` to avoid this. Don't remove it.

---

## 5. Sham Cash protocol notes (from `SC EPay Doc.pdf`)

- **Direct JWE**, `alg=dir`, `enc=A256GCM`, `cty=json`. Token layout:
  `header..iv.ciphertext.tag` (2nd segment always empty). The Base64url header is
  the AES-GCM **AAD**. Every payload carries `iat`/`exp` (5-min TTL) for replay
  protection.
- Requests: `{ "encData": <JWE>, "agentKey": <key> }`. Responses are **cleartext
  JSON** `{ result, succeeded, data, message }`. **HTTP 200 ≠ success** — always
  check `result`/`succeeded` (`2500` = success).
- Bill statuses: `1 pending`, `2 refund`, `3 expired`, `4 paid`, `5 partly refunded`.
- Bills **expire after 10 minutes**. Rely on the webhook; use `getBillInfo` only
  as a fallback after the safety window. `1704 (Bill No Already Exists)` on retry
  means the original bill was recorded — reconcile instead of failing.
- Webhooks are **encrypted** the same way and may be **retried** → processing is
  idempotent (keyed on `billNo`).

---

## 6. Monthly payout workflow

1. During the month, completed visits with a paid, non-refunded booking accrue.
2. Month end — admin runs either:
   - CLI: `python manage.py compute_payouts --year 2026 --month 7`, or
   - API: `GET /api/v1/payments/payouts/?year=2026&month=7` (also builds rows).
3. Each `PayoutSettlement` shows `handled_count` and `total_amount` owed.
4. Admin transfers the amount out-of-band, then marks it paid:
   `POST /api/v1/payments/payouts/` with `{settlement_id, paid_reference, note}`.

---

## 7. Verification status

- ✅ Unit + HTTP tests (12) pass: JWE round-trip/format/expiry/tamper, fee math,
  booking, webhook paid/expired, refund, payout aggregation, webhook HTTP view.
- ✅ **Live** `createBill` + `getBillInfo` against the Sham Cash dev server return
  `result=2500` with a real `paymentUrl` — confirms the encryption handshake.
- ✅ `flutter analyze` — 0 errors.

Run backend tests: `cd medixpro_backend && ./venv/bin/python manage.py test payments`

---

*Added 2026-07-20. Companion to `PROJECT_DOCUMENTATION.md` and `MIGRATION.md`.*
