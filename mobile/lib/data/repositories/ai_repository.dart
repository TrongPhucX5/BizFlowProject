import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class AiRepository {
  final Dio _dio = DioClient.instance;

  /// Gửi văn bản để AI phân tích và trả về đơn hàng nháp
  /// [text]: Nội dung nhập (VD: "Bán 2 bao xi măng cho anh Nam")
  /// Trả về: List các item trong đơn hàng
  Future<List<Map<String, dynamic>>> generateDraftOrder(String text) async {
    try {
      final response = await _dio.post(ApiConstants.aiChatEndpoint, data: {
        "message": text,
        "history": [], // Có thể gửi kèm lịch sử chat nếu cần context
        "intent": "CREATE_ORDER" // Gợi ý cho Backend biết đây là intent tạo đơn
      });

      if (response.statusCode == 200) {
        final data = response.data;
        // Giả định cấu trúc response từ Backend:
        // {
        //   "result": {
        //     "reply": "Đã tạo đơn...",
        //     "draftOrder": { "items": [...] }
        //   }
        // }
        
        final result = data['result'] ?? {};
        final draftOrder = result['draftOrder'] ?? {};
        final items = draftOrder['items'] ?? [];

        return List<Map<String, dynamic>>.from(items);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi phân tích AI');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}