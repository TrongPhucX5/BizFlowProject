import 'package:flutter/material.dart';
import 'package:mobile/features/Sales/presentation/quick_sale_screen.dart';
import 'package:mobile/features/order/presentation/order_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuickSale() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuickSaleScreen()),
    );
  }

  void _openSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortItem("Mới nhất"),
            _buildSortItem("Bán chạy"),
            _buildSortItem("Giá thấp → cao"),
            _buildSortItem("Giá cao → thấp"),
            ListTile(
              leading: Icon(_isGridView ? Icons.list : Icons.grid_view),
              title: Text(_isGridView ? "Xem dạng danh sách" : "Xem dạng lưới"),
              onTap: () {
                setState(() => _isGridView = !_isGridView);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bán hàng", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildAction("Bán nhanh", Icons.flash_on, _openQuickSale),
          _buildAction(
            "Đơn hàng",
            Icons.receipt_long,
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _openSortMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAddProductCard(kPrimaryColor),
          ),
          Expanded(
            child: Center(
              child: Text(
                _isGridView ? "Chế độ xem lưới" : "Chế độ xem danh sách",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Tìm theo tên, barcode, SKU",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mở quét QR (demo)")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductCard(Color primaryColor) {
    return InkWell(
      onTap: _openQuickSale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: primaryColor),
            const SizedBox(height: 8),
            Text("Thêm sản phẩm", style: TextStyle(color: primaryColor)),
          ],
        ),
      ),
    );
  }
}
