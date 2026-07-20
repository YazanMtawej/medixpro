import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/payments_datasource.dart';

/// Opens the ShamCash checkout for [payment], then shows a dialog that polls the
/// backend until the payment reaches a terminal state.
///
/// Returns true when the payment is confirmed paid, false otherwise.
Future<bool> runBookingPaymentFlow(
  BuildContext context,
  PaymentsDataSource ds,
  BookingPayment payment,
) async {
  // Open the ShamCash deep-link / web checkout. externalApplication lets the
  // ShamCash app take over when installed, otherwise it opens the web portal.
  final uri = Uri.tryParse(payment.paymentUrl);
  if (uri != null) {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore launch failures — the user can still retry from the dialog.
    }
  }

  if (!context.mounted) return false;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PaymentStatusDialog(ds: ds, payment: payment),
  );
  return result ?? false;
}

class _PaymentStatusDialog extends StatefulWidget {
  final PaymentsDataSource ds;
  final BookingPayment payment;
  const _PaymentStatusDialog({required this.ds, required this.payment});

  @override
  State<_PaymentStatusDialog> createState() => _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends State<_PaymentStatusDialog> {
  String _status = "pending";
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _status = widget.payment.status;
    // Poll every 4s; ShamCash bills expire after 10 minutes.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
    Future.delayed(const Duration(seconds: 2), _check);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isTerminal =>
      _status == "paid" ||
      _status == "expired" ||
      _status == "failed" ||
      _status == "refunded";

  Future<void> _check() async {
    if (_checking || !mounted) return;
    setState(() => _checking = true);
    try {
      final s = await widget.ds.paymentStatus(widget.payment.paymentId);
      if (!mounted) return;
      setState(() => _status = s);
      if (_isTerminal) {
        _timer?.cancel();
      }
    } catch (_) {
      // Transient error — keep polling.
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _reopen() async {
    final uri = Uri.tryParse(widget.payment.paymentUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    late final IconData icon;
    late final Color color;
    late final String title;
    late final String message;

    switch (_status) {
      case "paid":
        icon = Icons.check_circle_rounded;
        color = AppColors.success;
        title = "Payment confirmed";
        message = "Your booking request has been sent to the doctor.";
        break;
      case "expired":
        icon = Icons.timer_off_rounded;
        color = AppColors.error;
        title = "Payment expired";
        message = "The payment window closed. Please try booking again.";
        break;
      case "failed":
        icon = Icons.error_rounded;
        color = AppColors.error;
        title = "Payment failed";
        message = "We couldn't process the payment. Please try again.";
        break;
      case "refunded":
        icon = Icons.replay_circle_filled_rounded;
        color = AppColors.warning;
        title = "Payment refunded";
        message = "This payment was refunded.";
        break;
      default:
        icon = Icons.hourglass_top_rounded;
        color = AppColors.primary;
        title = "Waiting for payment";
        message =
            "Complete the payment of ${widget.payment.amount} SYP in ShamCash. "
            "This screen updates automatically.";
    }

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Icon(icon, color: color, size: 56),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          if (!_isTerminal) ...[
            const SizedBox(height: 18),
            const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4)),
          ],
        ],
      ),
      actions: _isTerminal
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context, _status == "paid"),
                child: const Text("Done"),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: _reopen,
                child: const Text("Reopen payment"),
              ),
              FilledButton(
                onPressed: _checking ? null : _check,
                child: const Text("I've paid"),
              ),
            ],
    );
  }
}
