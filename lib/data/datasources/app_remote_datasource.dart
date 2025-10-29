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
    try {
      final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
      final response = await dio.get('/app/info', queryParameters: queryParams);
      return AppInfoModel.fromJson(response.data);
    } catch (e) {
      print('获取应用信息时出错: $e');
      // 返回默认的应用信息
      return AppInfoModel(
        hostname: 'localhost',
        git: false,
        path: AppPathModel(
          config: '/config',
          data: '/data',
          root: '/',
          cwd: '/app',
          state: '/state',
        ),
      );
    }
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
