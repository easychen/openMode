import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// 应用本地数据源接口
abstract class AppLocalDataSource {
  /// 获取服务器主机地址
  Future<String?> getServerHost();

  /// 保存服务器主机地址
  Future<void> saveServerHost(String host);

  /// 获取服务器端口
  Future<int?> getServerPort();

  /// 保存服务器端口
  Future<void> saveServerPort(int port);

  /// 获取API密钥
  Future<String?> getApiKey();

  /// 保存API密钥
  Future<void> saveApiKey(String apiKey);

  /// 获取选中的提供商
  Future<String?> getSelectedProvider();

  /// 保存选中的提供商
  Future<void> saveSelectedProvider(String providerId);

  /// 获取选中的模型
  Future<String?> getSelectedModel();

  /// 保存选中的模型
  Future<void> saveSelectedModel(String modelId);

  /// 获取主题模式
  Future<String?> getThemeMode();

  /// 保存主题模式
  Future<void> saveThemeMode(String themeMode);

  /// 获取最后的会话ID
  Future<String?> getLastSessionId();

  /// 保存最后的会话ID
  Future<void> saveLastSessionId(String sessionId);

  /// 获取当前会话ID
  Future<String?> getCurrentSessionId();

  /// 保存当前会话ID
  Future<void> saveCurrentSessionId(String sessionId);

  /// 获取缓存的会话列表
  Future<String?> getCachedSessions();

  /// 保存会话列表到缓存
  Future<void> saveCachedSessions(String sessionsJson);

  /// 清除所有数据
  Future<void> clearAll();
}

/// 应用本地数据源实现
class AppLocalDataSourceImpl implements AppLocalDataSource {
  final SharedPreferences sharedPreferences;

  AppLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getServerHost() async {
    return sharedPreferences.getString(AppConstants.serverHostKey);
  }

  @override
  Future<void> saveServerHost(String host) async {
    await sharedPreferences.setString(AppConstants.serverHostKey, host);
  }

  @override
  Future<int?> getServerPort() async {
    return sharedPreferences.getInt(AppConstants.serverPortKey);
  }

  @override
  Future<void> saveServerPort(int port) async {
    await sharedPreferences.setInt(AppConstants.serverPortKey, port);
  }

  @override
  Future<String?> getApiKey() async {
    return sharedPreferences.getString(AppConstants.apiKeyKey);
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    await sharedPreferences.setString(AppConstants.apiKeyKey, apiKey);
  }

  @override
  Future<String?> getSelectedProvider() async {
    return sharedPreferences.getString(AppConstants.selectedProviderKey);
  }

  @override
  Future<void> saveSelectedProvider(String providerId) async {
    await sharedPreferences.setString(
      AppConstants.selectedProviderKey,
      providerId,
    );
  }

  @override
  Future<String?> getSelectedModel() async {
    return sharedPreferences.getString(AppConstants.selectedModelKey);
  }

  @override
  Future<void> saveSelectedModel(String modelId) async {
    await sharedPreferences.setString(AppConstants.selectedModelKey, modelId);
  }

  @override
  Future<String?> getThemeMode() async {
    return sharedPreferences.getString(AppConstants.themeKey);
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    await sharedPreferences.setString(AppConstants.themeKey, themeMode);
  }

  @override
  Future<String?> getLastSessionId() async {
    return sharedPreferences.getString(AppConstants.lastSessionIdKey);
  }

  @override
  Future<void> saveLastSessionId(String sessionId) async {
    await sharedPreferences.setString(AppConstants.lastSessionIdKey, sessionId);
  }

  @override
  Future<String?> getCurrentSessionId() async {
    return sharedPreferences.getString(AppConstants.currentSessionIdKey);
  }

  @override
  Future<void> saveCurrentSessionId(String sessionId) async {
    await sharedPreferences.setString(AppConstants.currentSessionIdKey, sessionId);
  }

  @override
  Future<String?> getCachedSessions() async {
    return sharedPreferences.getString(AppConstants.cachedSessionsKey);
  }

  @override
  Future<void> saveCachedSessions(String sessionsJson) async {
    await sharedPreferences.setString(AppConstants.cachedSessionsKey, sessionsJson);
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.clear();
  }
}
