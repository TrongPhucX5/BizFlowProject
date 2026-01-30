class Product {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stock;
  final String? unitName;
  final int? unitId;
  final String? imageUrl;
  final String? description;
  final int categoryId;
  final String status;
  final bool trackStock;
  final List<dynamic>? attributes;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.stock,
    this.unitName,
    this.unitId,
    this.imageUrl,
    this.description,
    this.categoryId = 0,
    this.status = 'ACTIVE',
    this.trackStock = false,
    this.attributes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: double.tryParse((json['price'] ?? 0).toString()) ?? 0.0,
      costPrice: double.tryParse((json['costPrice'] ?? json['cost'] ?? 0).toString()) ?? 0.0,
      stock: int.tryParse((json['stock'] ?? 0).toString()) ?? 0,
      unitName: json['unitName'],
      unitId: json['unitId'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      categoryId: json['categoryId'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      trackStock: json['trackStock'] ?? false,
      attributes: json['attributes'] is List ? json['attributes'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'unitName': unitName,
      'unitId': unitId,
      'imageUrl': imageUrl,
      'description': description,
      'categoryId': categoryId,
      'status': status,
      'trackStock': trackStock,
      'attributes': attributes,
    };
  }
}
