import 'package:flutter/material.dart';
import 'attribute_modal.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/inventory_repository.dart';

class ProductCreateScreen extends StatefulWidget {
  // Tham số tùy chọn: Nếu có -> Chế độ Sửa, Nếu null -> Chế độ Tạo
  final Map<String, dynamic>? existingProduct;

  const ProductCreateScreen({super.key, this.existingProduct});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final Color kPrimaryGreen = const Color(0xff289ca7);
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(); // Thêm controller tồn kho
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  bool _showUnitSuggestions = true;
  bool _isExpanded = false;
  bool _trackStock = false;
  String _status = 'ACTIVE'; // Thay _stockStatus bằng _status khớp DB

  List<Map<String, dynamic>> _attributes = [];

  // --- CONSTANTS (Tránh hard-code số 1) ---
  static const int DEFAULT_UNIT_ID = 1;
  // FIX: Không dùng const cho StoreID vì mỗi user có store khác nhau
  // static const int DEFAULT_STORE_ID = 1; 
  static const int DEFAULT_CATEGORY_ID = 1;

  // --- CẤU HÌNH MẶC ĐỊNH (Chuẩn bị cho API sau này) ---
  int _selectedUnitId = DEFAULT_UNIT_ID;
  int _selectedStoreId = 0; // Sẽ được load từ storage
  int _selectedCategoryId = DEFAULT_CATEGORY_ID;

  // Mock danh sách đơn vị để đồng bộ ID và Name
  final List<Map<String, dynamic>> _mockUnits = [
    {'id': 1, 'name': 'Cái'},
    {'id': 2, 'name': 'Hộp'},
    {'id': 3, 'name': 'Kg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadStoreId(); // Lấy StoreID thật
    // FILL DỮ LIỆU NẾU ĐANG SỬA
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameController.text = p['name'] ?? '';
      _priceController.text = p['price'] ?? '';
      _costController.text = (p['costPrice'] ?? p['cost'] ?? '').toString(); // Support cả 2 key
      _stockController.text = (p['stock'] ?? '0').toString();
      _unitController.text = p['unitName'] ?? '';
      _skuController.text = p['sku'] ?? '';
      _barcodeController.text = p['barcode'] ?? '';
      _trackStock = p['trackStock'] ?? false;
      _status = p['status'] ?? 'ACTIVE';

      // Load ID từ dữ liệu cũ nếu có
      _selectedUnitId = p['unitId'] ?? DEFAULT_UNIT_ID;
      _selectedStoreId = p['storeId'] ?? _selectedStoreId; 
      _selectedCategoryId = p['categoryId'] ?? DEFAULT_CATEGORY_ID;

      if (p['attributes'] != null) {
        _attributes = List<Map<String, dynamic>>.from(p['attributes']);
      }
      _showUnitSuggestions = _unitController.text.isEmpty;
    }
  }

