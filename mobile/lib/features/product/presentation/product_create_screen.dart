import 'package:flutter/material.dart';
import 'package:mobile/features/product/data/models/product_model.dart';
import 'attribute_modal.dart';
import 'package:mobile/features/product/data/repositories/product_repository.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/inventory_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../data/models/category_model.dart';
import 'dart:io';

class ProductCreateScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProduct; // Dữ liệu cũ (nếu sửa)

  const ProductCreateScreen({super.key, this.existingProduct});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final Color kPrimaryGreen = const Color(0xff289ca7);
  final ProductRepository _productRepository = ProductRepository();
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // NEW
  final TextEditingController _reorderLevelController = TextEditingController(); // NEW

  bool _showUnitSuggestions = true;
  bool _isExpanded = false;
  bool _trackStock = false;
  String _status = 'ACTIVE';
  String? _imageUrl;
  
  List<Category> _categories = [];
  Category? _selectedCategory;

  List<Map<String, dynamic>> _attributes = [];

  static const int DEFAULT_UNIT_ID = 1;
  int _selectedUnitId = DEFAULT_UNIT_ID;
  int _selectedStoreId = 0; 
  
  // Mock Units
  final List<Map<String, dynamic>> _mockUnits = [
    {'id': 1, 'name': 'Cái'},
    {'id': 2, 'name': 'Hộp'},
    {'id': 3, 'name': 'Kg'},
    {'id': 4, 'name': 'Bao'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadStoreId();
    await _fetchCategories();
    _fillDataIfEditing();
    setState(() => _isLoading = false);
  }

  Future<void> _loadStoreId() async {
    final storeId = await _authRepository.getCurrentStoreId();
    if (mounted) setState(() => _selectedStoreId = storeId);
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _productRepository.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          // Nếu có danh mục và chưa chọn -> chọn cái đầu tiên
          if (_categories.isNotEmpty && _selectedCategory == null) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } catch (e) {
      print("Lỗi tải danh mục: $e");
    }
  }

  void _fillDataIfEditing() {
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameController.text = p['name']?.toString() ?? '';
      _priceController.text = (p['price'] ?? '').toString();
      _costController.text = (p['costPrice'] ?? p['cost'] ?? '').toString();
      _stockController.text = (p['stock'] ?? '0').toString();
      _unitController.text = p['unitName']?.toString() ?? '';
      _skuController.text = p['sku']?.toString() ?? '';
      _barcodeController.text = p['barcode']?.toString() ?? '';
      _trackStock = p['trackStock'] ?? false;
      _status = p['status']?.toString() ?? 'ACTIVE';
      _imageUrl = p['imageUrl'];
      _descriptionController.text = p['description']?.toString() ?? '';
      _reorderLevelController.text = (p['reorderLevel'] ?? '0').toString();

      _selectedUnitId = p['unitId'] ?? DEFAULT_UNIT_ID;
      _selectedStoreId = p['storeId'] ?? _selectedStoreId; 
      
      // Map category ID
      final catId = p['categoryId'];
      if (catId != null && _categories.isNotEmpty) {
        try {
          _selectedCategory = _categories.firstWhere((c) => c.id == catId, orElse: () => _categories.first);
        } catch (_) {}
      }

      if (p['attributes'] != null) {
        _attributes = List<Map<String, dynamic>>.from(p['attributes']);
      }
      _showUnitSuggestions = _unitController.text.isEmpty;
    }
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
    _descriptionController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final url = await _productRepository.uploadImage(image.path);
        if (url != null) {
          setState(() {
            _imageUrl = url;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload ảnh thất bại")));
        }
      } catch (e) {
        print("Upload error: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi upload ảnh")));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

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


  void _saveProduct() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên sản phẩm")));
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giá bán không hợp lệ")));
      return;
    }

    setState(() => _isLoading = true);

    final productData = {
      'name': _nameController.text,
      'price': price,
      'costPrice': double.tryParse(_costController.text) ?? 0,
      'unitName': _unitController.text,
      'unitId': _selectedUnitId,
      'storeId': _selectedStoreId,
      'categoryId': _selectedCategory?.id ?? 1, // Default to 1 if null
      'sku': _skuController.text,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'barcode': _barcodeController.text,
      'trackStock': _trackStock,
      'status': _status,
      'barcode': _barcodeController.text,
      'trackStock': _trackStock,
      'status': _status,
      'description': _descriptionController.text,
      'reorderLevel': int.tryParse(_reorderLevelController.text) ?? 0,
      'attributes': _attributes,
      'attributes': _attributes,
      'imageUrl': _imageUrl,
    };

    try {
      if (widget.existingProduct != null) {
        // Update
        await _productRepository.updateProduct(widget.existingProduct!['id'], productData);
      } else {
        // Create
        final newProductId = await _productRepository.createProduct(productData);
        
        // Auto Stock In
        final int initialStock = productData['stock'] as int? ?? 0;
        if (newProductId > 0 && initialStock > 0) {
           final invRepo = InventoryRepository();
           final double unitCost = double.tryParse(_costController.text) ?? 0;
           
           await invRepo.stockIn(
             productId: newProductId, 
             quantity: initialStock, 
             unitCost: unitCost,
             note: "Tồn kho ban đầu",
             supplierName: "Khởi tạo"
           );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      if (widget.existingProduct!['id'] != null) {
          await _productRepository.deleteProduct(widget.existingProduct!['id']);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
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
        title: Text(widget.existingProduct != null ? "Sửa sản phẩm" : "Tạo sản phẩm", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButton(
            color: Colors.black87,
            onPressed: () async {
              if (await _onWillPop()) {
                if(!mounted) return;
                Navigator.pop(context);
              }
            }
        ),
        actions: [
           if (widget.existingProduct != null)
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _isLoading ? null : _deleteProduct),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            
            _buildLabel("Tên sản phẩm", isRequired: true),
            TextFormField(controller: _nameController, decoration: const InputDecoration(hintText: "Nhập tên sản phẩm")),
            const SizedBox(height: 16),
            


            Row(children: [
              Expanded(child: _buildInput("Mã SKU", _skuController, action: TextInputAction.next)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput("Mã vạch", _barcodeController, action: TextInputAction.next)),
            ]),
            const SizedBox(height: 16),

           _buildInput("Đơn vị", _unitController, action: TextInputAction.next, onChanged: (v) => setState(() => _showUnitSuggestions = v.isEmpty)),
            if (_showUnitSuggestions) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: _mockUnits.map((u) => _buildChip(u['name'], u['id'])).toList()),
            ],
            const SizedBox(height: 20),

             Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildLabel("Giá bán", isRequired: true),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryGreen),
                  decoration: const InputDecoration(hintText: "0", suffixText: "đ"),
                )
              ])),
              const SizedBox(width: 16),
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
                  
                  if (_trackStock)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInput(
                              widget.existingProduct != null ? "Tồn kho hiện tại" : "Tồn kho ban đầu", 
                              _stockController, 
                              isNumber: true, 
                              action: TextInputAction.done,
                              readOnly: widget.existingProduct != null
                          ),
                          if (widget.existingProduct != null)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                "Để sửa số lượng, vui lòng dùng chức năng 'Nhập hàng' hoặc 'Kiểm kê'",
                                style: TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            )
                        ],
                      ),
                    ),
                  
                  if (!_trackStock)
                    Row(children: [
                      const Text("Trạng thái kinh doanh"), const Spacer(),
                      _buildStatusBtn("Đang bán", 'ACTIVE'),
                      _buildStatusBtn("Ngừng bán", 'INACTIVE'),
                    ]),
                ]),
              ),
              const SizedBox(height: 20),



              // Min Stock Field (inside Expanded section)
              if (_trackStock)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
                  child: _buildInput("Định mức tồn kho tối thiểu (Cảnh báo khi dưới)", _reorderLevelController, isNumber: true),
                ),

              // Description Field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Mô tả chi tiết"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Nhập mô tả sản phẩm...",
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
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

            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(widget.existingProduct != null ? "Cập nhật" : "Lưu", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    ));
  }

  // ... Helpers Region ...
  Widget _buildLabel(String text, {bool isRequired = false}) => RichText(text: TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey), children: [if (isRequired) const TextSpan(text: " *", style: TextStyle(color: Colors.red))]));
  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false, Function(String)? onChanged, TextInputAction? action, bool readOnly = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(label), TextFormField(controller: ctrl, onChanged: onChanged, textInputAction: action, readOnly: readOnly, keyboardType: isNumber ? TextInputType.number : TextInputType.text)]);
  Widget _buildChip(String text, int id) => InkWell(onTap: () => setState(() { _unitController.text = text; _selectedUnitId = id; _showUnitSuggestions = false; }), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(text)));
  Widget _buildStatusBtn(String text, String val) { bool sel = _status == val; return InkWell(onTap: () => setState(() => _status = val), child: Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: sel ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: sel ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : []), child: Text(text, style: TextStyle(color: sel ? kPrimaryGreen : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)))); }

  // Image Section Helper 
  Widget _buildImageSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _imageUrl != null && _imageUrl!.isNotEmpty
                  ? _buildProductImage(_imageUrl!)
                  : Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            ),
          ),
          // Nút đổi ảnh (Edit Button)
          GestureDetector(
            onTap: _showImageSourcePicker,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
          // Nút xóa ảnh (nếu có ảnh)
          if (_imageUrl != null && _imageUrl!.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _imageUrl = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl, 
          width: 140, 
          height: 140, 
          fit: BoxFit.cover,
          errorBuilder: (_,__,___) => const Icon(Icons.broken_image_outlined, size: 40),
        );
      }
      // Xử lý Base64
      final base64String = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
      return Image.memory(
        const Base64Decoder().convert(base64String),
        width: 140, 
        height: 140, 
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => const Icon(Icons.broken_image_outlined, size: 40),
      );
    } catch (_) {
      return const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey);
    }
  }

  void _showImageSourcePicker() {
      showModalBottomSheet(
        context: context, 
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text("Chọn nguồn ảnh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library), 
              title: const Text("Thư viện ảnh"), 
              onTap: () { Navigator.pop(context); _pickAndUploadImage(ImageSource.gallery); }
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt), 
              title: const Text("Chụp ảnh mới"), 
              onTap: () { Navigator.pop(context); _pickAndUploadImage(ImageSource.camera); }
            ),
            const SizedBox(height: 20),
          ]
        )
      );
  }
}