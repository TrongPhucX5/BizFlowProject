class DashboardSummary {
  final double totalRevenue;
  final int lowStockCount;
  final double pendingPayment;
  final int totalProducts;

  DashboardSummary({
    required this.totalRevenue,
    required this.lowStockCount,
    required this.pendingPayment,
    required this.totalProducts,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalRevenue: double.tryParse(json['totalRevenue'].toString()) ?? 0.0,
      lowStockCount: int.tryParse(json['lowStockCount'].toString()) ?? 0,
      pendingPayment: double.tryParse(json['pendingPayment'].toString()) ?? 0.0,
      totalProducts: int.tryParse(json['totalProducts'].toString()) ?? 0,
    );
  }
}
