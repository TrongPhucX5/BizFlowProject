import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/api_constants.dart';

class AuthRepository {
  // ================== STORAGE & SOCIAL ==================
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ================== LOGIN (GIỮ NGUYÊN 100%) ==================
  /// Gọi API để đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final String fullUrl =
        "${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}";
    final url = Uri.parse(fullUrl);

    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    print("🚀 Đang gọi API: $fullUrl");
    print("📦 Body gửi đi: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      print("📩 Server phản hồi: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Chi tiết lỗi: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Đăng nhập thất bại (${response.statusCode})',
        );
      }
    } catch (e) {
      print("☠️ Lỗi kết nối: $e");
      throw Exception(
        'Không thể kết nối đến máy chủ. Hãy kiểm tra Backend đang chạy chưa.',
      );
    }
  }

  // ================== LOGOUT (BỔ SUNG) ==================
  /// Đăng xuất: xóa token + dữ liệu local + logout social (nếu có)
  Future<void> logout() async {
    try {
      // 1. Xóa toàn bộ dữ liệu lưu local (token, user...)
      await _storage.deleteAll();

      // 2. Logout Google (nếu user đăng nhập bằng Google)
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      print("✅ Logout thành công");
    } catch (e) {
      print("❌ Lỗi khi logout: $e");
      rethrow;
    }
  }
}
