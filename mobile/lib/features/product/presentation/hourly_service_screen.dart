import 'package:flutter/material.dart';
// Đảm bảo bạn đã import đúng đường dẫn các file này
import 'attribute_modal.dart';
import 'add_hourly_price_screen.dart';
// Lưu ý: Class PriceGroup và TimeSlot cần được public ở file add_hourly_price_screen hoặc file models riêng

class HourlyProductCreateScreen extends StatefulWidget {
  const HourlyProductCreateScreen({super.key});

  @override
  State<HourlyProductCreateScreen> createState() => _HourlyProductCreateScreenState();
}

class _HourlyProductCreateScreenState extends State<HourlyProductCreateScreen> {
  // --- 1. KHAI BÁO BIẾN ---
  final Color kPrimaryGreen = const Color(0xff289ca7);
  final TextEditingController _unitController = TextEditingController();

  bool _showUnitSuggestions = true;
  bool _isExpanded = false; // Mặc định ẩn thông tin
  bool _trackStock = false;
  String _stockStatus = 'available';

  // [THAY ĐỔI QUAN TRỌNG]: Dùng List<PriceGroup> để hứng dữ liệu thật thay vì Map giả
  List<PriceGroup> _priceGroups = [];

  // Danh sách thuộc tính đã thêm
  List<Map<String, dynamic>> _attributes = [];

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  // --- 2. HÀM HIỆN MODAL THUỘC TÍNH (THÊM & SỬA) ---
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

  // --- 3. HÀM ĐIỀU HƯỚNG BẢNG GIÁ (LOGIC THẬT) ---
  void _navigateToAddHourlyPrice() async {
    // Await kết quả trả về
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHourlyPriceScreen()),
    );

    // Kiểm tra và cập nhật dữ liệu thật
    if (result != null && result is List<PriceGroup>) {
      setState(() {
        _priceGroups.addAll(result);
      });
    }
  }

  // --- 4. HÀM XỬ LÝ NÚT BACK ---
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận thoát"),
        content: const Text("Bạn có muốn thoát mà không lưu không?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Không", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    )) ?? false;
  }

  // --- 5. GIAO DIỆN CHÍNH ---
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
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text("Tạo sản phẩm theo giờ", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                        text: "Tên dịch vụ/sản phẩm ",
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

                    // --- GIÁ BÁN & GIÁ VỐN (Giữ nguyên cấu trúc mới) ---
                    Row(
                      children: [
                        Expanded(child: _buildSimpleInput("Giá bán mặc định")),
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
                          _buildSuggestionChip("Phòng"), // Đổi thành Giờ/Suất cho hợp context
                          const SizedBox(width: 8),
                          _buildSuggestionChip("Giờ"),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 10),

                    // --- ẨN / HIỆN THÔNG TIN ---
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
                      const SizedBox(height: 24),

                      // ==========================================================
                      // --- PHẦN BẢNG GIÁ THEO KHUNG GIỜ (ĐÃ CẬP NHẬT LOGIC) ---
                      // ==========================================================

                      if (_priceGroups.isEmpty)
                        GestureDetector(
                          onTap: _navigateToAddHourlyPrice,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                            child: Row(
                              children: const [
                                Icon(Icons.add_circle_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text("Thêm bảng giá theo khung giờ", style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          color: const Color(0xFFF9F9F9),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("BẢNG GIÁ THEO KHUNG GIỜ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                                  // Nút thêm tiếp
                                  InkWell(
                                    onTap: _navigateToAddHourlyPrice,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.add, size: 16, color: Colors.blue),
                                        Text("Thêm", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Loop qua các nhóm giá thật
                              ..._priceGroups.asMap().entries.map((entry) {
                                int groupIdx = entry.key;
                                PriceGroup group = entry.value;
                                String dayText = group.selectedDays.isEmpty ? "Chưa chọn ngày" : group.selectedDays.join(", ");

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Tiêu đề: Ngày + Nút xóa
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(dayText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey))),
                                          InkWell(
                                            onTap: () => setState(() => _priceGroups.removeAt(groupIdx)),
                                            child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // List các khung giờ trong nhóm này
                                      ...group.timeSlots.map((slot) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.subdirectory_arrow_right, color: Colors.grey, size: 18),
                                              const SizedBox(width: 8),
                                              Text("${slot.startTime} - ${slot.endTime}", style: const TextStyle(fontSize: 15)),
                                              const Spacer(),
                                              Text("${slot.price.toInt()} đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
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

                      // --- THUỘC TÍNH (Giữ nguyên) ---
                      if (_attributes.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFF9F9F9),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("THUỘC TÍNH", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 16),
                              ..._attributes.asMap().entries.map((entry) {
                                int idx = entry.key;
                                Map<String, dynamic> attr = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${attr['name']} (${(attr['values'] as List).length})",
                                              style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                          InkWell(
                                            onTap: () {
                                              _showAddAttributeModal(context, index: idx, existingData: attr);
                                            },
                                            child: const Text("Sửa", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: (attr['values'] as List).map<Widget>((val) {
                                          return Chip(
                                            label: Text(val),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade300)),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

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
                      onPressed: () async {
                        // Logic lưu
                        if (await _onWillPop()) {
                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      },
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
      ),
    );
  }

  // --- WIDGETS HELPER (Giữ nguyên) ---
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