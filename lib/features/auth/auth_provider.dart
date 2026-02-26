import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/core/constants/app_constants.dart';
import 'package:monbudget/data/models/user_model.dart';
import 'package:monbudget/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================= AUTH STATE =================
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// ================= AUTH NOTIFIER =================
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._authRepository) : super(AuthState());

  // LOGIN
  Future<void> login({
    required String email,
    required String motDePasse,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _authRepository.login(
        email: email,
        motDePasse: motDePasse,
      );

      // Sauvegarder les tokens
      await _storage.write(
        key: AppConstants.keyAccessToken,
        value: data['accessToken'],
      );
      await _storage.write(
        key: AppConstants.keyRefreshToken,
        value: data['refreshToken'],
      );

      // Sauvegarder le user dans SharedPreferences
      final user = UserModel.fromJson(data['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nom', user.nomComplet);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_id', user.id);

      // Mettre à jour l'état
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // REGISTER
  Future<void> register({
    required String nomComplet,
    required String email,
    required String motDePasse,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.register(
        nomComplet: nomComplet,
        email: email,
        motDePasse: motDePasse,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.keyRefreshToken,
      );
      if (refreshToken != null) {
        await _authRepository.logout(refreshToken: refreshToken);
      }
    } finally {
      await _storage.deleteAll();
      // Supprimer aussi les prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_nom');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      state = AuthState();
    }
  }

  // VÉRIFIER SI CONNECTÉ
  Future<void> checkAuth() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final nom = prefs.getString('user_nom');
      final email = prefs.getString('user_email');
      final id = prefs.getString('user_id');

      if (nom != null && email != null && id != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: UserModel(id: id, nomComplet: nom, email: email),
        );
      }
    }
  }
}

// ================= AUTH PROVIDER =================
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
