import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/appointments/domain/entities/appointment.dart';
import 'package:medixpro/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:medixpro/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:medixpro/features/patients/presentation/cubit/patients_state.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  int? selectedPatientId;

  DateTime? date;
  TimeOfDay? time;

  @override
  void initState() {
    super.initState();
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("New Appointment")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              /// Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔥 Patient Dropdown
              BlocBuilder<PatientsCubit, PatientsState>(
                builder: (context, state) {

                  if (state is PatientsLoaded) {

                    return DropdownButtonFormField<int>(
                      value: selectedPatientId,
                      hint: const Text("Select Patient"),

                      items: state.patients.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),

                      onChanged: (val) {
                        setState(() => selectedPatientId = val);
                      },
                    );
                  }

                  return const CircularProgressIndicator();
                },
              ),

              const SizedBox(height: 16),

              /// Date
              ListTile(
                title: Text(date == null
                    ? "Select Date"
                    : "${date!.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              /// Time
              ListTile(
                title: Text(time == null
                    ? "Select Time"
                    : time!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submit,
                child: const Text("Create"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {

    if (selectedPatientId == null || date == null || time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete all fields")),
      );
      return;
    }

    final dateTime = DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );

    final appointment = Appointment(
      id: 0,
      title: _titleController.text,
      patientId: selectedPatientId!,
      patientName: "",
      dateTime: dateTime,
      status: "Scheduled",
    );

    context.read<AppointmentsCubit>().addNewAppointment(appointment);

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => time = picked);
  }
}