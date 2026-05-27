// lib/main.dart
import 'package:flutter/material.dart';

import 'local/app_database.dart';
import 'services/api_client.dart';
import 'services/global_sync_service.dart';
import 'services/pending_sync_service.dart';
import 'repositories/auth_repository.dart';
import 'screens/startup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home/home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crear ApiClient, AuthRepository y AppDatabase una sola vez
  final apiClient = await ApiClient.create();
  final authRepository = AuthRepository(apiClient);
  final db = AppDatabase();
  final pendingSyncService = PendingSyncService(api: apiClient, db: db);
  final syncService = GlobalSyncService(api: apiClient, db: db, pendingSync: pendingSyncService);

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
    db: db,
    syncService: syncService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AppDatabase db;
  final GlobalSyncService syncService;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
    required this.db,
    required this.syncService,
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
              db: db,
              syncService: syncService,
            ),
      },
    );
  }
}
