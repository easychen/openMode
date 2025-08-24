import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';

/// Server settings page
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
        title: const Text('Server Settings'),
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
              // Connection status card
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
                                appProvider.isConnected
                                    ? 'Connected'
                                    : 'Disconnected',
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
                              'Host: ${appProvider.appInfo!.hostname}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Working Directory: ${appProvider.appInfo!.path.cwd}',
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

              // Server configuration form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Configuration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Host address input
                      TextFormField(
                        controller: _hostController,
                        decoration: const InputDecoration(
                          labelText: 'Host Address',
                          hintText: 'e.g.: 127.0.0.1',
                          prefixIcon: Icon(Icons.computer),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter host address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // Port input
                      TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          hintText: 'e.g.: 4096',
                          prefixIcon: Icon(Icons.settings_ethernet),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter port number';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port < 1 || port > 65535) {
                            return 'Please enter valid port number (1-65535)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // Reset button
                      TextButton(
                        onPressed: _resetToDefault,
                        child: const Text('Reset to Default'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Save and test buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.wifi_find),
                      label: const Text('Test'),
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

  /// Save settings
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final host = _hostController.text.trim();
    final port = int.parse(_portController.text.trim());

    final appProvider = context.read<AppProvider>();
    final success = await appProvider.updateServerConfig(host, port);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${appProvider.errorMessage}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Test connection
  void _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    // Save settings first
    await _saveSettings();

    // Then test connection
    final appProvider = context.read<AppProvider>();
    await appProvider.getAppInfo();

    if (mounted) {
      if (appProvider.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${appProvider.errorMessage}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Check connection
  void _checkConnection() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.checkConnection();

    if (mounted) {
      final message = appProvider.isConnected
          ? 'Connection OK'
          : 'Connection failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Reset to default values
  void _resetToDefault() {
    _hostController.text = ApiConstants.defaultHost;
    _portController.text = ApiConstants.defaultPort.toString();
  }
}
