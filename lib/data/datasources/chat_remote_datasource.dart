import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';
import '../../core/errors/exceptions.dart';

/// Chat remote data source
abstract class ChatRemoteDataSource {
  /// Get session list
  Future<List<ChatSessionModel>> getSessions(String workspaceId);

  /// Get session details
  Future<ChatSessionModel> getSession(String sessionId);

  /// Create session
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

/// Chat remote data source实现
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
      print('=== 开始发送消息 ===');
      print('会话ID: $sessionId');
      print('消息ID: ${input.messageId}');
      print('==================');

      // 启动 SSE 监听器，监听消息更新事件
      final eventController = StreamController<ChatMessageModel>();
      late StreamSubscription eventSubscription;
      bool messageCompleted = false;

      // 创建 SSE 监听器
      try {
        final eventResponse = await dio.get(
          '/event',
          options: Options(
            headers: {
              'Accept': 'text/event-stream',
              'Cache-Control': 'no-cache',
            },
            responseType: ResponseType.stream,
          ),
        );

        if (eventResponse.statusCode == 200) {
          print('✅ 成功连接到事件流');

          eventSubscription = (eventResponse.data as Stream<Uint8List>)
              .transform(
                StreamTransformer.fromHandlers(
                  handleData: (Uint8List data, EventSink<String> sink) {
                    sink.add(utf8.decode(data));
                  },
                ),
              )
              .transform(const LineSplitter())
              .where((line) => line.startsWith('data: '))
              .map((line) => line.substring(6)) // 移除 "data: " 前缀
              .where((data) => data.isNotEmpty && data != '[DONE]')
              .listen(
                (eventData) {
                  try {
                    final event = jsonDecode(eventData) as Map<String, dynamic>;
                    final eventType = event['type'] as String?;

                    print('📨 收到事件: $eventType');

                    if (eventType == 'message.updated') {
                      final properties =
                          event['properties'] as Map<String, dynamic>?;
                      final info = properties?['info'] as Map<String, dynamic>?;

                      if (info != null && info['sessionID'] == sessionId) {
                        print('🔄 消息更新事件: ${info['id']}');
                        // 获取完整的消息信息（包括 parts）
                        _getCompleteMessage(sessionId, info['id'])
                            .then((message) {
                              if (message != null) {
                                eventController.add(message);

                                // 检查消息是否完成
                                if (message.completedTime != null &&
                                    !messageCompleted) {
                                  messageCompleted = true;
                                  print('🎉 消息完成，准备关闭事件流');
                                  // 延迟关闭，确保最后的更新被处理
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      eventSubscription.cancel();
                                      eventController.close();
                                    },
                                  );
                                }
                              }
                            })
                            .catchError((error) {
                              print('获取完整消息失败: $error');
                            });
                      }
                    } else if (eventType == 'message.part.updated') {
                      final properties =
                          event['properties'] as Map<String, dynamic>?;
                      final part = properties?['part'] as Map<String, dynamic>?;

                      if (part != null && part['sessionID'] == sessionId) {
                        print(
                          '🔄 消息部件更新: ${part['messageID']} - ${part['id']}',
                        );
                        // 获取完整的消息信息
                        _getCompleteMessage(sessionId, part['messageID'])
                            .then((message) {
                              if (message != null) {
                                eventController.add(message);

                                // 检查消息是否完成
                                if (message.completedTime != null &&
                                    !messageCompleted) {
                                  messageCompleted = true;
                                  print('🎉 消息完成，准备关闭事件流');
                                  // 延迟关闭，确保最后的更新被处理
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      eventSubscription.cancel();
                                      eventController.close();
                                    },
                                  );
                                }
                              }
                            })
                            .catchError((error) {
                              print('获取完整消息失败: $error');
                            });
                      }
                    }
                  } catch (e) {
                    print('解析事件失败: $e');
                    print('事件数据: $eventData');
                  }
                },
                onError: (error) {
                  print('事件流错误: $error');
                  eventController.addError(error);
                },
                onDone: () {
                  print('事件流结束');
                  eventController.close();
                },
              );
        }
      } catch (e) {
        print('连接事件流失败: $e');
      }

      // 发送消息请求
      final response = await dio.post(
        '/session/$sessionId/message',
        data: input.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('=== 消息发送成功 ===');
        print('响应数据: ${jsonEncode(responseData)}');
        print('==================');

        // 如果有直接响应，先yield一次
        if (responseData is Map<String, dynamic>) {
          try {
            // 检查响应是否包含 info 和 parts 字段
            if (responseData.containsKey('info')) {
              print('=== 处理包含 info 的响应 ===');
              final info = responseData['info'] as Map<String, dynamic>;
              final parts = responseData['parts'] as List<dynamic>? ?? [];

              print('Info 数据: ${jsonEncode(info)}');
              print('Parts 数量: ${parts.length}');

              // 检查 time 字段结构
              print('=== Time 字段分析 ===');
              final timeField = info['time'];
              print('Time 字段类型: ${timeField.runtimeType}');
              print('Time 字段内容: $timeField');
              if (timeField is Map<String, dynamic>) {
                print('Time.created: ${timeField['created']}');
                print('Time.completed: ${timeField['completed']}');
              }
              print('==================');

              // 合并 info 和 parts
              final messageData = Map<String, dynamic>.from(info);
              messageData['parts'] = parts;

              final message = ChatMessageModel.fromJson(messageData);
              print('✅ 成功解析响应消息: ${message.id}');
              yield message;
            } else {
              // 直接解析整个响应
              print('=== 直接解析响应 ===');
              final message = ChatMessageModel.fromJson(responseData);
              print('✅ 成功解析响应消息: ${message.id}');
              yield message;
            }
          } catch (e, stackTrace) {
            print('=== 解析直接响应失败 ===');
            print('❌ 错误: $e');
            print('堆栈跟踪: $stackTrace');
            print('响应数据: ${jsonEncode(responseData)}');
            print('=======================');
          }
        }

        // 然后监听流式更新
        await for (final message in eventController.stream) {
          yield message;
        }
      } else {
        eventSubscription.cancel();
        eventController.close();
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

  /// 获取完整的消息信息（包括parts）
  Future<ChatMessageModel?> _getCompleteMessage(
    String sessionId,
    String messageId,
  ) async {
    try {
      final response = await dio.get('/session/$sessionId/message/$messageId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('=== 获取完整消息响应 ===');
        print('消息ID: $messageId');
        print('响应数据: ${jsonEncode(responseData)}');

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('info') &&
              responseData.containsKey('parts')) {
            final info = responseData['info'] as Map<String, dynamic>;
            final parts = responseData['parts'] as List<dynamic>? ?? [];

            // 检查完整消息的 time 字段
            print('=== 完整消息 Time 字段分析 ===');
            final timeField = info['time'];
            print('Time 字段类型: ${timeField.runtimeType}');
            print('Time 字段内容: $timeField');
            if (timeField is Map<String, dynamic>) {
              print('Time.created: ${timeField['created']}');
              print('Time.completed: ${timeField['completed']}');
            }
            print('==========================');

            final messageData = Map<String, dynamic>.from(info);
            messageData['parts'] = parts;

            final message = ChatMessageModel.fromJson(messageData);
            print('✅ 完整消息解析成功: ${message.id}');
            print('完成时间: ${message.completedTime}');
            return message;
          } else {
            return ChatMessageModel.fromJson(responseData);
          }
        }
      }
    } catch (e) {
      print('获取消息详情失败: $e');
    }
    return null;
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
