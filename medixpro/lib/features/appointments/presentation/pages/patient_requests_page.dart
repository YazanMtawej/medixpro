import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:medixpro/features/patients/presentation/cubit/patients_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment_request.dart';
import '../../data/datasources/appointments_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PatientRequestsPage extends StatefulWidget {
  const PatientRequestsPage({super.key});

  @override
  State<PatientRequestsPage> createState() => _PatientRequestsPageState();
}

class _PatientRequestsPageState extends State<PatientRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<AppointmentRequest> _requests = [];
  bool _loading = true;

  late final AppointmentsRemoteDataSource _ds;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    final tokenStorage = TokenStorage(const FlutterSecureStorage());
    _ds = AppointmentsRemoteDataSource(ApiClient(tokenStorage));
    _loadRequests();
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      _requests = await _ds.getAppointmentRequests();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
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
              title: const Text("Appointment Requests",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
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
                Tab(text: "My Requests"),
                Tab(text: "New Request"),
              ],
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tab,
              children: [
                // ─── My Requests ────────────────────────────────────
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: _requests.isEmpty
                            ? const Center(
                                child: Text("No requests sent yet"))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _requests.length,
                                itemBuilder: (_, i) => _RequestCard(
                                  request: _requests[i],
                                  isDark: isDark,
                                  onConfirmSuggestion: _requests[i].isSuggested
                                      ? () async {
                                          await _ds.confirmSuggestion(
                                              _requests[i].id);
                                          await _loadRequests();
                                        }
                                      : null,
                                ),
                              ),
                      ),

                // ─── New Request ─────────────────────────────────────
                _NewRequestForm(
                  isDark: isDark,
                  onSubmit: (req) async {
                    await _ds.sendAppointmentRequest(req);
                    await _loadRequests();
                    _tab.animateTo(0);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Request sent successfully!"),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final AppointmentRequest request;
  final bool isDark;
  final VoidCallback? onConfirmSuggestion;

  const _RequestCard({
    required this.request,
    required this.isDark,
    this.onConfirmSuggestion,
  });

  Color get _statusColor {
    switch (request.status) {
      case "accepted":  return AppColors.success;
      case "rejected":  return AppColors.error;
      case "suggested": return AppColors.warning;
      default:          return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _statusColor, width: 3),
          top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8),
          right: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8),
          bottom: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(request.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    )),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Preferred: ${request.preferredDate.substring(0, 16).replaceAll("T", " ")}",
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (request.isSuggested && request.suggestedDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Doctor suggested alternative:",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning)),
                  const SizedBox(height: 4),
                  Text(
                    request.suggestedDate!.substring(0, 16).replaceAll("T", " "),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (request.doctorNote.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(request.doctorNote,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        )),
                  ],
                ],
              ),
            ),
            if (onConfirmSuggestion != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirmSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Confirm This Time"),
                ),
              ),
            ],
          ],
          if (request.isRejected && request.doctorNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text("Reason: ${request.doctorNote}",
                style: const TextStyle(
                    fontSize: 12, color: AppColors.error)),
          ],
        ],
      ),
    );
  }
}

// ─── New Request Form ─────────────────────────────────────────────────────────
class _NewRequestForm extends StatefulWidget {
  final bool isDark;
  final Future<void> Function(AppointmentRequest) onSubmit;

  const _NewRequestForm({required this.isDark, required this.onSubmit});

  @override
  State<_NewRequestForm> createState() => _NewRequestFormState();
}

class _NewRequestFormState extends State<_NewRequestForm> {
  final _formKey       = GlobalKey<FormState>();
  final _titleCtrl     = TextEditingController();
  final _reasonCtrl    = TextEditingController();
  final _symptomsCtrl  = TextEditingController();
  String     _type     = "general";
  DateTime?  _date;
  TimeOfDay? _time;
  bool       _loading  = false;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date and time"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final dt = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );

    // المريض يحتاج patient ID — نجلبه من الـ cubit
    final patientsState = context.read<PatientsCubit>().state;
    int patientId = 0;
    if (patientsState is PatientsLoaded && patientsState.patients.isNotEmpty) {
      patientId = patientsState.patients.first.id;
    }

    final req = AppointmentRequest(
      id:              0,
      patientId:       patientId,
      patientName:     "",
      doctorName:      "",
      requestedByName: "",
      title:           _titleCtrl.text.trim(),
      type:            _type,
      preferredDate:   dt.toUtc().toIso8601String(),
      reason:          _reasonCtrl.text.trim(),
      symptoms:        _symptomsCtrl.text.trim(),
      status:          "pending",
      doctorNote:      "",
    );

    await widget.onSubmit(req);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_titleCtrl, "Appointment Title", Icons.title, required: true),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: InputDecoration(
              labelText: "Type",
              prefixIcon: const Icon(Icons.category_outlined, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _types.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _datePicker()),
              const SizedBox(width: 12),
              Expanded(child: _timePicker()),
            ],
          ),
          const SizedBox(height: 12),
          _field(_reasonCtrl, "Reason for Visit", Icons.help_outline, maxLines: 2),
          const SizedBox(height: 12),
          _field(_symptomsCtrl, "Symptoms", Icons.sick_outlined, maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text("Send Request"),
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
          : null,
    );
  }

  Widget _datePicker() {
    return InkWell(
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
        decoration: InputDecoration(
          labelText: "Date",
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          _date == null
              ? "Select"
              : "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}",
          style: TextStyle(color: _date == null ? Colors.grey : null),
        ),
      ),
    );
  }

  Widget _timePicker() {
    return InkWell(
      onTap: () async {
        final p = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (p != null) setState(() => _time = p);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Time",
          prefixIcon: const Icon(Icons.access_time_outlined, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          _time == null ? "Select" : _time!.format(context),
          style: TextStyle(color: _time == null ? Colors.grey : null),
        ),
      ),
    );
  }
}