import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  // URL API Login (Dành cho máy ảo Android)
  // Nếu chạy máy thật thì đổi 10.0.2.2 thành IP máy tính (ví dụ 192.168.1.x)
  static const String _baseUrl = 'http://10.0.2.2:8080/auth/login';

  /// Gọi API để đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse(_baseUrl);

    // 1. Đóng gói dữ liệu thành JSON
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    print("🚀 Đang gọi API: $_baseUrl");
    print("📦 Body gửi đi: $body");

    try {
      // 2. Gửi request POST
      final response = await http.post(
        url,
        // QUAN TRỌNG: Header này giúp Backend hiểu đây là JSON
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      print("📩 Server phản hồi: ${response.statusCode}");

      // 3. Xử lý kết quả
      if (response.statusCode == 200) {
        // Thành công: Giải mã JSON và trả về (chứa jwt, role)
        // Backend trả về: { "jwt": "...", "role": "..." }
        return jsonDecode(response.body);
      } else {
        // Thất bại (401, 403, 500...)
        // Cố gắng đọc lỗi từ server trả về
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Sai tài khoản hoặc mật khẩu!');
      }
    } catch (e) {
      // Lỗi kết nối (Mất mạng, sai IP, Server sập...)
      print("☠️ Lỗi kết nối: $e");
      throw Exception('Không thể kết nối đến máy chủ. Kiểm tra lại Internet/IP.');
    }
  }
}