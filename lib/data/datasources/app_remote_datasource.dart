import '../models/app_info_model.dart';
import '../models/provider_model.dart';

/// 应用远程数据源接口
abstract class AppRemoteDataSource {
  /// 获取应用信息
  Future<AppInfoModel> getAppInfo();

  /// 初始化应用
  Future<bool> initializeApp();

  /// 获取提供商信息
  Future<ProvidersResponseModel> getProviders();
}

/// 应用远程数据源实现
class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final dynamic dio;

  AppRemoteDataSourceImpl({required this.dio});

  @override
  Future<AppInfoModel> getAppInfo() async {
    final response = await dio.get('/app');
    return AppInfoModel.fromJson(response.data);
  }

  @override
  Future<bool> initializeApp() async {
    final response = await dio.post('/app/init');
    return response.data as bool;
  }

  @override
  Future<ProvidersResponseModel> getProviders() async {
    try {
      final response = await dio.get('/config/providers');
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
}
