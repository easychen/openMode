// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  parentId: json['parentId'] as String?,
  title: json['title'] as String,
  version: json['version'] as String,
  time: SessionTimeModel.fromJson(json['time'] as Map<String, dynamic>),
  share: json['share'] == null
      ? null
      : SessionShareModel.fromJson(json['share'] as Map<String, dynamic>),
  revert: json['revert'] == null
      ? null
      : SessionRevertModel.fromJson(json['revert'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'title': instance.title,
      'version': instance.version,
      'time': instance.time.toJson(),
      'share': instance.share?.toJson(),
      'revert': instance.revert?.toJson(),
    };

SessionTimeModel _$SessionTimeModelFromJson(Map<String, dynamic> json) =>
    SessionTimeModel(
      created: (json['created'] as num).toInt(),
      updated: (json['updated'] as num).toInt(),
    );

Map<String, dynamic> _$SessionTimeModelToJson(SessionTimeModel instance) =>
    <String, dynamic>{'created': instance.created, 'updated': instance.updated};

SessionShareModel _$SessionShareModelFromJson(Map<String, dynamic> json) =>
    SessionShareModel(url: json['url'] as String);

Map<String, dynamic> _$SessionShareModelToJson(SessionShareModel instance) =>
    <String, dynamic>{'url': instance.url};

SessionRevertModel _$SessionRevertModelFromJson(Map<String, dynamic> json) =>
    SessionRevertModel(
      messageId: json['messageId'] as String,
      partId: json['partId'] as String?,
      snapshot: json['snapshot'] as String?,
      diff: json['diff'] as String?,
    );

Map<String, dynamic> _$SessionRevertModelToJson(SessionRevertModel instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'partId': instance.partId,
      'snapshot': instance.snapshot,
      'diff': instance.diff,
    };
