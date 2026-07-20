"""
Sham Cash (ShamCash / SandLogix) E-Payment client.

Implements the "Direct JWE" (AES-GCM 256-bit) security scheme described in the
SC E-Pay integration document (v1.0.0) and the four ElectronicPayment endpoints:
createBill, getBillInfo, refundBill, getTransactions.

Security note: the AES ``secretKey`` authorises the entire agent account and MUST
stay server-side. Never ship it to the Flutter app or any client.
"""
from __future__ import annotations

import base64
import json
import os
import time
import logging
from dataclasses import dataclass
from typing import Any

import requests
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from django.conf import settings

logger = logging.getLogger("payments")

# Exact JWE header required by ShamCash for Direct AES-GCM. It is also used, byte
# for byte, as the Additional Authenticated Data (AAD) during encryption.
_JWE_HEADER = '{"alg":"dir","enc":"A256GCM","cty":"json"}'

# ShamCash bill status ids (section 6.3 "Bill Status Codes").
STATUS_PENDING = 1
STATUS_REFUND = 2          # fully refunded
STATUS_EXPIRED = 3
STATUS_PAID = 4
STATUS_PARTLY_REFUNDED = 5

# Application response codes we handle explicitly (section 7.1).
CODE_SUCCESS = 2500
CODE_BILL_ALREADY_EXISTS = 1704
CODE_ORIGIN_NOT_PAID = 1707
CODE_REFUND_EXCEEDS = 1708

# Token freshness. The doc recommends exp = iat + 5 minutes.
_TOKEN_TTL_SECONDS = 5 * 60
# Reject inbound (webhook) tokens whose exp is this far in the past, to allow a
# little clock skew while still enforcing replay protection.
_CLOCK_SKEW_SECONDS = 60


def _b64url_encode(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")


def _b64url_decode(data: str) -> bytes:
    padding = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + padding)


class ShamCashError(Exception):
    """Raised for transport failures or non-success application responses."""

    def __init__(self, message: str, *, code: int | None = None, http_status: int | None = None):
        super().__init__(message)
        self.message = message
        self.code = code
        self.http_status = http_status


@dataclass
class ShamCashResponse:
    result: int | None
    succeeded: bool
    data: Any
    message: str

    @property
    def ok(self) -> bool:
        return bool(self.succeeded)


