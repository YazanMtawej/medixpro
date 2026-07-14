import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/localization/locale_cubit.dart';

/// A compact pill button that switches the app language between English and
/// Arabic. It shows the language you would switch **to** (so it reads as an
/// action), together with a translate icon.
///
/// Designed to sit on top of a colored/gradient surface (login header,
/// register app bar), so it uses a translucent white style by default.
/// Tapping it calls [LocaleCubit.toggleLocale], which persists the choice and
/// rebuilds the whole app (including RTL flipping for Arabic).
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever the locale changes so the label stays correct.
    final isArabic = context.watch<LocaleCubit>().isArabic;

    // Label = the language the user will switch TO.
    final targetLabel = isArabic ? 'English' : 'العربية';

    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.read<LocaleCubit>().toggleLocale(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                targetLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
