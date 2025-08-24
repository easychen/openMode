import 'package:equatable/equatable.dart';

/// 失败结果基类
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// 网络失败
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// 解析失败
class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

/// 验证失败
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 文件失败
class FileFailure extends Failure {
  const FileFailure(super.message);
}

/// 未找到失败
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
