import '../../domain/entities/project.dart';

/// Project 数据模型
class ProjectModel {
  final String id;
  final String name;
  final String path;
  final String createdAt;
  final String? updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从 JSON 创建 ProjectModel
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  /// 转换为领域实体
  Project toDomain() {
    return Project(
      id: id,
      name: name,
      path: path,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// 从领域实体创建
  factory ProjectModel.fromDomain(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      path: project.path,
      createdAt: project.createdAt.toIso8601String(),
      updatedAt: project.updatedAt?.toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel &&
        other.id == id &&
        other.name == name &&
        other.path == path &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        path.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, name: $name, path: $path, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Projects 响应模型
class ProjectsResponseModel {
  final List<ProjectModel> projects;

  const ProjectsResponseModel({
    required this.projects,
  });

  /// 从 JSON 创建 ProjectsResponseModel
  factory ProjectsResponseModel.fromJson(dynamic json) {
    if (json is List) {
      return ProjectsResponseModel(
        projects: json.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } else if (json is Map<String, dynamic> && json.containsKey('projects')) {
      return ProjectsResponseModel(
        projects: (json['projects'] as List)
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw FormatException('Invalid JSON format for ProjectsResponseModel');
    }
  }

  /// 转换为 JSON
  dynamic toJson() {
    return projects.map((project) => project.toJson()).toList();
  }

  /// 转换为领域实体列表
  List<Project> toDomain() {
    return projects.map((project) => project.toDomain()).toList();
  }
}