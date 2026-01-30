import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

class PaymentRepository {
  final Dio _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> getPayments({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get('/v1/payments', queryParameters: {
        'page': page,
        'size': size,
        'sort': 'createdAt,desc', 
      });

      if (response.statusCode == 200 && response.data['result'] != null) {
        final data = response.data['result'];
        if (data is Map && data.containsKey('content')) {
          return List<Map<String, dynamic>>.from(data['content']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi tải lịch sử thanh toán");
    } catch (e) {
      throw Exception("Lỗi không xác định: $e");
    }
  }
}
