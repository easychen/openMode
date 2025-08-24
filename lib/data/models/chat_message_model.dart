import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

/// 聊天消息模型
@JsonSerializable()
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.time,
    this.completedTime,
    this.parts = const [],
    this.providerId,
    this.modelId,
    this.cost,
    this.tokens,
    this.error,
    this.mode,
    this.system,
    this.path,
  });

  final String id;
  @JsonKey(name: 'sessionID')
  final String sessionId;
  final String role;
  @JsonKey(fromJson: _timeFromJson)
  final DateTime time;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? completedTime;

  static DateTime _timeFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      // 处理 {"created": number, "completed": number} 格式
      final created = value['created'] as int?;
      if (created != null) {
        return DateTime.fromMillisecondsSinceEpoch(created);
      }
    } else if (value is int) {
      // 处理直接的时间戳
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      // 处理 ISO 字符串格式
      return DateTime.parse(value);
    }
    // 默认返回当前时间
    return DateTime.now();
  }

  static DateTime? _completedTimeFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      // 处理 {"created": number, "completed": number} 格式
      final completed = value['completed'] as int?;
      if (completed != null && completed > 0) {
        return DateTime.fromMillisecondsSinceEpoch(completed);
      }
    }
    return null;
  }

  final List<MessagePartModel> parts;
  @JsonKey(name: 'providerID')
  final String? providerId;
  @JsonKey(name: 'modelID')
  final String? modelId;
  final double? cost;
  final MessageTokensModel? tokens;
  final MessageErrorModel? error;
  final String? mode;
  @JsonKey(fromJson: _systemFromJson)
  final List<String>? system;
  @JsonKey(fromJson: _pathFromJson)
  final Map<String, String>? path;

  static List<String>? _systemFromJson(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }
    if (value is String) {
      return [value];
    }
    return null;
  }

  static Map<String, String>? _pathFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, val) => MapEntry(key, val.toString()));
    }
    return null;
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final model = _$ChatMessageModelFromJson(json);

    // 手动处理 completedTime
    final completedTime = _completedTimeFromJson(json['time']);

    return ChatMessageModel(
      id: model.id,
      sessionId: model.sessionId,
      role: model.role,
      time: model.time,
      completedTime: completedTime,
      parts: model.parts,
      providerId: model.providerId,
      modelId: model.modelId,
      cost: model.cost,
      tokens: model.tokens,
      error: model.error,
      mode: model.mode,
      system: model.system,
      path: model.path,
    );
  }

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  /// 转换为领域实体
  ChatMessage toDomain() {
    final messageRole = role == 'user'
        ? MessageRole.user
        : MessageRole.assistant;
    final domainParts = parts.map((p) => p.toDomain()).toList();

    if (messageRole == MessageRole.user) {
      return UserMessage(
        id: id,
        sessionId: sessionId,
        time: time,
        parts: domainParts,
      );
    } else {
      return AssistantMessage(
        id: id,
        sessionId: sessionId,
        time: time,
        parts: domainParts,
        completedTime: completedTime,
        providerId: providerId,
        modelId: modelId,
        cost: cost,
        tokens: tokens?.toDomain(),
        error: error?.toDomain(),
        mode: mode,
      );
    }
  }

  /// 从领域实体创建
  static ChatMessageModel fromDomain(ChatMessage message) {
    final parts = message.parts
        .map((p) => MessagePartModel.fromDomain(p))
        .toList();

    if (message is AssistantMessage) {
      return ChatMessageModel(
        id: message.id,
        sessionId: message.sessionId,
        role: 'assistant',
        time: message.time,
        completedTime: message.completedTime,
        parts: parts,
        providerId: message.providerId,
        modelId: message.modelId,
        cost: message.cost,
        tokens: message.tokens != null
            ? MessageTokensModel.fromDomain(message.tokens!)
            : null,
        error: message.error != null
            ? MessageErrorModel.fromDomain(message.error!)
            : null,
        mode: message.mode,
      );
    } else {
      return ChatMessageModel(
        id: message.id,
        sessionId: message.sessionId,
        role: 'user',
        time: message.time,
        parts: parts,
      );
    }
  }
}

/// 消息部件模型
@JsonSerializable()
class MessagePartModel {
  const MessagePartModel({
    required this.id,
    required this.messageId,
    required this.sessionId,
    required this.type,
    this.text,
    this.url,
    this.mime,
    this.filename,
    this.source,
    this.callId,
    this.tool,
    this.state,
    this.time,
  });

