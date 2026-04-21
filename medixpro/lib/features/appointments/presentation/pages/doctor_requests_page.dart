import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment_request.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AppointmentsCubit>().fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [

            /// 🔥 HEADER
            _Header(isDark: isDark),

            /// 🔥 TABS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Pending"),
                  Tab(text: "Suggested"),
                  Tab(text: "Done"),
                ],
              ),
            ),

            /// 🔥 CONTENT
            Expanded(
              child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
                builder: (context, state) {

                  if (state is AppointmentsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RequestsLoaded) {
                    final pending   = state.requests.where((r) => r.isPending).toList();
                    final suggested = state.requests.where((r) => r.isSuggested).toList();
                    final done      = state.requests.where((r) => r.isAccepted || r.isRejected).toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _AnimatedList(pending),
                        _AnimatedList(suggested),
                        _AnimatedList(done),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("👨‍⚕️ Doctor Dashboard",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text("Manage your appointment requests easily",
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ANIMATED LIST
////////////////////////////////////////////////////////////

class _AnimatedList extends StatelessWidget {
  final List<AppointmentRequest> data;

  const _AnimatedList(this.data);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text("✨ Nothing here yet"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final r = data[i];

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (i * 80)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (_, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _ModernCard(request: r),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// MODERN CARD
////////////////////////////////////////////////////////////

class _ModernCard extends StatelessWidget {
  final AppointmentRequest request;

  const _ModernCard({required this.request});

  Color get statusColor {
    switch (request.status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "suggested":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 HEADER (Name + Status)
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withOpacity(0.15),
                child: Icon(Icons.person, color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  request.patientName.isNotEmpty
                      ? request.patientName
                      : request.requestedByName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              /// STATUS BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 📅 DATE (VERY IMPORTANT → highlight)
          _infoRow(
            icon: Icons.calendar_month,
            title: "Appointment",
            value: _formatDate(request.preferredDate),
            highlight: true,
          ),

          const SizedBox(height: 6),

          /// 🏷 TYPE
          _infoRow(
            icon: Icons.medical_services_outlined,
            title: "Type",
            value: request.type.replaceAll("_", " "),
          ),

          /// 📄 REASON
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow(
              icon: Icons.notes_outlined,
              title: "Reason",
              value: request.reason,
            ),
          ],

          /// ⏳ Suggested Date
          if (request.isSuggested && request.suggestedDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    "Suggested: ${_formatDate(request.suggestedDate!)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],

          /// DIVIDER
          if (request.isPending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
          ],

          /// ⚡ ACTIONS
          if (request.isPending)
            Row(
              children: [
                Expanded(
                  child: _actionBtn("Accept", Colors.green, Icons.check, () {
                    context.read<AppointmentsCubit>().acceptRequest(request.id);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionBtn("Suggest", Colors.orange, Icons.schedule, () {}),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionBtn("Reject", Colors.red, Icons.close, () {
                    context.read<AppointmentsCubit>().rejectRequest(request.id);
                  }),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 🔹 reusable row
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: highlight ? Colors.blue : Colors.grey),
        const SizedBox(width: 6),
        Text(
          "$title: ",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.blue : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(String text, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    return "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} "
        "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}