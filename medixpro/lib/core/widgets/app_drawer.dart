import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:medixpro/core/localization/locale_cubit.dart';
import 'package:medixpro/core/theme/app_colors.dart';
import 'package:medixpro/core/theme/theme_cubit.dart';
import 'package:medixpro/l10n/app_localizations.dart';

/// App-wide navigation drawer.
///
/// Hosts the language switch (English ⇄ Arabic) as a [SwitchListTile],
/// alongside the dark-mode toggle.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientLight,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_hospital_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Language switch ────────────────────────────────────
            BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                final isArabic = locale.languageCode == 'ar';
                return SwitchListTile(
                  secondary: const Icon(Icons.language_rounded,
                      color: AppColors.primary),
                  title: Text(l10n.language),
                  subtitle: Text(
                    isArabic ? l10n.arabic : l10n.english,
                  ),
                  value: isArabic,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) =>
                      context.read<LocaleCubit>().toggleLocale(),
                );
              },
            ),

            // ─── Dark-mode switch ───────────────────────────────────
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                final isDarkMode = mode == ThemeMode.dark;
                return SwitchListTile(
                  secondary: Icon(
                    isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(
                      isDarkMode ? l10n.darkMode : l10n.lightMode),
                  subtitle: Text(l10n.appearanceSubtitle),
                  value: isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) =>
                      context.read<ThemeCubit>().toggleTheme(),
                );
              },
            ),

            const Spacer(),

            // ─── Settings shortcut ──────────────────────────────────
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: AppColors.primary),
              title: Text(l10n.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/settings");
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
