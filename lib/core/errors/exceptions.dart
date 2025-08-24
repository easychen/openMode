/// Application exception definitions
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Server exception
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Parse exception
class ParseException extends AppException {
  const ParseException(super.message);
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// File exception
class FileException extends AppException {
  const FileException(super.message);
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
