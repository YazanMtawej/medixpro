import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';


class RegisterPage extends StatefulWidget {
  final String  role;
  final String? doctorSecretKey;

  const RegisterPage({
    super.key,
    required this.role,
    this.doctorSecretKey,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  String _gender      = "male";
  bool   _obscure     = true;

  bool get _isPatient => widget.role == "patient";

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      username:        _usernameCtrl.text.trim(),
      email:           _emailCtrl.text.trim(),
      password:        _passwordCtrl.text,
      role:            widget.role,
      doctorSecretKey: widget.doctorSecretKey,
      fullName:        _isPatient ? _fullNameCtrl.text.trim() : null,
      age:             _isPatient ? _ageCtrl.text.trim()      : null,
      phone:           _isPatient ? _phoneCtrl.text.trim()    : null,
      gender:          _isPatient ? _gender                   : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
              context, "/dashboard", (_) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:         Text(state.message),
            backgroundColor: AppColors.error,
            behavior:        SnackBarBehavior.floating,
            margin:          const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
                title: Text(
                  _isPatient ? l10n.patientRegistration : l10n.doctorRegistration,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Account Information ───────────────────────────
                      _label(l10n.accountInformation),
                      const SizedBox(height: 12),
                      _field(
                        ctrl:  _usernameCtrl,
                        label: l10n.username,
                        icon:  Icons.person_outline,
                        isDark: isDark,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return l10n.usernameRequired;
                          if (v.trim().length < 3)
                            return l10n.atLeast3Chars;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _field(
                        ctrl:      _emailCtrl,
                        label:     l10n.email,
                        icon:      Icons.email_outlined,
                        isDark:    isDark,
                        inputType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return l10n.emailRequired;
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(v.trim()))
                            return l10n.enterValidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller:  _passwordCtrl,
                        obscureText: _obscure,
                        decoration: _decor(
                          l10n.password,
                          Icons.lock_outline,
                          isDark,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return l10n.passwordRequired;
                          if (v.length < 8)
                            return l10n.atLeast8Chars;
                          return null;
                        },
                      ),

                      // ─── Patient Profile Fields ────────────────────────
                      if (_isPatient) ...[
                        const SizedBox(height: 28),
                        _label(l10n.personalInformation),
                        const SizedBox(height: 12),

                        // Full Name
                        _field(
                          ctrl:  _fullNameCtrl,
                          label: l10n.fullName,
                          icon:  Icons.badge_outlined,
                          isDark: isDark,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.fullNameRequired
                                  : null,
                        ),
                        const SizedBox(height: 12),

                        // Age — digits only
                        TextFormField(
                          controller:  _ageCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration:
                              _decor(l10n.age, Icons.cake_outlined, isDark),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return l10n.ageRequired;
                            final age = int.tryParse(v);
                            if (age == null || age <= 0 || age > 150)
                              return l10n.enterValidAge;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Phone — numbers + + - space
                        TextFormField(
                          controller:  _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d\+\-\s]')),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          decoration: _decor(
                              l10n.phoneNumber, Icons.phone_outlined, isDark),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return l10n.phoneRequired;
                            final digits =
                                v.replaceAll(RegExp(r'\D'), '');
                            if (digits.length < 7)
                              return l10n.enterValidPhone;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Gender selector
                        Text(l10n.gender,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            )),
                        const SizedBox(height: 8),
                        _genderSelector(isDark),
                      ],

                      const SizedBox(height: 32),

                      // ─── Submit ───────────────────────────────────────
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return SizedBox(
                            width:  double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white))
                                  : Text(
                                      l10n.createAccount,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
      );

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller:   ctrl,
        keyboardType: inputType,
        decoration:   _decor(label, icon, isDark),
        validator:    validator,
      );

  InputDecoration _decor(String label, IconData icon, bool isDark,
      {Widget? suffix}) =>
      InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        suffixIcon: suffix,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
      );

  Widget _genderSelector(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Row(
        children: [
          _genderOption("male",   Icons.male_rounded,   l10n.male,   Colors.blue,  isDark),
          const SizedBox(width: 12),
          _genderOption("female", Icons.female_rounded, l10n.female, Colors.pink,  isDark),
        ],
      );
  }

  Widget _genderOption(String value, IconData icon, String label,
      Color color, bool isDark) =>
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _gender = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: _gender == value
                  ? color
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _gender == value
                    ? color
                    : (isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: _gender == value
                        ? Colors.white
                        : AppColors.lightTextSecondary),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _gender == value
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    )),
              ],
            ),
          ),
        ),
      );
}