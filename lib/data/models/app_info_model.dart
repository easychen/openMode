import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/app_info.dart';

part 'app_info_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AppInfoModel extends AppInfo {
  @override
  @JsonKey(name: 'path')
  final AppPathModel path;

  @override
  @JsonKey(name: 'time')
  final AppTimeModel? time;

  const AppInfoModel({
    required super.hostname,
    required super.git,
    required this.path,
    this.time,
  }) : super(path: path, time: time);

  factory AppInfoModel.fromJson(Map<String, dynamic> json) =>
      _$AppInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppInfoModelToJson(this);

  AppInfo toEntity() =>
      AppInfo(hostname: hostname, git: git, path: path, time: time);
}

@JsonSerializable()
class AppPathModel extends AppPath {
  const AppPathModel({
    required super.config,
    required super.data,
    required super.root,
    required super.cwd,
    required super.state,
  });

  factory AppPathModel.fromJson(Map<String, dynamic> json) =>
      _$AppPathModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppPathModelToJson(this);
}

@JsonSerializable()
class AppTimeModel extends AppTime {
  const AppTimeModel({super.initialized});

  factory AppTimeModel.fromJson(Map<String, dynamic> json) =>
      _$AppTimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppTimeModelToJson(this);
}
