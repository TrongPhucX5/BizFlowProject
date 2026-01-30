import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class InventoryRepository {
  final Dio _dio = DioClient.instance;

  Future<void> stockIn({
    required int productId,
    required int quantity,
    required double unitCost,
    String? supplierName,
    String? note,
  }) async {
    try {
      await _dio.post('/v1/inventory/import', data: {
        'productId': productId, // BE expects Long, int is fine
        'quantity': quantity,
        'unitCost': unitCost,
        'supplierName': supplierName,
        'note': note,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi nhập kho");
    }
  }

  Future<void> adjustStock({
    required int productId,
    required int newQuantity,
    String? reason,
  }) async {
    try {
      await _dio.post('/v1/inventory/adjust', data: {
        'productId': productId,
        'newQuantity': newQuantity,
        'reason': reason,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi điều chỉnh kho");
    }
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    return [];
  }
}