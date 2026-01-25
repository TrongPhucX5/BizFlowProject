class ProductDTO {
  final int id;
  final String name;
  final String sku;
  final int stock;
  final String? unitName;
  final String? imageUrl;
  final double price;

  ProductDTO({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
    this.unitName,
    this.imageUrl,
    required this.price,
  });

  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    return ProductDTO(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      unitName: json['unitName'],
      imageUrl: json['imageUrl'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}
