import '../models/project_model.dart';

/// Project 远程数据源接口
abstract class ProjectRemoteDataSource {
  /// 获取所有项目
  Future<ProjectsResponseModel> getProjects();

  /// 获取当前项目
  Future<ProjectModel> getCurrentProject({String? directory});

  /// 根据 ID 获取项目
  Future<ProjectModel> getProject(String projectId);
}

/// Project 远程数据源实现
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final dynamic dio;

  ProjectRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProjectsResponseModel> getProjects() async {
    final response = await dio.get('/project');
    return ProjectsResponseModel.fromJson(response.data);
  }

  @override
  Future<ProjectModel> getCurrentProject({String? directory}) async {
    final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
    final response = await dio.get('/project/current', queryParameters: queryParams);
    return ProjectModel.fromJson(response.data);
  }

  @override
  Future<ProjectModel> getProject(String projectId) async {
    final response = await dio.get('/project/current');
    return ProjectModel.fromJson(response.data);
  }
}