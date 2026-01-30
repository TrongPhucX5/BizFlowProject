import 'package:flutter/material.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart';
import 'package:mobile/features/product/presentation/stock_in_screen.dart';
import 'package:mobile/features/product/data/repositories/product_repository.dart';
import 'package:mobile/data/repositories/inventory_repository.dart';
import 'package:intl/intl.dart';
import '../data/models/product_model.dart';
import 'dart:convert';


class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final ProductRepository _productRepository = ProductRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  bool _isLoading = false;

  bool _isGridView = true;
  String _selectedSort = 'Mới nhất';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showOnlyLowStock = false;


  List<Product> _products = [];

  List<Product> get _filteredProducts {
    List<Product> list = _products.where((p) {
      final name = p.name.toLowerCase();
      final sku = p.sku.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || sku.contains(query);
    }).toList();

    if (_selectedSort == 'Giá tăng') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Giá giảm') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  List<Product> get _inventoryProducts {
    var list = _products.where((p) {
      final name = p.name.toLowerCase();
      final sku = p.sku.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || sku.contains(query);
    }).toList();

    if (_showOnlyLowStock) {
      list = list.where((p) => p.stock <= 10).toList();
    }
    return list;
  }



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Reset filter if we switch away from inventory tab
        if (_tabController.index != 1 && _showOnlyLowStock) {
          setState(() => _showOnlyLowStock = false);
        }
        setState(() {});
      }
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _productRepository.getProducts();
      setState(() => _products = data);
    } catch (e) {
      print("Lỗi tải sản phẩm: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void switchToInventoryTab() {
    if (mounted) {
      if (_showOnlyLowStock) setState(() => _showOnlyLowStock = false);
      _tabController.animateTo(1);
    }
  }

  void switchToLowStock() {
    if (mounted) {
      setState(() => _showOnlyLowStock = true);
      _tabController.animateTo(1);
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _addNewProduct() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ProductCreateScreen())
    );
    if (result == true) _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sản phẩm & Kho'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
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
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Sản phẩm"),
                  Tab(text: "Tồn kho"),
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
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildTopSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Expanded(child: TextField(controller: _searchController, decoration: const InputDecoration(hintText: "Tìm kiếm...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
        const SizedBox(width: 8),
        IconButton(onPressed: () => setState(() => _isGridView = !_isGridView), icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view)),
      ]),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return _buildEmptyState(Icons.inventory_2_outlined, "Chưa có sản phẩm nào", "Thêm sản phẩm để bắt đầu kinh doanh", _addNewProduct);
    
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: _isGridView 
        ? _buildProductGrid(_filteredProducts)
        : _buildProductList(_filteredProducts),
    );
  }

  Widget _buildProductGrid(List<Product> items) {
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

  Widget _buildProductCard(Product item) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCreateScreen(existingProduct: item.toJson())));
        if (result == true) _fetchProducts();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: _buildProductImage(item.imageUrl, isGrid: true))),
          Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
             Text("${NumberFormat('#,###').format(item.price)} đ", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ]))
        ]),
      ),
    );
  }

  Widget _buildProductList(List<Product> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCreateScreen(existingProduct: item.toJson())));
            if (result == true) _fetchProducts();
          },
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          leading: SizedBox(width: 50, height: 50, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildProductImage(item.imageUrl))),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${NumberFormat('#,###').format(item.price)} đ", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    if (_inventoryProducts.isEmpty) {
       return Column(
         children: [
           if (_showOnlyLowStock) _buildLowStockFilterHeader(),
           Expanded(child: _buildEmptyState(Icons.warehouse_outlined, _showOnlyLowStock ? "Không có hàng sắp hết" : "Chưa có dữ liệu kho", _showOnlyLowStock ? "Mọi thứ đều đang ổn định" : "Thêm sản phẩm để theo dõi tồn kho", _showOnlyLowStock ? () => setState(() => _showOnlyLowStock = false) : _addNewProduct)),
         ],
       );
    }

    return Column(
      children: [
        if (_showOnlyLowStock) _buildLowStockFilterHeader(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _inventoryProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _inventoryProducts[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                leading: SizedBox(width: 50, height: 50, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildProductImage(item.imageUrl))),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("SKU: ${item.sku}"),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("${item.stock}", style: TextStyle(color: item.stock <= 10 ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  if (item.stock <= 10)
                    const Text("Sắp hết", style: TextStyle(color: Colors.red, fontSize: 10)),
                ]),
                onTap: () async {
                  // Navigate to StockInScreen with this product selected
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => StockInScreen(initialProductId: item.id))
                  );
                  if (result == true) _fetchProducts();
                },
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.filter_list_alt, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text("Đang lọc: Hàng sắp hết (Tồn ≤ 10)", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          TextButton(
            onPressed: () => setState(() => _showOnlyLowStock = false),
            child: const Text("Xóa lọc", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(IconData icon, String title, String sub, VoidCallback? onTap) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      if (sub.isNotEmpty) Text(sub, style: const TextStyle(color: Colors.grey)),
      if (onTap != null) ...[
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onTap, child: const Text("Tiếp tục"))
      ]
    ]));
  }

  Widget _buildFab() => FloatingActionButton(onPressed: _addNewProduct, child: const Icon(Icons.add));

  Widget _buildProductImage(String? imageUrl, {bool isGrid = false}) {
    if (imageUrl == null || imageUrl.isEmpty) return Container(color: Colors.grey.shade100, child: const Icon(Icons.image, color: Colors.grey));
    if (imageUrl.startsWith('http')) return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image));
    try {
      return Image.memory(base64Decode(imageUrl.split(',').last), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image));
    } catch (_) {
      return const Icon(Icons.broken_image);
    }
  }

  void _showAdjustmentDialog(Product product) {
    final qtyController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Điều chỉnh: ${product.name}"),
      content: TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Số lượng (+/-)")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
        ElevatedButton(onPressed: () async {
          final qty = int.tryParse(qtyController.text);
          if (qty != null) {
            await _inventoryRepository.adjustStock(productId: product.id, newQuantity: product.stock + qty, reason: "Điều chỉnh nhanh");
            Navigator.pop(ctx);
            _fetchProducts();
          }
        }, child: const Text("Cập nhật"))
      ],
    ));
  }
}
