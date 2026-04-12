import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient.dart';
import '../cubit/patients_cubit.dart';

class EditPatientPage extends StatefulWidget {
  final Patient patient;
  const EditPatientPage({super.key, required this.patient});

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _nationalId;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyPhone;
  late final TextEditingController _allergies;
  late final TextEditingController _chronicDiseases;
  late final TextEditingController _previousSurgeries;
  late final TextEditingController _currentMedications;
  late final TextEditingController _notes;
  late String _gender;
  late String _bloodType;
  DateTime? _birthDate;

  static const _bloodTypes = [
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "unknown"
  ];

  // ✅ تطبيع أي قيمة قديمة إلى lowercase
  String _normalizeGender(String g) {
    final lower = g.toLowerCase();
    return (lower == "female") ? "female" : "male";
  }

  // ✅ تطبيع bloodType — إذا كانت قيمة غير موجودة في القائمة
  String _normalizeBloodType(String bt) {
    return _bloodTypes.contains(bt) ? bt : "unknown";
  }

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _name               = TextEditingController(text: p.name);
    _age                = TextEditingController(text: p.age.toString());
    _phone              = TextEditingController(text: p.phone);
    _email              = TextEditingController(text: p.email ?? "");
    _address            = TextEditingController(text: p.address ?? "");
    _nationalId         = TextEditingController(text: p.nationalId ?? "");
    _emergencyName      = TextEditingController(text: p.emergencyContactName ?? "");
    _emergencyPhone     = TextEditingController(text: p.emergencyContactPhone ?? "");
    _allergies          = TextEditingController(text: p.allergies ?? "");
    _chronicDiseases    = TextEditingController(text: p.chronicDiseases ?? "");
    _previousSurgeries  = TextEditingController(text: p.previousSurgeries ?? "");
    _currentMedications = TextEditingController(text: p.currentMedications ?? "");
    _notes              = TextEditingController(text: p.notes ?? "");
    _gender             = _normalizeGender(p.gender);
    _bloodType          = _normalizeBloodType(p.bloodType);
    if (p.birthDate != null && p.birthDate!.isNotEmpty) {
      _birthDate = DateTime.tryParse(p.birthDate!);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name, _age, _phone, _email, _address, _nationalId,
      _emergencyName, _emergencyPhone, _allergies, _chronicDiseases,
      _previousSurgeries, _currentMedications, _notes,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updated = widget.patient.copyWith(
      name: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      gender: _gender,
      phone: _phone.text.trim(),
      bloodType: _bloodType,
      birthDate: _birthDate?.toIso8601String().split("T")[0],
      nationalId: _nationalId.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      emergencyContactName: _emergencyName.text.trim(),
      emergencyContactPhone: _emergencyPhone.text.trim(),
      allergies: _allergies.text.trim(),
      chronicDiseases: _chronicDiseases.text.trim(),
      previousSurgeries: _previousSurgeries.text.trim(),
      currentMedications: _currentMedications.text.trim(),
      notes: _notes.text.trim(),
    );

    await context.read<PatientsCubit>().updatePatient(widget.patient.id, updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Patient")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section("Basic Information"),
            _field(_name, "Full Name", required: true, icon: Icons.person),
            _field(_age, "Age", required: true, icon: Icons.cake, numeric: true),
            _field(_nationalId, "National ID", icon: Icons.badge),
            _dateField(),
            _genderDropdown(),
            _bloodTypeDropdown(),

            _section("Contact Information"),
            _field(_phone, "Phone", required: true, icon: Icons.phone, numeric: true),
            _field(_email, "Email", icon: Icons.email),
            _field(_address, "Address", icon: Icons.location_on, maxLines: 2),

            _section("Emergency Contact"),
            _field(_emergencyName, "Contact Name", icon: Icons.contact_phone),
            _field(_emergencyPhone, "Contact Phone", icon: Icons.phone_forwarded),

            _section("Medical Information"),
            _field(_allergies, "Allergies", icon: Icons.warning_amber, maxLines: 2),
            _field(_chronicDiseases, "Chronic Diseases",
                icon: Icons.medical_information, maxLines: 2),
            _field(_previousSurgeries, "Previous Surgeries",
                icon: Icons.history, maxLines: 2),
            _field(_currentMedications, "Current Medications",
                icon: Icons.medication, maxLines: 2),
            _field(_notes, "Notes", icon: Icons.note, maxLines: 3),

            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save Changes",
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            )),
      );

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    IconData? icon,
    bool numeric = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: numeric ? TextInputType.number : keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
            : null,
      ),
    );
  }

  Widget _dateField() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _birthDate = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: "Birth Date",
              prefixIcon: const Icon(Icons.calendar_today),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              _birthDate == null
                  ? "Select date"
                  : _birthDate!.toIso8601String().split("T")[0],
              style:
                  TextStyle(color: _birthDate == null ? Colors.grey : null),
            ),
          ),
        ),
      );

  Widget _genderDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: _gender,
          decoration: InputDecoration(
            labelText: "Gender",
            prefixIcon: const Icon(Icons.wc),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: const [
            DropdownMenuItem(value: "male", child: Text("Male")),
            DropdownMenuItem(value: "female", child: Text("Female")),
          ],
          onChanged: (v) => setState(() => _gender = v!),
        ),
      );

  Widget _bloodTypeDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: _bloodType,
          decoration: InputDecoration(
            labelText: "Blood Type",
            prefixIcon: const Icon(Icons.bloodtype),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: _bloodTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _bloodType = v!),
        ),
      );
}