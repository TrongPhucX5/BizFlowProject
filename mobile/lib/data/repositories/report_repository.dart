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
      
      // Gia cố dữ liệu: Đảm bảo không có giá trị Null trả về cho các trường số

      final Map<String, dynamic> rawData = (response.data is Map<String, dynamic>) 
          ? Map<String, dynamic>.from(response.data)
          : {};
      
      // Fallback cho ApiResponse wrapper
      Map<String, dynamic> finalData = rawData;
      if (rawData.isEmpty || !rawData.containsKey('revenueToday')) {
        final apiResponse = ApiResponse.fromJson(response.data);
        if (apiResponse.isSuccess && apiResponse.result is Map) {
          finalData = Map<String, dynamic>.from(apiResponse.result);
        }
      }

      return {
        'revenueToday': double.tryParse((finalData['revenueToday'] ?? 0).toString()) ?? 0.0,
        'ordersToday': int.tryParse((finalData['ordersToday'] ?? finalData['orders'] ?? 0).toString()) ?? 0,
        'totalDebt': double.tryParse((finalData['totalDebt'] ?? 0).toString()) ?? 0.0,
        'warningProducts': int.tryParse((finalData['warningProducts'] ?? finalData['lowStockCount'] ?? 0).toString()) ?? 0,
        'totalProducts': int.tryParse((finalData['totalProducts'] ?? 0).toString()) ?? 0,
        'totalStock': int.tryParse((finalData['totalStock'] ?? 0).toString()) ?? 0,
      };
    } catch (e) {
      print("Lỗi lấy dashboard stats: $e");
      return {
        'revenueToday': 0.0,
        'ordersToday': 0,
        'totalDebt': 0.0,
        'warningProducts': 0,
        'totalProducts': 0,
        'totalStock': 0,
      };
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
