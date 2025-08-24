import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/pages/home_page.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化依赖注入
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => di.sl<AppProvider>())],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // 默认使用深色主题
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
