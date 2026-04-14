import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/report.dart';
import '../cubit/reports_cubit.dart';
import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';
import '../../../appointments/presentation/cubit/appointments_cubit.dart';
import '../../../appointments/presentation/cubit/appointments_state.dart';
import '../../../medications/presentation/cubit/medications_cubit.dart';

class EditReportPage extends StatefulWidget {
  final Report report;
  const EditReportPage({super.key, required this.report});

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _chiefComplaintCtrl;
  late final TextEditingController _historyCtrl;
  late final TextEditingController _examinationCtrl;
  late final TextEditingController _diagnosisCtrl;
  late final TextEditingController _treatmentCtrl;
  late final TextEditingController _notesCtrl;

  late int      _patientId;
  int?          _appointmentId;
  late List<int> _selectedMedIds;
  late String   _status;
  DateTime?     _followUpDate;
  bool          _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.report;
    _titleCtrl          = TextEditingController(text: r.title);
    _chiefComplaintCtrl = TextEditingController(text: r.chiefComplaint);
    _historyCtrl        = TextEditingController(text: r.history);
    _examinationCtrl    = TextEditingController(text: r.examination);
    _diagnosisCtrl      = TextEditingController(text: r.diagnosis);
    _treatmentCtrl      = TextEditingController(text: r.treatmentPlan);
    _notesCtrl          = TextEditingController(text: r.notes);
    _patientId          = r.patientId;
    _appointmentId      = r.appointmentId;
    _selectedMedIds     = List.from(r.medicationIds);
    _status             = r.status;
    if (r.followUpDate != null && r.followUpDate!.isNotEmpty) {
      _followUpDate = DateTime.tryParse(r.followUpDate!);
    }
    context.read<PatientsCubit>().loadPatients();
    context.read<AppointmentsCubit>()
        .fetchAppointments(patientId: _patientId);
    context.read<MedicationsCubit>()
        .fetchMedications(patientId: _patientId);
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _chiefComplaintCtrl, _historyCtrl,
      _examinationCtrl, _diagnosisCtrl, _treatmentCtrl, _notesCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updated = widget.report.copyWith(
      patientId:     _patientId,
      appointmentId: _appointmentId,
      medicationIds: _selectedMedIds,
      title:         _titleCtrl.text.trim(),
      status:        _status,
      chiefComplaint: _chiefComplaintCtrl.text.trim(),
      history:       _historyCtrl.text.trim(),
      examination:   _examinationCtrl.text.trim(),
      diagnosis:     _diagnosisCtrl.text.trim(),
      treatmentPlan: _treatmentCtrl.text.trim(),
      notes:         _notesCtrl.text.trim(),
      followUpDate:  _followUpDate?.toIso8601String().split("T")[0],
    );

    await context.read<ReportsCubit>().editReport(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Edit Report",
            style: TextStyle(fontWeight: FontWeight.w700)),
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
            _card(isDark: isDark,
              child: BlocBuilder<PatientsCubit, PatientsState>(
                builder: (context, state) {
                  if (state is! PatientsLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<int>(
                    value: _patientId,
                    decoration: _decor("Patient", Icons.person_outline),
                    items: state.patients
                        .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _patientId      = v;
                        _appointmentId  = null;
                        _selectedMedIds = [];
                      });
                      context.read<AppointmentsCubit>()
                          .fetchAppointments(patientId: v);
                      context.read<MedicationsCubit>()
                          .fetchMedications(patientId: v);
                    },
                    validator: (v) =>
                        v == null ? "Please select a patient" : null,
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            _card(isDark: isDark,
              child: Column(children: [
                _field(_titleCtrl, "Report Title",
                    icon: Icons.title, required: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: _decor("Status", Icons.flag_outlined),
                  items: const [
                    DropdownMenuItem(value: "draft", child: Text("Draft")),
                    DropdownMenuItem(value: "final", child: Text("Final")),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ]),
            ),

            const SizedBox(height: 14),
 _card(
              isDark: isDark,
              child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
                builder: (context, state) {
                  final items = state is AppointmentsLoaded
                      ? state.appointments
                      : <dynamic>[];

                  // إزالة التكرار
                  final uniqueItems = {
                    for (var a in items) a.id: a
                  }.values.toList();

                  // حماية من crash
                  final safeValue =
                      uniqueItems.any((a) => a.id == _appointmentId)
                          ? _appointmentId
                          : null;

                  return DropdownButtonFormField<int?>(
                    value: safeValue,
                    decoration: _decor(
                      "Linked Appointment (optional)",
                      Icons.calendar_month_outlined,
                    ),
                    hint: const Text("Select appointment"),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("None"),
                      ),
                      ...uniqueItems.map((a) => DropdownMenuItem<int>(
                            value: a.id,
                            child: Text(
                              a.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: (v) =>
                        setState(() => _appointmentId = v),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            _card(isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prescribed Medications",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 10),
                  BlocBuilder<MedicationsCubit, MedicationsState>(
                    builder: (context, state) {
                      if (state is! MedicationsLoaded ||
                          state.medications.isEmpty) {
                        return Text("No medications for this patient",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ));
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: state.medications.map((m) {
                          final selected = _selectedMedIds.contains(m.id);
                          return FilterChip(
                            label: Text("${m.name} (${m.dosage})",
                                style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  _selectedMedIds.add(m.id);
                                } else {
                                  _selectedMedIds.remove(m.id);
                                }
                              });
                            },
                            selectedColor:
                                AppColors.primary.withOpacity(0.15),
                            checkmarkColor: AppColors.primary,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Clinical Details",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _field(_chiefComplaintCtrl, "Chief Complaint",
                      icon: Icons.help_outline, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_historyCtrl, "Medical History",
                      icon: Icons.history, maxLines: 3),
                  const SizedBox(height: 12),
                  _field(_examinationCtrl, "Physical Examination",
                      icon: Icons.search, maxLines: 3),
                  const SizedBox(height: 12),
                  _field(_diagnosisCtrl, "Diagnosis",
                      icon: Icons.medical_information_outlined,
                      required: true,
                      maxLines: 3),
                  const SizedBox(height: 12),
                  _field(_treatmentCtrl, "Treatment Plan",
                      icon: Icons.healing_outlined, maxLines: 3),
                  const SizedBox(height: 12),
                  _field(_notesCtrl, "Doctor Notes",
                      icon: Icons.note_outlined, maxLines: 3),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _followUpDate ??
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _followUpDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: _decor("Follow-up Date (optional)",
                          Icons.event_repeat_outlined),
                      child: Text(
                        _followUpDate == null
                            ? "Not set"
                            : _followUpDate!
                                .toIso8601String()
                                .split("T")[0],
                        style: TextStyle(
                            color:
                                _followUpDate == null ? Colors.grey : null,
                            fontSize: 14),
                      ),
                    ),
                  ),
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
                    : const Text("Update Report",
                        style: TextStyle(fontSize: 16)),
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

  Widget _card({required bool isDark, required Widget child}) =>
      Container(
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
              : [BoxShadow(color: Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: child,
      );

  Widget _field(TextEditingController c, String label,
      {IconData? icon, bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: _decor(label, icon),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
          : null,
    );
  }

  InputDecoration _decor(String label, IconData? icon) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );
}