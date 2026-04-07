// lib/main.dart
import 'package:flutter/material.dart';

import 'services/api_client.dart';
import 'repositories/auth_repository.dart';
import 'screens/startup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home/home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crear ApiClient y AuthRepository una sola vez
  final apiClient = await ApiClient.create();
  final authRepository = AuthRepository(apiClient);

  // Redirigir a login si cualquier llamada API devuelve 401 irrecuperable
  apiClient.onSessionExpired.listen((_) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  });

  runApp(MyApp(
    apiClient: apiClient,
    authRepository: authRepository,
  ));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodForNenes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      // Ruta inicial: Startup
      home: StartupScreen(
        authRepository: authRepository,
        apiClient: apiClient,
      ),
      // Definimos rutas con nombre por comodidad
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(
              authRepository: authRepository,
              apiClient: apiClient,
            ),
        HomeScreen.routeName: (context) => HomeScreen(
              apiClient: apiClient,
              authRepository: authRepository,
            ),
      },
    );
  }
}
