import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/network/dio_client.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'package:mobile/core/network/dio_client.dart';

class ProductRepository {
  final Dio _dio = DioClient.instance;

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get(
        ApiConstants.productsEndpoint,
        queryParameters: {'size': 100},
      );
      final apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.isSuccess) {
        var listData = apiResponse.result;
        if (listData is Map) {
          listData = listData['content'] ?? listData['items'] ?? [];
        }
        if (listData is List) {
          return listData.map((e) => Product.fromJson(e)).toList();
        }
        return <Product>[];
      }
      throw Exception(apiResponse.message);
    } catch (e) {
      throw Exception('Lỗi tải sản phẩm: $e');
    }
  }

  Future<List<Category>> getCategories() async {
     try {
      final response = await _dio.get(ApiConstants.categoriesEndpoint); // Ensure this endpoint exists in constants
      final apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.isSuccess) {
        var listData = apiResponse.result;
         if (listData is Map) {
          listData = listData['content'] ?? listData['items'] ?? [];
        }
        if (listData is List) {
          return listData.map((e) => Category.fromJson(e)).toList();
        }
        return <Category>[];
      }
      return <Category>[];
    } catch (e) {
      // Fail silently or log
      print('Lỗi tải danh mục: $e');
      return <Category>[];
    }
  }

  Future<int> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post(ApiConstants.productsEndpoint, data: productData);
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.result != null) {
        if (apiResponse.result is Map) {
          return apiResponse.result['id'] ?? 0;
        }
      }
      return 0;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      await _dio.put('${ApiConstants.productsEndpoint}/$id', data: productData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('${ApiConstants.productsEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

   Future<String?> uploadImage(String filePath) async {
    try {
      final file = await MultipartFile.fromFile(filePath);
      final formData = FormData.fromMap({'file': file});
      
      final response = await _dio.post(ApiConstants.uploadImageEndpoint, data: formData);
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.result != null) {
        if (apiResponse.result is Map) {
          return apiResponse.result['url'];
        }
        return apiResponse.result.toString();
      }
      return null;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.data != null) {
      try {
        final apiRes = ApiResponse.fromJson(e.response!.data);
        if (apiRes.errors != null && apiRes.errors!.isNotEmpty) {
           return Exception(apiRes.errors!.join('\n'));
        }
        return Exception(apiRes.message.isNotEmpty ? apiRes.message : 'Yêu cầu thất bại');
      } catch (_) {
         return Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
      }
    }
    return Exception('Lỗi kết nối: ${e.message}');
  }
}
