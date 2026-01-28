import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';

class ReportRepository {
  final Dio _dio = DioClient.instance;

  /// Lấy thống kê tổng quan dashboard
  /// Trả về: revenueToday, ordersToday, totalDebt, warningProducts
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get(ApiConstants.reportDashboardStatsEndpoint);
      
      // Backend trả về trực tiếp Map (không wrap trong ApiResponse)
      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }
      
      // Fallback nếu có wrapper
      final apiResponse = ApiResponse.fromJson(response.data);
      if (apiResponse.isSuccess && apiResponse.result != null) {
        return Map<String, dynamic>.from(apiResponse.result);
      }
      
      return {};
    } catch (e) {
      print("Lỗi lấy dashboard stats: $e");
      return {};
    }
  }

  /// Lấy dữ liệu biểu đồ doanh thu
  /// [period]: week, month, year
  Future<List<Map<String, dynamic>>> getRevenueData({String period = 'week'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.reportRevenueEndpoint,
        queryParameters: {'period': period},
      );
      
      // Backend trả về List trực tiếp
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      // Fallback nếu có wrapper
      final apiResponse = ApiResponse.fromJson(response.data);
      if (apiResponse.isSuccess && apiResponse.result != null) {
        if (apiResponse.result is List) {
          return List<Map<String, dynamic>>.from(apiResponse.result);
        }
      }
      
      return [];
    } catch (e) {
      print("Lỗi lấy revenue data: $e");
      return [];
    }
  }

  /// Lấy danh sách top sản phẩm bán chạy
  Future<List<Map<String, dynamic>>> getBestSellingProducts() async {
    try {
      final response = await _dio.get(ApiConstants.reportBestSellingEndpoint);
      
      // Backend trả về List trực tiếp
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      // Fallback nếu có wrapper
      final apiResponse = ApiResponse.fromJson(response.data);
      if (apiResponse.isSuccess && apiResponse.result != null) {
        if (apiResponse.result is List) {
          return List<Map<String, dynamic>>.from(apiResponse.result);
        }
      }
      
      return [];
    } catch (e) {
      print("Lỗi lấy best selling: $e");
      return [];
    }
  }
}
