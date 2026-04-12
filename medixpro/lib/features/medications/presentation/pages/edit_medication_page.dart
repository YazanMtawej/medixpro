import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/medication.dart';
import '../cubit/medications_cubit.dart';
import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';

class EditMedicationPage extends StatefulWidget {
  final Medication medication;
  const EditMedicationPage({super.key, required this.medication});

  @override
  State<EditMedicationPage> createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _durationController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _notesController;

  late int _selectedPatientId;
  late String _frequency;
  late String _route;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  static const _frequencies = {
    "once_daily": "Once Daily",
    "twice_daily": "Twice Daily",
    "three_times_daily": "Three Times Daily",
    "four_times_daily": "Four Times Daily",
    "every_8_hours": "Every 8 Hours",
    "every_12_hours": "Every 12 Hours",
    "as_needed": "As Needed",
    "weekly": "Weekly",
  };

  static const _routes = {
    "oral": "Oral",
    "injection": "Injection",
    "topical": "Topical",
    "inhalation": "Inhalation",
    "sublingual": "Sublingual",
    "iv": "Intravenous (IV)",
    "eye_drops": "Eye Drops",
    "ear_drops": "Ear Drops",
  };

  @override
  void initState() {
    super.initState();

    final m = widget.medication;

    _nameController = TextEditingController(text: m.name);
    _dosageController = TextEditingController(text: m.dosage);
    _durationController =
        TextEditingController(text: m.durationDays?.toString() ?? "");
    _instructionsController =
        TextEditingController(text: m.instructions);
    _notesController = TextEditingController(text: m.notes);

    _selectedPatientId = m.patientId;
    _frequency = _frequencies.containsKey(m.frequency)
        ? m.frequency
        : "once_daily";
    _route =
        _routes.containsKey(m.route) ? m.route : "oral";

    if (m.startDate != null && m.startDate!.isNotEmpty) {
      _startDate = DateTime.tryParse(m.startDate!);
    }

    if (m.endDate != null && m.endDate!.isNotEmpty) {
      _endDate = DateTime.tryParse(m.endDate!);
    }

    context.read<PatientsCubit>().loadPatients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = widget.medication.copyWith(
      patientId: _selectedPatientId,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequency,
      route: _route,
      durationDays: int.tryParse(_durationController.text),
      startDate: _startDate?.toIso8601String().split("T")[0],
      endDate: _endDate?.toIso8601String().split("T")[0],
      instructions: _instructionsController.text.trim(),
      notes: _notesController.text.trim(),
    );

    await context
        .read<MedicationsCubit>()
        .updateExistingMedication(updated);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Prescription"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ─── Patient ─────────────────────
            _card(
              child: BlocBuilder<PatientsCubit, PatientsState>(
                builder: (context, state) {
                  if (state is! PatientsLoaded) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedPatientId,
                    decoration: _decor("Patient", Icons.person),
                    items: state.patients
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ))
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

            /// ─── Medication Info ─────────────
            _card(
              child: Column(
                children: [
                  _field(_nameController, "Medication Name",
                      icon: Icons.medication, required: true),
                  const SizedBox(height: 12),
                  _field(_dosageController, "Dosage",
                      icon: Icons.science_outlined, required: true),
                  const SizedBox(height: 12),
                  _dropdown(
                    "Frequency",
                    Icons.schedule,
                    _frequency,
                    _frequencies,
                    (v) => setState(() => _frequency = v!),
                  ),
                  const SizedBox(height: 12),
                  _dropdown(
                    "Route",
                    Icons.route_outlined,
                    _route,
                    _routes,
                    (v) => setState(() => _route = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// ─── Duration & Dates ───────────
            _card(
              child: Column(
                children: [
                  _field(_durationController, "Duration (days)",
                      icon: Icons.timelapse_outlined, numeric: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _datePicker(
                          "Start Date",
                          _startDate,
                          (d) => setState(() => _startDate = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _datePicker(
                          "End Date",
                          _endDate,
                          (d) => setState(() => _endDate = d),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// ─── Notes ─────────────────────
            _card(
              child: Column(
                children: [
                  _field(_instructionsController, "Instructions",
                      icon: Icons.info_outline, maxLines: 2),
                  const SizedBox(height: 12),
                  _field(_notesController, "Notes",
                      icon: Icons.note_outlined, maxLines: 2),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ─── Submit ────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Update Prescription"),
                onPressed: _isLoading ? null : _submit,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// ───────────────── Helpers ─────────────────

  Widget _card({required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
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
      keyboardType:
          numeric ? TextInputType.number : TextInputType.text,
      decoration: _decor(label, icon),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
              ? "Required"
              : null
          : null,
    );
  }

  Widget _dropdown(
    String label,
    IconData icon,
    String value,
    Map<String, String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _decor(label, icon),
      items: items.entries
          .map((e) =>
              DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _datePicker(
      String label, DateTime? date, void Function(DateTime) onPicked) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: _decor(label, Icons.calendar_today_outlined),
        child: Text(
          date == null
              ? "Select"
              : date.toIso8601String().split("T")[0],
          style: TextStyle(
            color: date == null
                ? theme.hintColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
    );
  }
}