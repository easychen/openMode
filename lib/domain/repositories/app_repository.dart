import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/app_info.dart';
import '../entities/provider.dart';

/// 应用仓库接口
abstract class AppRepository {
  /// 获取应用信息
  Future<Either<Failure, AppInfo>> getAppInfo();

  /// 初始化应用
  Future<Either<Failure, bool>> initializeApp();

  /// 检查服务器连接
  Future<Either<Failure, bool>> checkConnection();

  /// 更新服务器配置
  Future<Either<Failure, void>> updateServerConfig(String host, int port);

  /// 获取提供商信息
  Future<Either<Failure, ProvidersResponse>> getProviders();
}
