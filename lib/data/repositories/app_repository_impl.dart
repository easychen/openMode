import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/provider.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_remote_datasource.dart';
import '../datasources/app_local_datasource.dart';
import '../../core/network/dio_client.dart';

/// 应用仓库实现
class AppRepositoryImpl implements AppRepository {
  final AppRemoteDataSource remoteDataSource;
  final AppLocalDataSource localDataSource;
  final DioClient dioClient;

  AppRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.dioClient,
  });

  @override
  Future<Either<Failure, AppInfo>> getAppInfo() async {
    try {
      final appInfoModel = await remoteDataSource.getAppInfo();
      return Right(appInfoModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> initializeApp() async {
    try {
      final result = await remoteDataSource.initializeApp();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkConnection() async {
    try {
      await remoteDataSource.getAppInfo();
      return const Right(true);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateServerConfig(
    String host,
    int port,
  ) async {
    try {
      // 保存到本地存储
      await localDataSource.saveServerHost(host);
      await localDataSource.saveServerPort(port);

      // 更新 Dio 客户端的基础 URL
      final baseUrl = 'http://$host:$port';
      dioClient.updateBaseUrl(baseUrl);

      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// 处理 Dio 异常
  Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('连接超时');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            return NetworkFailure('客户端错误', statusCode);
          } else if (statusCode >= 500) {
            return ServerFailure('服务器错误', statusCode);
          }
        }
        return const ServerFailure('响应错误');
      case DioExceptionType.cancel:
        return const NetworkFailure('请求被取消');
      case DioExceptionType.connectionError:
        return const NetworkFailure('网络连接错误');
      case DioExceptionType.unknown:
        return NetworkFailure('未知网络错误: ${e.message}');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('证书错误');
    }
  }

  @override
  Future<Either<Failure, ProvidersResponse>> getProviders() async {
    try {
      final providersModel = await remoteDataSource.getProviders();
      return Right(providersModel.toDomain());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
