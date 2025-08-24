import 'package:dartz/dartz.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../../core/errors/failures.dart';

/// 聊天仓储接口
abstract class ChatRepository {
  /// 获取会话列表
  Future<Either<Failure, List<ChatSession>>> getSessions(String workspaceId);

  /// 获取会话详情
  Future<Either<Failure, ChatSession>> getSession(String sessionId);

  /// 创建会话
  Future<Either<Failure, ChatSession>> createSession(SessionCreateInput input);

  /// 更新会话
  Future<Either<Failure, ChatSession>> updateSession(
    String sessionId,
    SessionUpdateInput input,
  );

  /// 删除会话
  Future<Either<Failure, void>> deleteSession(String sessionId);

  /// 分享会话
  Future<Either<Failure, ChatSession>> shareSession(String sessionId);

  /// 取消分享会话
  Future<Either<Failure, ChatSession>> unshareSession(String sessionId);

  /// 获取会话消息列表
  Future<Either<Failure, List<ChatMessage>>> getMessages(String sessionId);

  /// 获取消息详情
  Future<Either<Failure, ChatMessage>> getMessage(
    String sessionId,
    String messageId,
  );

  /// 发送聊天消息
  Stream<Either<Failure, ChatMessage>> sendMessage(
    String sessionId,
    ChatInput input,
  );

  /// 中止会话
  Future<Either<Failure, void>> abortSession(String sessionId);

  /// 撤销消息
  Future<Either<Failure, void>> revertMessage(
    String sessionId,
    String messageId,
  );

  /// 恢复撤销的消息
  Future<Either<Failure, void>> unrevertMessages(String sessionId);

  /// 初始化会话（分析应用并创建 AGENTS.md）
  Future<Either<Failure, void>> initSession(
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
  });

  /// 总结会话
  Future<Either<Failure, void>> summarizeSession(String sessionId);
}
