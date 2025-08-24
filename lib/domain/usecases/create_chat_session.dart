import 'package:dartz/dartz.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// 创建聊天会话用例
class CreateChatSession {
  const CreateChatSession(this.repository);

  final ChatRepository repository;

  /// 执行创建会话
  Future<Either<Failure, ChatSession>> call(
    CreateChatSessionParams params,
  ) async {
    return repository.createSession(params.input);
  }
}

/// 创建聊天会话参数
class CreateChatSessionParams {
  const CreateChatSessionParams({required this.input});

  final SessionCreateInput input;
}
