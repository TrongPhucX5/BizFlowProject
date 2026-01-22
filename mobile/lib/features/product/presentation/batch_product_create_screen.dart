import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class BatchProductCreateScreen extends StatefulWidget {
  const BatchProductCreateScreen({super.key});

  @override
  State<BatchProductCreateScreen> createState() => _BatchProductCreateScreenState();
}

class _BatchProductCreateScreenState extends State<BatchProductCreateScreen> {
  // Màu chủ đạo lấy từ code cũ của Anh
  final Color kPrimaryGreen = const Color(0xff289ca7);
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  // --- CẤU HÌNH MẶC ĐỊNH (Chuẩn bị cho API sau này) ---
  final int _defaultUnitId = 1;      // Mặc định: Cái
  final int _defaultStoreId = 1;     // Mặc định: Cửa hàng chính
  final int _defaultCategoryId = 1;  // Mặc định: Danh mục chung

  // State quản lý danh sách sản phẩm (Demo model đơn giản)
  // Thực tế Anh nên tạo class Model riêng
  List<Map<String, dynamic>> _items = [
    {
      "name": "Sản phẩm 1",
      "sku": "",
      "unitName": "Cái",
      "price": "5000",
      "costPrice": "0",
      "priceError": null, // Thêm trường để validate
      "costError": null,  // Thêm trường để validate
    }
  ];

  bool _hideCostPrice = false; // Trạng thái ẩn/hiện giá vốn

  // --- HÀM XỬ LÝ LOGIC ---

  // Thêm 10 dòng rỗng
  void _addTenRows() {
    setState(() {
      for (int i = 0; i < 10; i++) {
        _items.add({
          "name": "",
          "sku": "",
          "unitName": "Cái",
          "price": "0",
          "costPrice": "0",
          "priceError": null,
          "costError": null,
        });
      }
    });
  }

