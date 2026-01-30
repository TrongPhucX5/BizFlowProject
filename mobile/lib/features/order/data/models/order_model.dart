class Order {
  final int id;
  final String orderNumber;
  final int customerId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      customerId: json['customerId'] ?? 0,
      totalAmount: double.tryParse((json['totalAmount'] ?? 0).toString()) ?? 0.0,
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ?? [],
    );
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse((json['unitPrice'] ?? 0).toString()) ?? 0.0,
    );
  }
}
