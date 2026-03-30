import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/network/api_client.dart';
import 'package:medixpro/core/storage/token_storage.dart';
import 'package:medixpro/features/dashboard/presentation/pages/dashboard_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final TokenStorage tokenStorage;

  @override
  void initState() {
    super.initState();
    tokenStorage = context.read<TokenStorage>();
    _checkTokenAndRedirect();
  }

  Future<void> _checkTokenAndRedirect() async {
    await Future.delayed(const Duration(seconds: 2));

    final hasToken = await tokenStorage.hasToken();

    if (!mounted) return;

    if (hasToken) {
      try {
        await context.read<ApiClient>().dio.get("patients/");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );

      } on DioException catch (e) {

        /// 🔥 الحل الحقيقي هنا
        if (e.response?.statusCode == 401) {
          /// token expired فقط
          await tokenStorage.clear();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          /// ❗ أي خطأ ثاني (network / server down)
          /// لا تمسح التوكن
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }

      } catch (e) {
        /// fallback (نادر)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }

    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              "MedixPro",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}