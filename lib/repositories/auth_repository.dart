// lib/repositories/auth_repository.dart

import '../services/api_client.dart';

class AuthRepository {
  final ApiClient api;

  AuthRepository(this.api);

  /// Login contra el backend y guardado de tokens en secure storage.
  Future<void> login(String username, String password) async {
    final res = await api.post(
      '/api/v1/auth/jwt/create/',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en login: $data');
    }

    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;

    if (access == null || access.isEmpty) {
      throw Exception('Login sin token access: $data');
    }

    await api.saveTokens(access: access, refresh: refresh);
  }

  /// Devuelve true si existe sesión local (token presente y no vacío).
  /// La validación real contra el backend la gestiona el interceptor de Dio
  /// en el momento natural de cada petición.
  Future<bool> hasValidSession() async {
    final token = await api.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await api.clearTokens();
  }
}
