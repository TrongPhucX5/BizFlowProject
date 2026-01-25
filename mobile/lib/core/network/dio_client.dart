import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../services/token_service.dart';

class DioClient {
  // Biến cờ để kiểm soát quá trình refresh
  static bool _isRefreshing = false;
  // Hàng đợi lưu các request bị fail để retry sau
  // Lưu cặp (RequestOptions, ErrorInterceptorHandler) để xử lý lại
  static final List<Map<String, dynamic>> _failedRequests = [];

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  )

;

  static Dio get instance {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    
    // ALWAYS add interceptor (remove isEmpty check)
    _dio.interceptors.clear(); // Clear old interceptors first
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ bộ nhớ máy
        final token = await storage.read(key: 'accessToken');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print("✅ DIO REQUEST: Token attached (length: ${token.length})");
        } else {
          print("⚠️ DIO REQUEST: No access token found!");
        }
        // DEBUG LOGGING
        print("--- DIO REQUEST ---");
        print("URI: ${options.uri}");
        print("HEADERS: ${options.headers}");
        print("BODY: ${options.data}");
        return handler.next(options);
      },
        onError: (error, handler) async {
          // Xử lý lỗi chung (VD: 401 thì logout)
          print("--- DIO ERROR ---");
          print("URI: ${error.requestOptions.uri}");
          print("STATUS: ${error.response?.statusCode}");
          print("DATA SENT: ${error.requestOptions.data}");
          print("RESPONSE: ${error.response?.data}");

          // === AUTO REFRESH TOKEN LOGIC ===
          if (error.response?.statusCode == 401) {
            final RequestOptions options = error.requestOptions;

            // Nếu lỗi 401 xảy ra ngay tại API refresh token -> Logout luôn, không retry
            if (options.path.contains('/auth/refresh')) {
              // Xóa token và buộc đăng nhập lại (Logic UI sẽ handle việc check token null)
              await storage.deleteAll();
              return handler.next(error);
            }

            // Nếu đang có tiến trình refresh chạy, xếp request này vào hàng đợi
            if (_isRefreshing) {
              _failedRequests.add({
                'options': options,
                'handler': handler,
              });
              return; // Đợi, không next(error)
            }

            // Bắt đầu quá trình refresh
            _isRefreshing = true;
            try {
              final tokenService = TokenService();
              final newToken = await tokenService.refreshToken();

              if (newToken != null) {
                _isRefreshing = false;
                // 1. Retry request hiện tại
                options.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(options);
                
                // 2. Retry các request trong hàng đợi
                for (var requestMap in _failedRequests) {
                  final RequestOptions retryOptions = requestMap['options'];
                  final ErrorInterceptorHandler retryHandler = requestMap['handler'];
                  
                  // Cập nhật token mới cho request cũ
                  retryOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await _dio.fetch(retryOptions);
                  retryHandler.resolve(retryResponse);
                }
                _failedRequests.clear();

                return handler.resolve(response);
              } else {
                // Refresh thất bại
                _isRefreshing = false;
                // Từ chối tất cả các request đang chờ để UI nhận được lỗi
                for (var requestMap in _failedRequests) {
                  final ErrorInterceptorHandler retryHandler = requestMap['handler'];
                  retryHandler.next(error);
                }
                _failedRequests.clear();
                return handler.next(error);
              }
            } catch (e) {
              _isRefreshing = false;
              for (var requestMap in _failedRequests) {
                final ErrorInterceptorHandler retryHandler = requestMap['handler'];
                retryHandler.next(error);
              }
              _failedRequests.clear();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ));
    
    return _dio;
  }
}