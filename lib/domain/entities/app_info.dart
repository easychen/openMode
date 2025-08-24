import 'package:equatable/equatable.dart';

/// 应用信息实体
class AppInfo extends Equatable {
  final String hostname;
  final bool git;
  final AppPath path;
  final AppTime? time;

  const AppInfo({
    required this.hostname,
    required this.git,
    required this.path,
    this.time,
  });

  @override
  List<Object?> get props => [hostname, git, path, time];
}

/// 应用路径信息
class AppPath extends Equatable {
  final String config;
  final String data;
  final String root;
  final String cwd;
  final String state;

  const AppPath({
    required this.config,
    required this.data,
    required this.root,
    required this.cwd,
    required this.state,
  });

  @override
  List<Object> get props => [config, data, root, cwd, state];
}

/// 应用时间信息
class AppTime extends Equatable {
  final int? initialized;

  const AppTime({this.initialized});

  @override
  List<Object?> get props => [initialized];
}
