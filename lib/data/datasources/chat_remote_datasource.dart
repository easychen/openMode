import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';
import '../../core/errors/exceptions.dart';

/// 聊天远程数据源
abstract class ChatRemoteDataSource {
  /// 获取会话列表
  Future<List<ChatSessionModel>> getSessions(String workspaceId);

  /// 获取会话详情
  Future<ChatSessionModel> getSession(String sessionId);

  /// 创建会话
  Future<ChatSessionModel> createSession(SessionCreateInputModel input);

  /// 更新会话
  Future<ChatSessionModel> updateSession(
    String sessionId,
    SessionUpdateInputModel input,
  );

  /// 删除会话
  Future<void> deleteSession(String sessionId);

  /// 分享会话
  Future<ChatSessionModel> shareSession(String sessionId);

  /// 取消分享会话
  Future<ChatSessionModel> unshareSession(String sessionId);

  /// 获取会话消息列表
  Future<List<ChatMessageModel>> getMessages(String sessionId);

  /// 获取消息详情
  Future<ChatMessageModel> getMessage(String sessionId, String messageId);

  /// 发送聊天消息（流式）
  Stream<ChatMessageModel> sendMessage(String sessionId, ChatInputModel input);

  /// 中止会话
  Future<void> abortSession(String sessionId);

  /// 撤销消息
  Future<void> revertMessage(String sessionId, String messageId);

  /// 恢复撤销的消息
  Future<void> unrevertMessages(String sessionId);

  /// 初始化会话
  Future<void> initSession(
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
  });

  /// 总结会话
  Future<void> summarizeSession(String sessionId);
}

/// 聊天远程数据源实现
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<ChatSessionModel>> getSessions(String workspaceId) async {
    try {
      final response = await dio.get(
        '/session',
        queryParameters: {'workspaceID': workspaceId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatSessionModel.fromJson(json)).toList();
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> getSession(String sessionId) async {
    try {
      final response = await dio.get('/session/$sessionId');

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> createSession(SessionCreateInputModel input) async {
    try {
      final response = await dio.post('/session', data: input.toJson());

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> updateSession(
    String sessionId,
    SessionUpdateInputModel input,
  ) async {
    try {
      final response = await dio.patch(
        '/session/$sessionId',
        data: input.toJson(),
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await dio.delete('/session/$sessionId');

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> shareSession(String sessionId) async {
    try {
      final response = await dio.post('/session/$sessionId/share');

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> unshareSession(String sessionId) async {
    try {
      final response = await dio.delete('/session/$sessionId/share');

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String sessionId) async {
    try {
      final response = await dio.get('/session/$sessionId/message');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) {
          // API 返回的格式是 { info: Message, parts: Part[] }
          final info = item['info'] as Map<String, dynamic>;
          final parts = item['parts'] as List<dynamic>;

          return ChatMessageModel.fromJson({...info, 'parts': parts});
        }).toList();
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatMessageModel> getMessage(
    String sessionId,
    String messageId,
  ) async {
    try {
      final response = await dio.get('/session/$sessionId/message/$messageId');

      if (response.statusCode == 200) {
        // API 返回的格式是 { info: Message, parts: Part[] }
        final info = response.data['info'] as Map<String, dynamic>;
        final parts = response.data['parts'] as List<dynamic>;

        return ChatMessageModel.fromJson({...info, 'parts': parts});
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Stream<ChatMessageModel> sendMessage(
    String sessionId,
    ChatInputModel input,
  ) async* {
    try {
      // 先尝试普通的 JSON 响应
      final response = await dio.post(
        '/session/$sessionId/message',
        data: input.toJson(),
      );

      if (response.statusCode == 200) {
        // 处理直接返回的消息响应
        final responseData = response.data;
        print('发送消息响应: $responseData');

        if (responseData is Map<String, dynamic>) {
          // 检查是否包含 info 和 parts
          if (responseData.containsKey('info') &&
              responseData.containsKey('parts')) {
            final info = responseData['info'] as Map<String, dynamic>;
            final parts = responseData['parts'] as List<dynamic>? ?? [];
            print('解析消息 - info: $info, parts: $parts');

            // 合并 info 和 parts 到一个完整的消息对象
            final messageData = Map<String, dynamic>.from(info);
            messageData['parts'] = parts;

            try {
              print('准备解析消息数据: ${messageData.keys}');
              print('消息数据示例: ${messageData.toString().substring(0, 500)}...');
              final message = ChatMessageModel.fromJson(messageData);
              print('成功创建消息模型: ${message.id}');
              yield message;
            } catch (e, stackTrace) {
              print('创建消息模型失败: $e');
              print('堆栈跟踪: $stackTrace');
              print('失败的数据: $messageData');
              // 尝试提取文本内容作为备用
              String fallbackText = 'AI 回复解析失败';

              // 尝试从 parts 中提取文本
              if (parts.isNotEmpty) {
                final textParts = <String>[];
                for (final part in parts) {
                  if (part is Map<String, dynamic> && part['type'] == 'text') {
                    final text = part['text'] as String?;
                    if (text != null && text.isNotEmpty) {
                      textParts.add(text);
                    }
                  }
                }
                if (textParts.isNotEmpty) {
                  fallbackText = textParts.join('\n');
                }
              }

              // 创建一个简单的文本消息作为备用
              yield ChatMessageModel(
                id: info['id'] ?? 'unknown',
                sessionId: info['sessionID'] ?? '',
                role: info['role'] ?? 'assistant',
                time: DateTime.now(),
                parts: [
                  MessagePartModel(
                    id: 'part_${DateTime.now().millisecondsSinceEpoch}',
                    sessionId: info['sessionID'] ?? '',
                    messageId: info['id'] ?? 'unknown',
                    type: 'text',
                    text: fallbackText,
                  ),
                ],
              );
            }
          } else {
            // 如果直接是消息对象
            print('直接解析消息: $responseData');
            try {
              yield ChatMessageModel.fromJson(responseData);
            } catch (e) {
              print('直接解析消息失败: $e');
            }
          }
        }
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> abortSession(String sessionId) async {
    try {
      final response = await dio.post('/session/$sessionId/abort');

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> revertMessage(String sessionId, String messageId) async {
    try {
      final response = await dio.post(
        '/session/$sessionId/revert',
        data: {'messageID': messageId},
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> unrevertMessages(String sessionId) async {
    try {
      final response = await dio.post('/session/$sessionId/unrevert');

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> initSession(
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
  }) async {
    try {
      final response = await dio.post(
        '/session/$sessionId/init',
        data: {
          'messageID': messageId,
          'providerID': providerId,
          'modelID': modelId,
        },
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> summarizeSession(String sessionId) async {
    try {
      final response = await dio.post('/session/$sessionId/summarize');

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }
}
