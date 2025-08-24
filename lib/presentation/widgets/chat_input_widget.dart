import 'package:flutter/material.dart';

/// 聊天输入组件
class ChatInputWidget extends StatefulWidget {
  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    this.enabled = true,
  });

  final Function(String message) onSendMessage;
  final bool enabled;

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.enabled) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  void _handleTextChanged(String text) {
    setState(() {
      _isComposing = text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 附件按钮
              IconButton(
                onPressed: widget.enabled ? _showAttachmentOptions : null,
                icon: const Icon(Icons.attach_file),
                tooltip: '添加附件',
              ),
              const SizedBox(width: 8),

              // 输入框
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    onChanged: _handleTextChanged,
                    onSubmitted: (_) => _handleSendMessage(),
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 发送按钮
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  onPressed: (_isComposing && widget.enabled)
                      ? _handleSendMessage
                      : null,
                  icon: Icon(
                    Icons.send,
                    color: (_isComposing && widget.enabled)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: '发送消息',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('选择图片'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('选择文件'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    // TODO: 实现图片选择功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('图片选择功能待实现')));
  }

  void _pickFile() {
    // TODO: 实现文件选择功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('文件选择功能待实现')));
  }

  void _takePhoto() {
    // TODO: 实现拍照功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('拍照功能待实现')));
  }
}
