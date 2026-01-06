// lib/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

/// Excepción genérica de la API.
/// La usaremos para propagar errores controlados a la UI.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Claves donde guardaremos los tokens en el móvil
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';

  String? _accessToken; // cache en memoria

  ApiClient._internal(this._dio, this._storage);

  /// Fábrica para crear un ApiClient configurado.
  static Future<ApiClient> create() async {
    final storage = const FlutterSecureStorage();

    final options = BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dio = Dio(options);

    final client = ApiClient._internal(dio, storage);

    // Cargar token guardado (si lo hay)
    await client._loadStoredToken();

    // Interceptor para añadir Authorization en cada petición
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (client._accessToken != null) {
            options.headers['Authorization'] = 'Bearer ${client._accessToken}';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          // Aquí podríamos hacer lógica de refresh token en el futuro
          handler.next(e);
        },
      ),
    );

    return client;
  }

  /// Carga el token de acceso guardado en almacenamiento seguro.
  Future<void> _loadStoredToken() async {
    _accessToken = await _storage.read(key: _kAccessTokenKey);
  }

  /// Guarda access y refresh tokens tras un login.
  Future<void> saveTokens({
    required String access,
    String? refresh,
  }) async {
    _accessToken = access;
    await _storage.write(key: _kAccessTokenKey, value: access);

    if (refresh != null) {
      await _storage.write(key: _kRefreshTokenKey, value: refresh);
    }
  }

  /// Borra tokens (logout).
  Future<void> clearTokens() async {
    _accessToken = null;
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
  }

  /// Obtiene el refresh token (para futuros flujos de refresh JWT).
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _kRefreshTokenKey);
  }

  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  // --------------------
  // Métodos HTTP genéricos
  // --------------------

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      return await _dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      return await _dio.patch(
        path,
        queryParameters: queryParameters,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // --------------------
  // Manejo de errores Dio -> ApiException
  // --------------------
  ApiException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // 👇 DEBUG TEMPORAL (para saber qué pasa)
    print('--- DIO ERROR ---');
    print('type: ${e.type}');
    print('url: ${e.requestOptions.uri}');
    print('status: $statusCode');
    print('data: $data');
    print('message: ${e.message}');
    print('---------------');

    String message;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Timeout de conexión con el servidor.';
    } else if (e.type == DioExceptionType.badResponse) {
      // Errores HTTP con respuesta (4xx, 5xx)
      if (statusCode == 400) {
        message = 'Petición inválida.';
      } else if (statusCode == 401) {
        message = 'No autorizado. Vuelve a iniciar sesión.';
      } else if (statusCode == 403) {
        message = 'No tienes permisos para realizar esta acción.';
      } else if (statusCode == 404) {
        message = 'Recurso no encontrado.';
      } else if (statusCode != null && statusCode >= 500) {
        message = 'Error en el servidor. Inténtalo de nuevo más tarde.';
      } else {
        message = 'Error inesperado en la respuesta del servidor.';
      }
    } else if (e.type == DioExceptionType.unknown) {
      message = 'Error de red. Revisa tu conexión a internet.';
    } else {
      message = 'Error de comunicación con el servidor.';
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }
}
