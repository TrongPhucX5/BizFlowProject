import 'package:flutter/material.dart';
import 'attribute_modal.dart';

class ProductCreateScreen extends StatefulWidget {
  // Tham số tùy chọn: Nếu có -> Chế độ Sửa, Nếu null -> Chế độ Tạo
  final Map<String, dynamic>? existingProduct;

  const ProductCreateScreen({super.key, this.existingProduct});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final Color kPrimaryGreen = const Color(0xff289ca7);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  bool _showUnitSuggestions = true;
  bool _isExpanded = false;
  bool _trackStock = false;
  String _stockStatus = 'available';

  List<Map<String, dynamic>> _attributes = [];

  @override
  void initState() {
    super.initState();
    // FILL DỮ LIỆU NẾU ĐANG SỬA
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameController.text = p['name'] ?? '';
      _priceController.text = p['price'] ?? '';
      _costController.text = p['cost'] ?? '';
      _unitController.text = p['unit'] ?? '';
      _skuController.text = p['sku'] ?? '';
      _barcodeController.text = p['barcode'] ?? '';
      _trackStock = p['trackStock'] ?? false;
      _stockStatus = p['stockStatus'] ?? 'available';

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
  void _saveProduct() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên sản phẩm")));
      return;
    }

    // Đóng gói dữ liệu trả về
    final productData = {
      'name': _nameController.text,
      'price': _priceController.text,
      'cost': _costController.text,
      'unit': _unitController.text,
      'sku': _skuController.text,
      'barcode': _barcodeController.text,
      'trackStock': _trackStock,
      'stockStatus': _stockStatus,
      'attributes': _attributes, // <-- Lưu mảng thuộc tính
    };

    Navigator.pop(context, productData);
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
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      _buildImageBox(Icons.image, "Thêm ảnh"),
                      const SizedBox(width: 12),
                      _buildImageBox(Icons.camera_alt, "Chụp ảnh"),
                    ]),
                    const SizedBox(height: 24),

                    _buildLabel("Tên sản phẩm", isRequired: true),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: "Nhập tên sản phẩm", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent))),
                    ),
                    const SizedBox(height: 20),

                    Row(children: [
                      Expanded(child: _buildInput("Giá bán", _priceController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInput("Giá vốn", _costController, isNumber: true)),
                    ]),
                    const SizedBox(height: 20),

                    _buildInput("Đơn vị", _unitController, onChanged: (v) => setState(() => _showUnitSuggestions = v.isEmpty)),
                    if (_showUnitSuggestions) ...[
                      const SizedBox(height: 12),
                      Row(children: [_buildChip("Cái"), const SizedBox(width: 8), _buildChip("Hộp")]),
                    ],

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
                      Row(children: [
                        Expanded(child: _buildInput("Mã SKU", _skuController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput("Mã vạch", _barcodeController)),
                      ]),
                      const SizedBox(height: 20),

                      // Tồn kho
                      Container(
                        color: const Color(0xFFF9F9F9),
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          SwitchListTile(contentPadding: EdgeInsets.zero, activeColor: kPrimaryGreen, title: const Text("THEO DÕI TỒN KHO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)), value: _trackStock, onChanged: (v) => setState(() => _trackStock = v)),
                          Row(children: [
                            const Text("Tình trạng"), const Spacer(),
                            _buildStockBtn("Còn hàng", 'available'),
                            _buildStockBtn("Hết hàng", 'out_of_stock'),
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
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  child: Text(widget.existingProduct != null ? "Cập nhật" : "Lưu", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false, Function(String)? onChanged}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(label), TextFormField(controller: ctrl, onChanged: onChanged, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12))))]);
  Widget _buildChip(String text) => InkWell(onTap: () => setState(() { _unitController.text = text; _showUnitSuggestions = false; }), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(text)));
  Widget _buildStockBtn(String text, String val) { bool sel = _stockStatus == val; return InkWell(onTap: () => setState(() => _stockStatus = val), child: Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: sel ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: sel ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : []), child: Text(text, style: TextStyle(color: sel ? kPrimaryGreen : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)))); }
  Widget _buildImageBox(IconData icon, String label) => Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.blue), Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54))]));
}