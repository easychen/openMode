import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/app_repository.dart';

/// 检查服务器连接用例
class CheckConnection {
  final AppRepository repository;

  CheckConnection(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkConnection();
  }
}