class ShamCashClient:
    """Thin, self-contained client. One instance per process is fine."""

    def __init__(
        self,
        base_url: str | None = None,
        agent_key: str | None = None,
        secret_key_b64: str | None = None,
        timeout: int = 20,
    ):
        self.base_url = (base_url or settings.SHAMCASH_BASE_URL).rstrip("/")
        self.agent_key = agent_key or settings.SHAMCASH_AGENT_KEY
        secret_b64 = secret_key_b64 or settings.SHAMCASH_SECRET_KEY
        # The secretKey is a Base64 string encoding exactly 32 raw bytes. Decode
        # to raw binary — do NOT utf-8 encode the base64 string itself.
        self._key = base64.b64decode(secret_b64)
        if len(self._key) != 32:
            raise ShamCashError(
                f"SHAMCASH_SECRET_KEY must decode to 32 bytes, got {len(self._key)}"
            )
        self.timeout = timeout
        # The gateway's WAF rejects the default "python-requests" User-Agent with
        # an HTTP 403 ban page, so send an explicit, well-behaved UA.
        self._session = requests.Session()
        self._session.headers.update({
            "User-Agent": "MedixPro-Agent/1.0",
            "Accept": "application/json",
            "Content-Type": "application/json",
        })

    # ─── JWE (Direct A256GCM) ─────────────────────────────────────────────
    def encrypt(self, payload: dict) -> str:
        """Serialise ``payload`` (with iat/exp claims injected) into a JWE token."""
        now = int(time.time())
        body = dict(payload)
        body.setdefault("iat", now)
        body.setdefault("exp", now + _TOKEN_TTL_SECONDS)

        header_b64 = _b64url_encode(_JWE_HEADER.encode("ascii"))
        aad = header_b64.encode("ascii")
        plaintext = json.dumps(body, separators=(",", ":")).encode("utf-8")

        iv = os.urandom(12)
        ct_and_tag = AESGCM(self._key).encrypt(iv, plaintext, aad)
        ciphertext, tag = ct_and_tag[:-16], ct_and_tag[-16:]

        # Direct encryption → the EncryptedKey (2nd) segment is always empty.
        return ".".join([
            header_b64,
            "",
            _b64url_encode(iv),
            _b64url_encode(ciphertext),
            _b64url_encode(tag),
        ])

    def decrypt(self, token: str) -> dict:
        """Decrypt an inbound JWE (webhook payload) and enforce the exp claim."""
        parts = token.split(".")
        if len(parts) != 5:
            raise ShamCashError("Malformed JWE token")
        header_b64, _enc_key, iv_b64, ct_b64, tag_b64 = parts

        try:
            header = json.loads(_b64url_decode(header_b64))
        except Exception as exc:  # noqa: BLE001
            raise ShamCashError("Invalid JWE header") from exc
        if header.get("alg") != "dir" or header.get("enc") != "A256GCM":
            raise ShamCashError("Unexpected JWE algorithm")

        aad = header_b64.encode("ascii")
        iv = _b64url_decode(iv_b64)
        ciphertext = _b64url_decode(ct_b64)
        tag = _b64url_decode(tag_b64)
        try:
            plaintext = AESGCM(self._key).decrypt(iv, ciphertext + tag, aad)
        except Exception as exc:  # noqa: BLE001
            raise ShamCashError("JWE decryption/authentication failed") from exc

        body = json.loads(plaintext.decode("utf-8"))
        exp = body.get("exp")
        if exp is not None and int(time.time()) > int(exp) + _CLOCK_SKEW_SECONDS:
            raise ShamCashError("JWE token expired (possible replay)")
        return body

    # ─── HTTP ─────────────────────────────────────────────────────────────
    def _post(self, endpoint: str, payload: dict) -> ShamCashResponse:
        url = f"{self.base_url}/api/ElectronicPayment/{endpoint}"
        body = {"encData": self.encrypt(payload), "agentKey": self.agent_key}
        try:
            resp = self._session.post(url, json=body, timeout=self.timeout)
        except requests.RequestException as exc:
            logger.error("ShamCash %s transport error: %s", endpoint, exc)
            raise ShamCashError(f"Network error calling ShamCash: {exc}") from exc

        # An HTTP 200 does NOT mean success — inspect the JSON `result` field.
        try:
            parsed = resp.json()
        except ValueError as exc:
            logger.error("ShamCash %s non-JSON response (HTTP %s): %s",
                         endpoint, resp.status_code, resp.text[:500])
            raise ShamCashError(
                f"ShamCash returned non-JSON (HTTP {resp.status_code})",
                http_status=resp.status_code,
            ) from exc

        result = ShamCashResponse(
            result=parsed.get("result"),
            succeeded=bool(parsed.get("succeeded")),
            data=parsed.get("data"),
            message=parsed.get("message", ""),
        )
        logger.info("ShamCash %s → result=%s succeeded=%s msg=%s",
                    endpoint, result.result, result.succeeded, result.message)
        return result

    # ─── Endpoints ────────────────────────────────────────────────────────
    def create_bill(
        self,
        *,
        bill_no: str,
        amount,
        callback_url: str,
        redirect_url: str,
        currency_id: int | None = None,
        note: str = "",
    ) -> ShamCashResponse:
        payload = {
            "billNo": bill_no,
            "amount": float(amount),
            "currencyId": currency_id if currency_id is not None else settings.SHAMCASH_CURRENCY_ID,
            "callbackUrl": callback_url,
            "redirectUrl": redirect_url,
        }
        if note:
            payload["note"] = note[:250]
        return self._post("createBill", payload)

    def get_bill_info(self, bill_no: str) -> ShamCashResponse:
        return self._post("getBillInfo", {"billNo": bill_no})

    def refund_bill(self, *, bill_no: str, amount, idempotency_key: str, note: str = "") -> ShamCashResponse:
        payload = {
            "billNo": bill_no,
            "amount": float(amount),
            "idempotencyKey": idempotency_key,
        }
        if note:
            payload["note"] = note[:250]
        return self._post("refundBill", payload)

    def get_transactions(
        self,
        *,
        from_date: str | None = None,
        to_date: str | None = None,
        after_tran_id: int = 0,
        limit: int = 500,
    ) -> ShamCashResponse:
        payload = {"afterTranId": after_tran_id, "limit": limit}
        if from_date:
            payload["fromDate"] = from_date
        if to_date:
            payload["toDate"] = to_date
        return self._post("getTransactions", payload)


# Module-level singleton for convenience.
_client: ShamCashClient | None = None


def get_client() -> ShamCashClient:
    global _client
    if _client is None:
        _client = ShamCashClient()
    return _client
