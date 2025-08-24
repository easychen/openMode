import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session.dart';

part 'session_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SessionModel extends Session {
  @JsonKey(name: 'parentID')
  final String? parentIdField;

  @override
  @JsonKey(name: 'time')
  final SessionTimeModel time;

  @override
  @JsonKey(name: 'share')
  final SessionShareModel? share;

  @override
  @JsonKey(name: 'revert')
  final SessionRevertModel? revert;

  const SessionModel({
    required String id,
    String? parentId,
    required String title,
    required String version,
    required this.time,
    this.share,
    this.revert,
  }) : parentIdField = parentId,
       super(
         id: id,
         parentId: parentId,
         title: title,
         version: version,
         time: time,
         share: share,
         revert: revert,
       );

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  Session toEntity() => Session(
    id: id,
    parentId: parentId,
    title: title,
    version: version,
    time: time,
    share: share,
    revert: revert,
  );
}

@JsonSerializable()
class SessionTimeModel extends SessionTime {
  const SessionTimeModel({required int created, required int updated})
    : super(created: created, updated: updated);

  factory SessionTimeModel.fromJson(Map<String, dynamic> json) =>
      _$SessionTimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTimeModelToJson(this);
}

@JsonSerializable()
class SessionShareModel extends SessionShare {
  const SessionShareModel({required String url}) : super(url: url);

  factory SessionShareModel.fromJson(Map<String, dynamic> json) =>
      _$SessionShareModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionShareModelToJson(this);
}

@JsonSerializable()
class SessionRevertModel extends SessionRevert {
  @JsonKey(name: 'messageID')
  final String messageIdField;
  @JsonKey(name: 'partID')
  final String? partIdField;

  const SessionRevertModel({
    required String messageId,
    String? partId,
    String? snapshot,
    String? diff,
  }) : messageIdField = messageId,
       partIdField = partId,
       super(
         messageId: messageId,
         partId: partId,
         snapshot: snapshot,
         diff: diff,
       );

  factory SessionRevertModel.fromJson(Map<String, dynamic> json) =>
      _$SessionRevertModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRevertModelToJson(this);
}
