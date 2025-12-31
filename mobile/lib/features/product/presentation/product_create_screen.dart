import 'package:flutter/material.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  // --- 1. KHAI BÁO BIẾN ---
  final Color kPrimaryGreen = const Color(0xff289ca7);

  // Controller
  final TextEditingController _unitController = TextEditingController();

  // Biến trạng thái
  bool _showUnitSuggestions = true;
  bool _isExpanded = false; // Mặc định là ẩn
  bool _trackStock = false;
  String _stockStatus = 'available'; // available | out_of_stock

  // --- 2. QUẢN LÝ MEMORY ---
  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  // --- 3. HÀM HIỆN MODAL THUỘC TÍNH ---
  void _showAddAttributeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AttributeModalContent(),
    );
  }

  // --- 4. GIAO DIỆN CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Tạo sản phẩm", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ẢNH SẢN PHẨM ---
                  Row(
                    children: [
                      _buildImagePlaceholder(Icons.image, "Thêm ảnh"),
                      const SizedBox(width: 12),
                      _buildImagePlaceholder(Icons.camera_alt, "Chụp ảnh"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- TÊN SẢN PHẨM ---
                  RichText(
                    text: const TextSpan(
                      text: "Tên sản phẩm ",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      children: [TextSpan(text: "*", style: TextStyle(color: Colors.red))],
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Nhập tên sản phẩm",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Thông tin bắt buộc", style: TextStyle(color: Colors.red, fontSize: 11)),
                  const SizedBox(height: 20),

                  // --- GIÁ BÁN & GIÁ VỐN ---
                  Row(
                    children: [
                      Expanded(child: _buildSimpleInput("Giá bán")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSimpleInput("Giá vốn")),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- ĐƠN VỊ TÍNH ---
                  _buildSimpleInput(
                    "Đơn vị",
                    controller: _unitController,
                    onChanged: (val) {
                      setState(() {
                        _showUnitSuggestions = val.isEmpty;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _unitController.clear();
                        _showUnitSuggestions = true;
                      });
                    },
                  ),
                  if (_showUnitSuggestions) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSuggestionChip("Cái"),
                        const SizedBox(width: 8),
                        _buildSuggestionChip("Hộp"),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 10),

                  // ========================================================
                  // --- NÚT BẤM ẨN / HIỆN THÔNG TIN ---
                  // ========================================================
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Text(_isExpanded ? "Ẩn thông tin" : "Thông tin thêm",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 4),
                          Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),

                  // ========================================================
                  // --- PHẦN MỞ RỘNG (Chỉ hiện khi _isExpanded = true) ---
                  // ========================================================
                  if (_isExpanded) ...[
                    const SizedBox(height: 10),

                    // Mã sản phẩm & Mã vạch
                    Row(
                      children: [
                        Expanded(child: _buildSimpleInput("Mã sản phẩm")),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Mã vạch", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                              TextFormField(
                                decoration: const InputDecoration(
                                  isDense: true,
                                  suffixIcon: Icon(Icons.qr_code_scanner, color: Colors.black54),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildSimpleInput("Giá khuyến mãi"),

                    const SizedBox(height: 20),

                    // Danh mục
                    const Text("Danh mục (1)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.menu, color: Colors.grey),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: (){},
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Tạo mới"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: const BorderSide(color: Colors.blue),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildDropdownInput("Nhóm bán kèm"),

                    const SizedBox(height: 24),

                    // TỒN KHO
                    Container(
                      color: const Color(0xFFF9F9F9),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: kPrimaryGreen,
                            title: Row(
                              children: const [
                                Text("THEO DÕI SỐ LƯỢNG TỒN KHO", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.info_outline, size: 16, color: Colors.black54)
                              ],
                            ),
                            value: _trackStock,
                            onChanged: (v) => setState(() => _trackStock = v),
                          ),
                          Row(
                            children: [
                              const Text("Tình trạng tồn kho", style: TextStyle(fontSize: 14)),
                              const Spacer(),
                              Container(
                                height: 36,
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    _buildStockBtn("Còn hàng", 'available'),
                                    _buildStockBtn("Hết hàng", 'out_of_stock'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- NÚT THÊM THUỘC TÍNH ---
                    GestureDetector(
                      onTap: () => _showAddAttributeModal(context),
                      child: Row(
                        children: const [
                          Icon(Icons.add_circle_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Thêm thuộc tính (Kích cỡ, màu sắc...)", style: TextStyle(color: Colors.blue, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],

                  // ĐÃ XÓA PHẦN ELSE VÀ PHẦN CÀI ĐẶT HIỂN THỊ Ở ĐÂY

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- FOOTER BUTTONS ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryGreen,
                        side: BorderSide(color: kPrimaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
                    ),
                    child: const Text("Lưu và thêm mới", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
                    ),
                    child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // CÁC WIDGET CON (HELPER)
  // ==========================================

  Widget _buildImagePlaceholder(IconData icon, String label) {
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))
        ],
      ),
    );
  }

  Widget _buildSimpleInput(String label, {
    TextEditingController? controller,
    Function(String)? onChanged,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            suffixIcon: (onClear != null && controller != null && controller.text.isNotEmpty)
                ? IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
              onPressed: onClear,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            )
                : null,
          ),
        )
      ],
    );
  }

  Widget _buildDropdownInput(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(" ", style: TextStyle(fontSize: 14)),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _unitController.text = text;
          _showUnitSuggestions = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  Widget _buildStockBtn(String text, String statusValue) {
    bool isSelected = _stockStatus == statusValue;
    return GestureDetector(
      onTap: () => setState(() => _stockStatus = statusValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : [],
        ),
        child: Text(text, style: TextStyle(
            color: isSelected ? kPrimaryGreen : Colors.black54,
            fontWeight: FontWeight.bold, fontSize: 12)
        ),
      ),
    );
  }
}

// =======================================================
// CLASS XỬ LÝ MODAL THUỘC TÍNH (GIỮ NGUYÊN)
// =======================================================
class _AttributeModalContent extends StatefulWidget {
  const _AttributeModalContent();

  @override
  State<_AttributeModalContent> createState() => _AttributeModalContentState();
}

class _AttributeModalContentState extends State<_AttributeModalContent> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _valueControllers = [TextEditingController()];

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onValueChanged(String value, int index) {
    setState(() {
      if (index == _valueControllers.length - 1 && value.isNotEmpty) {
        _valueControllers.add(TextEditingController());
      }
    });
  }

  void _removeValueField(int index) {
    setState(() {
      _valueControllers[index].dispose();
      _valueControllers.removeAt(index);
      if (_valueControllers.isEmpty) {
        _valueControllers.add(TextEditingController());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text("Thêm thuộc tính", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: "Tên thuộc tính ",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                            children: [TextSpan(text: "*", style: TextStyle(color: Colors.red))],
                          ),
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "Ví dụ: Màu sắc, Kích thước...",
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Thông tin bắt buộc", style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Text(
                      "GIÁ TRỊ (VÍ DỤ: ĐỎ, VÀNG, SIZE S, SIZE M...)",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: List.generate(_valueControllers.length, (index) {
                        bool hasText = _valueControllers[index].text.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            controller: _valueControllers[index],
                            onChanged: (val) => _onValueChanged(val, index),
                            decoration: InputDecoration(
                              hintText: "Thêm giá trị",
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              suffixIcon: hasText
                                  ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () => _removeValueField(index),
                              )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black54,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}