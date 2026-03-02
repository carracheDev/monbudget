class AppConstants {
  // URL de base de l'API
static const String baseUrl = 'http://10.209.110.47:3000';//hostname -I

  //Clées de stockage local
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyOnboardingDone = 'onboading_done';
  static const String keyUserId = 'user_id';

  // Timeouts
  static const int connectTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;
}
