import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';

class AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final Dio _dio = DioClient.instance;



  // ================== LOGIN ==================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEndpoint, data: {
        'username': username,
        'password': password,
      });

      // Sử dụng ApiResponse để parse chuẩn
      final apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.isSuccess && apiResponse.result != null) {
        final data = apiResponse.result!; // data là Map (LoginResponse)
        final String token = data['token'];

        // 1. Lưu Token
        await _storage.write(key: 'accessToken', value: token);
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        }

        // 2. Decode Token để lấy StoreID
        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          
          // Kiểm tra các key có thể có: storeId, store_id, storeID...
          String? storeId;
          if (decodedToken.containsKey('storeId')) storeId = decodedToken['storeId'].toString();
          else if (decodedToken.containsKey('store_id')) storeId = decodedToken['store_id'].toString();
          
          if (storeId != null) {
            await _storage.write(key: 'storeId', value: storeId);
            print("AUTH: Đã lưu StoreID từ Token: $storeId");
          } else {
            print("AUTH: Token không chứa storeId. UserContext trên BE có thể bị thiếu.");
            // Fallback tạm thời nếu backend lỗi config
            await _storage.write(key: 'storeId', value: "1"); 
          }
        } catch (e) {
          print("AUTH error decoding token: $e");
        }
        
        // Trả về map gốc để compatible với code cũ
        return (data is Map<String, dynamic>) ? data : {};
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi từ BE trả về (400, 401...)
      if (e.response != null && e.response!.data != null) {
        final errorRes = ApiResponse.fromJson(e.response!.data);
        throw Exception(errorRes.message.isNotEmpty ? errorRes.message : 'Đăng nhập thất bại');
      }
      throw Exception('Lỗi kết nối máy chủ');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }

  // ================== REGISTER ==================
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.registerEndpoint, data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'username': (username != null && username.isNotEmpty) ? username : phone,
      });
      
      final apiResponse = ApiResponse.fromJson(response.data);
      if (!apiResponse.isSuccess) {
        if (apiResponse.errors != null && apiResponse.errors!.isNotEmpty) {
           throw Exception(apiResponse.errors!.join('\n'));
        }
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
       _handleDioError(e);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // ================== CUSTOMER API ==================
  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final response = await _dio.get(ApiConstants.customersEndpoint);
      final apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.isSuccess) {
        // Handle Pagination logic (content/items)
        var listData = apiResponse.result;
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
      throw Exception('Lỗi tải khách hàng: $e');
    }
  }

  Future<void> createCustomer(Map<String, dynamic> customer) async {
    try {
      await _dio.post(ApiConstants.customersEndpoint, data: customer);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== PRODUCT API ==================

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      // Thêm size=100 để lấy nhiều products như web admin
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
           return List<Map<String, dynamic>>.from(listData);
        }
        return [];
      }
      throw Exception(apiResponse.message);
    } catch (e) {
      throw Exception('Lỗi tải sản phẩm: $e');
    }
  }

  // FIX: Trả về ID sản phẩm vừa tạo để UI có thể gọi tiếp API nhập kho
  Future<int> createProduct(Map<String, dynamic> product) async {
    try {
      final requestBody = {
        'name': product['name'],
        'sku': product['sku'],
        'price': product['price'] ?? product['sellingPrice'] ?? 0, 
        'costPrice': product['costPrice'] ?? product['cost'] ?? product['importPrice'] ?? 0,
        'categoryId': product['categoryId'],
        'unitId': product['unitId'],
        'description': product['description'],
        'imageUrl': product['imageUrl'],
        'reorderLevel': product['reorderLevel'],
      };

      final response = await _dio.post(ApiConstants.productsEndpoint, data: requestBody);
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.result != null) {
        if (apiResponse.result is Map) {
          return apiResponse.result['id'] ?? 0;
        }
      }
      return 0;
    } on DioException catch (e) {
      _handleDioError(e);
      return 0; // Should throw inside handleDioError
    }
  }

  Future<void> updateProduct(dynamic id, Map<String, dynamic> product) async {
    try {
      // FIX LOGIC: Remap keys here too
      final requestBody = {
        'name': product['name'],
        'sku': product['sku'],
        'price': product['price'] ?? product['sellingPrice'],
        'costPrice': product['costPrice'] ?? product['cost'],
        'categoryId': product['categoryId'],
        'unitId': product['unitId'],
        'description': product['description'],
        'imageUrl': product['imageUrl'],
        'reorderLevel': product['reorderLevel'],
      };

      await _dio.put('${ApiConstants.productsEndpoint}/$id', data: requestBody);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== HELPER ==================
  
  void _handleDioError(DioException e) {
    if (e.response?.data != null) {
      // Try parsing ApiResponse
      try {
        final apiRes = ApiResponse.fromJson(e.response!.data);
        if (apiRes.errors != null && apiRes.errors!.isNotEmpty) {
           throw Exception(apiRes.errors!.join('\n'));
        }
        throw Exception(apiRes.message.isNotEmpty ? apiRes.message : 'Yêu cầu thất bại');
      } catch (_) {
         // Nếu không parse được thì lấy nguyên văn
         throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
      }
    }
    throw Exception('Lỗi kết nối: ${e.message}');
  }

  Future<int> getCurrentStoreId() async {
    String? id = await _storage.read(key: 'storeId');
    return id != null ? int.parse(id) : 1;
  }
  
  // Keep other methods like delete logic...
  Future<void> deleteProduct(dynamic id) async {
      await _dio.delete('${ApiConstants.productsEndpoint}/$id');
  }
   Future<void> deleteCustomer(dynamic id) async {
      await _dio.delete('${ApiConstants.customersEndpoint}/$id');
  }

  Future<void> updateCustomer(dynamic id, Map<String, dynamic> customer) async {
    try {
      await _dio.put('${ApiConstants.customersEndpoint}/$id', data: customer);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== FORGOT PASSWORD ==================
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiConstants.forgotPasswordEndpoint, data: {'email': email});
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== CHANGE PASSWORD ==================
  // ================== CHANGE PASSWORD ==================
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _dio.put('/v1/users/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== UPDATE PROFILE ==================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/v1/users/profile', data: data);
      final apiResponse = ApiResponse.fromJson(response.data);
      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== CUSTOMER GROUP API ==================
  Future<List<Map<String, dynamic>>> getCustomerGroups() async {
    try {
      final response = await _dio.get(ApiConstants.customerGroupsEndpoint);
      // Try/Catch silent or proper error
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data);
        if (apiResponse.isSuccess) {
           var listData = apiResponse.result;
           if (listData is Map) listData = listData['content'] ?? listData['items'] ?? [];
           if (listData is List) return List<Map<String, dynamic>>.from(listData);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> createCustomerGroup(String name, List<dynamic> customerIds) async {
    try {
      await _dio.post(ApiConstants.customerGroupsEndpoint, data: {
        'name': name,
        'customerIds': customerIds,
      });
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<void> updateCustomerGroup(int groupId, String name, List<dynamic> customerIds) async {
    try {
      await _dio.put('${ApiConstants.customerGroupsEndpoint}/$groupId', data: {
        'name': name,
        'customerIds': customerIds,
      });
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<void> deleteCustomerGroup(int groupId) async {
    try {
      await _dio.delete('${ApiConstants.customerGroupsEndpoint}/$groupId');
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== BATCH API ==================
  Future<void> createProductsBatch(List<Map<String, dynamic>> products) async {
    try {
      await _dio.post(ApiConstants.productsBatchEndpoint, data: products);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ================== UPLOAD FILE ==================
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

  // ================== GET CURRENT USER ==================
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _dio.get('/v1/auth/me');
      final apiResponse = ApiResponse.fromJson(response.data);
      
      if (apiResponse.isSuccess && apiResponse.result != null) {
        return Map<String, dynamic>.from(apiResponse.result);
      }
      return null;
    } on DioException catch (e) {
      print("Lỗi lấy thông tin user: ${e.message}");
      // Trả về mock data nếu offline hoặc lỗi để không crash app
      return null;
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }
}
