import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Ajouter l'intercepteur
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Récupérer le token depuis le stockage sécurisé
          final token = await _storage.read(key: AppConstants.keyAccessToken);
          
          // Si token existe → l'ajouter dans le header
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
      
      onError: (error, handler) async {
        // Si erreur 401 → token expiré
       if (error.response?.statusCode == 401) {
    try {
      // Récupérer le refresh token
      final refreshToken = await _storage.read(
        key: AppConstants.keyRefreshToken
      );

      if (refreshToken == null) {
        return handler.next(error);
      }

      // Demander un nouveau token
      final response = await _dio.post('/auth/refresh', 
        data: {'refreshToken': refreshToken}
      );

      // Sauvegarder le nouveau token
      final newToken = response.data['accessToken'];
      await _storage.write(
        key: AppConstants.keyAccessToken, 
        value: newToken
      );

      // Relancer la requête originale avec le nouveau token
      error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await _dio.fetch(error.requestOptions);
      return handler.resolve(retryResponse);

    } catch (e) {
      // Refresh échoué → déconnecter
      await _storage.deleteAll();
      return handler.next(error);
    }
  }
  return handler.next(error);
   },
      ),
    );
  }

  Dio get dio => _dio;
}