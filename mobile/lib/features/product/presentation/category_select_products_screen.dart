import 'package:flutter/material.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart'; // Import màn hình tạo sản phẩm nếu cần

class CategorySelectProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategorySelectProductsScreen({super.key, required this.categoryName});

  @override
  State<CategorySelectProductsScreen> createState() => _CategorySelectProductsScreenState();
}

class _CategorySelectProductsScreenState extends State<CategorySelectProductsScreen> {
  // SỬA LẠI: List rỗng vì kho chưa có gì
  // Sau này ông sẽ truyền list sản phẩm thật từ API/Database vào đây
  final List<Map<String, dynamic>> _availableProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thêm sản phẩm", style: TextStyle(fontSize: 16, color: Colors.black)),
            Text("Vào danh mục: ${widget.categoryName}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Chỉ hiện nút LƯU nếu có dữ liệu, còn không thì thôi hoặc disable
          if (_availableProducts.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("LƯU", style: TextStyle(color: Color(0xff289ca7), fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: _availableProducts.isEmpty
          ? _buildEmptyState() // Nếu list rỗng thì hiện cái này
          : _buildProductList(), // Nếu có hàng thì hiện list
    );
  }

  // --- WIDGET 1: KHI KHÔNG CÓ SẢN PHẨM ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chưa có sản phẩm nào để thêm!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vui lòng tạo sản phẩm trước.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Nút gợi ý đi tạo sản phẩm (Optional - thêm cho UX mượt)
          SizedBox(
            width: 200, height: 45,
            child: OutlinedButton(
              onPressed: () {
                // Điều hướng về màn tạo sản phẩm (nếu muốn)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductCreateScreen()));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff289ca7)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tạo sản phẩm ngay", style: TextStyle(color: Color(0xff289ca7), fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET 2: LIST SẢN PHẨM (Logic cũ) ---
  Widget _buildProductList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Tìm sản phẩm...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _availableProducts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = _availableProducts[index];
              return CheckboxListTile(
                value: product['isSelected'],
                activeColor: const Color(0xff289ca7),
                title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text("${product['price']} đ", style: const TextStyle(color: Colors.grey)),
                onChanged: (bool? value) {
                  setState(() {
                    product['isSelected'] = value;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}