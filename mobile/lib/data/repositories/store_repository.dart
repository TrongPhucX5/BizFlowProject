import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

class StoreRepository {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getMyStore() async {
    try {
      final response = await _dio.get('/v1/stores/me');
      return response.data['result'] ?? {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi tải thông tin cửa hàng");
    }
  }

  Future<void> updateMyStore(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/v1/stores/me', data: data);
       if (response.statusCode != 200) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi cập nhật cửa hàng");
    }
  }
}
