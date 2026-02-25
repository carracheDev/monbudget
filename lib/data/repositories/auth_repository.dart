import 'package:dio/dio.dart';
import 'package:monbudget/data/models/user_model.dart';
import 'package:monbudget/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // REGISTER
  Future<UserModel> register({
    required String nomComplet,
    required String email,
    required String motDePasse,
  }) async {
    try {
      return await _authService.register(
        nomComplet: nomComplet,
        email: email,
        motDePasse: motDePasse,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erreur inscription");
    } catch (e) {
      throw Exception('Erreur inattendue');
    }
  }

  /// LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    try {
      return await _authService.login(email: email, motDePasse: motDePasse);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erreur connexion");
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }

  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    try {
      return await _authService.refresh(refreshToken: refreshToken);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erreur de deconnexion");
    } catch (e) {
      throw Exception("Erreur inatendue");
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      return await _authService.logout(refreshToken: refreshToken);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Erreur de deconnexion");
    } catch (e) {
      throw Exception('Erreur inatendue');
    }
  }
}
