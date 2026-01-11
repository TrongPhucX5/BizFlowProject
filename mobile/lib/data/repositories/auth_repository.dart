import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ================== LOGIN ==================
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}");
    final body = jsonEncode({'username': username, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ');
    }
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    try {
      await _storage.deleteAll();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    } catch (e) {
      rethrow;
    }
  }

  // ================== REGISTER ==================
  Future<void> register(String username, String email, String password) async {
    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}");
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ');
    }
  }

  // ================== FORGOT PASSWORD ==================
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.forgotPasswordEndpoint}");
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gửi email quên mật khẩu thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ');
    }
  }
}
