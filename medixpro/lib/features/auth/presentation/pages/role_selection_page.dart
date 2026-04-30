import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../../core/theme/app_colors.dart';
import 'register_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Role Selection"),centerTitle: true,backgroundColor: AppColors.primaryLight,),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_hospital_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Who are you?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select your role to get started",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 48),
      
                  _RoleCard(
                    icon: Icons.person_rounded,
                    title: "Patient",
                    subtitle: "Book appointments & view your records",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(role: "patient"),
                      ),
                    ),
                  ),
      
                  const SizedBox(height: 16),
      
                  _RoleCard(
                    icon: Icons.medical_services_rounded,
                    title: "Doctor",
                    subtitle: "Manage patients & clinic operations",
                    onTap: () => _showDoctorKeyDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDoctorKeyDialog(BuildContext context) {
    final ctrl = TextEditingController();
    bool obscure = true;
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false, // ✅ لا يُغلق بالضغط خارجه
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                "Doctor Verification",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter the verification code provided by your clinic administrator.",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                obscureText: obscure,
                onChanged: (_) {
                  // مسح الخطأ عند الكتابة
                  if (errorText != null) {
                    setStateDialog(() => errorText = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: "Verification Code",
                  hintText: "Enter code...",
                  errorText: errorText,
                  prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => setStateDialog(() => obscure = !obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Don't have a code? Contact your administrator.",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () async {
                final code = ctrl.text.trim();

                if (code.isEmpty) {
                  setStateDialog(() {
                    errorText = "Please enter the code";
                  });
                  return;
                }

                setStateDialog(() {
                  errorText = null;
                });

                final valid = await context.read<AuthCubit>().verifyDoctorKey(
                  code,
                );

                if (!valid) {
                  setStateDialog(() {
                    errorText = "Invalid verification code";
                  });
                  return;
                }

                Navigator.pop(ctx);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RegisterPage(role: "doctor", doctorSecretKey: code),
                  ),
                );
              },
              child: const Text(
                "Continue",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
