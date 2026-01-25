import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';

class InventoryRepository {
  final Dio _dio = DioClient.instance;

  // Endpoint điều chỉnh kho KHÔNG tồn tại trên BE
  Future<void> adjustInventory({
    required int productId,
    required int quantity,
    required String reason,
  }) async {
    // Tạm thời báo lỗi vì BE chưa hỗ trợ
    throw Exception("Tính năng Điều chỉnh kho chưa hỗ trợ trên Server!");
  }

  /// Nhập hàng (Stock In) - Map sang API /v1/inventory/import
  Future<void> stockIn({
    required int productId,
    required int quantity,
    required double unitCost, // Thêm giá nhập
    String? note,
    String? supplierName,
  }) async {
    try {
      final data = {
        'productId': productId,
        'quantity': quantity,
        'unitCost': unitCost,
        'note': note,
        'supplierName': supplierName,
      };

      // Gọi đúng Endpoint BE: /v1/inventory/import
      // Cần map endpoint trong ApiConstants.dart (inventoryStockInEndpoint đang là /stock-in)
      // Tạm thời hardcode đường dẫn đúng ở đây hoặc sửa ApiConstants
      // Theo ApiConstants hiện tại là "/v1/inventory/stock-in", BE là "/v1/inventory/import"
      // -> Sửa lại call trực tiếp
      await _dio.post('/v1/inventory/import', data: data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
         try {
            final apiRes = ApiResponse.fromJson(e.response!.data);
            throw Exception(apiRes.message);
         } catch (_) {}
         throw Exception(e.response?.data['message'] ?? 'Lỗi nhập hàng');
      }
      throw Exception('Lỗi nhập hàng');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy danh sách tồn kho thấp -> FILTER LOCALLY (BE không có API)
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    // Trả về rỗng để UI không crash. 
    // Logic filter sẽ nằm ở ProductScreen
    return [];
  }
}