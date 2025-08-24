import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/app_info.dart';
import '../repositories/app_repository.dart';

/// 获取应用信息用例
class GetAppInfo {
  final AppRepository repository;

  GetAppInfo(this.repository);

  Future<Either<Failure, AppInfo>> call() async {
    return await repository.getAppInfo();
  }
}
