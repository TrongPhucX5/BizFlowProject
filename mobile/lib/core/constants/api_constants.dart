import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // BẮT BUỘC PHẢI LÀ 10.0.2.2 KHI CHẠY MÁY ẢO
      return "http://10.0.2.2:8080/api";
    } else {
      // Windows hoặc iOS thì dùng localhost
      return "http://localhost:8080/api";
    }
  }

  // Nhớ kiểm tra kỹ cái đuôi này, backend của bạn có /v1
  static const String loginEndpoint = "/v1/auth/login";
  static const String registerEndpoint = "/v1/auth/register";
  static const String forgotPasswordEndpoint = "/v1/auth/forgot-password";

  // Customer
  static const String customersEndpoint = "/v1/customers";
  static const String customerGroupsEndpoint = "/v1/customer-groups";

  // Product
  static const String productsEndpoint = "/v1/products";
  static const String productsBatchEndpoint = "/v1/products/batch";
  static const String categoriesEndpoint = "/v1/categories";

  // Inventory
  static const String inventoryAdjustEndpoint = "/v1/inventory/adjust";
  static const String inventoryStockInEndpoint = "/v1/inventory/stock-in";
  static const String inventoryLowStockEndpoint = "/v1/inventory/low-stock";

  // Order
  static const String ordersEndpoint = "/v1/orders";

  // AI
  static const String aiChatEndpoint = "/v1/ai/chat";

  // Debt
  static const String debtsEndpoint = "/v1/debts";

  // Payment
  static const String paymentsEndpoint = "/v1/payments";

  // Report
  static const String reportDashboardStatsEndpoint = "/v1/reports/dashboard-stats";
  static const String reportRevenueEndpoint = "/v1/reports/revenue";
  static const String reportBestSellingEndpoint = "/v1/reports/best-selling";

  // Upload
  static const String uploadImageEndpoint = "/v1/upload/image";
}