import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/widgets/medical_animation.dart';
import 'package:medixpro/features/auth/presentation/pages/login_page.dart';
import 'package:medixpro/l10n/app_localizations.dart';

import 'package:medixpro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medixpro/features/auth/presentation/pages/onboarding.dart';
import 'package:medixpro/features/dashboard/presentation/pages/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late Animation<double> _fade;
  late Animation<double> _scale;

  bool _animationDone = false;
  AuthState? _authState;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progress = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3)).then((_) {
      _animationDone = true;
      _tryNavigate();
    });

    context.read<AuthCubit>().autoLogin();
  }

  void _tryNavigate() {
    if (!_animationDone || _authState == null) return;

    if (_authState is AuthAuthenticated) {
      _goTo(const DashboardPage());
    } else if (_authState is AuthLoggedOut) {
      _goTo(const LoginPage());
    }
  }

  void _goTo(Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _authState = state;
        _tryNavigate();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E6CFF), Color(0xFF0A4EDC)],
            ),
          ),
          child: Stack(
            children: [
              /// 🔥 خلفية glow خفيفة
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              Positioned(
                bottom: -100,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    /// 🔥 Animation
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          child: const MedicalAnimation(
                            asset: "assets/animations/Medical Care.json",
                            size: 200,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// 🔥 Title
                    FadeTransition(
                      opacity: _fade,
                      child: const Text(
                        "MedixPro",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        "Smart Clinic Management",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    /// 🔥 Progress
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final percent = (_progress.value * 100).toInt();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).initializingSystems,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "$percent%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _progress.value,
                                  minHeight: 7,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const Spacer(),

                    /// 🔥 Footer
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        AppLocalizations.of(context).versionEdition,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
