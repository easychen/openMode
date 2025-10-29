/// Application level constants definition
class AppConstants {
  // App information
  static const String appName = 'OpenMode';
  static const String appSubtitle = 'Mobile App for OpenCode and more';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Mobile client for OpenCode AI assistant';

  // Storage keys
  static const String serverHostKey = 'server_host';
  static const String serverPortKey = 'server_port';
  static const String apiKeyKey = 'api_key';
  static const String selectedProviderKey = 'selected_provider';
  static const String selectedModelKey = 'selected_model';
  static const String themeKey = 'theme_mode';
  static const String lastSessionIdKey = 'last_session_id';
  static const String cachedSessionsKey = 'cached_sessions';
  static const String currentSessionIdKey = 'current_session_id';

  // Default configuration
  static const String defaultTheme = 'system';
  static const int maxMessageLength = 10000;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Animation duration
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error';
  static const String unknownError = 'Unknown error';
  static const String connectionTimeout = 'Connection timeout';
  static const String invalidResponse = 'Invalid response';
}
