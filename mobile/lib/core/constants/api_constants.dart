import 'dart:io';

class ApiConstants {
  // 1. Tự động chọn IP đúng
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Nếu chạy trên Máy ảo Android
      return "http://10.0.2.2:8080";
    } else {
      // Nếu chạy trên Windows (Máy tính)
      return "http://localhost:8080";
    }
  }

  // 2. Định nghĩa các endpoints
  static const String loginEndpoint = "/auth/login";
  static const String registerEndpoint = "/auth/register";

  // Ví dụ endpoint lấy user
  static const String userEndpoint = "/users";
}