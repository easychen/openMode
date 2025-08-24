/// 应用级别常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'OpenCode Mobile';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Mobile client for opencode AI assistant';

  // 存储键名
  static const String serverHostKey = 'server_host';
  static const String serverPortKey = 'server_port';
  static const String apiKeyKey = 'api_key';
  static const String selectedProviderKey = 'selected_provider';
  static const String selectedModelKey = 'selected_model';
  static const String themeKey = 'theme_mode';
  static const String lastSessionIdKey = 'last_session_id';

  // 默认配置
  static const String defaultTheme = 'system';
  static const int maxMessageLength = 10000;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // UI常量
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // 动画持续时间
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // 错误消息
  static const String networkError = '网络连接错误';
  static const String serverError = '服务器错误';
  static const String unknownError = '未知错误';
  static const String connectionTimeout = '连接超时';
  static const String invalidResponse = '无效响应';
}
