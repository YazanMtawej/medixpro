import base64
import time
from decimal import Decimal
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import TestCase, override_settings, Client
from django.utils import timezone

from appointments.models import Appointment, AppointmentRequest
from patients.models import Patient
from users.models import Profile
from .models import Payment
from . import services
from .shamcash import ShamCashClient, ShamCashError, ShamCashResponse

User = get_user_model()

# A valid Base64-encoded 32-byte key for tests.
TEST_KEY_B64 = base64.b64encode(b"0123456789abcdef0123456789abcdef").decode()


class JWECryptoTests(TestCase):
    def setUp(self):
        self.client_ = ShamCashClient(
            base_url="https://example.test/services",
            agent_key="AGENT",
            secret_key_b64=TEST_KEY_B64,
        )

    def test_token_has_five_parts_with_empty_encrypted_key(self):
        token = self.client_.encrypt({"billNo": "BN-1", "amount": 10.5})
        parts = token.split(".")
        self.assertEqual(len(parts), 5)
        self.assertEqual(parts[1], "", "Direct JWE must leave the EncryptedKey segment empty")

    def test_round_trip(self):
        token = self.client_.encrypt({"billNo": "BN-1", "statusId": 4, "tranId": 99})
        body = self.client_.decrypt(token)
        self.assertEqual(body["billNo"], "BN-1")
        self.assertEqual(body["statusId"], 4)
        self.assertIn("iat", body)
        self.assertIn("exp", body)

    def test_expired_token_rejected(self):
        # Craft a token whose exp is well in the past.
        past = int(time.time()) - 10_000
        token = self.client_.encrypt({"billNo": "BN-1", "iat": past, "exp": past + 1})
        with self.assertRaises(ShamCashError):
            self.client_.decrypt(token)

    def test_tampered_token_fails_authentication(self):
        token = self.client_.encrypt({"billNo": "BN-1"})
        header, _, iv, ct, tag = token.split(".")
        # Flip a character in the ciphertext.
        bad_ct = ("A" if ct[0] != "A" else "B") + ct[1:]
        tampered = ".".join([header, "", iv, bad_ct, tag])
        with self.assertRaises(ShamCashError):
            self.client_.decrypt(tampered)


@override_settings(PLATFORM_FEE_RATE="0.20", SHAMCASH_CURRENCY_ID=2)
class FeeMathTests(TestCase):
    def test_fee_is_20_percent_two_decimals(self):
        self.assertEqual(services.fee_for(Decimal("10000")), Decimal("2000.00"))
        self.assertEqual(services.fee_for(Decimal("2501")), Decimal("500.20"))


