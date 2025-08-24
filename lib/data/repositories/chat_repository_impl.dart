import 'package:dartz/dartz.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_session_model.dart';

/// 聊天仓储实现
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({required this.remoteDataSource});

  final ChatRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<ChatSession>>> getSessions(
    String workspaceId,
  ) async {
    try {
      final sessions = await remoteDataSource.getSessions(workspaceId);
      return Right(sessions.map((s) => s.toDomain()).toList());
    } on ServerException {
      return const Left(ServerFailure('获取会话列表失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> getSession(String sessionId) async {
    try {
      final session = await remoteDataSource.getSession(sessionId);
      return Right(session.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('获取会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> createSession(
    SessionCreateInput input,
  ) async {
    try {
      final inputModel = SessionCreateInputModel.fromDomain(input);
      final session = await remoteDataSource.createSession(inputModel);
      return Right(session.toDomain());
    } on ValidationException {
      return const Left(ValidationFailure('输入参数无效'));
    } on ServerException {
      return const Left(ServerFailure('创建会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> updateSession(
    String sessionId,
    SessionUpdateInput input,
  ) async {
    try {
      final inputModel = SessionUpdateInputModel.fromDomain(input);
      final session = await remoteDataSource.updateSession(
        sessionId,
        inputModel,
      );
      return Right(session.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ValidationException {
      return const Left(ValidationFailure('输入参数无效'));
    } on ServerException {
      return const Left(ServerFailure('更新会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('删除会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> shareSession(String sessionId) async {
    try {
      final session = await remoteDataSource.shareSession(sessionId);
      return Right(session.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('分享会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> unshareSession(String sessionId) async {
    try {
      final session = await remoteDataSource.unshareSession(sessionId);
      return Right(session.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('取消分享会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String sessionId,
  ) async {
    try {
      final messages = await remoteDataSource.getMessages(sessionId);
      return Right(messages.map((m) => m.toDomain()).toList());
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('获取消息列表失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> getMessage(
    String sessionId,
    String messageId,
  ) async {
    try {
      final message = await remoteDataSource.getMessage(sessionId, messageId);
      return Right(message.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('消息不存在'));
    } on ServerException {
      return const Left(ServerFailure('获取消息失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Stream<Either<Failure, ChatMessage>> sendMessage(
    String sessionId,
    ChatInput input,
  ) async* {
    try {
      final inputModel = ChatInputModel.fromDomain(input);
      final messageStream = remoteDataSource.sendMessage(sessionId, inputModel);

      await for (final message in messageStream) {
        yield Right(message.toDomain());
      }
    } on NotFoundException {
      yield const Left(NotFoundFailure('会话不存在'));
    } on ValidationException {
      yield const Left(ValidationFailure('输入参数无效'));
    } on ServerException {
      yield const Left(ServerFailure('发送消息失败'));
    } on NetworkException {
      yield const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      yield const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, void>> abortSession(String sessionId) async {
    try {
      await remoteDataSource.abortSession(sessionId);
      return const Right(null);
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('中止会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, void>> revertMessage(
    String sessionId,
    String messageId,
  ) async {
    try {
      await remoteDataSource.revertMessage(sessionId, messageId);
      return const Right(null);
    } on NotFoundException {
      return const Left(NotFoundFailure('消息不存在'));
    } on ServerException {
      return const Left(ServerFailure('撤销消息失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, void>> unrevertMessages(String sessionId) async {
    try {
      await remoteDataSource.unrevertMessages(sessionId);
      return const Right(null);
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('恢复消息失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, void>> initSession(
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
  }) async {
    try {
      await remoteDataSource.initSession(
        sessionId,
        messageId: messageId,
        providerId: providerId,
        modelId: modelId,
      );
      return const Right(null);
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ValidationException {
      return const Left(ValidationFailure('输入参数无效'));
    } on ServerException {
      return const Left(ServerFailure('初始化会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }

  @override
  Future<Either<Failure, void>> summarizeSession(String sessionId) async {
    try {
      await remoteDataSource.summarizeSession(sessionId);
      return const Right(null);
    } on NotFoundException {
      return const Left(NotFoundFailure('会话不存在'));
    } on ServerException {
      return const Left(ServerFailure('总结会话失败'));
    } on NetworkException {
      return const Left(NetworkFailure('网络连接失败'));
    } catch (e) {
      return const Left(UnknownFailure('未知错误'));
    }
  }
}
