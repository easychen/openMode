import 'package:equatable/equatable.dart';

/// 消息角色枚举
enum MessageRole { user, assistant }

/// 消息实体基类
abstract class Message extends Equatable {
  final String id;
  final String sessionId;
  final MessageRole role;
  final MessageTime time;

  const Message({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.time,
  });
}

/// 用户消息
class UserMessage extends Message {
  const UserMessage({
    required String id,
    required String sessionId,
    required MessageTime time,
  }) : super(id: id, sessionId: sessionId, role: MessageRole.user, time: time);

  @override
  List<Object> get props => [id, sessionId, role, time];
}

/// 助手消息
class AssistantMessage extends Message {
  final MessageError? error;
  final List<String> system;
  final String modelId;
  final String providerId;
  final String mode;
  final MessagePath path;
  final bool? summary;
  final double cost;
  final MessageTokens tokens;

  const AssistantMessage({
    required String id,
    required String sessionId,
    required MessageTime time,
    this.error,
    required this.system,
    required this.modelId,
    required this.providerId,
    required this.mode,
    required this.path,
    this.summary,
    required this.cost,
    required this.tokens,
  }) : super(
         id: id,
         sessionId: sessionId,
         role: MessageRole.assistant,
         time: time,
       );

  @override
  List<Object?> get props => [
    id,
    sessionId,
    role,
    time,
    error,
    system,
    modelId,
    providerId,
    mode,
    path,
    summary,
    cost,
    tokens,
  ];
}

/// 消息时间信息
class MessageTime extends Equatable {
  final int created;
  final int? completed;

  const MessageTime({required this.created, this.completed});

  @override
  List<Object?> get props => [created, completed];
}

/// 消息路径信息
class MessagePath extends Equatable {
  final String cwd;
  final String root;

  const MessagePath({required this.cwd, required this.root});

  @override
  List<Object> get props => [cwd, root];
}

/// 消息令牌信息
class MessageTokens extends Equatable {
  final int input;
  final int output;
  final int reasoning;
  final TokenCache cache;

  const MessageTokens({
    required this.input,
    required this.output,
    required this.reasoning,
    required this.cache,
  });

  @override
  List<Object> get props => [input, output, reasoning, cache];
}

/// 令牌缓存信息
class TokenCache extends Equatable {
  final int read;
  final int write;

  const TokenCache({required this.read, required this.write});

  @override
  List<Object> get props => [read, write];
}

/// 消息错误信息
abstract class MessageError extends Equatable {
  final String name;

  const MessageError({required this.name});
}

/// 提供商认证错误
class ProviderAuthError extends MessageError {
  final String providerId;
  final String message;

  const ProviderAuthError({required this.providerId, required this.message})
    : super(name: 'ProviderAuthError');

  @override
  List<Object> get props => [name, providerId, message];
}

/// 未知错误
class UnknownError extends MessageError {
  final String message;

  const UnknownError({required this.message}) : super(name: 'UnknownError');

  @override
  List<Object> get props => [name, message];
}

/// 消息输出长度错误
class MessageOutputLengthError extends MessageError {
  const MessageOutputLengthError() : super(name: 'MessageOutputLengthError');

  @override
  List<Object> get props => [name];
}

/// 消息中止错误
class MessageAbortedError extends MessageError {
  const MessageAbortedError() : super(name: 'MessageAbortedError');

  @override
  List<Object> get props => [name];
}
