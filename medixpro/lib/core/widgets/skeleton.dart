import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const Skeleton({
    super.key,
    this.width  = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width:  widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

// ─── Ready-made skeleton cards ────────────────────────────────────────────────

class PatientCardSkeleton extends StatelessWidget {
  final bool isDark;
  const PatientCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const Skeleton(width: 48, height: 48, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 14),
                const SizedBox(height: 8),
                Skeleton(width: MediaQuery.of(context).size.width * 0.4, height: 11),
                const SizedBox(height: 6),
                Skeleton(width: MediaQuery.of(context).size.width * 0.3, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentCardSkeleton extends StatelessWidget {
  final bool isDark;
  const AppointmentCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Skeleton(width: 40, height: 40, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(height: 14),
                    const SizedBox(height: 6),
                    Skeleton(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 11),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(children: [
            Skeleton(width: MediaQuery.of(context).size.width * 0.25, height: 11),
            const SizedBox(width: 16),
            Skeleton(width: MediaQuery.of(context).size.width * 0.2, height: 11),
          ]),
        ],
      ),
    );
  }
}

class DashboardStatsSkeleton extends StatelessWidget {
  final bool isDark;
  const DashboardStatsSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: List.generate(4, (_) => _statCard()),
    );
  }

  Widget _statCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Skeleton(width: 36, height: 36, radius: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(width: 48, height: 26),
                const SizedBox(height: 6),
                const Skeleton(height: 11),
              ],
            ),
          ],
        ),
      );
}

/// استخدم هذا في أي قائمة
class SkeletonList extends StatelessWidget {
  final Widget Function() itemBuilder;
  final int count;

  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics:     const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount:   count,
      itemBuilder: (_, __) => itemBuilder(),
    );
  }
}