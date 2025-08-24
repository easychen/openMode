import 'package:flutter/material.dart';
import '../../domain/entities/chat_session.dart';

/// 聊天会话列表组件
class ChatSessionList extends StatelessWidget {
  const ChatSessionList({
    super.key,
    required this.sessions,
    this.currentSession,
    this.onSessionSelected,
    this.onSessionDeleted,
  });

  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final Function(ChatSession session)? onSessionSelected;
  final Function(ChatSession session)? onSessionDeleted;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
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
              '暂无对话',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '创建一个新对话开始聊天',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isSelected = currentSession?.id == session.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          elevation: isSelected ? 2 : 0,
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                Icons.chat,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            title: Text(
              session.title ?? '新对话',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.summary != null && session.summary!.isNotEmpty)
                  Text(
                    session.summary!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer.withOpacity(0.8)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTime(session.time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (session.shared) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.share,
                        size: 12,
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    _showRenameDialog(context, session);
                    break;
                  case 'share':
                    _shareSession(session);
                    break;
                  case 'delete':
                    _showDeleteDialog(context, session);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('重命名'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(session.shared ? Icons.link_off : Icons.link),
                      const SizedBox(width: 8),
                      Text(session.shared ? '取消分享' : '分享'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => onSessionSelected?.call(session),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  void _showRenameDialog(BuildContext context, ChatSession session) {
    final controller = TextEditingController(text: session.title);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名对话'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新的对话名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                // TODO: 实现重命名功能
                Navigator.of(context).pop();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _shareSession(ChatSession session) {
    // TODO: 实现分享/取消分享功能
  }

  void _showDeleteDialog(BuildContext context, ChatSession session) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除对话'),
        content: Text('确定要删除对话 "${session.title ?? '新对话'}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSessionDeleted?.call(session);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
