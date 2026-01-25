import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';

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
  Future<List<Map<String, dynamic>>> getOrders({int size = 100}) async {
    try {
      final response = await _dio.get(
        ApiConstants.ordersEndpoint,
        queryParameters: {'size': size},
      );
      
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.isSuccess) {
        var listData = apiResponse.result;
        
        // Handle pagination: result có thể là Map (Page) hoặc List
        if (listData is Map) {
          listData = listData['content'] ?? listData['items'] ?? [];
        }
        
        if (listData is List) {
          return List<Map<String, dynamic>>.from(listData);
        }
        return [];
      }
      
      throw Exception(apiResponse.message);
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