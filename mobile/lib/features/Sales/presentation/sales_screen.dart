import 'package:flutter/material.dart';
import 'package:mobile/features/home/presentation/management_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- KHAI BÁO MÀU SẮC ---
    const Color kContentColor = Colors.black87;
    // Sửa thành màu xanh biển (dùng Colors.blue hoặc mã màu cụ thể)
    const Color kPrimaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      // === 1. APPBAR ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bán hàng',
          style: TextStyle(color: kContentColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildAppBarActionButton(Icons.flash_on, "Bán nhanh", kContentColor),
          _buildAppBarActionButton(Icons.receipt_long, "Đơn hàng", kContentColor),
          IconButton(
            icon: const Icon(Icons.more_vert, color: kContentColor),
            onPressed: () {},
          ),
        ],
      ),
      // === 2. BODY ===
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Thanh tìm kiếm & Quét mã ---
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200))
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Tìm theo tên, barcode, SKU",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    debugPrint("Mở quét mã");
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: kContentColor),
                  ),
                ),
              ],
            ),
          ),

          // --- Nút Thêm sản phẩm (Màu Xanh Biển) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAddProductCard(kPrimaryColor),
          ),

          Expanded(child: Container()),
        ],
      ),
    );
  }

  // Widget nút nhỏ trên AppBar
  Widget _buildAppBarActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Thẻ "Thêm sản phẩm" (Được truyền màu vào)
  Widget _buildAddProductCard(Color primaryColor) {
    return InkWell(
      onTap: () {
        debugPrint("Bấm thêm sản phẩm");
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Bóng đổ màu xanh biển nhạt
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          // Viền màu xanh biển
          border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon dấu cộng
            Icon(Icons.add, size: 40, color: primaryColor),
            const SizedBox(height: 8),
            // Chữ bên dưới
            Text(
              "Thêm sản phẩm",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}