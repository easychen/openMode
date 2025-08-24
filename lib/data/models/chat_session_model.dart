import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_session.dart';

part 'chat_session_model.g.dart';

/// 聊天会话模型
@JsonSerializable()
class ChatSessionModel {
  const ChatSessionModel({
    required this.id,
    required this.time,
    this.workspaceId,
    this.title,
    this.version,
    this.shared = false,
    this.summary,
    this.path,
    this.share,
  });

  final String id;
  final String? workspaceId;
  final SessionTimeModel time;
  final String? title;
  final String? version;
  final bool shared;
  final String? summary;
  final SessionPathModel? path;
  final SessionShareModel? share;

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);

  /// 转换为领域实体
  ChatSession toDomain() {
    return ChatSession(
      id: id,
      workspaceId: workspaceId ?? 'default',
      time: time.toDomain(),
      title: title,
      shared: share != null,
      summary: summary,
      path: path?.toDomain(),
    );
  }

  /// 从领域实体创建
  static ChatSessionModel fromDomain(ChatSession session) {
    return ChatSessionModel(
      id: session.id,
      workspaceId: session.workspaceId,
      time: SessionTimeModel.fromDomain(session.time),
      title: session.title,
      shared: session.shared,
      summary: session.summary,
      path: session.path != null
          ? SessionPathModel.fromDomain(session.path!)
          : null,
    );
  }
}

/// 会话时间模型
@JsonSerializable()
class SessionTimeModel {
  const SessionTimeModel({required this.created, required this.updated});

  final int created;
  final int updated;

  factory SessionTimeModel.fromJson(Map<String, dynamic> json) =>
      _$SessionTimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTimeModelToJson(this);

  DateTime toDomain() {
    return DateTime.fromMillisecondsSinceEpoch(created);
  }

  static SessionTimeModel fromDomain(DateTime time) {
    final timestamp = time.millisecondsSinceEpoch;
    return SessionTimeModel(created: timestamp, updated: timestamp);
  }
}

/// 会话分享模型
@JsonSerializable()
class SessionShareModel {
  const SessionShareModel({required this.url});

  final String url;

  factory SessionShareModel.fromJson(Map<String, dynamic> json) =>
      _$SessionShareModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionShareModelToJson(this);
}

/// 会话路径模型
@JsonSerializable()
class SessionPathModel {
  const SessionPathModel({required this.root, required this.workspace});

  final String root;
  final String workspace;

  factory SessionPathModel.fromJson(Map<String, dynamic> json) =>
      _$SessionPathModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionPathModelToJson(this);

  SessionPath toDomain() {
    return SessionPath(root: root, workspace: workspace);
  }

  static SessionPathModel fromDomain(SessionPath path) {
    return SessionPathModel(root: path.root, workspace: path.workspace);
  }
}

/// 聊天输入模型
@JsonSerializable()
class ChatInputModel {
  const ChatInputModel({
    this.messageId,
    required this.parts,
    required this.providerId,
    required this.modelId,
    this.agent,
    this.system,
    this.tools,
  });

  @JsonKey(name: 'messageID')
  final String? messageId;
  @JsonKey(name: 'providerID')
  final String providerId;
  @JsonKey(name: 'modelID')
  final String modelId;
  final String? agent;
  final String? system;
  final Map<String, bool>? tools;
  final List<ChatInputPartModel> parts;

  factory ChatInputModel.fromJson(Map<String, dynamic> json) =>
      _$ChatInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatInputModelToJson(this);

  /// 从领域实体创建
  static ChatInputModel fromDomain(ChatInput input) {
    return ChatInputModel(
      messageId: input.messageId,
      providerId: input.providerId,
      modelId: input.modelId,
      agent: input.agent,
      system: input.system,
      tools: input.tools,
      parts: input.parts.map((p) => ChatInputPartModel.fromDomain(p)).toList(),
    );
  }
}

/// 聊天输入部件模型
@JsonSerializable()
class ChatInputPartModel {
  const ChatInputPartModel({
    required this.type,
    this.text,
    this.source,
    this.filename,
    this.name,
    this.id,
  });

  final String type;
  final String? text;
  final Map<String, dynamic>? source;
  final String? filename;
  final String? name;
  final String? id;

  factory ChatInputPartModel.fromJson(Map<String, dynamic> json) =>
      _$ChatInputPartModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatInputPartModelToJson(this);

  /// 从领域实体创建
  static ChatInputPartModel fromDomain(ChatInputPart part) {
    switch (part.type) {
      case ChatInputPartType.text:
        final textPart = part as TextInputPart;
        return ChatInputPartModel(
          type: 'text', 
          text: textPart.text,
          id: 'prt_${DateTime.now().millisecondsSinceEpoch}', // 生成唯一ID
        );
      case ChatInputPartType.file:
        final filePart = part as FileInputPart;
        return ChatInputPartModel(
          type: 'file',
          source: filePart.source.toMap(),
          filename: filePart.filename,
          id: 'prt_${DateTime.now().millisecondsSinceEpoch}', // 生成唯一ID
        );
      case ChatInputPartType.agent:
        final agentPart = part as AgentInputPart;
        return ChatInputPartModel(
          type: 'agent',
          name: agentPart.name,
          id: agentPart.id ?? 'prt_${DateTime.now().millisecondsSinceEpoch}', // 生成唯一ID
          source: agentPart.source?.toMap(),
        );
    }
  }
}

/// 会话创建输入模型
@JsonSerializable()
class SessionCreateInputModel {
  const SessionCreateInputModel({
    required this.workspaceId,
    required this.title,
  });

  @JsonKey(name: 'workspaceID')
  final String workspaceId;
  final String title;

  factory SessionCreateInputModel.fromJson(Map<String, dynamic> json) =>
      _$SessionCreateInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionCreateInputModelToJson(this);

  static SessionCreateInputModel fromDomain(SessionCreateInput input) {
    return SessionCreateInputModel(
      workspaceId: input.workspaceId,
      title: input.title ?? '新对话',
    );
  }
}

/// 会话更新输入模型
@JsonSerializable()
class SessionUpdateInputModel {
  const SessionUpdateInputModel({this.title});

  final String? title;

  factory SessionUpdateInputModel.fromJson(Map<String, dynamic> json) =>
      _$SessionUpdateInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionUpdateInputModelToJson(this);

  static SessionUpdateInputModel fromDomain(SessionUpdateInput input) {
    return SessionUpdateInputModel(title: input.title);
  }
}

/// 扩展方法
extension on FileInputSource {
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'text': {'value': text.value, 'start': text.start, 'end': text.end},
      'type': type,
    };
  }
}

extension on AgentInputSource {
  Map<String, dynamic> toMap() {
    return {'value': value, 'start': start, 'end': end};
  }
}
