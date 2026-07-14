import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/widgets/language_toggle_button.dart';
import 'package:medixpro/core/widgets/medical_animation.dart';
import 'package:medixpro/core/widgets/medical_loading.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import 'role_selection_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    context.read<AuthCubit>().login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Background ──────────────────────────────────────────────
          Container(
            height: size.height * 0.5,
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
          Container(
            margin: EdgeInsets.only(top: size.height * 0.45),
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),

          // ─── Main Content ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ─── Logo ─────────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        size: 42, color: AppColors.primary),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "MedixPro",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.smartClinicManagement,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),

                  const SizedBox(height: 36),

                  // ─── Card ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 0.8,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthAuthenticated) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DashboardPage()),
                            (_) => false,
                          );
                        } else if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return Stack(
                          children: [
                            // ─── Form UI ────────────────────────────────
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.welcomeBack,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.signInToYourAccount,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Username
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: l10n.username,
                                    prefixIcon: const Icon(Icons.person_outline),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    labelText: l10n.password,
                                    prefixIcon:
                                        const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () => setState(
                                          () => _obscure = !_obscure),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onLogin,
                                    child: Text(l10n.signIn,
                                        style: const TextStyle(fontSize: 15)),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Register
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RoleSelectionPage(),
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: l10n.dontHaveAccount,
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: l10n.register,
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ─── Loading Overlay ─────────────────────────
                            if (isLoading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: MedicalLoading(
                                    text: l10n.checkingCredentials,
                                    size: 160,
                                    showText: true,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    l10n.allRightsReserved,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  // space for bottom animation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ─── Language Switch (top-right) ──────────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: const LanguageToggleButton(),
              ),
            ),
          ),

          // ─── Lottie Bottom Animation ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.85,
                child: MedicalAnimation(
                  asset: "assets/animations/sign in hover.json",
                  size: size.width * 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}