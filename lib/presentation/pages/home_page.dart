import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/chat_provider.dart';
import 'server_settings_page.dart';
import 'chat_page.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';

/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时检查连接状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().checkConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCode Mobile'),
        actions: [
          // 连接状态指示器
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return IconButton(
                icon: Icon(
                  appProvider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: appProvider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServerSettingsPage(),
                    ),
                  );
                },
              );
            },
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (!appProvider.isConnected) {
            return _buildConnectionRequired();
          }

          return _buildConnectedContent();
        },
      ),
    );
  }

  /// 构建需要连接的界面
  Widget _buildConnectionRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              '需要连接到 OpenCode 服务器',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              '请配置服务器地址和端口',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServerSettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('配置服务器'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建已连接的内容
  Widget _buildConnectedContent() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 欢迎卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        '已连接到 OpenCode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Consumer<AppProvider>(
                    builder: (context, appProvider, child) {
                      if (appProvider.appInfo != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppConstants.smallPadding),
                            Text(
                              '服务器: ${appProvider.serverUrl}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '主机: ${appProvider.appInfo!.hostname}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // 功能菜单
          Text('功能', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppConstants.smallPadding),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.smallPadding,
              mainAxisSpacing: AppConstants.smallPadding,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.chat,
                  title: 'AI 对话',
                  subtitle: '与 AI 助手聊天',
                  onTap: () {
                    _navigateToChat(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.folder,
                  title: '文件管理',
                  subtitle: '浏览和编辑文件',
                  onTap: () {
                    // TODO: 导航到文件管理页面
                    _showComingSoon(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.history,
                  title: '会话历史',
                  subtitle: '查看历史对话',
                  onTap: () {
                    // TODO: 导航到会话历史页面
                    _showComingSoon(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.psychology,
                  title: 'AI 代理',
                  subtitle: '选择 AI 代理',
                  onTap: () {
                    // TODO: 导航到代理选择页面
                    _showComingSoon(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能卡片
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导航到聊天页面
  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => sl<ChatProvider>(),
          child: const ChatPage(),
        ),
      ),
    );
  }

  /// 显示即将推出提示
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('功能开发中，敬请期待！')));
  }
}
