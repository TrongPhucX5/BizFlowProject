import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance;

  /// Tạo đơn hàng mới
  /// [orderData] bao gồm: customerId, items, paymentMethod, totalAmount
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _dio.post(ApiConstants.ordersEndpoint, data: orderData);
    } on DioException catch (e) {
      // Xử lý lỗi từ server trả về (nếu có message)
      throw Exception(e.response?.data['message'] ?? 'Tạo đơn hàng thất bại');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy danh sách đơn hàng
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get(ApiConstants.ordersEndpoint);
      
      if (response.statusCode == 200) {
        final data = response.data;
        var listData = (data is Map && data.containsKey('result')) ? data['result'] : data;
        final list = (listData is Map) 
            ? (listData['content'] ?? listData['items'] ?? []) 
            : (listData is List ? listData : []);
            
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi tải đơn hàng: $e');
    }
  }

  /// Lấy nội dung hóa đơn để in (HTML)
  Future<String> printOrder(int orderId) async {
    try {
      // Endpoint: GET /v1/orders/{id}/print
      final response = await _dio.get('${ApiConstants.ordersEndpoint}/$orderId/print');
      
      // Xử lý trường hợp Backend trả về JSON wrapper
      if (response.data is Map && response.data['result'] != null) {
        return response.data['result'].toString();
      }
      return response.data.toString();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tải hóa đơn');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}