import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // BẮT BUỘC PHẢI LÀ 10.0.2.2 KHI CHẠY MÁY ẢO
      return "http://10.0.2.2:8080/api";
    } else {
      // Windows hoặc iOS thì dùng localhost
      return "http://localhost:8080/api";
    }
  }

  // Nhớ kiểm tra kỹ cái đuôi này, backend của bạn có /v1
  static const String loginEndpoint = "/v1/auth/login";
  static const String registerEndpoint = "/auth/register";
  static const String forgotPasswordEndpoint = "/auth/forgot-password";

}