import 'package:equatable/equatable.dart';

/// 聊天消息实体
abstract class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.time,
    this.parts = const [],
  });

  final String id;
  final String sessionId;
  final MessageRole role;
  final DateTime time;
  final List<MessagePart> parts;

  @override
  List<Object?> get props => [id, sessionId, role, time, parts];
}

/// 用户消息
class UserMessage extends ChatMessage {
  const UserMessage({
    required super.id,
    required super.sessionId,
    required super.time,
    super.parts,
  }) : super(role: MessageRole.user);
}

/// 助手消息
class AssistantMessage extends ChatMessage {
  const AssistantMessage({
    required super.id,
    required super.sessionId,
    required super.time,
    super.parts,
    this.providerId,
    this.modelId,
    this.cost,
    this.tokens,
    this.error,
    this.mode,
  }) : super(role: MessageRole.assistant);

  final String? providerId;
  final String? modelId;
  final double? cost;
  final MessageTokens? tokens;
  final MessageError? error;
  final String? mode;

  @override
  List<Object?> get props => [
    ...super.props,
    providerId,
    modelId,
    cost,
    tokens,
    error,
    mode,
  ];
}

/// 消息角色枚举
enum MessageRole { user, assistant }

/// 消息部件基类
abstract class MessagePart extends Equatable {
  const MessagePart({
    required this.id,
    required this.messageId,
    required this.sessionId,
    required this.type,
  });

  final String id;
  final String messageId;
  final String sessionId;
  final PartType type;

  @override
  List<Object?> get props => [id, messageId, sessionId, type];
}

/// 文本部件
class TextPart extends MessagePart {
  const TextPart({
    required super.id,
    required super.messageId,
    required super.sessionId,
    required this.text,
    this.time,
  }) : super(type: PartType.text);

  final String text;
  final DateTime? time;

  @override
  List<Object?> get props => [...super.props, text, time];
}

/// 文件部件
class FilePart extends MessagePart {
  const FilePart({
    required super.id,
    required super.messageId,
    required super.sessionId,
    required this.url,
    required this.mime,
    this.filename,
    this.source,
  }) : super(type: PartType.file);

  final String url;
  final String mime;
  final String? filename;
  final FileSource? source;

  @override
  List<Object?> get props => [...super.props, url, mime, filename, source];
}

/// 工具部件
class ToolPart extends MessagePart {
  const ToolPart({
    required super.id,
    required super.messageId,
    required super.sessionId,
    required this.callId,
    required this.tool,
    required this.state,
  }) : super(type: PartType.tool);

  final String callId;
  final String tool;
  final ToolState state;

  @override
  List<Object?> get props => [...super.props, callId, tool, state];
}

/// 推理部件
class ReasoningPart extends MessagePart {
  const ReasoningPart({
    required super.id,
    required super.messageId,
    required super.sessionId,
    required this.text,
    this.time,
  }) : super(type: PartType.reasoning);

  final String text;
  final DateTime? time;

  @override
  List<Object?> get props => [...super.props, text, time];
}

/// 部件类型枚举
enum PartType {
  text,
  file,
  tool,
  agent,
  reasoning,
  stepStart,
  stepFinish,
  snapshot,
}

/// 文件源
class FileSource extends Equatable {
  const FileSource({
    required this.path,
    required this.text,
    required this.type,
  });

  final String path;
  final FilePartSourceText text;
  final String type;

  @override
  List<Object?> get props => [path, text, type];
}

/// 文件部件源文本
class FilePartSourceText extends Equatable {
  const FilePartSourceText({
    required this.value,
    required this.start,
    required this.end,
  });

  final String value;
  final int start;
  final int end;

  @override
  List<Object?> get props => [value, start, end];
}

/// 工具状态
abstract class ToolState extends Equatable {
  const ToolState({required this.status});

  final ToolStatus status;

  @override
  List<Object?> get props => [status];
}

/// 工具状态 - 等待中
class ToolStatePending extends ToolState {
  const ToolStatePending() : super(status: ToolStatus.pending);
}

/// 工具状态 - 运行中
class ToolStateRunning extends ToolState {
  const ToolStateRunning({
    required this.input,
    required this.time,
    this.title,
    this.metadata,
  }) : super(status: ToolStatus.running);

  final Map<String, dynamic> input;
  final DateTime time;
  final String? title;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [...super.props, input, time, title, metadata];
}

/// 工具状态 - 已完成
class ToolStateCompleted extends ToolState {
  const ToolStateCompleted({
    required this.input,
    required this.output,
    required this.time,
    this.title,
    this.metadata,
  }) : super(status: ToolStatus.completed);

  final Map<String, dynamic> input;
  final String output;
  final ToolTime time;
  final String? title;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
    ...super.props,
    input,
    output,
    time,
    title,
    metadata,
  ];
}

/// 工具状态 - 错误
class ToolStateError extends ToolState {
  const ToolStateError({
    required this.input,
    required this.error,
    required this.time,
    this.title,
    this.metadata,
  }) : super(status: ToolStatus.error);

  final Map<String, dynamic> input;
  final String error;
  final ToolTime time;
  final String? title;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
    ...super.props,
    input,
    error,
    time,
    title,
    metadata,
  ];
}

/// 工具状态枚举
enum ToolStatus { pending, running, completed, error }

/// 工具时间
class ToolTime extends Equatable {
  const ToolTime({required this.start, this.end});

  final DateTime start;
  final DateTime? end;

  @override
  List<Object?> get props => [start, end];
}

/// 消息令牌信息
class MessageTokens extends Equatable {
  const MessageTokens({
    required this.input,
    required this.output,
    required this.total,
  });

  final int input;
  final int output;
  final int total;

  @override
  List<Object?> get props => [input, output, total];
}

/// 消息错误
class MessageError extends Equatable {
  const MessageError({required this.name, required this.message});

  final String name;
  final String message;

  @override
  List<Object?> get props => [name, message];
}
