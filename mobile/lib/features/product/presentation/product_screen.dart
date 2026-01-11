import 'package:flutter/material.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart';
import 'package:mobile/features/product/presentation/hourly_service_screen.dart';
import 'package:mobile/features/product/presentation/batch_product_create_screen.dart';
import 'package:mobile/features/product/presentation/combo_create_screen.dart';
import 'category_select_products_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Trạng thái giao diện
  bool _isGridView = false;
  String _selectedSort = 'Mới nhất';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // DỮ LIỆU CHÍNH (State)
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _combos = [];
  List<Map<String, dynamic>> _categories = [];

  // --- GETTERS (Lọc dữ liệu theo Search & Sort) ---

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> list = _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final sku = (p['sku'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || sku.contains(query);
    }).toList();

    // Logic sắp xếp
    if (_selectedSort == 'Giá tăng') {
      list.sort((a, b) => (double.tryParse(a['price'].toString()) ?? 0).compareTo(double.tryParse(b['price'].toString()) ?? 0));
    } else if (_selectedSort == 'Giá giảm') {
      list.sort((a, b) => (double.tryParse(b['price'].toString()) ?? 0).compareTo(double.tryParse(a['price'].toString()) ?? 0));
    }
    // Mặc định là 'Mới nhất' (theo thứ tự insert đầu danh sách)
    return list;
  }

  List<Map<String, dynamic>> get _inventoryProducts =>
      _filteredProducts.where((p) => p['trackStock'] == true).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });

    // Lắng nghe tìm kiếm
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- XỬ LÝ KẾT QUẢ TRẢ VỀ ---
  void _handleProductResult(dynamic result, {int? index}) {
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index != null) {
          _products[index] = result;
        } else {
          _products.insert(0, result);
        }
      });
    }
  }

  void _handleComboResult(dynamic result) {
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _combos.add(result));
    }
  }

  void _handleCategoryResult(dynamic result) {
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _categories.add(result));
    }
  }

  // --- NAVIGATION & ACTIONS ---

  void _showProductCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xff289ca7)),
            title: const Text("Tạo sản phẩm thường"),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductCreateScreen()));
              _handleProductResult(result);
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time, color: Color(0xff289ca7)),
            title: const Text("Tạo dịch vụ theo giờ"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HourlyProductCreateScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: Color(0xff289ca7)),
            title: const Text("Tạo sản phẩm hàng loạt"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BatchProductCreateScreen()));
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _createInventoryProduct() async {
    // Mở màn hình tạo sản phẩm (User tự tích chọn trackStock)
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductCreateScreen()));
    _handleProductResult(result);
  }

  void _createCombo() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cần có sản phẩm trước khi tạo Combo!")));
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComboCreateScreen(availableProducts: _products)),
    );
    _handleComboResult(result);
  }

  void _createCategory() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo danh mục mới"),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Nhập tên danh mục"), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectProductsScreen(
                      categoryName: nameController.text,
                      availableProducts: _products,
                    ),
                  ),
                ).then((res) {
                  _handleCategoryResult({'name': nameController.text, 'products': res ?? []});
                });
              }
            },
            child: const Text("Tiếp tục"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xff289ca7);
    const Color kGreyBg = Color(0xFFF5F5F5);

    // FAB Logic
    bool showFab = false;
    VoidCallback? fabAction;
    switch (_tabController.index) {
      case 0: if (_products.isNotEmpty) { showFab = true; fabAction = () => _showProductCreateOptions(context); } break;
      case 1: if (_inventoryProducts.isNotEmpty) { showFab = true; fabAction = _createInventoryProduct; } break;
      case 2: if (_combos.isNotEmpty) { showFab = true; fabAction = _createCombo; } break;
      case 3: if (_categories.isNotEmpty) { showFab = true; fabAction = _createCategory; } break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(color: kGreyBg, borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Tìm tên, mã SKU, ...",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.tune, color: Colors.black87),
                      onSelected: (String value) => setState(() => _selectedSort = value),
                      itemBuilder: (BuildContext context) => [
                        "Mới nhất", "Giá tăng", "Giá giảm"
                      ].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                      icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: kPrimaryGreen,
                unselectedLabelColor: Colors.black87,
                indicatorColor: kPrimaryGreen,
                indicatorWeight: 3.0,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
          // TAB 1: SẢN PHẨM
          _products.isEmpty
              ? _buildEmptyState(Icons.shopping_bag_outlined, "Chưa có sản phẩm", "Tạo ngay", () => _showProductCreateOptions(context), kPrimaryGreen)
              : (_isGridView
              ? _buildProductGrid(_filteredProducts, kPrimaryGreen)
              : _buildProductList(_filteredProducts, kPrimaryGreen)),

          // TAB 2: TỒN KHO
          _inventoryProducts.isEmpty
              ? _buildEmptyState(Icons.warehouse_outlined, "Chưa có tồn kho", "Tạo sản phẩm có theo dõi tồn kho", _createInventoryProduct, kPrimaryGreen)
              : _buildInventoryList(_inventoryProducts, kPrimaryGreen),

          // TAB 3: BÁN KÈM
          _combos.isEmpty
              ? _buildEmptyState(Icons.layers_outlined, "Chưa có combo", "Tạo nhóm bán kèm", _createCombo, kPrimaryGreen)
              : _buildComboList(_combos, kPrimaryGreen),

          // TAB 4: DANH MỤC
          _categories.isEmpty
              ? _buildEmptyState(Icons.category_outlined, "Chưa có danh mục", "Tạo danh mục", _createCategory, kPrimaryGreen)
              : _buildCategoryList(_categories, kPrimaryGreen),
        ],
      ),

      floatingActionButton: showFab
          ? FloatingActionButton(
        onPressed: fabAction,
        backgroundColor: kPrimaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // --- WIDGETS HIỂN THỊ ---

  // Empty State (Giữ nguyên)
  Widget _buildEmptyState(IconData icon, String title, String btn, VoidCallback tap, Color color) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 60, color: Colors.grey[300]), const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      ElevatedButton(onPressed: tap, style: ElevatedButton.styleFrom(backgroundColor: color), child: Text(btn, style: const TextStyle(color: Colors.white)))
    ]));
  }

  // 1. Product List (Dạng danh sách)
  Widget _buildProductList(List<Map<String, dynamic>> items, Color color) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text("${item['price']} đ", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCreateScreen(existingProduct: item)));
            _handleProductResult(result, index: index);
          },
        );
      },
    );
  }

  // 1. Product Grid (Dạng lưới - Đã khôi phục)
  Widget _buildProductGrid(List<Map<String, dynamic>> items, Color color) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCreateScreen(existingProduct: item)));
            _handleProductResult(result, index: index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                    child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("${item['price']} đ", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Inventory List (Hiển thị chi tiết hơn)
  Widget _buildInventoryList(List<Map<String, dynamic>> items, Color color) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool available = item['stockStatus'] == 'available';
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.inventory_2, color: Colors.blue[300]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("SKU: ${item['sku'] ?? '---'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("100", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Demo số lượng
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: available ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(available ? "Còn hàng" : "Hết hàng",
                          style: TextStyle(color: available ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Combo List
  Widget _buildComboList(List<Map<String, dynamic>> items, Color color) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final products = item['products'] as List? ?? [];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.layers, color: Colors.orange),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Gồm ${products.length} sản phẩm - Giá: ${item['price']} đ"),
            children: products.map<Widget>((p) => ListTile(
              dense: true,
              leading: const Icon(Icons.check, size: 16, color: Colors.green),
              title: Text(p['name']),
              trailing: Text("${p['price']} đ"),
            )).toList(),
          ),
        );
      },
    );
  }

  // 4. Category List
  Widget _buildCategoryList(List<Map<String, dynamic>> items, Color color) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final category = items[index];
        final products = category['products'] as List? ?? [];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(Icons.category, color: Colors.blue)),
            title: Text(category['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${products.length} sản phẩm"),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategorySelectProductsScreen(categoryName: category['name'], availableProducts: _products))
                ).then((res) {
                  if(res != null) setState(() => category['products'] = res);
                });
              },
            ),
          ),
        );
      },
    );
  }
}