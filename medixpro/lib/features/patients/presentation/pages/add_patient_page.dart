import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient.dart';
import '../cubit/patients_cubit.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _nationalId = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _allergies = TextEditingController();
  final _chronicDiseases = TextEditingController();
  final _previousSurgeries = TextEditingController();
  final _currentMedications = TextEditingController();
  final _notes = TextEditingController();

  String _gender = "male";
  String _bloodType = "unknown";
  DateTime? _birthDate;
  bool _isLoading = false;

  final List<String> _bloodTypes = [
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "unknown"
  ];

  @override
  void dispose() {
    for (final c in [
      _name, _age, _phone, _email, _address, _nationalId,
      _emergencyName, _emergencyPhone, _allergies, _chronicDiseases,
      _previousSurgeries, _currentMedications, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final patient = Patient(
      id: 0,
      name: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      gender: _gender,
      phone: _phone.text.trim(),
      bloodType: _bloodType,
      birthDate: _birthDate != null
          ? _birthDate!.toIso8601String().split("T")[0]
          : null,
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

    await context.read<PatientsCubit>().addPatient(patient);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle("Basic Information"),
            _field(_name, "Full Name", required: true, icon: Icons.person),
            _field(_age, "Age", required: true,
                icon: Icons.cake, numeric: true),
            _field(_nationalId, "National ID", icon: Icons.badge),
            _dateField(),
            _dropdownGender(),
            _dropdownBloodType(),

            _sectionTitle("Contact Information"),
            _field(_phone, "Phone Number", required: true,
                icon: Icons.phone, numeric: true),
            _field(_email, "Email", icon: Icons.email,
                keyboardType: TextInputType.emailAddress),
            _field(_address, "Address", icon: Icons.location_on, maxLines: 2),

            _sectionTitle("Emergency Contact"),
            _field(_emergencyName, "Contact Name", icon: Icons.contact_phone),
            _field(_emergencyPhone, "Contact Phone",
                icon: Icons.phone_forwarded, numeric: true),

            _sectionTitle("Medical Information"),
            _field(_allergies, "Allergies", icon: Icons.warning_amber,
                maxLines: 2),
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
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Save Patient",
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
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
        controller: controller,
        maxLines: maxLines,
        keyboardType: numeric
            ? TextInputType.number
            : keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
            : null,
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => _birthDate = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Birth Date",
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            _birthDate == null
                ? "Select date"
                : _birthDate!.toIso8601String().split("T")[0],
            style: TextStyle(
              color: _birthDate == null ? Colors.grey : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownGender() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: InputDecoration(
          labelText: "Gender",
          prefixIcon: const Icon(Icons.wc),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        items: const [
          DropdownMenuItem(value: "male", child: Text("Male")),
          DropdownMenuItem(value: "female", child: Text("Female")),
        ],
        onChanged: (v) => setState(() => _gender = v!),
      ),
    );
  }

  Widget _dropdownBloodType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _bloodType,
        decoration: InputDecoration(
          labelText: "Blood Type",
          prefixIcon: const Icon(Icons.bloodtype),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        items: _bloodTypes
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) => setState(() => _bloodType = v!),
      ),
    );
  }
}