  Future<void> _loadStoreId() async {
    final storeId = await _authRepository.getCurrentStoreId();
    if (mounted) setState(() => _selectedStoreId = storeId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  // Hiện modal thuộc tính
  void _showAddAttributeModal(BuildContext context, {int? index, Map<String, dynamic>? existingData}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttributeModalContent(initialData: existingData),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index != null) {
          _attributes[index] = result;
        } else {
          _attributes.add(result);
        }
      });
    }
  }

  // Hàm LƯU SẢN PHẨM
  void _saveProduct() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên sản phẩm")));
      return;
    }

    // --- VALIDATION SỐ LIỆU ---
    final price = double.tryParse(_priceController.text);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giá bán không hợp lệ (phải là số >= 0)")));
      return;
    }

    if (_costController.text.isNotEmpty) {
      final cost = double.tryParse(_costController.text);
      if (cost == null || cost < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giá vốn không hợp lệ (phải là số >= 0)")));
        return;
      }
    }

    if (_trackStock && _stockController.text.isNotEmpty) {
      final stock = int.tryParse(_stockController.text);
      if (stock == null || stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tồn kho không hợp lệ (phải là số nguyên >= 0)")));
        return;
      }
    }

    setState(() => _isLoading = true);

    // Đóng gói dữ liệu trả về

    // Đóng gói dữ liệu trả về
    final productData = {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0, // Parse Double
      'costPrice': double.tryParse(_costController.text) ?? 0, // Parse Double
      'unitName': _unitController.text,
      'unitId': _selectedUnitId,
      'storeId': _selectedStoreId,
      'categoryId': _selectedCategoryId,
      'sku': _skuController.text,
      'stock': int.tryParse(_stockController.text) ?? 0, // Parse Int
      'barcode': _barcodeController.text,
      'trackStock': _trackStock,
      'status': _status, // Sử dụng biến status đã chọn từ UI
      'description': null, // UI chưa có nhập mô tả -> gửi null
      'reorderLevel': 0, // Mặc định mức báo động tồn kho là 0
      'attributes': _attributes, // <-- Lưu mảng thuộc tính
    };

    try {
      if (widget.existingProduct != null) {
        // Update logic (giữ nguyên)
        await _authRepository.updateProduct(widget.existingProduct!['id'], productData);
      } else {
        // Create logic + Chained Stock In
        final newProductId = await _authRepository.createProduct(productData);
        
        // Nếu có nhập tồn kho ban đầu -> Tự động nhập kho
        final int initialStock = productData['stock'] as int? ?? 0;
        if (newProductId > 0 && initialStock > 0) {
           // Import InventoryRepository locally or global
           final invRepo = InventoryRepository();
           // Giá nhập lấy từ Giá vốn (Cost Price)
           final double unitCost = double.tryParse(_costController.text) ?? 0;
           
           await invRepo.stockIn(
             productId: newProductId, 
             quantity: initialStock, 
             unitCost: unitCost,
             note: "Tồn kho ban đầu khi tạo sản phẩm",
             supplierName: "Khởi tạo"
           );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green));
      Navigator.pop(context, true); // Trả về true để reload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm XÓA SẢN PHẨM
  void _deleteProduct() async {
    if (widget.existingProduct == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _authRepository.deleteProduct(widget.existingProduct!['id']);
      if (!mounted) return;
      Navigator.pop(context, true); // Trả về true để reload list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi xóa: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isEmpty) return true;
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Thoát mà không lưu?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Không")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Thoát", style: TextStyle(color: Colors.red))),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () async {
              if (await _onWillPop()) {
                if(!mounted) return;
                Navigator.pop(context);
              }
            },
          ),
          title: Text(widget.existingProduct != null ? "Sửa sản phẩm" : "Tạo sản phẩm", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          actions: [
            if (widget.existingProduct != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _isLoading ? null : _deleteProduct,
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tạm ẩn tính năng ảnh vì chưa có API Upload thật
                    // Tránh để UI giả gây hiểu nhầm
                    // Row(children: [
                    //   _buildImageBox(Icons.image, "Thêm ảnh"),
                    //   const SizedBox(width: 12),
                    //   _buildImageBox(Icons.camera_alt, "Chụp ảnh"),
                    // ]),
                    // const SizedBox(height: 24),

                    _buildLabel("Tên sản phẩm", isRequired: true),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next, // Enter -> Xuống dòng dưới
                      decoration: const InputDecoration(hintText: "Nhập tên sản phẩm", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent))),
                    ),
                    const SizedBox(height: 16),

                    // 1. Đưa SKU/Barcode ra ngoài (Ngay dưới tên sản phẩm)
                    Row(children: [
                      Expanded(child: _buildInput("Mã SKU", _skuController, action: TextInputAction.next)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInput("Mã vạch", _barcodeController, action: TextInputAction.next)),
                    ]),
                    const SizedBox(height: 20),

                    // 2. Đơn vị tính (Đưa lên trước giá)
                    _buildInput("Đơn vị", _unitController, action: TextInputAction.next, onChanged: (v) => setState(() => _showUnitSuggestions = v.isEmpty)),
                    if (_showUnitSuggestions) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _mockUnits.map((u) => _buildChip(u['name'], u['id'])).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // 3. Giá bán & Giá vốn
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      // Giá bán: Nổi bật hơn hẳn (To, Đậm, Màu xanh chủ đạo)
                      Expanded(
                        flex: 3,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("Giá bán", isRequired: true),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryGreen),
                            decoration: InputDecoration(
                              hintText: "0", suffixText: "đ", isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryGreen, width: 2))
                            ),
                          )
                        ]),
                      ),
                      const SizedBox(width: 16),
                      // Giá vốn: Nhỏ hơn, màu thường
                      Expanded(flex: 2, child: _buildInput("Giá vốn", _costController, isNumber: true, action: TextInputAction.done)),
                    ]),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),

                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(children: [
                          Text(_isExpanded ? "Ẩn thông tin" : "Thông tin thêm", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.blue),
                        ]),
                      ),
                    ),

                    if (_isExpanded) ...[
                      // Tồn kho
                      Container(
                        color: const Color(0xFFF9F9F9),
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          SwitchListTile(contentPadding: EdgeInsets.zero, activeColor: kPrimaryGreen, title: const Text("THEO DÕI TỒN KHO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)), value: _trackStock, onChanged: (v) => setState(() => _trackStock = v)),
                          
                          // Nếu theo dõi tồn kho -> Cho nhập số lượng ban đầu
                          if (_trackStock)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildInput("Tồn kho ban đầu", _stockController, isNumber: true, action: TextInputAction.done),
                            ),
                          
                          // Logic hiển thị theo yêu cầu:
                          // - Bật theo dõi kho -> Ẩn nút tình trạng (Mặc định hệ thống xử lý)
                          // - Tắt theo dõi kho -> Cho phép chỉnh Đang bán/Ngừng bán
                          if (!_trackStock)
                            Row(children: [
                              const Text("Trạng thái kinh doanh"), const Spacer(),
                              _buildStatusBtn("Đang bán", 'ACTIVE'),
                              _buildStatusBtn("Ngừng bán", 'INACTIVE'),
                            ]),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      // Danh sách thuộc tính
                      if (_attributes.isNotEmpty)
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFF9F9F9),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text("THUỘC TÍNH", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 12),
                            ..._attributes.asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(entry.value['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text((entry.value['values'] as List).join(", "), style: const TextStyle(color: Colors.grey)),
                                  ]),
                                  InkWell(onTap: () => _showAddAttributeModal(context, index: entry.key, existingData: entry.value), child: const Text("Sửa", style: TextStyle(color: Colors.blue))),
                                ]),
                              );
                            }).toList()
                          ]),
                        ),

                      InkWell(
                        onTap: () => _showAddAttributeModal(context),
                        child: Row(children: const [Icon(Icons.add_circle_outline, color: Colors.blue), SizedBox(width: 8), Text("Thêm thuộc tính", style: TextStyle(color: Colors.blue))]),
                      ),
                    ],
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.existingProduct != null ? "Cập nhật" : "Lưu", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _buildLabel(String text, {bool isRequired = false}) => RichText(text: TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey), children: [if (isRequired) const TextSpan(text: " *", style: TextStyle(color: Colors.red))]));
  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false, Function(String)? onChanged, TextInputAction? action}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(label), TextFormField(controller: ctrl, onChanged: onChanged, textInputAction: action, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12))))]);
  
  // Cập nhật Chip để set cả ID và Name
  Widget _buildChip(String text, int id) => InkWell(onTap: () => setState(() { 
    _unitController.text = text; 
    _selectedUnitId = id; // Đồng bộ ID
    _showUnitSuggestions = false; 
  }), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(text)));
  
  Widget _buildStatusBtn(String text, String val) { bool sel = _status == val; return InkWell(onTap: () => setState(() => _status = val), child: Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: sel ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: sel ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : []), child: Text(text, style: TextStyle(color: sel ? kPrimaryGreen : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)))); }
  Widget _buildImageBox(IconData icon, String label) => Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.blue), Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54))]));
}