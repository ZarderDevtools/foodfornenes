// lib/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import 'dart:async';

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
  late final Dio _refreshDio;
  final FlutterSecureStorage _storage;

  // Claves donde guardaremos los tokens en el móvil
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';

  String? _accessToken; // cache en memoria
  bool _isRefreshing = false;
  final List<void Function(String newAccess)> _refreshQueue = [];

  // Stream para notificar sesión expirada a la capa de UI
  final _sessionExpiredController = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;
  bool _isHandlingSessionExpiry = false;

  void _triggerSessionExpiry() {
    if (_isHandlingSessionExpiry) return;
    _isHandlingSessionExpiry = true;
    clearTokens().then((_) => _sessionExpiredController.add(null));
  }

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

    client._refreshDio = Dio(BaseOptions(
      baseUrl: dio.options.baseUrl,
      connectTimeout: dio.options.connectTimeout,
      receiveTimeout: dio.options.receiveTimeout,
      sendTimeout: dio.options.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

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
        onError: (DioException e, handler) async {
          // Aquí podríamos hacer lógica de refresh token en el futuro
          final status = e.response?.statusCode;
          final data = e.response?.data;

          final isTokenNotValid =
              status == 401 && data is Map && data['code'] == 'token_not_valid';

          final alreadyRetried = e.requestOptions.extra['retried'] == true;

          // Si no es expiración de token, o ya reintentamos, seguimos normal
          if (!isTokenNotValid || alreadyRetried) {
            if (status == 401) client._triggerSessionExpiry();
            return handler.next(e);
          }

          // Si no hay refresh token, no podemos refrescar
          final refresh = await client.getRefreshToken();
          if (refresh == null || refresh.isEmpty) {
            client._triggerSessionExpiry();
            return handler.next(e);
          }

          try {
            final completer = Completer<Response<dynamic>>();

            // Encolamos esta request para reintentarlo cuando tengamos token nuevo
            client._refreshQueue.add((newAccess) async {
              final opts = e.requestOptions;
              opts.extra['retried'] = true;
              opts.headers['Authorization'] = 'Bearer $newAccess';

              final response = await dio.fetch(opts);
              completer.complete(response);
            });

            // Solo la primera request lanza el refresh real
            if (!client._isRefreshing) {
              client._isRefreshing = true;

              await client.refreshAccessToken(); // usa _refreshDio y guarda el nuevo access

              final newAccess = await client.getAccessToken();
              if (newAccess == null || newAccess.isEmpty) {
                throw Exception('Refresh OK pero no hay access guardado');
              }

              // Ejecuta todas las requests pendientes
              final queued = List.of(client._refreshQueue);
              client._refreshQueue.clear();
              for (final fn in queued) {
                fn(newAccess);
              }

              client._isRefreshing = false;
            }

            final response = await completer.future;
            return handler.resolve(response);
          } catch (_) {
            client._isRefreshing = false;
            client._refreshQueue.clear();
            client._triggerSessionExpiry();
            return handler.next(e);
          }
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
    _isHandlingSessionExpiry = false; // permite manejar futuros 401 tras re-login
    _accessToken = access;
    await _storage.write(key: _kAccessTokenKey, value: access);

    if (refresh != null) {
      await _storage.write(key: _kRefreshTokenKey, value: refresh);
    }
    
    final storedRefresh = await _storage.read(key: _kRefreshTokenKey);
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

  Future<void> refreshAccessToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw ApiException(statusCode: 401, message: 'No hay refresh token guardado.');
    }

    final res = await _refreshDio.post(
      '/api/v1/auth/jwt/refresh/',
      data: {'refresh': refresh},
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en refresh: $data');
    }

    final newAccess = data['access'] as String?;
    final newRefresh = data['refresh'] as String?; // por si el backend rota refresh

    if (newAccess == null || newAccess.isEmpty) {
      throw Exception('Refresh sin access: $data');
    }

    await saveTokens(access: newAccess, refresh: newRefresh);
  }


  // --------------------
  // Manejo de errores Dio -> ApiException
  // --------------------
  ApiException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;


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
