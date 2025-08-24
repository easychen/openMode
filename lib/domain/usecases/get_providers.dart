import 'package:dartz/dartz.dart';
import '../entities/provider.dart';
import '../repositories/app_repository.dart';
import '../../core/errors/failures.dart';

/// 获取提供商用例
class GetProviders {
  final AppRepository repository;

  GetProviders(this.repository);

  Future<Either<Failure, ProvidersResponse>> call() async {
    return await repository.getProviders();
  }
}
