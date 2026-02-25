import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/core/constants/app_constants.dart';
import 'package:monbudget/data/models/user_model.dart';
import 'package:monbudget/data/repositories/auth_repository.dart';

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

      // Mettre à jour l'état
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: UserModel.fromJson(data['user']),
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
      state = AuthState();
    }
  }

  // VÉRIFIER SI CONNECTÉ
  Future<void> checkAuth() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }
}

// ================= AUTH PROVIDER =================
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
