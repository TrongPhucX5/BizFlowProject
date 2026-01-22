import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance {
    const storage = FlutterSecureStorage();
    // FIX: Chỉ add interceptor nếu chưa có (Tránh bị duplicate khi gọi nhiều lần)
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token từ bộ nhớ máy
          final token = await storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // DEBUG LOGGING
          print("--- DIO REQUEST ---");
          print("URI: ${options.uri}");
          print("HEADERS: ${options.headers}");
          print("BODY: ${options.data}");
          return handler.next(options);
        },
        onError: (error, handler) {
          // Xử lý lỗi chung (VD: 401 thì logout)
          print("--- DIO ERROR ---");
          print("URI: ${error.requestOptions.uri}");
          print("STATUS: ${error.response?.statusCode}");
          print("DATA SENT: ${error.requestOptions.data}");
          print("RESPONSE: ${error.response?.data}");
          return handler.next(error);
        },
      ));
    }
    return _dio;
  }
}