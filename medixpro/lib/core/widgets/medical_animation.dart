import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MedicalAnimation extends StatelessWidget {
  final String asset;
  final double size;
  final bool repeat;

  const MedicalAnimation({
    super.key,
    required this.asset,
    this.size = 180,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final adaptiveSize = size > screenSize.shortestSide * 0.6
        ? screenSize.shortestSide * 0.6
        : size;

    return RepaintBoundary(
      child: SizedBox(
        height: adaptiveSize,
        width: adaptiveSize,
        child: Lottie.asset(
          asset,
          repeat: repeat,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}