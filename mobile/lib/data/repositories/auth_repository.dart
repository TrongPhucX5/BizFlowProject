import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthRepository {
  // ❌ KHÔNG DÙNG DÒNG NÀY NỮA (Nó là nguyên nhân gây lỗi)
  // static const String _baseUrl = 'http://10.0.2.2:8080/auth/login';

  /// Gọi API để đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {

    // ✅ DÙNG CÁI NÀY: Lấy URL từ ApiConstants (Đã có sẵn logic chọn IP và /api/v1)
    final String fullUrl = "${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}";
    final url = Uri.parse(fullUrl);

    // 1. Đóng gói dữ liệu thành JSON
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    print("🚀 Đang gọi API: $fullUrl"); // In ra để kiểm tra
    print("📦 Body gửi đi: $body");

    try {
      // 2. Gửi request POST
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      print("📩 Server phản hồi: ${response.statusCode}");

      // In luôn nội dung lỗi nếu có để dễ debug
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Chi tiết lỗi: ${response.body}");
      }

      // 3. Xử lý kết quả
      if (response.statusCode == 200 || response.statusCode == 201) { // Thêm 201 cho chắc
        // Thành công
        return jsonDecode(response.body);
      } else {
        // Thất bại
        final errorData = jsonDecode(response.body);
        // Lấy message lỗi từ backend (nếu có)
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại (${response.statusCode})');
      }
    } catch (e) {
      print("☠️ Lỗi kết nối: $e");
      throw Exception('Không thể kết nối đến máy chủ. Hãy kiểm tra lại Backend đang chạy chưa.');
    }
  }
}