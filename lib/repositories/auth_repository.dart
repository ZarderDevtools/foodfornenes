// lib/repositories/auth_repository.dart

import 'package:dio/dio.dart';
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

  /// Devuelve true solo si hay token y (si existe) el endpoint verify lo valida.
  Future<bool> hasValidSession() async {
    final token = await api.getAccessToken();
    if (token == null || token.isEmpty) return false;

    // Intentamos verificar token si el backend lo soporta.
    try {
      await api.post(
        '/api/v1/auth/jwt/verify/',
        data: {'token': token},
      );
      return true;
    } catch (e) {
      // Si el backend NO tiene verify, devolvería 404.
      // En ese caso, asumimos "hay sesión" y dejamos que falle cuando toque.
      if (e is ApiException && e.statusCode == 404) {
        return true;
      }

      // Para 401/403 u otros errores, limpiamos tokens y obligamos login.
      await api.clearTokens();
      return false;
    }
  }

  Future<void> logout() async {
    await api.clearTokens();
  }
}
