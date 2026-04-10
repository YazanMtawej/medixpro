import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/theme/app_colors.dart';

import '../cubit/patients_cubit.dart';
import '../cubit/patients_state.dart';

import 'add_patient_page.dart';
import 'edit_patient_page.dart';
import 'patient_details_page.dart';
import '../widgets/patient_card.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text("Patients"),
  centerTitle: true,

  actions: [
   
    IconButton(
      icon: const Icon(Icons.add_circle,color:AppColors.primaryDark,),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddPatientPage(),
          ),
        );
        context.read<PatientsCubit>().loadPatients();
      },
    ),
     SizedBox(width: 20,),
  ],
),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("New Patient"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientPage()),
          );
          context.read<PatientsCubit>().loadPatients();
        },
      ),

      body: BlocBuilder<PatientsCubit, PatientsState>(
        builder: (context, state) {
          if (state is PatientsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientsError) {
            return Center(child: Text(state.message));
          }

          if (state is PatientsLoaded) {
            if (state.patients.isEmpty) {
              return const Center(child: Text("No patients found"));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final crossAxisCount = _getCrossAxisCount(width);
                final itemWidth =
                    (width - (12 * (crossAxisCount - 1))) / crossAxisCount;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,

                      children: List.generate(state.patients.length, (i) {
                        final p = state.patients[i];

                        return SizedBox(
                          width: itemWidth,

                          child: PatientCard(
                            p,

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailsPage(
                                    patientId: p.id,
                                  ),
                                ),
                              );
                            },

                            onEdit: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditPatientPage(patient: p),
                                ),
                              );

                              context
                                  .read<PatientsCubit>()
                                  .loadPatients();
                            },

                            onDelete: () {
                              context
                                  .read<PatientsCubit>()
                                  .deletePatient(p.id);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// 📱 Responsive breakpoints
  int _getCrossAxisCount(double width) {
    if (width < 600) return 1;   // mobile
    if (width < 1000) return 2;  // tablet
    return 3;                    // desktop
  }
}