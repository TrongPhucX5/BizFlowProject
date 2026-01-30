import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class DebtRepository {
  final Dio _dio = DioClient.instance;

  /// Lấy danh sách công nợ khách hàng
  Future<List<Map<String, dynamic>>> getDebts({int? customerId}) async {
    try {
      final Map<String, dynamic> query = {};
      if (customerId != null) query['customerId'] = customerId;

      final response = await _dio.get(ApiConstants.debtsEndpoint, queryParameters: query);
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Xử lý cấu trúc response (result -> content/items)
        var listData = (data is Map && data.containsKey('result')) ? data['result'] : data;
        final list = (listData is Map) 
            ? (listData['content'] ?? listData['items'] ?? []) 
            : (listData is List ? listData : []);
            
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải danh sách công nợ');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Tạo thanh toán mới (Thu tiền / Trả nợ)
  Future<void> createPayment(Map<String, dynamic> paymentData) async {
    try {
      // Endpoint: POST /v1/payments
      await _dio.post(ApiConstants.paymentsEndpoint, data: paymentData);
    } on DioException catch (e) {
      // Xử lý lỗi từ server
      throw Exception(e.response?.data['message'] ?? 'Thanh toán thất bại');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}