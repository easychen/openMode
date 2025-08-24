import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

import '../widgets/chat_message_widget.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/chat_session_list.dart';

/// 聊天页面
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final chatProvider = context.read<ChatProvider>();

    // 使用默认工作空间 ID（实际项目中应该从用户配置或服务器获取）
    const workspaceId = 'default';
    chatProvider.loadSessions(workspaceId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'new_session':
                      await _createNewSession();
                      break;
                    case 'refresh':
                      await chatProvider.refresh();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'new_session',
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('新建对话'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('刷新'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildSessionDrawer(),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // 当前会话信息
              if (chatProvider.currentSession != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    chatProvider.currentSession!.title ?? '新对话',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),

              // 消息列表
              Expanded(child: _buildMessageList(chatProvider)),

              // 输入框
              ChatInputWidget(
                onSendMessage: (text) async {
                  await chatProvider.sendMessage(text);
                  _scrollToBottom();
                },
                enabled:
                    chatProvider.currentSession != null &&
                    chatProvider.state != ChatState.sending,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionDrawer() {
    return Drawer(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              AppBar(
                title: const Text('对话列表'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _createNewSession,
                    tooltip: '新建对话',
                  ),
                ],
              ),
              Expanded(
                child: ChatSessionList(
                  sessions: chatProvider.sessions,
                  currentSession: chatProvider.currentSession,
                  onSessionSelected: (session) {
                    chatProvider.selectSession(session);
                    Navigator.of(context).pop(); // 关闭抽屉
                  },
                  onSessionDeleted: (session) {
                    // TODO: 实现删除会话功能
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    if (chatProvider.state == ChatState.loading &&
        chatProvider.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.state == ChatState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              chatProvider.errorMessage ?? '发生错误',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                chatProvider.clearError();
                chatProvider.refresh();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (chatProvider.currentSession == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '选择或创建一个对话开始聊天',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createNewSession,
              icon: const Icon(Icons.add),
              label: const Text('新建对话'),
            ),
          ],
        ),
      );
    }

    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.waving_hand,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '你好！我是你的 AI 助手',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '有什么可以帮助你的吗？',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount:
          chatProvider.messages.length +
          (chatProvider.state == ChatState.sending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < chatProvider.messages.length) {
          final message = chatProvider.messages[index];
          return ChatMessageWidget(key: ValueKey(message.id), message: message);
        } else {
          // 显示加载指示器
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(width: 40), // 头像占位
                const SizedBox(width: 12),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  '正在思考中...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> _createNewSession() async {
    final chatProvider = context.read<ChatProvider>();

    // 使用默认工作空间 ID（实际项目中应该从用户配置或服务器获取）
    const workspaceId = 'default';
    await chatProvider.createNewSession(workspaceId);
  }
}
