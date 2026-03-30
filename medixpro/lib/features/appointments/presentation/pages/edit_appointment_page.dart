import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/appointments_cubit.dart';
import '../../domain/entities/appointment.dart';

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

  late TextEditingController _titleController;

  int? selectedPatientId;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _status;

  final List<String> _statusOptions = ["Scheduled", "Completed", "Cancelled"];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.appointment.title);

    selectedPatientId = widget.appointment.patientId;

    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);

    _status = widget.appointment.status;

    /// 🔥 تحميل المرضى
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Appointment")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              /// Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter title" : null,
              ),

              const SizedBox(height: 16),

              /// 🔥 Patient Dropdown
              BlocBuilder<PatientsCubit, PatientsState>(
                builder: (context, state) {

                  if (state is PatientsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PatientsLoaded) {

                    return DropdownButtonFormField<int>(
                      value: selectedPatientId,
                      decoration: const InputDecoration(
                        labelText: "Patient",
                        border: OutlineInputBorder(),
                      ),

                      items: state.patients.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),

                      onChanged: (val) {
                        setState(() => selectedPatientId = val);
                      },

                      validator: (val) =>
                          val == null ? "Select patient" : null,
                    );
                  }

                  return const SizedBox();
                },
              ),

              const SizedBox(height: 16),

              /// Date
              ListTile(
                title: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              /// Time
              ListTile(
                title: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),

              const SizedBox(height: 16),

              /// Status
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submit,
                child: const Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {

    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedAppointment = Appointment(
      id: widget.appointment.id,
      title: _titleController.text,
      patientId: selectedPatientId!, // 🔥 FIX
      patientName: "", // optional
      dateTime: dateTime,
      status: _status,
    );

    context.read<AppointmentsCubit>().editAppointment(updatedAppointment);

    Navigator.pop(context);
  }
}