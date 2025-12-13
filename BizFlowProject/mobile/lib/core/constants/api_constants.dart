class ApiConstants {
  // Thay đổi IP này tùy theo môi trường chạy
  // static const String baseUrl = "http://192.168.1.x:8080/api/v1"; // Máy thật (Thay x bằng IP máy tính)
  static const String baseUrl = "http://10.0.2.2:8080/api/v1"; // Máy ảo Android

  static const String loginEndpoint = "/auth/login";
  static const String productsEndpoint = "/products";
}