import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../core/errors/failures.dart';

/// 项目状态枚举
enum ProjectStatus { initial, loading, loaded, error }

/// 项目管理提供者
class ProjectProvider extends ChangeNotifier {
  final ProjectRepository _projectRepository;
  
  ProjectProvider({required ProjectRepository projectRepository})
      : _projectRepository = projectRepository;

  ProjectStatus _status = ProjectStatus.initial;
  List<Project> _projects = [];
  Project? _currentProject;
  String? _error;

  // Getters
  ProjectStatus get status => _status;
  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  String? get error => _error;
  String get currentProjectId => _currentProject?.id ?? 'default';

  /// 初始化项目
  Future<void> initializeProject() async {
    _setStatus(ProjectStatus.loading);
    
    try {
      // 首先尝试从本地存储获取当前项目ID
      final prefs = await SharedPreferences.getInstance();
      final savedProjectId = prefs.getString('current_project_id');
      
      if (savedProjectId != null) {
        // 尝试获取保存的项目
        final result = await _projectRepository.getProject(savedProjectId);
        result.fold(
          (failure) async {
            // 如果获取失败，尝试获取当前项目
            await _getCurrentProject();
          },
          (project) {
            _currentProject = project;
            _setStatus(ProjectStatus.loaded);
          },
        );
      } else {
        // 没有保存的项目ID，尝试获取项目列表
        await _loadProjects();
        
        if (_projects.isNotEmpty) {
          // 使用第一个项目作为当前项目
          _currentProject = _projects.first;
          await _saveCurrentProjectId(_currentProject!.id);
          _setStatus(ProjectStatus.loaded);
        } else {
          // 没有项目，获取当前项目
          await _getCurrentProject();
        }
      }
    } catch (e) {
      _setError('初始化项目失败: $e');
    }
  }

  /// 加载项目列表
  Future<void> loadProjects() async {
    _setStatus(ProjectStatus.loading);
    await _loadProjects();
  }

  /// 内部方法：加载项目列表
  Future<void> _loadProjects() async {
    try {
      final result = await _projectRepository.getProjects();
      result.fold(
        (failure) {
          _setError('获取项目列表失败: ${failure.toString()}');
        },
        (projects) {
          _projects = projects;
          if (_status == ProjectStatus.loading) {
            _setStatus(ProjectStatus.loaded);
          }
        },
      );
    } catch (e) {
      _setError('获取项目列表时发生异常: $e');
    }
  }

  /// 获取当前项目
  Future<void> _getCurrentProject() async {
    try {
      final result = await _projectRepository.getCurrentProject();
      result.fold(
        (failure) {
          // 对于项目获取失败，使用更友好的错误消息
          if (failure is NetworkFailure) {
            _setError('网络连接失败，请检查网络设置');
          } else if (failure is ServerFailure) {
            // 对于404等服务器错误，不显示技术性错误消息
            _setError('暂时无法获取项目信息，请稍后重试');
          } else {
            _setError('获取项目信息失败，请检查服务器连接');
          }
        },
        (project) async {
          _currentProject = project;
          // 如果项目列表中没有这个项目，添加到列表中
          if (!_projects.any((p) => p.id == project.id)) {
            _projects = [project, ..._projects];
          }
          await _saveCurrentProjectId(project.id);
          _setStatus(ProjectStatus.loaded);
        },
      );
    } catch (e) {
      _setError('获取项目信息时发生异常，请重试');
    }
  }

  /// 切换当前项目
  Future<void> switchProject(String projectId) async {
    try {
      final project = _projects.firstWhere((p) => p.id == projectId);
      _currentProject = project;
      await _saveCurrentProjectId(projectId);
      notifyListeners();
    } catch (e) {
      _setError('切换项目失败: $e');
    }
  }

  /// 保存当前项目ID到本地存储
  Future<void> _saveCurrentProjectId(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_project_id', projectId);
    } catch (e) {
      print('保存项目ID失败: $e');
    }
  }

  /// 设置状态
  void _setStatus(ProjectStatus status) {
    _status = status;
    if (status != ProjectStatus.error) {
      _error = null;
    }
    notifyListeners();
  }

  /// 设置错误
  void _setError(String error) {
    _error = error;
    _status = ProjectStatus.error;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    if (_status == ProjectStatus.error) {
      _status = ProjectStatus.initial;
    }
    notifyListeners();
  }
}