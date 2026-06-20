import 'package:flutter/widgets.dart';
import 'package:medixpro/l10n/app_localizations.dart';

/// Maps backend appointment status/type codes to localized display labels.
/// Keeps the (data code → label) mapping in one place for every appointment
/// screen.
String appointmentStatusLabel(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  switch (code) {
    case "scheduled":
      return l10n.statusScheduled;
    case "completed":
      return l10n.statusCompleted;
    case "cancelled":
      return l10n.statusCancelled;
    case "pending":
      return l10n.statusPending;
    case "no_show":
      return l10n.statusNoShow;
    case "rescheduled":
      return l10n.statusRescheduled;
    default:
      return code;
  }
}

String appointmentRequestStatusLabel(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  switch (code) {
    case "pending":
      return l10n.statusPending;
    case "accepted":
      return l10n.statusAccepted;
    case "rejected":
      return l10n.statusRejected;
    case "suggested":
      return l10n.statusSuggested;
    default:
      return code;
  }
}

/// Patient-facing request status label (includes a leading emoji).
String patientRequestStatusLabel(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  switch (code) {
    case "pending":
      return l10n.patientReqStatusPending;
    case "accepted":
      return l10n.patientReqStatusAccepted;
    case "rejected":
      return l10n.patientReqStatusRejected;
    case "suggested":
      return l10n.patientReqStatusSuggested;
    default:
      return code;
  }
}

String appointmentTypeLabel(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  switch (code) {
    case "general":
      return l10n.typeGeneral;
    case "follow_up":
      return l10n.typeFollowUp;
    case "consultation":
      return l10n.typeConsultation;
    case "emergency":
      return l10n.typeEmergency;
    case "lab_results":
      return l10n.typeLabResults;
    case "procedure":
      return l10n.typeProcedure;
    case "vaccination":
      return l10n.typeVaccination;
    default:
      return code;
  }
}
