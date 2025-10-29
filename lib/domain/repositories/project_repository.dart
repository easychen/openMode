import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/project.dart';

/// Project 仓库接口
abstract class ProjectRepository {
  /// 获取所有项目
  Future<Either<Failure, List<Project>>> getProjects();

  /// 获取当前项目
  Future<Either<Failure, Project>> getCurrentProject({
    String? directory,
  });

  /// 根据 ID 获取项目
  Future<Either<Failure, Project>> getProject(String projectId);
}