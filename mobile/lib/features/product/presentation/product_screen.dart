import 'package:flutter/material.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart';
import 'package:mobile/features/product/presentation/hourly_service_screen.dart';
import 'package:mobile/features/product/presentation/batch_product_create_screen.dart';
import 'package:mobile/features/product/presentation/combo_create_screen.dart';
import 'category_select_products_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'dart:convert';
import 'package:mobile/data/repositories/inventory_repository.dart';
import 'package:mobile/features/product/presentation/stock_in_screen.dart';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthRepository _authRepository = AuthRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  bool _isLoading = false;

  bool _isGridView = true;
  String _selectedSort = 'Mới nhất';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _combos = [];
  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> list = _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final sku = (p['sku'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || sku.contains(query);
    }).toList();

    if (_selectedSort == 'Giá tăng') {
      list.sort((a, b) => (double.tryParse(a['price'].toString()) ?? 0).compareTo(double.tryParse(b['price'].toString()) ?? 0));
    } else if (_selectedSort == 'Giá giảm') {
      list.sort((a, b) => (double.tryParse(b['price'].toString()) ?? 0).compareTo(double.tryParse(a['price'].toString()) ?? 0));
    }
    return list;
  }

  List<Map<String, dynamic>> get _inventoryProducts =>
      _products.where((p) {
        final int stock = int.tryParse((p['stock'] ?? 0).toString()) ?? 0;
        final int reorderLevel = int.tryParse((p['reorderLevel'] ?? 10).toString()) ?? 10;
        final bool isLow = stock <= reorderLevel;
        final name = (p['name'] ?? '').toString().toLowerCase();
        final sku = (p['sku'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return isLow && (name.contains(query) || sku.contains(query));
      }).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _authRepository.getProducts();
      setState(() => _products = data);
    } catch (e) {
      print("Lỗi tải sản phẩm: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showProductCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _buildOptionItem(Icons.shopping_bag_outlined, "Sản phẩm thường", "Theo dõi tồn kho cơ bản", () async {
              Navigator.pop(context);
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductCreateScreen()));
              if (result == true) _fetchProducts();
            }),
            _buildOptionItem(Icons.access_time_rounded, "Dịch vụ theo giờ", "Tính tiền theo thời gian sử dụng", () async {
              Navigator.pop(context);
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const HourlyProductCreateScreen()));
              if (result == true) _fetchProducts();
            }),
            _buildOptionItem(Icons.copy_rounded, "Tạo hàng loạt", "Import nhiều sản phẩm cùng lúc", () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const BatchProductCreateScreen()));
              _fetchProducts();
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF475569)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Sản phẩm & Kho'),
        actions: [
          IconButton(
            onPressed: _fetchProducts,
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Tải lại',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104.0),
          child: Column(
            children: [
              _buildTopSearchRow(),
              TabBar(
                controller: _tabController,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Sản phẩm"),
                  Tab(text: "Tồn kho"),
                  Tab(text: "Bán kèm"),
                  Tab(text: "Danh mục"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildInventoryTab(),
          _buildComboTab(),
          _buildCategoryTab(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildTopSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Tìm kiếm...",
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return _buildEmptyState(Icons.inventory_2_outlined, "Chưa có sản phẩm nào", "Thêm sản phẩm để bắt đầu kinh doanh", _showProductCreateOptions);
    
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: _isGridView 
        ? _buildProductGrid(_filteredProducts)
        : _buildProductList(_filteredProducts),
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildProductCard(item);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCreateScreen(existingProduct: item)));
        if (result == true) _fetchProducts();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: _buildProductImage(item['imageUrl'], isGrid: true),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, 
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text("${NumberFormat('#,###').format(item['price'])} đ", 
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCreateScreen(existingProduct: item)));
            if (result == true) _fetchProducts();
          },
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildProductImage(item['imageUrl']),
            ),
          ),
          title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text("${NumberFormat('#,###').format(item['price'])} đ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    if (_inventoryProducts.isEmpty) return _buildEmptyState(Icons.warehouse_outlined, "Kho đã đầy đủ", "Mọi sản phẩm đều đủ tồn kho an toàn", () {});
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _inventoryProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _inventoryProducts[index];
        final stock = item['stock'] ?? 0;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(item['imageUrl']),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text("SKU: ${item['sku'] ?? '---'}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$stock", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFEF4444))),
                  const Text("Sắp hết", style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
                ],
              ),
              IconButton(onPressed: () => _showAdjustmentDialog(item), icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComboTab() {
    return _isLoading ? const Center(child: CircularProgressIndicator()) : _buildEmptyState(Icons.layers_outlined, "Chia nhóm bán lẻ", "Tạo các gói combo để tăng doanh số", () {});
  }

  Widget _buildCategoryTab() {
    return _isLoading ? const Center(child: CircularProgressIndicator()) : _buildEmptyState(Icons.category_outlined, "Phân loại hàng hóa", "Giúp khách hàng tìm kiếm dễ dàng hơn", () {});
  }

  Widget _buildEmptyState(IconData icon, String title, String sub, VoidCallback onTap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ),
          const SizedBox(height: 24),
          if (onTap != null)
            ElevatedButton(onPressed: onTap, child: const Text("Tiếp tục")),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _showProductCreateOptions,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  Widget _buildProductImage(String? imageUrl, {bool isGrid = false}) {
    double? size = isGrid ? null : 32;
    if (imageUrl == null || imageUrl.isEmpty) return Center(child: Icon(Icons.image_outlined, size: isGrid ? 48 : 24, color: const Color(0xFFCBD5E1)));
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(imageUrl, width: size, height: size, fit: BoxFit.cover, 
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, size: size, color: const Color(0xFFCBD5E1)));
      }
      return Image.memory(const Base64Decoder().convert(imageUrl.split(',').last), width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, size: size, color: const Color(0xFFCBD5E1)));
    } catch (_) {
      return Center(child: Icon(Icons.broken_image_outlined, size: isGrid ? 48 : 24, color: const Color(0xFFCBD5E1)));
    }
  }

  void _showAdjustmentDialog(Map<String, dynamic> product) {
    final qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Điều chỉnh: ${product['name']}"),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Số lượng điều chỉnh (+/-)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text);
              if (qty != null) {
                await _inventoryRepository.adjustInventory(productId: product['id'], quantity: qty, reason: "Điều chỉnh nhanh");
                Navigator.pop(ctx);
                _fetchProducts();
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }
}