@override_settings(PLATFORM_FEE_RATE="0.20", SHAMCASH_CURRENCY_ID=2)
class BookingFlowTests(TestCase):
    def setUp(self):
        self.doctor = User.objects.create_user("doc", "doc@x.com", "pw", role=User.Role.DOCTOR)
        Profile.objects.create(user=self.doctor, receipt_amount=Decimal("10000"))
        self.patient_user = User.objects.create_user("pat", "pat@x.com", "pw", role=User.Role.PATIENT)
        self.patient = Patient.objects.create(
            user=self.patient_user, name="Pat", age=30, phone="1", gender="male", email="pat@x.com"
        )

    def _fake_create_bill(self, **kwargs):
        return ShamCashResponse(
            result=2500, succeeded=True,
            data={"statusId": 1, "statusName": "pending", "billNo": kwargs["bill_no"],
                  "paymentUrl": "https://pay.example/abc", "tranId": None, "refunds": []},
            message="Success",
        )

    @patch("payments.shamcash.ShamCashClient.create_bill")
    def test_book_creates_hidden_request_and_pending_payment(self, mock_create):
        mock_create.side_effect = lambda **kw: self._fake_create_bill(**kw)

        payment = services.create_booking_payment(
            patient_user=self.patient_user,
            doctor_user=self.doctor,
            request_data={"title": "Checkup", "type": "general",
                          "preferred_date": timezone.now(), "reason": "", "symptoms": ""},
        )
        self.assertEqual(payment.amount, Decimal("2000.00"))
        self.assertEqual(payment.status, Payment.Status.PENDING)
        self.assertTrue(payment.payment_url.startswith("https://pay.example"))
        req = payment.appointment_request
        self.assertTrue(req.awaiting_payment, "request must be hidden until paid")
        self.assertEqual(req.doctor, self.doctor)

    @patch("payments.shamcash.ShamCashClient.create_bill")
    def test_webhook_paid_reveals_request(self, mock_create):
        mock_create.side_effect = lambda **kw: self._fake_create_bill(**kw)
        payment = services.create_booking_payment(
            patient_user=self.patient_user, doctor_user=self.doctor,
            request_data={"title": "Checkup", "type": "general",
                          "preferred_date": timezone.now(), "reason": "", "symptoms": ""},
        )
        services.apply_webhook({"billNo": payment.bill_no, "statusId": 4, "tranId": 555})
        payment.refresh_from_db()
        self.assertEqual(payment.status, Payment.Status.PAID)
        self.assertEqual(payment.tran_id, 555)
        payment.appointment_request.refresh_from_db()
        self.assertFalse(payment.appointment_request.awaiting_payment)

    @patch("payments.shamcash.ShamCashClient.create_bill")
    def test_webhook_expired_discards_request(self, mock_create):
        mock_create.side_effect = lambda **kw: self._fake_create_bill(**kw)
        payment = services.create_booking_payment(
            patient_user=self.patient_user, doctor_user=self.doctor,
            request_data={"title": "Checkup", "type": "general",
                          "preferred_date": timezone.now(), "reason": "", "symptoms": ""},
        )
        req_id = payment.appointment_request_id
        services.apply_webhook({"billNo": payment.bill_no, "statusId": 3, "tranId": None})
        payment.refresh_from_db()
        self.assertEqual(payment.status, Payment.Status.EXPIRED)
        self.assertFalse(AppointmentRequest.objects.filter(id=req_id).exists())

    @patch("payments.shamcash.ShamCashClient.refund_bill")
    @patch("payments.shamcash.ShamCashClient.create_bill")
    def test_refund_marks_payment_refunded(self, mock_create, mock_refund):
        mock_create.side_effect = lambda **kw: self._fake_create_bill(**kw)
        mock_refund.side_effect = lambda **kw: ShamCashResponse(
            result=2500, succeeded=True, data={"tranId": 777}, message="Success")

        payment = services.create_booking_payment(
            patient_user=self.patient_user, doctor_user=self.doctor,
            request_data={"title": "Checkup", "type": "general",
                          "preferred_date": timezone.now(), "reason": "", "symptoms": ""},
        )
        services.apply_webhook({"billNo": payment.bill_no, "statusId": 4, "tranId": 555})
        payment.refresh_from_db()

        services.refund_payment(payment, "test refund")
        payment.refresh_from_db()
        self.assertEqual(payment.status, Payment.Status.REFUNDED)
        self.assertEqual(payment.refund_tran_id, 777)
        self.assertEqual(payment.refunded_amount, Decimal("2000.00"))

    @patch("payments.shamcash.ShamCashClient.create_bill")
    def test_payout_counts_completed_paid_visits(self, mock_create):
        mock_create.side_effect = lambda **kw: self._fake_create_bill(**kw)
        payment = services.create_booking_payment(
            patient_user=self.patient_user, doctor_user=self.doctor,
            request_data={"title": "Checkup", "type": "general",
                          "preferred_date": timezone.now(), "reason": "", "symptoms": ""},
        )
        services.apply_webhook({"billNo": payment.bill_no, "statusId": 4, "tranId": 555})

        req = payment.appointment_request
        req.refresh_from_db()
        appt = Appointment.objects.create(
            patient=self.patient, title="Checkup", type="general",
            date_time=timezone.now(), status=Appointment.Status.COMPLETED,
        )
        req.appointment = appt
        req.status = AppointmentRequest.Status.ACCEPTED
        req.save()

        now = timezone.now()
        rows = services.compute_payouts(now.year, now.month)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["handled_count"], 1)
        self.assertEqual(rows[0]["total_amount"], Decimal("2000.00"))


@override_settings(
    PLATFORM_FEE_RATE="0.20",
    SHAMCASH_CURRENCY_ID=2,
    SHAMCASH_SECRET_KEY=TEST_KEY_B64,
    SHAMCASH_AGENT_KEY="AGENT",
)
class WebhookEndpointTests(TestCase):
    """The webhook HTTP view must decrypt a genuine JWE and update the payment."""

    def setUp(self):
        self.doctor = User.objects.create_user("doc2", "doc2@x.com", "pw", role=User.Role.DOCTOR)
        Profile.objects.create(user=self.doctor, receipt_amount=Decimal("5000"))
        self.patient_user = User.objects.create_user("pat2", "pat2@x.com", "pw", role=User.Role.PATIENT)
        self.patient = Patient.objects.create(
            user=self.patient_user, name="Pat2", age=40, phone="2", gender="male", email="pat2@x.com"
        )
        self.payment = Payment.objects.create(
            patient=self.patient_user, doctor=self.doctor, bill_no="MEDIX-WH-1",
            receipt_amount=Decimal("5000"), amount=Decimal("1000.00"),
            currency_id=2, status=Payment.Status.PENDING,
        )

    def _reset_client_singleton(self):
        # Force the module singleton to rebuild with the overridden test key.
        from payments import shamcash
        shamcash._client = None

    def test_webhook_paid_via_http(self):
        self._reset_client_singleton()
        from payments.shamcash import ShamCashClient
        enc = ShamCashClient(secret_key_b64=TEST_KEY_B64).encrypt(
            {"billNo": "MEDIX-WH-1", "statusId": 4, "tranId": 4242}
        )
        resp = Client().post(
            "/api/v1/payments/webhook/shamcash/",
            data={"encData": enc}, content_type="application/json",
        )
        self.assertEqual(resp.status_code, 200)
        self.payment.refresh_from_db()
        self.assertEqual(self.payment.status, Payment.Status.PAID)
        self.assertEqual(self.payment.tran_id, 4242)
        self._reset_client_singleton()

    def test_webhook_rejects_garbage(self):
        self._reset_client_singleton()
        resp = Client().post(
            "/api/v1/payments/webhook/shamcash/",
            data={"encData": "not-a-valid-jwe"}, content_type="application/json",
        )
        self.assertEqual(resp.status_code, 400)
        self._reset_client_singleton()
