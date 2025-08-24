import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/session.dart';
import '../entities/message.dart';

/// 会话仓库接口
abstract class SessionRepository {
  /// 获取所有会话
  Future<Either<Failure, List<Session>>> getSessions();

  /// 获取指定会话
  Future<Either<Failure, Session>> getSession(String sessionId);

  /// 创建新会话
  Future<Either<Failure, Session>> createSession({
    String? parentId,
    String? title,
  });

  /// 更新会话
  Future<Either<Failure, Session>> updateSession(
    String sessionId, {
    String? title,
  });

  /// 删除会话
  Future<Either<Failure, bool>> deleteSession(String sessionId);

  /// 获取子会话
  Future<Either<Failure, List<Session>>> getChildSessions(String sessionId);

  /// 分享会话
  Future<Either<Failure, Session>> shareSession(String sessionId);

  /// 取消分享会话
  Future<Either<Failure, Session>> unshareSession(String sessionId);

  /// 中止会话
  Future<Either<Failure, bool>> abortSession(String sessionId);

  /// 总结会话
  Future<Either<Failure, bool>> summarizeSession(
    String sessionId,
    String providerId,
    String modelId,
  );

  /// 获取会话消息
  Future<Either<Failure, List<Message>>> getSessionMessages(String sessionId);

  /// 发送消息
  Future<Either<Failure, Message>> sendMessage({
    required String sessionId,
    required String providerId,
    required String modelId,
    required List<MessagePart> parts,
    String? messageId,
    String? agent,
    String? system,
    Map<String, bool>? tools,
  });

  /// 撤销消息
  Future<Either<Failure, Session>> revertMessage(
    String sessionId,
    String messageId, {
    String? partId,
  });

  /// 恢复撤销的消息
  Future<Either<Failure, Session>> unrevertMessages(String sessionId);
}

/// 消息部分基类
abstract class MessagePart {
  final String type;

  const MessagePart({required this.type});
}

/// 文本消息部分
class TextMessagePart extends MessagePart {
  final String text;
  final bool? synthetic;

  const TextMessagePart({required this.text, this.synthetic})
    : super(type: 'text');
}

/// 文件消息部分
class FileMessagePart extends MessagePart {
  final String mime;
  final String url;
  final String? filename;

  const FileMessagePart({required this.mime, required this.url, this.filename})
    : super(type: 'file');
}

/// 代理消息部分
class AgentMessagePart extends MessagePart {
  final String name;

  const AgentMessagePart({required this.name}) : super(type: 'agent');
}
