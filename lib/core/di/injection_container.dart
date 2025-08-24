import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

import '../../data/datasources/app_remote_datasource.dart';
import '../../data/datasources/app_local_datasource.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../domain/repositories/app_repository.dart';
import '../../domain/usecases/get_app_info.dart';
import '../../domain/usecases/check_connection.dart';
import '../../domain/usecases/update_server_config.dart';
import '../../domain/usecases/send_chat_message.dart';
import '../../domain/usecases/get_chat_sessions.dart';
import '../../domain/usecases/create_chat_session.dart';
import '../../domain/usecases/get_chat_messages.dart';
import '../../domain/usecases/get_providers.dart';
import '../../domain/usecases/delete_chat_session.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../presentation/providers/app_provider.dart';
import '../../presentation/providers/chat_provider.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Network
  sl.registerLazySingleton(() => DioClient());

  // Data sources
  sl.registerLazySingleton<AppRemoteDataSource>(
    () => AppRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  sl.registerLazySingleton<AppLocalDataSource>(
    () => AppLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Repositories
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      dioClient: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAppInfo(sl()));
  sl.registerLazySingleton(() => CheckConnection(sl()));
  sl.registerLazySingleton(() => UpdateServerConfig(sl()));
  sl.registerLazySingleton(() => SendChatMessage(sl()));
  sl.registerLazySingleton(() => GetChatSessions(sl()));
  sl.registerLazySingleton(() => CreateChatSession(sl()));
  sl.registerLazySingleton(() => GetChatMessages(sl()));
  sl.registerLazySingleton(() => GetProviders(sl()));
  sl.registerLazySingleton(() => DeleteChatSession(sl()));

  // State management
  sl.registerFactory(
    () => AppProvider(
      getAppInfo: sl(),
      checkConnection: sl(),
      updateServerConfig: sl(),
    ),
  );

  sl.registerFactory(
    () => ChatProvider(
      sendChatMessage: sl(),
      getChatSessions: sl(),
      createChatSession: sl(),
      getChatMessages: sl(),
      getProviders: sl(),
      deleteChatSession: sl(),
    ),
  );

  // Load local configuration
  await _loadLocalConfig();
}

/// Load local configuration
Future<void> _loadLocalConfig() async {
  final localDataSource = sl<AppLocalDataSource>();
  final dioClient = sl<DioClient>();

  // Get saved server configuration
  final host = await localDataSource.getServerHost();
  final port = await localDataSource.getServerPort();

  if (host != null && port != null) {
    final baseUrl = 'http://$host:$port';
    dioClient.updateBaseUrl(baseUrl);
  }
}
