/// 应用异常定义
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// 认证异常
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException(super.message);
}

/// 解析异常
class ParseException extends AppException {
  const ParseException(super.message);
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// 文件异常
class FileException extends AppException {
  const FileException(super.message);
}

/// 未找到异常
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
