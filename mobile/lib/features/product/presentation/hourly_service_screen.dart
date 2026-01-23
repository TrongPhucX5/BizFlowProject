import 'dart:convert';
import 'package:flutter/material.dart';
import 'attribute_modal.dart';
import 'add_hourly_price_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
// Lưu ý: Đảm bảo class PriceGroup đã được define trong add_hourly_price_screen.dart hoặc imports models

// ĐỔI TÊN CLASS CHÍNH THỨC TẠI ĐÂY
class HourlyProductCreateScreen extends StatefulWidget {
  const HourlyProductCreateScreen({super.key});

  @override
  // SỬA: State phải khớp với class
  State<HourlyProductCreateScreen> createState() => _HourlyProductCreateScreenState();
}

class _HourlyProductCreateScreenState extends State<HourlyProductCreateScreen> {
  final Color kPrimaryGreen = const Color(0xff289ca7);
  final AuthRepository _authRepository = AuthRepository();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  bool _showUnitSuggestions = true;
  bool _isExpanded = false;
  bool _trackStock = false;
  String _stockStatus = 'available';

  // Dữ liệu bảng giá theo giờ
  List<PriceGroup> _priceGroups = [];
  List<Map<String, dynamic>> _attributes = [];
  bool _isLoading = false;
  int _storeId = 0;

  @override
  void initState() {
    super.initState();
    _loadStoreId();
  }

  Future<void> _loadStoreId() async {
    _storeId = await _authRepository.getCurrentStoreId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _unitController.dispose();
    super.dispose();
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

  void _navigateToAddHourlyPrice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHourlyPriceScreen()),
    );
    if (result != null && result is List<PriceGroup>) {
      setState(() {
        _priceGroups.addAll(result);
      });
    }
  }

  // --- LOGIC LƯU SẢN PHẨM ---
  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên dịch vụ/sản phẩm")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Map cấu hình giá theo giờ sang JSON để lưu vào description hoặc attributes
      // Vì backend hiện tại dùng chung API createProduct, ta sẽ tận dụng trường description
      // hoặc attributes để lưu cấu hình phức tạp này.
      final hourlyConfig = _priceGroups.map((g) => {
        'days': g.selectedDays,
        'slots': g.timeSlots.map((s) => {
          'start': s.startTime,
          'end': s.endTime,
          'price': s.price
        }).toList()
      }).toList();

      final productData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'costPrice': double.tryParse(_costController.text) ?? 0,
        'unitName': _unitController.text.isNotEmpty ? _unitController.text : 'Giờ',
        'unitId': 1, // Mặc định hoặc cần logic chọn unit
        'storeId': _storeId,
        'sku': 'HOURLY_${DateTime.now().millisecondsSinceEpoch}', // Tự sinh SKU
        'trackStock': false, // Dịch vụ thường không tồn kho
        'status': 'ACTIVE',
        'description': jsonEncode({'type': 'HOURLY', 'config': hourlyConfig}), // Lưu config vào description
        'attributes': _attributes,
      };

      // 2. Gọi API
      await _authRepository.createProduct(productData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo dịch vụ thành công!"), backgroundColor: Colors.green),
        );
        // 3. Trả về true để màn hình cha reload
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString().replaceAll("Exception: ", "")}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


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
                  // Ảnh
                  Row(children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.image, color: Colors.blue), Text("Thêm ảnh", style: TextStyle(fontSize: 10, color: Colors.black54))])),
                    const SizedBox(width: 12),
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.camera_alt, color: Colors.blue), Text("Chụp ảnh", style: TextStyle(fontSize: 10, color: Colors.black54))])),
                  ]),
                  const SizedBox(height: 24),

                  const Text("Tên dịch vụ/sản phẩm *", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: "Nhập tên", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent))),
                  ),
                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Giá bán mặc định", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "0", suffixText: "đ"),
                      )
                    ])),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Giá vốn", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                      TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "0", suffixText: "đ"),
                      )
                    ])),
                  ]),
                  const SizedBox(height: 20),

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Đơn vị", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                    TextFormField(controller: _unitController, onChanged: (v) => setState(() => _showUnitSuggestions = v.isEmpty)),
                  ]),
                  if (_showUnitSuggestions) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      InkWell(onTap: () => setState(() {_unitController.text = "Phòng"; _showUnitSuggestions=false;}), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: Colors.grey[200], child: const Text("Phòng"))),
                      const SizedBox(width: 8),
                      InkWell(onTap: () => setState(() {_unitController.text = "Giờ"; _showUnitSuggestions=false;}), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: Colors.grey[200], child: const Text("Giờ"))),
                    ]),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),

                  // BẢNG GIÁ THEO GIỜ
                  if (_priceGroups.isEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      title: const Text("Thêm bảng giá theo khung giờ", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      onTap: _navigateToAddHourlyPrice,
                    )
                  else
                    Container(
                      color: const Color(0xFFF9F9F9),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text("BẢNG GIÁ THEO KHUNG GIỜ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            InkWell(onTap: _navigateToAddHourlyPrice, child: const Text("+ Thêm", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))
                          ]),
                          const SizedBox(height: 12),
                          ..._priceGroups.map((group) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(group.selectedDays.join(", "), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                ...group.timeSlots.map((slot) => Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 4),
                                  child: Text("${slot.startTime}-${slot.endTime}: ${slot.price}đ"),
                                )),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),
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
                    : const Text("Lưu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}