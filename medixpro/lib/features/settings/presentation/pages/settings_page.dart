import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/widgets/medical_loading.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoggedOut) {
          Navigator.pushNamedAndRemoveUntil(
              context, "/login", (_) => false);
        } else if (state is SettingsError) {
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
        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          body: CustomScrollView(
            slivers: [
              // ─── AppBar ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
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
                  title: const Text(
                    "Settings",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: AppColors.primary,
              ),

              if (state is SettingsLoading)
               const SliverFillRemaining(
                  child: Center(child: MedicalLoading()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ─── Account ────────────────────────────────
                      _SectionLabel("Account", isDark),
                      const SizedBox(height: 8),
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: "Profile",
                        subtitle: "View and edit your profile",
                        isDark: isDark,
                        onTap: () =>
                            Navigator.pushNamed(context, "/profile"),
                      ),

                      const SizedBox(height: 20),

                      // ─── Notifications ───────────────────────────
                      _SectionLabel("Notifications", isDark),
                      const SizedBox(height: 8),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: "Notifications",
                        subtitle: "View all alerts and updates",
                        isDark: isDark,
                        onTap: () => Navigator.pushNamed(
                            context, "/notifications"),
                        trailing: _NotifBadge(isDark: isDark),
                      ),

                      const SizedBox(height: 20),

                      // ─── Appearance ──────────────────────────────
                      _SectionLabel("Appearance", isDark),
                      const SizedBox(height: 8),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, mode) {
                          final isDarkMode = mode == ThemeMode.dark;
                          return _SettingsTile(
                            icon: isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            title: isDarkMode ? "Light Mode" : "Dark Mode",
                            subtitle: "Switch app appearance",
                            isDark: isDark,
                            onTap: () =>
                                context.read<ThemeCubit>().toggleTheme(),
                            trailing: Switch(
                              value: isDarkMode,
                              onChanged: (_) =>
                                  context.read<ThemeCubit>().toggleTheme(),
                              activeColor: AppColors.primary,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // ─── Logout ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text("Logout",
                              style: TextStyle(fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _confirmLogout(context),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text("Logout",
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<SettingsCubit>().logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class _NotifBadge extends StatelessWidget {
  final bool isDark;
  const _NotifBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is! NotificationsLoaded || state.unreadCount == 0) {
          return const Icon(Icons.arrow_forward_ios_rounded, size: 14);
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${state.unreadCount}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData  icon;
  final String    title;
  final String    subtitle;
  final bool      isDark;
  final VoidCallback onTap;
  final Widget?   trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}