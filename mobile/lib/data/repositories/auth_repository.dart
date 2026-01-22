import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = DioClient.instance;

  // ================== LOGIN ==================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEndpoint, data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend trả về dạng { result: { token: "...", ... } }
        final data = response.data['result'] ?? response.data;
        
        // Lưu Token
        if (data['token'] != null) await _storage.write(key: 'accessToken', value: data['token']);
        // Lưu StoreID (Giả sử backend trả về user: { storeId: 123 })
        if (data['user'] != null && data['user']['storeId'] != null) {
          await _storage.write(key: 'storeId', value: data['user']['storeId'].toString());
        }
        
        return data;
      }
      throw Exception('Đăng nhập thất bại');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    try {
      await _storage.deleteAll();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
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
    String? username, // Thêm tham số tùy chọn
  }) async {
    try {
      await _dio.post(ApiConstants.registerEndpoint, data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'username': (username != null && username.isNotEmpty) ? username : phone, // Ưu tiên username tùy chỉnh, nếu không có thì dùng phone
      });
    } on DioException catch (e) {
      print("Register Error Response: ${e.response?.data}"); // Log để debug xem lỗi chi tiết là gì

      // Lấy thông báo lỗi chính
      String errorMessage = e.response?.data['message'] ?? 'Đăng ký thất bại';
      
      // Nếu Backend trả về danh sách lỗi chi tiết (Validation errors) trong 'result'
      if (e.response?.data != null && e.response?.data['result'] is List) {
        final List errors = e.response?.data['result'];
        if (errors.isNotEmpty) {
          errorMessage += "\n• ${errors.join('\n• ')}"; // Nối thêm chi tiết lỗi
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // ================== FORGOT PASSWORD ==================
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiConstants.forgotPasswordEndpoint, data: {'email': email});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gửi yêu cầu thất bại');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // ================== CUSTOMER API ==================
  
  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final response = await _dio.get('/customers');
      if (response.statusCode == 200) {
        final data = response.data;
        // Support 'result' wrapper, 'content' (Spring), 'items' (SRS)
        var listData = data;
        if (data is Map && data.containsKey('result')) {
          listData = data['result'];
        }
        
        final list = (listData is Map) 
            ? (listData['content'] ?? listData['items'] ?? []) 
            : (listData is List ? listData : []);
            
        return List<Map<String, dynamic>>.from(list);
      }
      throw Exception('Không thể tải danh sách khách hàng');
    } catch (e) {
      throw Exception('Lỗi tải khách hàng: $e');
    }
  }

  Future<void> createCustomer(Map<String, dynamic> customer) async {
    try {
      await _dio.post('/customers', data: customer);
    } catch (e) {
      throw Exception('Thêm khách hàng thất bại: $e');
    }
  }

  Future<void> updateCustomer(dynamic id, Map<String, dynamic> customer) async {
    try {
      await _dio.put('/customers/$id', data: customer);
    } catch (e) {
      throw Exception('Cập nhật khách hàng thất bại: $e');
    }
  }

  Future<void> deleteCustomer(dynamic id) async {
    try {
      await _dio.delete('/customers/$id');
    } catch (e) {
      throw Exception('Xóa khách hàng thất bại: $e');
    }
  }

  // ================== CUSTOMER GROUP API ==================
  Future<void> createCustomerGroup(String name, List<dynamic> customerIds) async {
    try {
      await _dio.post('/customer-groups', data: {
        'name': name,
        'customerIds': customerIds,
      });
    } catch (e) {
      throw Exception('Tạo nhóm thất bại: $e');
    }
  }

  // ================== PRODUCT API ==================

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final data = response.data;
        
        var listData = data;
        if (data is Map && data.containsKey('result')) {
          listData = data['result'];
        }

        final list = (listData is Map)
            ? (listData['content'] ?? listData['items'] ?? [])
            : (listData is List ? listData : []);
            
        return List<Map<String, dynamic>>.from(list);
      }
      throw Exception('Không thể tải danh sách sản phẩm');
    } catch (e) {
      throw Exception('Lỗi tải sản phẩm: $e');
    }
  }

  Future<void> createProduct(Map<String, dynamic> product) async {
    try {
      // Đảm bảo mapping đúng key unitId
      await _dio.post('/products', data: product);
    } catch (e) {
      throw Exception('Thêm sản phẩm thất bại: $e');
    }
  }

  Future<void> updateProduct(dynamic id, Map<String, dynamic> product) async {
    try {
      await _dio.put('/products/$id', data: product);
    } catch (e) {
      throw Exception('Cập nhật sản phẩm thất bại: $e');
    }
  }

  Future<void> deleteProduct(dynamic id) async {
    try {
      await _dio.delete('/products/$id');
    } catch (e) {
      throw Exception('Xóa sản phẩm thất bại: $e');
    }
  }

  // ================== BATCH API ==================
  Future<void> createProductsBatch(List<Map<String, dynamic>> products) async {
    try {
      await _dio.post('/products/batch', data: products);
    } catch (e) {
      throw Exception('Tạo sản phẩm hàng loạt thất bại: $e');
    }
  }

  // Helper lấy StoreID hiện tại
  Future<int> getCurrentStoreId() async {
    String? id = await _storage.read(key: 'storeId');
    return id != null ? int.parse(id) : 1; // Fallback 1 nếu không tìm thấy (hoặc throw error)
  }
}
