import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class AiRepository {
  final Dio _dio = DioClient.instance;

  /// Gửi văn bản để AI phân tích (và tạo đơn nếu là intent tạo đơn)
  /// [text]: Nội dung nhập (VD: "Bán 2 bao xi măng cho anh Nam")
  /// Trả về: Toàn bộ kết quả từ Backend (reply, is_order, data, ...)
  Future<Map<String, dynamic>> chatWithAI(String text) async {
    try {
      final response = await _dio.post(ApiConstants.aiChatEndpoint, data: {
        "message": text,
        "history": [],
      });

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi phân tích AI');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
