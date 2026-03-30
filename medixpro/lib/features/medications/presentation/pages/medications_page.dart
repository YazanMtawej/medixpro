import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/medications_cubit.dart';
import 'add_medication_page.dart';
import 'edit_medication_page.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {

  @override
  void initState() {
    super.initState();

    /// 🔥 تحميل البيانات مرة واحدة فقط
    Future.microtask(() {
      context.read<MedicationsCubit>().fetchMedications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddMedicationPage(),
                ),
              );

              /// 🔄 تحديث بعد الرجوع
              context.read<MedicationsCubit>().fetchMedications();
            },
          ),
        ],
      ),

      body: BlocBuilder<MedicationsCubit, MedicationsState>(
        builder: (context, state) {

          /// ⏳ Loading
          if (state is MedicationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ Error
          else if (state is MedicationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MedicationsCubit>().fetchMedications();
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          /// ✅ Loaded
          else if (state is MedicationsLoaded) {
            final meds = state.medications;

            if (meds.isEmpty) {
              return const Center(
                child: Text("No medications found"),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<MedicationsCubit>().fetchMedications();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: meds.length,
                itemBuilder: (_, index) {
                  final med = meds[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        med.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${med.description}\nDosage: ${med.dosage}",
                      ),
                      isThreeLine: true,

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// ✏️ Edit
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditMedicationPage(medication: med),
                                ),
                              );

                              /// 🔄 تحديث بعد الرجوع
                              context.read<MedicationsCubit>().fetchMedications();
                            },
                          ),

                          /// 🗑 Delete
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(context, med.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// 🔥 Confirm Delete Dialog
  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Medication"),
        content: const Text("Are you sure you want to delete this medication?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              await context
                  .read<MedicationsCubit>()
                  .deleteExistingMedication(id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}