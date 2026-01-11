import 'package:flutter/material.dart';

class BatchProductCreateScreen extends StatefulWidget {
  const BatchProductCreateScreen({super.key});

  @override
  State<BatchProductCreateScreen> createState() => _BatchProductCreateScreenState();
}

class _BatchProductCreateScreenState extends State<BatchProductCreateScreen> {
  // Màu chủ đạo lấy từ code cũ của Anh
  final Color kPrimaryGreen = const Color(0xff289ca7);

  // State quản lý danh sách sản phẩm (Demo model đơn giản)
  // Thực tế Anh nên tạo class Model riêng
  List<Map<String, dynamic>> _items = [
    {"name": "Sản phẩm 1", "unit": "Cái", "price": "5000", "cost": "0"}
  ];

  bool _hideCostPrice = false; // Trạng thái ẩn/hiện giá vốn

  // --- HÀM XỬ LÝ LOGIC ---

  // Thêm 10 dòng rỗng
  void _addTenRows() {
    setState(() {
      for (int i = 0; i < 10; i++) {
        _items.add({"name": "", "unit": "Cái", "price": "0", "cost": "0"});
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
                  onPressed: () {
                    // Logic lưu data ở đây
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Hoàn tất", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          // Tên sản phẩm
          Expanded(
            flex: 3,
            child: _buildTextField(_items[index]['name'], "Nhập tên"),
          ),
          _verticalDivider(),
          // Đơn vị
          Expanded(
            flex: 1,
            child: Center(child: Text(_items[index]['unit'], style: const TextStyle(fontSize: 13))),
          ),
          _verticalDivider(),
          // Giá bán
          Expanded(
            flex: 2,
            child: _buildTextField(_items[index]['price'], "0", isNumber: true),
          ),
          if (!_hideCostPrice) ...[
            _verticalDivider(),
            // Giá vốn
            Expanded(
              flex: 2,
              child: _buildTextField(_items[index]['cost'], "0", isNumber: true),
            ),
          ]
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(width: 0.5, height: 40, color: Colors.grey.shade300);

  Widget _buildTextField(String initVal, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        initialValue: initVal,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}