  // Hàm hiển thị Dialog xác nhận khi thoát
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cảnh báo"),
        content: const Text("Dữ liệu chưa được lưu. Bạn có chắc chắn muốn thoát không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Ở lại
            child: const Text("Ở lại", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Thoát luôn
            child: const Text("Thoát không lưu", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false; // Nếu bấm ra ngoài thì mặc định là false (ở lại)
  }

  // --- UI BUILDING BLOCKS ---

  @override
  Widget build(BuildContext context) {
    // PopScope là widget mới thay thế WillPopScope để bắt sự kiện Back (Android hoặc Swipe iOS)
    return PopScope(
      canPop: false, // Chặn thoát mặc định
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tạo sản phẩm hàng loạt", style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              // Xử lý nút Back trên AppBar thủ công
              final shouldPop = await _showExitConfirmDialog();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            // Banner thông báo màu xanh
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Text(
                "Bạn có thể sử dụng tính năng tạo nhiều sản phẩm bằng cách nhập file excel trên phiên bản Website",
                style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
              ),
            ),

            // Header bảng & Nút ẩn giá vốn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đã thêm ${_items.length}",
                      style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                  GestureDetector(
                    onTap: () => setState(() => _hideCostPrice = !_hideCostPrice),
                    child: Row(
                      children: [
                        Icon(_hideCostPrice ? Icons.visibility_off : Icons.visibility,
                            size: 18, color: kPrimaryGreen),
                        const SizedBox(width: 4),
                        Text("Ẩn giá vốn", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // HEADER CỦA TABLE
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _buildHeaderCell("MÃ SKU", flex: 2),
                  _buildHeaderCell("TÊN SẢN PHẨM *", flex: 3),
                  _buildHeaderCell("ĐƠN VỊ", flex: 1),
                  _buildHeaderCell("GIÁ BÁN *", flex: 2),
                  if (!_hideCostPrice) _buildHeaderCell("GIÁ VỐN", flex: 2),
                ],
              ),
            ),

            // DANH SÁCH DÒNG NHẬP LIỆU
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (ctx, index) => const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  return _buildInputRow(index);
                },
              ),
            ),

            // NÚT THÊM 10 DÒNG
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _addTenRows,
                icon: const Icon(Icons.add),
                label: const Text("Tạo thêm 10 dòng"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: kPrimaryGreen,
                  side: BorderSide(color: kPrimaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            // NÚT HOÀN TẤT (Fixed bottom)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    // 1. Lọc các dòng có tên sản phẩm
                    final validItems = _items.where((e) => e['name'].toString().trim().isNotEmpty).toList();

                    if (validItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập ít nhất 1 tên sản phẩm")));
                      return;
                    }

                    // --- KIỂM TRA LỖI VALIDATION TRƯỚC KHI SUBMIT ---
                    final hasError = _items.any((item) =>
                        item['priceError'] != null ||
                        item['costError'] != null);

                    if (hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng sửa các lỗi được đánh dấu đỏ."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      // 2. Map dữ liệu để gửi API
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final payload = validItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return {
                          "name": item['name'],
                          "unitName": item['unitName'],
                          "unitId": _defaultUnitId,
                          "storeId": _defaultStoreId,
                          "categoryId": _defaultCategoryId,
                          "price": item['price'],
                          "costPrice": item['costPrice'],
                          "sku": (item['sku'] as String).isNotEmpty ? item['sku'] : "AUTO_${timestamp}_$index", // Dùng SKU người nhập, nếu trống thì tự sinh
                          "description": null,
                          "reorderLevel": 0,
                          "status": "ACTIVE",
                          "trackStock": false,
                        };
                      }).toList();

                      // 3. Gọi API Batch
                      await _authRepository.createProductsBatch(payload);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Hoàn tất", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Header Cell
  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget con: Input Row
  Widget _buildInputRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: (_items[index]['priceError'] != null || _items[index]['costError'] != null)
          ? Colors.red.withOpacity(0.05) // Highlight dòng lỗi
          : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã SKU
          Expanded(
            flex: 2,
            child: _buildTextField(
              initialValue: _items[index]['sku'],
              hint: "Nhập SKU",
              onChanged: (val) {
                _items[index]['sku'] = val;
              },
            ),
          ),
          _verticalDivider(),
          // Tên sản phẩm
          Expanded(
            flex: 3,
            child: _buildTextField(
              initialValue: _items[index]['name'],
              hint: "Nhập tên",
              onChanged: (val) {
                _items[index]['name'] = val;
              },
            ),
          ),
          _verticalDivider(),
          // Đơn vị
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Căn giữa với textfield
                child: Text(_items[index]['unitName'], style: const TextStyle(fontSize: 13)),
              ),
            ),
          ),
          _verticalDivider(),
          // Giá bán
          Expanded(
            flex: 2,
            child: _buildTextField(
              initialValue: _items[index]['price'],
              hint: "0",
              isNumber: true,
              errorText: _items[index]['priceError'],
              onChanged: (val) {
                setState(() {
                  _items[index]['price'] = val;
                  final price = double.tryParse(val);
                  if (val.isNotEmpty && (price == null || price < 0)) {
                    _items[index]['priceError'] = 'Giá không hợp lệ';
                  } else {
                    _items[index]['priceError'] = null;
                  }
                });
              },
            ),
          ),
          if (!_hideCostPrice) ...[
            _verticalDivider(),
            // Giá vốn
            Expanded(
              flex: 2,
              child: _buildTextField(
                initialValue: _items[index]['costPrice'],
                hint: "0",
                isNumber: true,
                errorText: _items[index]['costError'],
                onChanged: (val) {
                  setState(() {
                    _items[index]['costPrice'] = val;
                    final cost = double.tryParse(val);
                    if (val.isNotEmpty && (cost == null || cost < 0)) {
                      _items[index]['costError'] = 'Giá không hợp lệ';
                    } else {
                      _items[index]['costError'] = null;
                    }
                  });
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(width: 0.5, height: 40, color: Colors.grey.shade300);

  Widget _buildTextField({
    required String initialValue,
    required String hint,
    bool isNumber = false,
    Function(String)? onChanged,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged, // Quan trọng: Cập nhật dữ liệu khi gõ
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          errorText: errorText,
          errorStyle: const TextStyle(fontSize: 10), // Lỗi nhỏ gọn
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}