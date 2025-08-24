import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';

/// 服务器设置页面
class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({Key? key}) : super(key: key);

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appProvider = context.read<AppProvider>();
    _hostController.text = appProvider.serverHost;
    _portController.text = appProvider.serverPort.toString();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器设置'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return IconButton(
                icon: Icon(
                  appProvider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: appProvider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () => _checkConnection(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 连接状态卡片
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                appProvider.isConnected
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: appProvider.isConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Text(
                                appProvider.isConnected ? '已连接' : '未连接',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          if (!appProvider.isConnected &&
                              appProvider.errorMessage.isNotEmpty) ...[
                            const SizedBox(height: AppConstants.smallPadding),
                            Text(
                              appProvider.errorMessage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (appProvider.isConnected &&
                              appProvider.appInfo != null) ...[
                            const SizedBox(height: AppConstants.smallPadding),
                            Text(
                              '主机: ${appProvider.appInfo!.hostname}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '工作目录: ${appProvider.appInfo!.path.cwd}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // 服务器配置表单
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '服务器配置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // 主机地址输入
                      TextFormField(
                        controller: _hostController,
                        decoration: const InputDecoration(
                          labelText: '主机地址',
                          hintText: '例如: 127.0.0.1',
                          prefixIcon: Icon(Icons.computer),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入主机地址';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // 端口输入
                      TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(
                          labelText: '端口',
                          hintText: '例如: 4096',
                          prefixIcon: Icon(Icons.settings_ethernet),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入端口号';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port < 1 || port > 65535) {
                            return '请输入有效的端口号 (1-65535)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // 重置按钮
                      TextButton(
                        onPressed: _resetToDefault,
                        child: const Text('重置为默认值'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // 保存和测试按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('保存设置'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.wifi_find),
                      label: const Text('测试连接'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final host = _hostController.text.trim();
    final port = int.parse(_portController.text.trim());

    final appProvider = context.read<AppProvider>();
    final success = await appProvider.updateServerConfig(host, port);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('设置已保存')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: ${appProvider.errorMessage}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// 测试连接
  void _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    // 先保存设置
    await _saveSettings();

    // 然后测试连接
    final appProvider = context.read<AppProvider>();
    await appProvider.getAppInfo();

    if (mounted) {
      if (appProvider.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('连接成功!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: ${appProvider.errorMessage}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 检查连接
  void _checkConnection() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.checkConnection();

    if (mounted) {
      final message = appProvider.isConnected ? '连接正常' : '连接失败';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// 重置为默认值
  void _resetToDefault() {
    _hostController.text = ApiConstants.defaultHost;
    _portController.text = ApiConstants.defaultPort.toString();
  }
}
