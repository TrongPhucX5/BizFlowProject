import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class InventoryRepository {
  final Dio _dio = DioClient.instance;

  /// Điều chỉnh tồn kho (Kiểm kê, Nhập hàng lẻ, Xuất hủy...)
  /// [productId]: ID sản phẩm
  /// [quantity]: Số lượng điều chỉnh (Dương là tăng, Âm là giảm)
  /// [reason]: Lý do (VD: "Nhập hàng", "Hư hỏng", "Kiểm kê sai lệch")
  Future<void> adjustInventory({
    required int productId,
    required int quantity,
    required String reason,
  }) async {
    try {
      // Payload chuẩn theo nghiệp vụ kho
      final data = {
        'productId': productId,
        'quantity': quantity, 
        'reason': reason,
        'type': quantity > 0 ? 'IMPORT' : 'EXPORT', // Tự động xác định loại phiếu
        'referenceCode': 'ADJ-${DateTime.now().millisecondsSinceEpoch}', // Mã tham chiếu tự sinh
      };

      await _dio.post(ApiConstants.inventoryAdjustEndpoint, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi điều chỉnh kho');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Nhập hàng (Stock In) - Tăng số lượng tồn kho
  Future<void> stockIn({
    required int productId,
    required int quantity,
    String? note,
  }) async {
    try {
      final data = {
        'productId': productId,
        'quantity': quantity,
        'note': note,
        'referenceCode': 'IN-${DateTime.now().millisecondsSinceEpoch}',
      };

      await _dio.post(ApiConstants.inventoryStockInEndpoint, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi nhập hàng');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy danh sách sản phẩm tồn kho thấp (Cảnh báo)
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    try {
      final response = await _dio.get(ApiConstants.inventoryLowStockEndpoint);
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Xử lý response wrapper (result/content/items)
        var listData = (data is Map && data.containsKey('result')) ? data['result'] : data;
        final list = (listData is Map) 
            ? (listData['content'] ?? listData['items'] ?? []) 
            : (listData is List ? listData : []);
            
        return List<Map<String, dynamic>>.from(list);
      }
      throw Exception('Không thể tải danh sách tồn kho thấp');
    } catch (e) {
      throw Exception('Lỗi tải tồn kho: $e');
    }
  }
}