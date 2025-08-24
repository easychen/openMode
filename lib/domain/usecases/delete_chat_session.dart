import 'package:dartz/dartz.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// 删除聊天会话参数
class DeleteChatSessionParams {
  const DeleteChatSessionParams({required this.sessionId});

  final String sessionId;
}

/// 删除聊天会话用例
class DeleteChatSession {
  const DeleteChatSession(this.repository);

  final ChatRepository repository;

  /// 执行删除会话
  Future<Either<Failure, void>> call(DeleteChatSessionParams params) async {
    return await repository.deleteSession(params.sessionId);
  }
}
