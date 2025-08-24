// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppInfoModel _$AppInfoModelFromJson(Map<String, dynamic> json) => AppInfoModel(
  hostname: json['hostname'] as String,
  git: json['git'] as bool,
  path: AppPathModel.fromJson(json['path'] as Map<String, dynamic>),
  time: json['time'] == null
      ? null
      : AppTimeModel.fromJson(json['time'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppInfoModelToJson(AppInfoModel instance) =>
    <String, dynamic>{
      'hostname': instance.hostname,
      'git': instance.git,
      'path': instance.path.toJson(),
      'time': instance.time?.toJson(),
    };

AppPathModel _$AppPathModelFromJson(Map<String, dynamic> json) => AppPathModel(
  config: json['config'] as String,
  data: json['data'] as String,
  root: json['root'] as String,
  cwd: json['cwd'] as String,
  state: json['state'] as String,
);

Map<String, dynamic> _$AppPathModelToJson(AppPathModel instance) =>
    <String, dynamic>{
      'config': instance.config,
      'data': instance.data,
      'root': instance.root,
      'cwd': instance.cwd,
      'state': instance.state,
    };

AppTimeModel _$AppTimeModelFromJson(Map<String, dynamic> json) =>
    AppTimeModel(initialized: (json['initialized'] as num?)?.toInt());

Map<String, dynamic> _$AppTimeModelToJson(AppTimeModel instance) =>
    <String, dynamic>{'initialized': instance.initialized};
