import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/app_repository.dart';

/// 更新服务器配置参数
class UpdateServerConfigParams {
  final String host;
  final int port;

  const UpdateServerConfigParams({required this.host, required this.port});
}

/// 更新服务器配置用例
class UpdateServerConfig {
  final AppRepository repository;

  UpdateServerConfig(this.repository);

  Future<Either<Failure, void>> call(UpdateServerConfigParams params) async {
    return await repository.updateServerConfig(params.host, params.port);
  }
}
