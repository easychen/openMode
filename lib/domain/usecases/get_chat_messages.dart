import 'package:dartz/dartz.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// 获取聊天消息列表用例
class GetChatMessages {
  const GetChatMessages(this.repository);

  final ChatRepository repository;

  /// 执行获取消息列表
  Future<Either<Failure, List<ChatMessage>>> call(
    GetChatMessagesParams params,
  ) async {
    return repository.getMessages(params.sessionId);
  }
}

/// 获取聊天消息列表参数
class GetChatMessagesParams {
  const GetChatMessagesParams({required this.sessionId});

  final String sessionId;
}
