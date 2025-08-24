import 'package:dartz/dartz.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// 发送聊天消息用例
class SendChatMessage {
  const SendChatMessage(this.repository);

  final ChatRepository repository;

  /// 执行发送消息
  Stream<Either<Failure, ChatMessage>> call(SendChatMessageParams params) {
    return repository.sendMessage(params.sessionId, params.input);
  }
}

/// 发送聊天消息参数
class SendChatMessageParams {
  const SendChatMessageParams({required this.sessionId, required this.input});

  final String sessionId;
  final ChatInput input;
}
