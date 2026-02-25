import 'package:monbudget/core/config/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // INSCRIPTION
  Future<UserModel> register({
    required String nomComplet,
    required String email,
    required String motDePasse,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'nomComplet': nomComplet,
        'email': email,
        'motDePasse': motDePasse,
      },
    );
    return UserModel.fromJson(response.data['user']);
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'motDePasse': motDePasse},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    final response = await _apiClient.dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return response.data;
  }

  Future<void> logout({required String refreshToken}) async {
    await _apiClient.dio.post(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
