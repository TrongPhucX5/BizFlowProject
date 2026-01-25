import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_summary.dart';
import '../models/product_dto.dart';

class DashboardRepository {
  final Dio _dio = DioClient.instance;

  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _dio.get('/v1/dashboard/orders/summary');
      if (response.data != null) {
        // Fix: Use ApiResponse wrapper
        final apiRes = response.data; // Depending on how Dio returns it
        // Or if response.data is Map
        if (response.data is Map<String, dynamic>) {
           // Backend returns { "code":..., "result": {...} }
           final result = response.data['result'];
           if (result != null) {
             return DashboardSummary.fromJson(result);
           }
        }
      }
      // If result is null, return default 0s instead of throwing
      return DashboardSummary(totalRevenue: 0, lowStockCount: 0, pendingPayment: 0, totalProducts: 0);
    } catch (e) {
      throw Exception("Lỗi tải tổng quan: $e");
    }
  }

  Future<List<ProductDTO>> getLowStockProducts() async {
    try {
      final response = await _dio.get('/v1/dashboard/products/low-stock');
       if (response.data is Map<String, dynamic>) {
           final result = response.data['result'];
           if (result is List) {
             return result.map((e) => ProductDTO.fromJson(e)).toList();
           }
       }
       return [];
    } catch (e) {
      throw Exception("Lỗi tải cảnh báo tồn kho: $e");
    }
  }
}
