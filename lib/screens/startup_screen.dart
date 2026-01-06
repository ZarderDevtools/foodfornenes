// lib/screens/startup_screen.dart
import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../services/api_client.dart';
import 'login_screen.dart';
import 'home/home_screen.dart';

class StartupScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final ApiClient apiClient;

  const StartupScreen({
    super.key,
    required this.authRepository,
    required this.apiClient,
  });

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final hasSession = await widget.authRepository.hasValidSession();

    if (!mounted) return;

    if (hasSession) {
      // Ir a Home
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);

    } else {
      // ir a Login
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla sencilla tipo "splash" mientras decide a dónde ir
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'FoodForNenes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
