import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment.dart';
import '../cubit/appointments_cubit.dart';
import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment appointment;
  const EditAppointmentPage({super.key, required this.appointment});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _reasonController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _notesController;
  late final TextEditingController _durationController;

  late int      _selectedPatientId;
  late String   _type;
  late String   _status;
  late DateTime _date;
  late TimeOfDay _time;
  DateTime?     _followUpDate;
  bool          _isLoading = false;

  static const _types = {
    "general":      "General Checkup",
    "follow_up":    "Follow Up",
    "consultation": "Consultation",
    "emergency":    "Emergency",
    "lab_results":  "Lab Results Review",
    "procedure":    "Procedure",
    "vaccination":  "Vaccination",
  };

  static const _statuses = {
    "scheduled":   "Scheduled",
    "completed":   "Completed",
    "cancelled":   "Cancelled",
    "no_show":     "No Show",
    "rescheduled": "Rescheduled",
  };

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    _titleController    = TextEditingController(text: a.title);
    _reasonController   = TextEditingController(text: a.reason);
    _symptomsController = TextEditingController(text: a.symptoms);
    _diagnosisController = TextEditingController(text: a.diagnosis);
    _notesController    = TextEditingController(text: a.notes);
    _durationController =
        TextEditingController(text: a.durationMinutes.toString());
    _selectedPatientId  = a.patientId;
    _type   = _types.containsKey(a.type) ? a.type : "general";
    _status = _statuses.containsKey(a.status) ? a.status : "scheduled";
    _date   = a.dateTime.toLocal();
    _time   = TimeOfDay.fromDateTime(a.dateTime.toLocal());
    if (a.followUpDate != null && a.followUpDate!.isNotEmpty) {
      _followUpDate = DateTime.tryParse(a.followUpDate!);
    }
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final dateTime = DateTime(
      _date.year, _date.month, _date.day,
      _time.hour, _time.minute,
    );

    final updated = widget.appointment.copyWith(
      patientId:       _selectedPatientId,
      title:           _titleController.text.trim(),
      type:            _type,
      dateTime:        dateTime,
      durationMinutes: int.tryParse(_durationController.text) ?? 30,
      status:          _status,
      reason:          _reasonController.text.trim(),
      symptoms:        _symptomsController.text.trim(),
      diagnosis:       _diagnosisController.text.trim(),
      notes:           _notesController.text.trim(),
      followUpDate:    _followUpDate?.toIso8601String().split("T")[0],
    );

    await context.read<AppointmentsCubit>().editAppointment(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Edit Appointment",
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
                    value: _selectedPatientId,
                    decoration: _decor("Patient", Icons.person_outline),
                    items: state.patients
                        .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedPatientId = v!),
                    validator: (v) =>
                        v == null ? "Please select a patient" : null,
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            _card(isDark: isDark,
              child: Column(children: [
                _field(_titleController, "Appointment Title",
                    icon: Icons.title, required: true),
                const SizedBox(height: 12),
                _dropdown("Type", Icons.category_outlined, _type,
                    _types, (v) => setState(() => _type = v!)),
                const SizedBox(height: 12),
                _dropdown("Status", Icons.flag_outlined, _status,
                    _statuses, (v) => setState(() => _status = v!)),
              ]),
            ),

            const SizedBox(height: 14),

            _card(isDark: isDark,
              child: Column(children: [
                Row(children: [
                  Expanded(child: _datePicker(
                    "Date", Icons.calendar_today_outlined, _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onPicked: (d) => setState(() => _date = d),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _timePicker(
                    _time, (t) => setState(() => _time = t))),
                ]),
                const SizedBox(height: 12),
                _field(_durationController, "Duration (minutes)",
                    icon: Icons.timelapse_outlined, numeric: true),
                const SizedBox(height: 12),
                _datePicker(
                  "Follow-up Date (optional)",
                  Icons.event_repeat_outlined,
                  _followUpDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  onPicked: (d) => setState(() => _followUpDate = d),
                  optional: true,
                ),
              ]),
            ),

            const SizedBox(height: 14),

            _card(isDark: isDark,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Clinical Information",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _field(_reasonController, "Reason for Visit",
                      icon: Icons.help_outline, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_symptomsController, "Symptoms",
                      icon: Icons.sick_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_diagnosisController, "Diagnosis",
                      icon: Icons.medical_information_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_notesController, "Doctor Notes",
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
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Update Appointment",
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
      {IconData? icon, bool required = false,
      bool numeric = false, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: _decor(label, icon),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
          : null,
    );
  }

  Widget _dropdown(String label, IconData icon, String value,
      Map<String, String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _decor(label, icon),
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _datePicker(String label, IconData icon, DateTime? date,
      {required DateTime firstDate, required DateTime lastDate,
      required void Function(DateTime) onPicked, bool optional = false}) {
    return InkWell(
      onTap: () async {
        final p = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (p != null) onPicked(p);
      },
      child: InputDecorator(
        decoration: _decor(label, icon),
        child: Text(
          date == null
              ? (optional ? "Not set" : "Select")
              : date.toIso8601String().split("T")[0],
          style: TextStyle(
              color: date == null ? Colors.grey : null, fontSize: 14),
        ),
      ),
    );
  }

  Widget _timePicker(TimeOfDay time, void Function(TimeOfDay) onPicked) {
    return InkWell(
      onTap: () async {
        final p = await showTimePicker(
            context: context, initialTime: time);
        if (p != null) onPicked(p);
      },
      child: InputDecorator(
        decoration: _decor("Time", Icons.access_time_outlined),
        child: Text(time.format(context),
            style: const TextStyle(fontSize: 14)),
      ),
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