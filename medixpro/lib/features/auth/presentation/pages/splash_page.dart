import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  bool _animationDone = false;
  AuthState? _authState;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    /// ⏱️ نضمن عرض Splash لمدة كافية
    Future.delayed(const Duration(seconds: 3)).then((_) {
      _animationDone = true;
      _tryNavigate();
    });

    /// 🔥 تشغيل auth
    context.read<AuthCubit>().autoLogin();
  }

  void _tryNavigate() {
    if (!_animationDone || _authState == null) return;

    if (_authState is AuthAuthenticated) {
      _goTo(const DashboardPage());
    } else if (_authState is AuthLoggedOut) {
      _goTo(const OnboardingPage());
    }
  }

  void _goTo(Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
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
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                /// 🔥 App Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_hospital_rounded,
                      size: 48,
                      color: Color(0xFF1E6CFF),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "MedixPro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Smart Clinic Management",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(flex: 2),

                /// 🔥 Progress Section
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final percent = (_progress.value * 100).toInt();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Initializing systems...",
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
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 6,
                              backgroundColor:
                                  Colors.white.withOpacity(0.25),
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

                Text(
                  "VERSION 2.4.0 · ENTERPRISE EDITION",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}