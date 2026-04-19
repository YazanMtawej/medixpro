import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment_request.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class PatientRequestsPage extends StatefulWidget {
  const PatientRequestsPage({super.key});

  @override
  State<PatientRequestsPage> createState() => _PatientRequestsPageState();
}

class _PatientRequestsPageState extends State<PatientRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<AppointmentsCubit>().fetchRequests());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        if (state is RequestActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        } else if (state is AppointmentsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: const Text("My Requests",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                centerTitle: true,
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              bottom: TabBar(
                controller: _tab,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt_rounded), text: "My Requests"),
                  Tab(icon: Icon(Icons.add_circle_outline), text: "New Request"),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tab,
                children: [
                  _MyRequestsList(isDark: isDark),
                  _NewRequestForm(
                    isDark: isDark,
                    onSubmit: (req) {
                      context.read<AppointmentsCubit>().sendRequest(req);
                      _tab.animateTo(0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── My Requests List ─────────────────────────────────────────────────────────
class _MyRequestsList extends StatelessWidget {
  final bool isDark;
  const _MyRequestsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  Text("No requests yet",
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      )),
                  const SizedBox(height: 6),
                  Text("Send your first appointment request",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      )),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AppointmentsCubit>().fetchRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (_, i) => _PatientRequestCard(
                request: state.requests[i],
                isDark: isDark,
                onConfirm: state.requests[i].isSuggested
                    ? () => context.read<AppointmentsCubit>().confirmSuggestion(state.requests[i].id)
                    : null,
              ),
            ),
          );
        }

        return const Center(child: Text("Pull to refresh"));
      },
    );
  }
}

class _PatientRequestCard extends StatelessWidget {
  final AppointmentRequest request;
  final bool isDark;
  final VoidCallback? onConfirm;

  const _PatientRequestCard({
    required this.request,
    required this.isDark,
    this.onConfirm,
  });

  Color get _color {
    switch (request.status) {
      case "accepted":  return AppColors.success;
      case "rejected":  return AppColors.error;
      case "suggested": return AppColors.warning;
      default:          return AppColors.primary;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case "pending":   return "⏳ Pending";
      case "accepted":  return "✅ Accepted";
      case "rejected":  return "❌ Rejected";
      case "suggested": return "📅 New Time Suggested";
      default:          return request.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _color, width: 4),
          top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
          right: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
          bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
        ),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(request.title,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _color.withOpacity(0.3)),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _color)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Preferred date
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  "Requested: ${_formatDate(request.preferredDate)}",
                  style: TextStyle(fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ],
            ),

            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 13, color: AppColors.lightTextSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(request.reason,
                        style: TextStyle(fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ),
                ],
              ),
            ],

            // Suggested alternative
            if (request.isSuggested && request.suggestedDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(isDark ? 0.1 : 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text("Doctor suggested alternative time:",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_formatDate(request.suggestedDate!),
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        )),
                    if (request.doctorNote.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text("Note: ${request.doctorNote}",
                          style: TextStyle(fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text("Confirm This Time"),
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Rejection note
            if (request.isRejected && request.doctorNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_outlined, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text("Reason: ${request.doctorNote}",
                          style: const TextStyle(fontSize: 12, color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

// ─── New Request Form ─────────────────────────────────────────────────────────
class _NewRequestForm extends StatefulWidget {
  final bool isDark;
  final void Function(AppointmentRequest) onSubmit;

  const _NewRequestForm({required this.isDark, required this.onSubmit});

  @override
  State<_NewRequestForm> createState() => _NewRequestFormState();
}

class _NewRequestFormState extends State<_NewRequestForm> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _reasonCtrl   = TextEditingController();
  final _symptomsCtrl = TextEditingController();

  String     _type = "general";
  DateTime?  _date;
  TimeOfDay? _time;

  static const _types = {
    "general":      "General Checkup",
    "follow_up":    "Follow Up",
    "consultation": "Consultation",
    "emergency":    "Emergency",
    "lab_results":  "Lab Results",
    "vaccination":  "Vaccination",
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _reasonCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select date and time"),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final dt = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);

    final req = AppointmentRequest(
      id:             0,
      patientId:      0,
      patientName:    "",
      doctorName:     "",
      requestedById:  0,
      requestedByName: "",
      title:          _titleCtrl.text.trim(),
      type:           _type,
      preferredDate:  dt.toUtc().toIso8601String(),
      reason:         _reasonCtrl.text.trim(),
      symptoms:       _symptomsCtrl.text.trim(),
      status:         "pending",
      doctorNote:     "",
    );

    widget.onSubmit(req);

    // Reset form
    _titleCtrl.clear();
    _reasonCtrl.clear();
    _symptomsCtrl.clear();
    setState(() { _date = null; _time = null; _type = "general"; });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(child: Column(children: [
            _field(_titleCtrl, "Appointment Title", Icons.title, required: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: _decor("Type", Icons.category_outlined),
              items: _types.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
          ])),

          const SizedBox(height: 14),

          _card(child: Column(children: [
            Row(children: [
              Expanded(child: _datePicker()),
              const SizedBox(width: 12),
              Expanded(child: _timePicker()),
            ]),
          ])),

          const SizedBox(height: 14),

          _card(child: Column(children: [
            _field(_reasonCtrl, "Reason for Visit", Icons.help_outline, maxLines: 2),
            const SizedBox(height: 12),
            _field(_symptomsCtrl, "Symptoms", Icons.sick_outlined, maxLines: 2),
          ])),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: const Text("Send Request", style: TextStyle(fontSize: 15)),
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 0.8,
      ),
    ),
    child: child,
  );

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: _decor(label, icon),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null : null,
    );
  }

  Widget _datePicker() => InkWell(
    onTap: () async {
      final p = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );
      if (p != null) setState(() => _date = p);
    },
    child: InputDecorator(
      decoration: _decor("Date", Icons.calendar_today_outlined),
      child: Text(
        _date == null ? "Select" : "${_date!.year}-${_date!.month.toString().padLeft(2,'0')}-${_date!.day.toString().padLeft(2,'0')}",
        style: TextStyle(color: _date == null ? Colors.grey : null, fontSize: 14),
      ),
    ),
  );

  Widget _timePicker() => InkWell(
    onTap: () async {
      final p = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (p != null) setState(() => _time = p);
    },
    child: InputDecorator(
      decoration: _decor("Time", Icons.access_time_outlined),
      child: Text(
        _time == null ? "Select" : _time!.format(context),
        style: TextStyle(color: _time == null ? Colors.grey : null, fontSize: 14),
      ),
    ),
  );

  InputDecoration _decor(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}