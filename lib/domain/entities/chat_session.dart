import 'package:equatable/equatable.dart';

/// 聊天会话实体
class ChatSession extends Equatable {
  const ChatSession({
    required this.id,
    required this.workspaceId,
    required this.time,
    this.title,
    this.shared = false,
    this.summary,
    this.path,
  });

  /// 会话 ID
  final String id;

  /// 工作空间 ID
  final String workspaceId;

  /// 创建时间
  final DateTime time;

  /// 会话标题
  final String? title;

  /// 是否共享
  final bool shared;

  /// 会话摘要
  final String? summary;

  /// 会话路径信息
  final SessionPath? path;

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    time,
    title,
    shared,
    summary,
    path,
  ];

  /// 创建副本
  ChatSession copyWith({
    String? id,
    String? workspaceId,
    DateTime? time,
    String? title,
    bool? shared,
    String? summary,
    SessionPath? path,
  }) {
    return ChatSession(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      time: time ?? this.time,
      title: title ?? this.title,
      shared: shared ?? this.shared,
      summary: summary ?? this.summary,
      path: path ?? this.path,
    );
  }
}

/// 会话路径信息
class SessionPath extends Equatable {
  const SessionPath({required this.root, required this.workspace});

  final String root;
  final String workspace;

  @override
  List<Object?> get props => [root, workspace];
}

/// 聊天输入
class ChatInput extends Equatable {
  const ChatInput({
    this.messageId,
    required this.parts,
    required this.providerId,
    required this.modelId,
    this.agent,
    this.system,
    this.tools,
  });

  /// 消息 ID
  final String? messageId;

  /// 提供商 ID
  final String providerId;

  /// 模型 ID
  final String modelId;

  /// 代理
  final String? agent;

  /// 系统提示
  final String? system;

  /// 工具配置
  final Map<String, bool>? tools;

  /// 消息部件
  final List<ChatInputPart> parts;

  @override
  List<Object?> get props => [
    messageId,
    providerId,
    modelId,
    agent,
    system,
    tools,
    parts,
  ];
}

/// 聊天输入部件
abstract class ChatInputPart extends Equatable {
  const ChatInputPart({required this.type});

  final ChatInputPartType type;

  @override
  List<Object?> get props => [type];
}

/// 文本输入部件
class TextInputPart extends ChatInputPart {
  const TextInputPart({required this.text})
    : super(type: ChatInputPartType.text);

  final String text;

  @override
  List<Object?> get props => [...super.props, text];
}

/// 文件输入部件
class FileInputPart extends ChatInputPart {
  const FileInputPart({required this.source, this.filename})
    : super(type: ChatInputPartType.file);

  final FileInputSource source;
  final String? filename;

  @override
  List<Object?> get props => [...super.props, source, filename];
}

/// 代理输入部件
class AgentInputPart extends ChatInputPart {
  const AgentInputPart({required this.name, this.id, this.source})
    : super(type: ChatInputPartType.agent);

  final String name;
  final String? id;
  final AgentInputSource? source;

  @override
  List<Object?> get props => [...super.props, name, id, source];
}

/// 聊天输入部件类型
enum ChatInputPartType { text, file, agent }

/// 文件输入源
class FileInputSource extends Equatable {
  const FileInputSource({
    required this.path,
    required this.text,
    required this.type,
  });

  final String path;
  final FileInputSourceText text;
  final String type;

  @override
  List<Object?> get props => [path, text, type];
}

/// 文件输入源文本
class FileInputSourceText extends Equatable {
  const FileInputSourceText({
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

/// 代理输入源
class AgentInputSource extends Equatable {
  const AgentInputSource({
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

/// 会话创建输入
class SessionCreateInput extends Equatable {
  const SessionCreateInput({this.parentId, this.title});

  final String? parentId;
  final String? title;

  @override
  List<Object?> get props => [parentId, title];
}

/// 会话更新输入
class SessionUpdateInput extends Equatable {
  const SessionUpdateInput({this.title});

  final String? title;

  @override
  List<Object?> get props => [title];
}
