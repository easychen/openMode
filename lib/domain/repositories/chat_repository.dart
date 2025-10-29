import 'package:dartz/dartz.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../../core/errors/failures.dart';

/// 聊天仓储接口
abstract class ChatRepository {
  /// 获取会话列表
  Future<Either<Failure, List<ChatSession>>> getSessions({String? directory});

  /// 获取会话详情
  Future<Either<Failure, ChatSession>> getSession(String projectId, String sessionId, {String? directory});

  /// 创建会话
  Future<Either<Failure, ChatSession>> createSession(String projectId, SessionCreateInput input, {String? directory});

  /// 更新会话
  Future<Either<Failure, ChatSession>> updateSession(
    String projectId,
    String sessionId,
    SessionUpdateInput input, {
    String? directory,
  });

  /// 删除会话
  Future<Either<Failure, void>> deleteSession(String projectId, String sessionId, {String? directory});

  /// 分享会话
  Future<Either<Failure, ChatSession>> shareSession(String projectId, String sessionId, {String? directory});

  /// 取消分享会话
  Future<Either<Failure, ChatSession>> unshareSession(String projectId, String sessionId, {String? directory});

  /// 获取会话消息列表
  Future<Either<Failure, List<ChatMessage>>> getMessages(String projectId, String sessionId, {String? directory});

  /// 获取消息详情
  Future<Either<Failure, ChatMessage>> getMessage(
    String projectId,
    String sessionId,
    String messageId, {
    String? directory,
  });

  /// 发送聊天消息
  Stream<Either<Failure, ChatMessage>> sendMessage(
    String projectId,
    String sessionId,
    ChatInput input, {
    String? directory,
  });

  /// 中止会话
  Future<Either<Failure, void>> abortSession(String projectId, String sessionId, {String? directory});

  /// 撤销消息
  Future<Either<Failure, void>> revertMessage(
    String projectId,
    String sessionId,
    String messageId, {
    String? directory,
  });

  /// 恢复撤销的消息
  Future<Either<Failure, void>> unrevertMessages(String projectId, String sessionId, {String? directory});

  /// 初始化会话（分析应用并创建 AGENTS.md）
  Future<Either<Failure, void>> initSession(
    String projectId,
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
    String? directory,
  });

  /// 总结会话
  Future<Either<Failure, void>> summarizeSession(String projectId, String sessionId, {String? directory});
}
