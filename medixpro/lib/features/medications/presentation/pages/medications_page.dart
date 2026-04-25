import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/widgets/medical_loading.dart';
import '../cubit/medications_cubit.dart';
import '../../domain/entities/medication.dart';
import '../../../../../core/theme/app_colors.dart';
import 'add_medication_page.dart';
import 'edit_medication_page.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<MedicationsCubit>().fetchMedications());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<MedicationsCubit>().fetchMedications(
          search: query.trim().isEmpty ? null : query.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
              title: const Text(
                "Medications",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
            ),
            backgroundColor: cs.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddMedicationPage()),
                  );
                  if (mounted) {
                    context.read<MedicationsCubit>().fetchMedications();
                  }
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search medication or patient...",
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.8), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.white.withOpacity(0.8),
                                size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch("");
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
          ),

          // ─── Body ───────────────────────────────────────────────────
          BlocBuilder<MedicationsCubit, MedicationsState>(
            builder: (context, state) {
              if (state is MedicationsLoading) {
                return const SliverFillRemaining(
                  child: Center(child: MedicalLoading()),
                );
              }

              if (state is MedicationsError) {
                return SliverFillRemaining(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<MedicationsCubit>().fetchMedications(),
                  ),
                );
              }

              if (state is MedicationsLoaded) {
                if (state.medications.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyView(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _MedicationCard(
                        medication: state.medications[i],
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditMedicationPage(
                                  medication: state.medications[i]),
                            ),
                          );
                          if (mounted) {
                            context
                                .read<MedicationsCubit>()
                                .fetchMedications();
                          }
                        },
                        onDelete: () =>
                            _confirmDelete(context, state.medications[i].id),
                      ),
                      childCount: state.medications.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(child: SizedBox());
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text("New Prescription",
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationPage()),
          );
          if (mounted) {
            context.read<MedicationsCubit>().fetchMedications();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Delete Prescription",
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            "This prescription will be permanently removed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              context
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

// ─── Empty ────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.chipBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text("No prescriptions yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
          const SizedBox(height: 6),
          Text("Tap + to add a new prescription",
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 52, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.lightTextSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  Color _routeColor(BuildContext context) {
    switch (medication.route) {
      case "injection":
      case "iv":
        return AppColors.error;
      case "topical":
        return AppColors.success;
      case "inhalation":
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _frequencyLabel() {
    const map = {
      "once_daily": "Once Daily",
      "twice_daily": "Twice Daily",
      "three_times_daily": "3× Daily",
      "four_times_daily": "4× Daily",
      "every_8_hours": "Every 8h",
      "every_12_hours": "Every 12h",
      "as_needed": "As Needed",
      "weekly": "Weekly",
    };
    return map[medication.frequency] ?? medication.frequency;
  }

  String _routeLabel() {
    const map = {
      "oral": "Oral",
      "injection": "Injection",
      "topical": "Topical",
      "inhalation": "Inhalation",
      "sublingual": "Sublingual",
      "iv": "IV",
      "eye_drops": "Eye Drops",
      "ear_drops": "Ear Drops",
    };
    return map[medication.route] ?? medication.route;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final color = _routeColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.12 : 0.07),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medication_rounded,
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          const SizedBox(width: 4),
                          Text(
                            medication.patientName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionBtn(
                      icon: Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 4),
                    _ActionBtn(
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                        icon: Icons.science_outlined,
                        label: medication.dosage,
                        color: AppColors.warning),
                    _InfoChip(
                        icon: Icons.schedule_outlined,
                        label: _frequencyLabel(),
                        color: AppColors.success),
                    _InfoChip(
                        icon: Icons.route_outlined,
                        label: _routeLabel(),
                        color: color),
                    if (medication.durationDays != null)
                      _InfoChip(
                          icon: Icons.calendar_today_outlined,
                          label: "${medication.durationDays}d",
                          color: Colors.purple),
                  ],
                ),
                if (medication.startDate != null &&
                    medication.startDate!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.date_range_outlined,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      const SizedBox(width: 6),
                      Text(
                        "${medication.startDate}"
                        "${medication.endDate != null && medication.endDate!.isNotEmpty ? "  →  ${medication.endDate}" : ""}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (medication.instructions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.warning.withOpacity(0.08)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            medication.instructions,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}