import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/provider.dart';
import '../../domain/usecases/send_chat_message.dart';
import '../../domain/usecases/get_chat_sessions.dart';
import '../../domain/usecases/create_chat_session.dart';
import '../../domain/usecases/get_chat_messages.dart';
import '../../domain/usecases/get_providers.dart';
import '../../domain/usecases/delete_chat_session.dart';
import '../../core/errors/failures.dart';

/// 聊天状态
enum ChatState { initial, loading, loaded, error, sending }

/// 聊天提供者
class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required this.sendChatMessage,
    required this.getChatSessions,
    required this.createChatSession,
    required this.getChatMessages,
    required this.getProviders,
    required this.deleteChatSession,
  });

  // 滚动回调
  VoidCallback? _scrollToBottomCallback;

  final SendChatMessage sendChatMessage;
  final GetChatSessions getChatSessions;
  final CreateChatSession createChatSession;
  final GetChatMessages getChatMessages;
  final GetProviders getProviders;
  final DeleteChatSession deleteChatSession;

  ChatState _state = ChatState.initial;
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  String? _errorMessage;
  StreamSubscription<dynamic>? _messageSubscription;

  // 提供商相关状态
  List<Provider> _providers = [];
  Map<String, String> _defaultModels = {};
  String? _selectedProviderId;
  String? _selectedModelId;

  // Getters
  ChatState get state => _state;
  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  String? get errorMessage => _errorMessage;
  List<Provider> get providers => _providers;
  Map<String, String> get defaultModels => _defaultModels;
  String? get selectedProviderId => _selectedProviderId;
  String? get selectedModelId => _selectedModelId;

  /// 设置滚动到底部的回调
  void setScrollToBottomCallback(VoidCallback? callback) {
    _scrollToBottomCallback = callback;
  }

  /// 设置状态
  void _setState(ChatState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 设置错误
  void _setError(String message) {
    _errorMessage = message;
    _setState(ChatState.error);
  }

  /// 初始化提供商
  Future<void> initializeProviders() async {
    try {
      final result = await getProviders();
      result.fold(
        (failure) {
          print('获取提供商失败: ${failure.toString()}');
          // 使用默认值作为备用
          _selectedProviderId = 'moonshotai-cn'; // 从响应中看到的第一个提供商
          _selectedModelId = 'kimi-k2-turbo-preview'; // 从响应中看到的模型
        },
        (providersResponse) {
          print('成功获取提供商: ${providersResponse.providers.length} 个');
          _providers = providersResponse.providers;
          _defaultModels = providersResponse.defaultModels;

          // 选择默认模型，优先级：
          // 1. Anthropic 提供商（如果可用）
          // 2. 第一个可用的提供商
          if (_providers.isNotEmpty) {
            // 尝试找到 Anthropic 提供商
            Provider selectedProvider;
            final anthropicProvider = _providers
                .where((p) => p.id == 'anthropic')
                .firstOrNull;
            if (anthropicProvider != null) {
              selectedProvider = anthropicProvider;
            } else {
              selectedProvider = _providers.first;
            }

            _selectedProviderId = selectedProvider.id;

            // 获取默认模型或第一个可用模型
            if (_defaultModels.containsKey(selectedProvider.id)) {
              _selectedModelId = _defaultModels[selectedProvider.id];
            } else if (selectedProvider.models.isNotEmpty) {
              _selectedModelId = selectedProvider.models.keys.first;
            }

            print('选择了提供商: $_selectedProviderId, 模型: $_selectedModelId');
          }
        },
      );
    } catch (e) {
      print('初始化提供商时发生异常: $e');
      // 使用默认值作为备用
      _selectedProviderId = 'moonshotai-cn';
      _selectedModelId = 'kimi-k2-turbo-preview';
    }
    notifyListeners();
  }

  /// 加载会话列表
  Future<void> loadSessions(String workspaceId) async {
    _setState(ChatState.loading);

    final result = await getChatSessions(
      GetChatSessionsParams(workspaceId: workspaceId),
    );

    result.fold((failure) => _handleFailure(failure), (sessions) {
      _sessions = sessions;
      _setState(ChatState.loaded);
    });
  }

  /// 创建新会话
  Future<void> createNewSession(String workspaceId, {String? title}) async {
    _setState(ChatState.loading);

    // 生成基于时间的标题
    final now = DateTime.now();
    final defaultTitle = title ?? _generateSessionTitle(now);

    final result = await createChatSession(
      CreateChatSessionParams(
        input: SessionCreateInput(
          workspaceId: workspaceId,
          title: defaultTitle,
        ),
      ),
    );

    result.fold((failure) => _handleFailure(failure), (session) {
      _sessions.insert(0, session);
      _currentSession = session;
      _messages.clear(); // 确保新会话开始时消息列表为空
      _setState(ChatState.loaded);
    });
  }

  /// 生成基于时间的会话标题
  String _generateSessionTitle(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(time.year, time.month, time.day);

    if (sessionDate == today) {
      // 今天的对话显示时间
      return '今天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final difference = today.difference(sessionDate).inDays;
      if (difference == 1) {
        // 昨天的对话
        return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (difference < 7) {
        // 一周内的对话显示星期几
        final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        final weekday = weekdays[time.weekday - 1];
        return '$weekday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        // 更早的对话显示日期
        return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  /// 选择会话
  Future<void> selectSession(ChatSession session) async {
    if (_currentSession?.id == session.id) return;

    // 清空当前消息列表
    _messages.clear();
    _currentSession = session;
    notifyListeners();

    // 加载新会话的消息
    await loadMessages(session.id);
  }

  /// 加载消息列表
  Future<void> loadMessages(String sessionId) async {
    _setState(ChatState.loading);

    final result = await getChatMessages(
      GetChatMessagesParams(sessionId: sessionId),
    );

    result.fold((failure) => _handleFailure(failure), (messages) {
      _messages = messages;
      _setState(ChatState.loaded);
    });
  }

  /// 发送消息
  Future<void> sendMessage(String text) async {
    if (_currentSession == null || text.trim().isEmpty) return;

    _setState(ChatState.sending);

    // 生成消息 ID
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    // 添加用户消息到界面
    final userMessage = UserMessage(
      id: messageId,
      sessionId: _currentSession!.id,
      time: DateTime.now(),
      parts: [
        TextPart(
          id: '${messageId}_text',
          messageId: messageId,
          sessionId: _currentSession!.id,
          text: text,
          time: DateTime.now(),
        ),
      ],
    );

    _messages.add(userMessage);
    notifyListeners();

    // 确保已初始化提供商
    if (_selectedProviderId == null || _selectedModelId == null) {
      await initializeProviders();
    }

    // 创建聊天输入
    final input = ChatInput(
      messageId: messageId,
      providerId: _selectedProviderId ?? 'anthropic', // 使用选中的提供商
      modelId: _selectedModelId ?? 'claude-3-5-sonnet-20241022', // 使用选中的模型
      agent: 'general', // 默认 agent
      system: '', // 默认系统提示
      tools: const {}, // 默认工具配置
      parts: [TextInputPart(text: text)],
    );

    // 取消之前的订阅
    _messageSubscription?.cancel();

    // 发送消息并监听流式响应
    _messageSubscription =
        sendChatMessage(
          SendChatMessageParams(sessionId: _currentSession!.id, input: input),
        ).listen(
          (result) {
            result.fold((failure) => _handleFailure(failure), (message) {
              // 更新或添加助手消息
              _updateOrAddMessage(message);
            });
          },
          onError: (error) {
            _setError('发送消息失败: $error');
          },
          onDone: () {
            _setState(ChatState.loaded);
          },
        );
  }

  /// 更新或添加消息
  void _updateOrAddMessage(ChatMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message;
    } else {
      _messages.add(message);
    }
    notifyListeners();

    // 触发自动滚动
    _scrollToBottomCallback?.call();
  }

  /// 处理失败
  void _handleFailure(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        _setError('网络连接失败，请检查网络设置');
        break;
      case ServerFailure:
        _setError('服务器错误，请稍后再试');
        break;
      case NotFoundFailure:
        _setError('资源不存在');
        break;
      case ValidationFailure:
        _setError('输入参数无效');
        break;
      default:
        _setError('未知错误，请稍后再试');
        break;
    }
  }

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    if (_state == ChatState.error) {
      _setState(ChatState.loaded);
    }
  }

  /// 删除会话
  Future<void> deleteSession(String sessionId) async {
    final result = await deleteChatSession(
      DeleteChatSessionParams(sessionId: sessionId),
    );

    result.fold((failure) => _handleFailure(failure), (_) {
      // 从本地列表中移除会话
      _sessions.removeWhere((session) => session.id == sessionId);

      // 如果删除的是当前会话，清空当前会话和消息
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _messages.clear();

        // 如果还有其他会话，选择第一个
        if (_sessions.isNotEmpty) {
          selectSession(_sessions.first);
        }
      }

      notifyListeners();
    });
  }

  /// 刷新当前会话
  Future<void> refresh() async {
    if (_currentSession != null) {
      await loadMessages(_currentSession!.id);
    } else {
      // 如果没有当前会话，重新加载会话列表
      if (_sessions.isNotEmpty) {
        // 假设我们有 workspaceId，实际应该从应用状态中获取
        // 这里需要根据实际情况调整
        _setState(ChatState.loaded);
      }
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
