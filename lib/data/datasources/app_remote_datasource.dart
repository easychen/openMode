import '../models/provider_model.dart';
import '../models/app_info_model.dart';

/// 应用远程数据源接口
abstract class AppRemoteDataSource {
  /// 获取应用信息
  Future<AppInfoModel> getAppInfo({String? directory});

  /// 初始化应用
  Future<bool> initializeApp({String? directory});

  /// 获取提供商信息
  Future<ProvidersResponseModel> getProviders({String? directory});

  /// 获取配置信息
  Future<Map<String, dynamic>> getConfig({String? directory});
}

/// 应用远程数据源实现
class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final dynamic dio;

  AppRemoteDataSourceImpl({required this.dio});

  @override
  Future<AppInfoModel> getAppInfo({String? directory}) async {
    // Do NOT swallow network errors here.
    // Align to OpenAPI: use /path and /config instead of /app/info.
    // Let Dio throw exceptions so upper layers can handle connection status correctly.
    final queryParams = directory != null
        ? {'directory': directory}
        : <String, dynamic>{};

    // Fetch path info
    final pathResp = await dio.get('/path', queryParameters: queryParams);

    // Fetch config info (optional for future use)
    final configResp = await dio.get('/config', queryParameters: queryParams);

    final Map<String, dynamic> pathJson = pathResp.data as Map<String, dynamic>;

    // Map OpenAPI Path schema to AppInfoModel expected structure.
    // Where exact fields don't exist, provide sensible defaults.
    final mapped = <String, dynamic>{
      'hostname': 'OpenCode',
      'git': false,
      'path': {
        'config': pathJson['config'] ?? '',
        // There is no 'data' in Path schema; use worktree as a reasonable default.
        'data': pathJson['worktree'] ?? '',
        // Root is not explicitly defined; use worktree as root.
        'root': pathJson['worktree'] ?? '',
        // Use directory as current working directory.
        'cwd': pathJson['directory'] ?? '',
        'state': pathJson['state'] ?? '',
      },
      'time': null,
    };

    return AppInfoModel.fromJson(mapped);
  }

  @override
  Future<bool> initializeApp({String? directory}) async {
    try {
      final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
      final response = await dio.post('/app/init', queryParameters: queryParams);
      return response.data['success'] ?? true;
    } catch (e) {
      print('初始化应用时出错: $e');
      return false;
    }
  }

  @override
  Future<ProvidersResponseModel> getProviders({String? directory}) async {
    try {
      final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
      final response = await dio.get('/provider', queryParameters: queryParams);
      print('Providers API 响应: ${response.data}');
      return ProvidersResponseModel.fromJson(response.data);
    } catch (e) {
      print('解析提供商响应时出错: $e');
      // 返回一个最小的备用响应
      return ProvidersResponseModel(
        providers: [
          ProviderModel(
            id: 'moonshotai-cn',
            name: 'Moonshot AI (China)',
            env: const ['MOONSHOT_API_KEY'],
            models: {
              'kimi-k2-turbo-preview': ModelModel(
                id: 'kimi-k2-turbo-preview',
                name: 'Kimi K2 Turbo',
                releaseDate: '2025-07-14',
                attachment: false,
                reasoning: false,
                temperature: true,
                toolCall: true,
                cost: ModelCostModel(input: 2.4, output: 10.0),
                limit: ModelLimitModel(context: 131072, output: 16384),
              ),
            },
          ),
        ],
        defaultModels: {'moonshotai-cn': 'kimi-k2-turbo-preview'},
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getConfig({String? directory}) async {
    final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
    final response = await dio.get('/config', queryParameters: queryParams);
    return response.data as Map<String, dynamic>;
  }
}
