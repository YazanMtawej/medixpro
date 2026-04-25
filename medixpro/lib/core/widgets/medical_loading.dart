import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MedicalLoading extends StatefulWidget {
  final String text;
  final double size;
  final bool showText;

  const MedicalLoading({
    super.key,
    this.text = "Loading patient data...",
    this.size = 180,
    this.showText = true,
  });

  @override
  State<MedicalLoading> createState() => _MedicalLoadingState();
}

class _MedicalLoadingState extends State<MedicalLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _fade = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sizeData = MediaQuery.of(context).size;

    final scale = sizeData.width < 360
        ? 0.75
        : sizeData.width < 420
            ? 0.9
            : 1.0;

    final animationSize = (widget.size * scale).clamp(120.0, 260.0);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🚑 Animation with glow
                AnimatedBuilder(
                  animation: _fade,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _fade.value,
                      child: Container(
                        height: animationSize,
                        width: animationSize,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A4EDC)
                                  .withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          "assets/animations/ambulancia.json",
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// 🧠 Text (premium fade)
                if (widget.showText)
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: sizeData.width < 360 ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.4,
                    ),
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 14),

                /// ⏳ modern pill loader
                Container(
                  width: sizeData.width * 0.35,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: sizeData.width * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0A4EDC),
                            Color(0xFF38B6FF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// subtle status line
                Text(
                  "Synchronizing medical records...",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black45,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
