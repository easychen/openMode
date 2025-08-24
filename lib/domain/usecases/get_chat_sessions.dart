import 'package:dartz/dartz.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// 获取聊天会话列表用例
class GetChatSessions {
  const GetChatSessions(this.repository);

  final ChatRepository repository;

  /// 执行获取会话列表
  Future<Either<Failure, List<ChatSession>>> call(
    GetChatSessionsParams params,
  ) async {
    return repository.getSessions(params.workspaceId);
  }
}

/// 获取聊天会话列表参数
class GetChatSessionsParams {
  const GetChatSessionsParams({required this.workspaceId});

  final String workspaceId;
}
