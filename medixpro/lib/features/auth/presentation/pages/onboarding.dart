import 'package:flutter/material.dart';
import 'package:medixpro/core/widgets/medical_animation.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<_OnboardingItem> get _items {
    final l10n = AppLocalizations.of(context);
    return [
      _OnboardingItem(
        title: l10n.onboardTitle1,
        subtitle: l10n.onboardSubtitle1,
        animation: "assets/animations/Doctor welcoming pacient.json",
        sizeFactor: 0.88,
      ),
      _OnboardingItem(
        title: l10n.onboardTitle2,
        subtitle: l10n.onboardSubtitle2,
        animation: "assets/animations/Islamic business woman with gestures up.json",
        sizeFactor: 0.88,
      ),
      _OnboardingItem(
        title: l10n.onboardTitle3,
        subtitle: l10n.onboardSubtitle3,
        animation: "assets/animations/DOCTOR.json",
        sizeFactor: 0.88,
      ),
    ];
  }

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A4EDC);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            /// 🔥 Pages
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (_, index) =>
                    _OnboardingContent(item: _items[index]),
              ),
            ),

            /// 🔥 Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// 🔥 Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _currentPage == _items.length - 1
                          ? l10n.startYourJourney
                          : l10n.continueLabel2,
                      key: ValueKey(_currentPage),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Footer
            Text(
              l10n.precisionHealthcare,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
class _OnboardingContent extends StatelessWidget {
  final _OnboardingItem item;

  const _OnboardingContent({required this.item});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A4EDC);

    final screenWidth = MediaQuery.of(context).size.width;

    /// 🔥 حساب الحجم بشكل ذكي
    final rawSize = screenWidth * item.sizeFactor;

    /// 🔥 حدود أمان (super مهم)
    final animationSize = rawSize.clamp(180.0, 320.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// 🔥 Animation responsive
        RepaintBoundary(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: MedicalAnimation(
              key: ValueKey(item.animation),
              asset: item.animation,
              size: animationSize,
            ),
          ),
        ),

        const SizedBox(height: 40),

        /// Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),

        const SizedBox(height: 14),

        /// Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 🔥 Model
class _OnboardingItem {
  final String title;
  final String subtitle;
  final String animation;
  final double sizeFactor; // 🔥 جديد

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.animation,
    required this.sizeFactor,
  });
}