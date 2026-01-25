import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../network/api_response.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) return null;

      final tempDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      // Gọi API Refresh Token
      print('TOKEN_SERVICE: Attempting to refresh token...');
      final response = await tempDio.post('/v1/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      print('TOKEN_SERVICE: Refresh response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apiRes = ApiResponse.fromJson(response.data);
        if (apiRes.isSuccess && apiRes.result != null) {
          final data = apiRes.result as Map<String, dynamic>;
          final newAccessToken = data['token'] ?? data['accessToken'];
          
          if (newAccessToken != null) {
            await _storage.write(key: 'accessToken', value: newAccessToken);
            if (data['refreshToken'] != null) {
              await _storage.write(key: 'refreshToken', value: data['refreshToken']);
            }
            return newAccessToken;
          }
        }
      }
      return null;
    } catch (e) {
      // Nếu lỗi refresh token -> Xóa token để force logout
      print('TOKEN_SERVICE ERROR: Failed to refresh token - $e');
      await _storage.deleteAll();
      return null;
    }
  }
}
