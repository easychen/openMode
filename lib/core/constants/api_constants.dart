/// API相关常量定义
class ApiConstants {
  // 默认服务器配置
  static const String defaultHost = '127.0.0.1';
  static const int defaultPort = 4096;
  static const String defaultBaseUrl = 'http://$defaultHost:$defaultPort';

  // API端点
  static const String projectEndpoint = '/project';
  static const String providerEndpoint = '/provider';
  static const String configEndpoint = '/config';
  static const String sessionEndpoint = '/session';
  static const String agentEndpoint = '/agent';
  static const String fileEndpoint = '/file';
  static const String findEndpoint = '/find';
  static const String eventEndpoint = '/event';
  static const String authEndpoint = '/auth';
  static const String tuiEndpoint = '/tui';
  static const String logEndpoint = '/log';

  // HTTP方法
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';

  // 请求头
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';

  // 超时配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);
}