  final String id;
  @JsonKey(name: 'messageID')
  final String messageId;
  @JsonKey(name: 'sessionID')
  final String sessionId;
  final String type;
  final String? text;
  final String? url;
  final String? mime;
  final String? filename;
  final Map<String, dynamic>? source;
  @JsonKey(name: 'callID')
  final String? callId;
  final String? tool;
  final Map<String, dynamic>? state;
  @JsonKey(fromJson: _partTimeFromJson)
  final DateTime? time;

  static DateTime? _partTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      // 处理 {"start": number, "end": number} 格式
      final start = value['start'] as int?;
      if (start != null) {
        return DateTime.fromMillisecondsSinceEpoch(start);
      }
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return null;
  }

  factory MessagePartModel.fromJson(Map<String, dynamic> json) =>
      _$MessagePartModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessagePartModelToJson(this);

  /// 转换为领域实体
  MessagePart toDomain() {
    final partType = _parsePartType(type);

    switch (partType) {
      case PartType.text:
        return TextPart(
          id: id,
          messageId: messageId,
          sessionId: sessionId,
          text: text ?? '',
          time: time,
        );
      case PartType.file:
        return FilePart(
          id: id,
          messageId: messageId,
          sessionId: sessionId,
          url: url ?? '',
          mime: mime ?? '',
          filename: filename,
          source: source != null ? _parseFileSource(source!) : null,
        );
      case PartType.tool:
        return ToolPart(
          id: id,
          messageId: messageId,
          sessionId: sessionId,
          callId: callId ?? '',
          tool: tool ?? '',
          state: _parseToolState(state ?? {}),
        );
      case PartType.reasoning:
        return ReasoningPart(
          id: id,
          messageId: messageId,
          sessionId: sessionId,
          text: text ?? '',
          time: time,
        );
      default:
        // 默认返回文本部件
        return TextPart(
          id: id,
          messageId: messageId,
          sessionId: sessionId,
          text: text ?? '',
          time: time,
        );
    }
  }

  /// 从领域实体创建
  static MessagePartModel fromDomain(MessagePart part) {
    switch (part.type) {
      case PartType.text:
        final textPart = part as TextPart;
        return MessagePartModel(
          id: part.id,
          messageId: part.messageId,
          sessionId: part.sessionId,
          type: 'text',
          text: textPart.text,
          time: textPart.time,
        );
      case PartType.file:
        final filePart = part as FilePart;
        return MessagePartModel(
          id: part.id,
          messageId: part.messageId,
          sessionId: part.sessionId,
          type: 'file',
          url: filePart.url,
          mime: filePart.mime,
          filename: filePart.filename,
          source: filePart.source != null
              ? _fileSourceToMap(filePart.source!)
              : null,
        );
      case PartType.tool:
        final toolPart = part as ToolPart;
        return MessagePartModel(
          id: part.id,
          messageId: part.messageId,
          sessionId: part.sessionId,
          type: 'tool',
          callId: toolPart.callId,
          tool: toolPart.tool,
          state: _toolStateToMap(toolPart.state),
        );
      case PartType.reasoning:
        final reasoningPart = part as ReasoningPart;
        return MessagePartModel(
          id: part.id,
          messageId: part.messageId,
          sessionId: part.sessionId,
          type: 'reasoning',
          text: reasoningPart.text,
          time: reasoningPart.time,
        );
      default:
        return MessagePartModel(
          id: part.id,
          messageId: part.messageId,
          sessionId: part.sessionId,
          type: 'text',
        );
    }
  }

  static PartType _parsePartType(String type) {
    switch (type) {
      case 'text':
        return PartType.text;
      case 'file':
        return PartType.file;
      case 'tool':
        return PartType.tool;
      case 'agent':
        return PartType.agent;
      case 'reasoning':
        return PartType.reasoning;
      case 'step_start':
        return PartType.stepStart;
      case 'step_finish':
        return PartType.stepFinish;
      case 'snapshot':
        return PartType.snapshot;
      default:
        return PartType.text;
    }
  }

  static FileSource? _parseFileSource(Map<String, dynamic> source) {
    try {
      final text = source['text'] as Map<String, dynamic>?;
      if (text == null) return null;

      return FileSource(
        path: source['path'] as String? ?? '',
        text: FilePartSourceText(
          value: text['value'] as String? ?? '',
          start: text['start'] as int? ?? 0,
          end: text['end'] as int? ?? 0,
        ),
        type: source['type'] as String? ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> _fileSourceToMap(FileSource source) {
    return {
      'path': source.path,
      'text': {
        'value': source.text.value,
        'start': source.text.start,
        'end': source.text.end,
      },
      'type': source.type,
    };
  }

  static ToolState _parseToolState(Map<String, dynamic> state) {
    final status = state['status'] as String?;
    switch (status) {
      case 'pending':
        return const ToolStatePending();
      case 'running':
        return ToolStateRunning(
          input: state['input'] as Map<String, dynamic>? ?? {},
          time: DateTime.fromMillisecondsSinceEpoch(
            (state['time']?['start'] as int?) ?? 0,
          ),
          title: state['title'] as String?,
          metadata: state['metadata'] as Map<String, dynamic>?,
        );
      case 'completed':
        final time = state['time'] as Map<String, dynamic>?;
        return ToolStateCompleted(
          input: state['input'] as Map<String, dynamic>? ?? {},
          output: state['output'] as String? ?? '',
          time: ToolTime(
            start: DateTime.fromMillisecondsSinceEpoch(
              (time?['start'] as int?) ?? 0,
            ),
            end: time?['end'] != null
                ? DateTime.fromMillisecondsSinceEpoch(time!['end'] as int)
                : null,
          ),
          title: state['title'] as String?,
          metadata: state['metadata'] as Map<String, dynamic>?,
        );
      case 'error':
        final time = state['time'] as Map<String, dynamic>?;
        return ToolStateError(
          input: state['input'] as Map<String, dynamic>? ?? {},
          error: state['error'] as String? ?? '',
          time: ToolTime(
            start: DateTime.fromMillisecondsSinceEpoch(
              (time?['start'] as int?) ?? 0,
            ),
            end: time?['end'] != null
                ? DateTime.fromMillisecondsSinceEpoch(time!['end'] as int)
                : null,
          ),
          title: state['title'] as String?,
          metadata: state['metadata'] as Map<String, dynamic>?,
        );
      default:
        return const ToolStatePending();
    }
  }

  static Map<String, dynamic> _toolStateToMap(ToolState state) {
    switch (state.status) {
      case ToolStatus.pending:
        return {'status': 'pending'};
      case ToolStatus.running:
        final runningState = state as ToolStateRunning;
        return {
          'status': 'running',
          'input': runningState.input,
          'time': {'start': runningState.time.millisecondsSinceEpoch},
          'title': runningState.title,
          'metadata': runningState.metadata,
        };
      case ToolStatus.completed:
        final completedState = state as ToolStateCompleted;
        return {
          'status': 'completed',
          'input': completedState.input,
          'output': completedState.output,
          'time': {
            'start': completedState.time.start.millisecondsSinceEpoch,
            'end': completedState.time.end?.millisecondsSinceEpoch,
          },
          'title': completedState.title,
          'metadata': completedState.metadata,
        };
      case ToolStatus.error:
        final errorState = state as ToolStateError;
        return {
          'status': 'error',
          'input': errorState.input,
          'error': errorState.error,
          'time': {
            'start': errorState.time.start.millisecondsSinceEpoch,
            'end': errorState.time.end?.millisecondsSinceEpoch,
          },
          'title': errorState.title,
          'metadata': errorState.metadata,
        };
    }
  }
}

/// 消息令牌模型
@JsonSerializable()
class MessageTokensModel {
  const MessageTokensModel({
    required this.input,
    required this.output,
    required this.total,
  });

  @JsonKey(fromJson: _intFromJson)
  final int input;
  @JsonKey(fromJson: _intFromJson)
  final int output;
  @JsonKey(fromJson: _intFromJson)
  final int total;

  static int _intFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  factory MessageTokensModel.fromJson(Map<String, dynamic> json) =>
      _$MessageTokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageTokensModelToJson(this);

  MessageTokens toDomain() {
    return MessageTokens(input: input, output: output, total: total);
  }

  static MessageTokensModel fromDomain(MessageTokens tokens) {
    return MessageTokensModel(
      input: tokens.input,
      output: tokens.output,
      total: tokens.total,
    );
  }
}

/// 消息错误模型
@JsonSerializable()
class MessageErrorModel {
  const MessageErrorModel({required this.name, required this.message});

  final String name;
  final String message;

  factory MessageErrorModel.fromJson(Map<String, dynamic> json) =>
      _$MessageErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageErrorModelToJson(this);

  MessageError toDomain() {
    return MessageError(name: name, message: message);
  }

  static MessageErrorModel fromDomain(MessageError error) {
    return MessageErrorModel(name: error.name, message: error.message);
  }
}
