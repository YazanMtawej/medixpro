import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment.dart';
import '../appointment_l10n.dart';
import '../cubit/appointments_cubit.dart';
import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';

class AddAppointmentPage extends StatefulWidget {
  final int? preselectedPatientId;
  const AddAppointmentPage({super.key, this.preselectedPatientId});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey            = GlobalKey<FormState>();
  final _titleController    = TextEditingController();
  final _reasonController   = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController    = TextEditingController();
  final _durationController = TextEditingController(text: "30");

  int?       _selectedPatientId;
  String     _type   = "general";
  String     _status = "scheduled";
  DateTime?  _date;
  TimeOfDay? _time;
  DateTime?  _followUpDate;
  bool       _isLoading = false;

  static const _typeKeys = [
    "general",
    "follow_up",
    "consultation",
    "emergency",
    "lab_results",
    "procedure",
    "vaccination",
  ];

  static const _statusKeys = [
    "scheduled",
    "completed",
    "cancelled",
    "no_show",
    "rescheduled",
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.preselectedPatientId;
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectDateAndTime),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dateTime = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );

    final appointment = Appointment(
      id:              0,
      patientId:       _selectedPatientId!,
      patientName:     "",
      patientPhone:    "",
      patientAge:      0,
      title:           _titleController.text.trim(),
      type:            _type,
      dateTime:        dateTime,
      durationMinutes: int.tryParse(_durationController.text) ?? 30,
      status:          _status,
      reason:          _reasonController.text.trim(),
      symptoms:        _symptomsController.text.trim(),
      diagnosis:       "",
      notes:           _notesController.text.trim(),
      followUpDate:    _followUpDate?.toIso8601String().split("T")[0],
    );

    await context.read<AppointmentsCubit>().addNewAppointment(appointment);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.newAppointment,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? AppColors.gradientDark
                  : AppColors.gradientLight,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Patient ─────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: BlocBuilder<PatientsCubit, PatientsState>(
                builder: (context, state) {
                  if (state is! PatientsLoaded) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<int>(
                    value: _selectedPatientId,
                    hint: Text(l10n.selectPatient),
                    decoration:
                        _decor(l10n.patientLabel, Icons.person_outline),
                    items: state.patients
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedPatientId = v),
                    validator: (v) =>
                        v == null ? l10n.pleaseSelectPatient : null,
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ─── Appointment Info ─────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                children: [
                  _field(_titleController, l10n.appointmentTitle,
                      icon: Icons.title, required: true),
                  const SizedBox(height: 12),
                  _dropdown(l10n.typeLabel, Icons.category_outlined, _type,
                      _typeKeys, (k) => appointmentTypeLabel(context, k),
                      (v) => setState(() => _type = v!)),
                  const SizedBox(height: 12),
                  _dropdown(l10n.status, Icons.flag_outlined, _status,
                      _statusKeys, (k) => appointmentStatusLabel(context, k),
                      (v) => setState(() => _status = v!)),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ─── Date & Time ──────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _datePicker(
                          l10n.dateLabel,
                          Icons.calendar_today_outlined,
                          _date,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime(2030),
                          onPicked: (d) => setState(() => _date = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timePicker(
                          _time,
                          (t) => setState(() => _time = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(_durationController, l10n.durationMinutesLabel,
                      icon: Icons.timelapse_outlined, numeric: true),
                  const SizedBox(height: 12),
                  _datePicker(
                    l10n.followUpDateOptional,
                    Icons.event_repeat_outlined,
                    _followUpDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    onPicked: (d) => setState(() => _followUpDate = d),
                    optional: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ─── Clinical Info ────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(l10n.clinicalInformation),
                  const SizedBox(height: 12),
                  _field(_reasonController, l10n.reasonForVisit,
                      icon: Icons.help_outline, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_symptomsController, l10n.symptoms,
                      icon: Icons.sick_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_notesController, l10n.doctorNotes,
                      icon: Icons.note_outlined, maxLines: 3),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(l10n.saveAppointment,
                        style: const TextStyle(fontSize: 16)),
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ));
  }

  Widget _field(
    TextEditingController c,
    String label, {
    IconData? icon,
    bool required = false,
    bool numeric = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: _decor(label, icon),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
              ? AppLocalizations.of(context).requiredField
              : null
          : null,
    );
  }

  Widget _dropdown(
    String label,
    IconData icon,
    String value,
    List<String> keys,
    String Function(String) labelOf,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _decor(label, icon),
      items: keys
          .map((k) => DropdownMenuItem(value: k, child: Text(labelOf(k))))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _datePicker(
    String label,
    IconData icon,
    DateTime? date, {
    required DateTime firstDate,
    required DateTime lastDate,
    required void Function(DateTime) onPicked,
    bool optional = false,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: _decor(label, icon),
        child: Text(
          date == null
              ? (optional
                  ? AppLocalizations.of(context).notSet
                  : AppLocalizations.of(context).selectShort)
              : date.toIso8601String().split("T")[0],
          style: TextStyle(
            color: date == null ? Colors.grey : null,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _timePicker(
      TimeOfDay? time, void Function(TimeOfDay) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: _decor(AppLocalizations.of(context).timeLabel, Icons.access_time_outlined),
        child: Text(
          time == null ? AppLocalizations.of(context).selectShort : time.format(context),
          style: TextStyle(color: time == null ? Colors.grey : null,
              fontSize: 14),
        ),
      ),
    );
  }

  InputDecoration _decor(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}