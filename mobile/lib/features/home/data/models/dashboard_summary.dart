class DashboardSummary {

  final double totalRevenue;
  final int lowStockCount;
  final double pendingPayment;
  final int totalProducts;
  final int totalStock;

  DashboardSummary({
    required this.totalRevenue,
    required this.lowStockCount,
    required this.pendingPayment,
    required this.totalProducts,
    required this.totalStock,
  });

  factory DashboardSummary.zero() {
    return DashboardSummary(
      totalRevenue: 0.0,
      lowStockCount: 0,
      pendingPayment: 0.0,
      totalProducts: 0,
      totalStock: 0,
    );
  }


  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalRevenue: double.tryParse((json['totalRevenue'] ?? 0).toString()) ?? 0.0,
      lowStockCount: int.tryParse((json['lowStockCount'] ?? json['warningProducts'] ?? 0).toString()) ?? 0,
      pendingPayment: double.tryParse((json['pendingPayment'] ?? json['totalDebt'] ?? 0).toString()) ?? 0.0,
      totalProducts: int.tryParse((json['totalProducts'] ?? 0).toString()) ?? 0,
      totalStock: int.tryParse((json['totalStock'] ?? 0).toString()) ?? 0,
    );
  }

}

