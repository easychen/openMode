import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/entities/chat_message.dart';

/// 聊天消息组件
class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 现代化头像设计
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUser
                    ? [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ]
                    : [
                        Theme.of(context).colorScheme.tertiary,
                        Theme.of(context).colorScheme.tertiaryContainer,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      (isUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary)
                          .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isUser ? Icons.person : Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // 消息内容容器 - 现代化设计
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  topRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 消息头部信息 - 现代化设计
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(
                                  context,
                                ).colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUser ? '你' : 'AI 助手',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isUser
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatTime(message.time),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                        ),
                      ),
                      const Spacer(),
                      if (!isUser && message is AssistantMessage)
                        _buildAssistantInfo(
                          context,
                          message as AssistantMessage,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 消息部件列表
                  ...message.parts.map(
                    (part) => _buildMessagePart(context, part),
                  ),

                  // 错误信息
                  if (message is AssistantMessage &&
                      (message as AssistantMessage).error != null)
                    _buildErrorInfo(
                      context,
                      (message as AssistantMessage).error!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantInfo(BuildContext context, AssistantMessage message) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.info_outline,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      tooltip: '消息信息',
      itemBuilder: (context) => [
        if (message.modelId != null)
          PopupMenuItem(enabled: false, child: Text('模型: ${message.modelId}')),
        if (message.providerId != null)
          PopupMenuItem(
            enabled: false,
            child: Text('提供商: ${message.providerId}'),
          ),
        if (message.tokens != null)
          PopupMenuItem(
            enabled: false,
            child: Text('令牌: ${message.tokens!.total}'),
          ),
        if (message.cost != null)
          PopupMenuItem(
            enabled: false,
            child: Text('成本: \$${message.cost!.toStringAsFixed(6)}'),
          ),
      ],
    );
  }

  Widget _buildMessagePart(BuildContext context, MessagePart part) {
    switch (part.type) {
      case PartType.text:
        return _buildTextPart(context, part as TextPart);
      case PartType.file:
        return _buildFilePart(context, part as FilePart);
      case PartType.tool:
        return _buildToolPart(context, part as ToolPart);
      case PartType.reasoning:
        return _buildReasoningPart(context, part as ReasoningPart);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextPart(BuildContext context, TextPart part) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 使用 Markdown 渲染文本
          MarkdownBody(
            data: part.text,
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyMedium,
              code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              codeblockDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onTapLink: (text, href, title) {
              if (href != null) {
                // TODO: 实现链接跳转
              }
            },
          ),
          const SizedBox(height: 8),

          // 复制按钮
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: part.text));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('复制'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePart(BuildContext context, FilePart part) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(part.mime),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.filename ?? '文件',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (part.source?.path != null)
                  Text(
                    part.source!.path,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: 实现文件下载或查看
            },
            icon: const Icon(Icons.download),
            tooltip: '下载文件',
          ),
        ],
      ),
    );
  }

  Widget _buildToolPart(BuildContext context, ToolPart part) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '工具调用: ${part.tool}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              _buildToolStatusChip(context, part.state.status),
            ],
          ),
          const SizedBox(height: 8),

          // 工具状态详情
          _buildToolStateDetails(context, part.state),
        ],
      ),
    );
  }

  Widget _buildReasoningPart(BuildContext context, ReasoningPart part) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '思考过程',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            part.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildToolStatusChip(BuildContext context, ToolStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ToolStatus.pending:
        color = Colors.grey;
        label = '等待中';
        icon = Icons.schedule;
        break;
      case ToolStatus.running:
        color = Colors.blue;
        label = '运行中';
        icon = Icons.play_arrow;
        break;
      case ToolStatus.completed:
        color = Colors.green;
        label = '已完成';
        icon = Icons.check;
        break;
      case ToolStatus.error:
        color = Colors.red;
        label = '错误';
        icon = Icons.error;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildToolStateDetails(BuildContext context, ToolState state) {
    switch (state.status) {
      case ToolStatus.running:
        final runningState = state as ToolStateRunning;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (runningState.title != null)
              Text(
                runningState.title!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const LinearProgressIndicator(),
          ],
        );
      case ToolStatus.completed:
        final completedState = state as ToolStateCompleted;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (completedState.title != null)
              Text(
                completedState.title!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            if (completedState.output.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  completedState.output,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
          ],
        );
      case ToolStatus.error:
        final errorState = state as ToolStateError;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            errorState.error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorInfo(BuildContext context, MessageError error) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                Text(
                  error.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String mime) {
    if (mime.startsWith('image/')) {
      return Icons.image;
    } else if (mime.startsWith('video/')) {
      return Icons.video_file;
    } else if (mime.startsWith('audio/')) {
      return Icons.audio_file;
    } else if (mime.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mime.contains('text/')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
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
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
