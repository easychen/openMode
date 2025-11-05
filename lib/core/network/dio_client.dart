import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'dart:convert';

/// Dio HTTP客户端配置
class DioClient {
  late final Dio _dio;
  String? _basicAuthHeader; // cached Authorization header

  DioClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.defaultBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {ApiConstants.contentType: ApiConstants.applicationJson},
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    // Log base URL change for easier debugging during configuration updates
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('[Dio] Base URL updated: $baseUrl');
    }
  }

  /// Set Basic Authorization header using username and password
  void setBasicAuth(String username, String password) {
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    _basicAuthHeader = 'Basic $encoded';
    _dio.options.headers[ApiConstants.authorization] = _basicAuthHeader!;
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('[Dio] Basic auth header set');
    }
  }

  /// Clear Authorization header
  void clearAuth() {
    _basicAuthHeader = null;
    _dio.options.headers.remove(ApiConstants.authorization);
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('[Dio] Authorization header cleared');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        logPrint: (object) {
          // Print logs in debug mode only
          if (const bool.fromEnvironment('dart.vm.product') == false) {
            print(object);
          }
        },
      ),
    );

    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ensure Authorization header is present if configured
          if (_basicAuthHeader != null &&
              (options.headers[ApiConstants.authorization] == null)) {
            options.headers[ApiConstants.authorization] = _basicAuthHeader;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          // 统一错误处理
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // 超时错误
        break;
      case DioExceptionType.badResponse:
        // HTTP错误状态码
        break;
      case DioExceptionType.cancel:
        // 请求被取消
        break;
      case DioExceptionType.connectionError:
        // 连接错误
        break;
      case DioExceptionType.unknown:
        // 未知错误
        break;
      case DioExceptionType.badCertificate:
        // 证书错误
        break;
    }
  }

  // GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
