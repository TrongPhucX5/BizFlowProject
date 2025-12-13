import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // FIX: Chỉ add interceptor nếu chưa có (Tránh bị duplicate khi gọi nhiều lần)
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token từ bộ nhớ máy
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Xử lý lỗi chung (VD: 401 thì logout)
          print("Lỗi API: ${error.response?.statusCode} - ${error.message}");
          return handler.next(error);
        },
      ));
    }
    return _dio;
  }
}