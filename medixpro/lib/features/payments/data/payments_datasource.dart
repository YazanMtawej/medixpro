import '../../../core/network/api_client.dart';

/// A doctor a patient can book with, plus their pricing.
class DoctorOption {
  final int id;
  final String fullName;
  final String clinicName;
  final String? receiptAmount; // full consultation price (SYP)
  final String? bookingFee; // the % the patient actually pays now
  final int currencyId;
  final bool bookable;

  const DoctorOption({
    required this.id,
    required this.fullName,
    required this.clinicName,
    required this.receiptAmount,
    required this.bookingFee,
    required this.currencyId,
    required this.bookable,
  });

  factory DoctorOption.fromJson(Map<String, dynamic> j) => DoctorOption(
        id: j["id"] as int,
        fullName: (j["full_name"] ?? j["username"] ?? "Doctor").toString(),
        clinicName: (j["clinic_name"] ?? "").toString(),
        receiptAmount: j["receipt_amount"]?.toString(),
        bookingFee: j["booking_fee"]?.toString(),
        currencyId: (j["currency_id"] ?? 2) as int,
        bookable: (j["bookable"] ?? false) as bool,
      );
}

/// Result of initiating a booking payment.
class BookingPayment {
  final int paymentId;
  final int? requestId;
  final String billNo;
  final String amount;
  final int currencyId;
  final String paymentUrl;
  final String status;

  const BookingPayment({
    required this.paymentId,
    required this.requestId,
    required this.billNo,
    required this.amount,
    required this.currencyId,
    required this.paymentUrl,
    required this.status,
  });

  factory BookingPayment.fromJson(Map<String, dynamic> j) => BookingPayment(
        paymentId: j["payment_id"] as int,
        requestId: j["request_id"] as int?,
        billNo: (j["bill_no"] ?? "").toString(),
        amount: (j["amount"] ?? "").toString(),
        currencyId: (j["currency_id"] ?? 2) as int,
        paymentUrl: (j["payment_url"] ?? "").toString(),
        status: (j["status"] ?? "pending").toString(),
      );
}

class PaymentsDataSource {
  final ApiClient api;
  const PaymentsDataSource(this.api);

  Future<List<DoctorOption>> getDoctors() async {
    final res = await api.dio.get("doctors/");
    final List data = res.data["data"] as List? ?? [];
    return data
        .map((e) => DoctorOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create the payment-gated request + ShamCash bill, returning the payment_url.
  Future<BookingPayment> book({
    required int doctorId,
    required String title,
    required String type,
    required String preferredDateIso,
    String reason = "",
    String symptoms = "",
  }) async {
    final res = await api.dio.post("payments/book/", data: {
      "doctor": doctorId,
      "title": title,
      "type": type,
      "preferred_date": preferredDateIso,
      "reason": reason,
      "symptoms": symptoms,
    });
    final data = res.data["data"] as Map<String, dynamic>;
    return BookingPayment.fromJson(data);
  }

  /// Poll a payment's current status. Returns the raw payment status string,
  /// e.g. "pending" | "paid" | "expired" | "refunded" | "failed".
  Future<String> paymentStatus(int paymentId) async {
    final res = await api.dio.get("payments/$paymentId/status/");
    final data = res.data["data"] as Map<String, dynamic>?;
    return (data?["status"] ?? "pending").toString();
  }
}
