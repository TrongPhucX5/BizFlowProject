import 'package:flutter/material.dart';

class CategorySelectProductsScreen extends StatefulWidget {
  final String categoryName;
  // Nhận danh sách sản phẩm có sẵn
  final List<Map<String, dynamic>> availableProducts;

  const CategorySelectProductsScreen({
    super.key,
    required this.categoryName,
    required this.availableProducts,
  });

  @override
  State<CategorySelectProductsScreen> createState() => _CategorySelectProductsScreenState();
}

class _CategorySelectProductsScreenState extends State<CategorySelectProductsScreen> {
  // Lưu trạng thái chọn (Set để tránh trùng lặp)
  final Set<Map<String, dynamic>> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xff289ca7);

    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm vào: ${widget.categoryName}"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        actions: [
          TextButton(
            onPressed: () {
              // Trả về danh sách đã chọn
              Navigator.pop(context, _selectedItems.toList());
            },
            child: const Text("Xong", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: widget.availableProducts.isEmpty
          ? const Center(child: Text("Chưa có sản phẩm nào để chọn"))
          : ListView.separated(
        itemCount: widget.availableProducts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = widget.availableProducts[index];
          final isSelected = _selectedItems.contains(product);

          return CheckboxListTile(
            activeColor: kPrimaryGreen,
            title: Text(product['name'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text("${product['price']} đ"),
            secondary: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.image, color: Colors.grey, size: 20),
            ),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedItems.add(product);
                } else {
                  _selectedItems.remove(product);
                }
              });
            },
          );
        },
      ),
    );
  }
}