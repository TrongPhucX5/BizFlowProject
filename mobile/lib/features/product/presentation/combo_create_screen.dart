import 'package:flutter/material.dart';

class ComboCreateScreen extends StatefulWidget {
  const ComboCreateScreen({super.key});

  @override
  State<ComboCreateScreen> createState() => _ComboCreateScreenState();
}

class _ComboCreateScreenState extends State<ComboCreateScreen> {
  // --- KHAI BÁO BIẾN ---
  final Color kPrimaryGreen = const Color(0xff289ca7);
  final Color kBlueButton = const Color(0xFF2F80ED); // Màu xanh dương giống ảnh

  // Controller tên nhóm
  final TextEditingController _groupNameController = TextEditingController();

  // Danh sách các tùy chọn đã thêm (Lưu tạm vào List)
  final List<Map<String, dynamic>> _options = [];

  // Các biến checkbox cài đặt
  bool _isRequired = false;      // Bắt buộc chọn
  bool _allowMultiple = false;   // Chọn nhiều
  bool _allowQuantity = false;   // Chọn số lượng nhiều

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  // --- HÀM HIỆN MODAL THÊM TÙY CHỌN (Giống ảnh 2) ---
  void _showAddOptionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOptionModal(
        onAdd: (name, price, cost) {
          setState(() {
            _options.add({
              'name': name,
              'price': price,
              'cost': cost,
            });
          });
          Navigator.pop(context); // Đóng modal sau khi thêm
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Nền xám nhẹ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Tạo nhóm bán kèm", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KHỐI NHẬP TÊN NHÓM (Nền trắng)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: "Tên nhóm bán kèm ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            children: [TextSpan(text: "*", style: TextStyle(color: Colors.red))],
                          ),
                        ),
                        TextField(
                          controller: _groupNameController,
                          decoration: const InputDecoration(
                            hintText: "Ví dụ: Trân châu",
                            hintStyle: TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                            // Counter text (0/20)
                            counterText: "",
                          ),
                          maxLength: 20,
                        ),
                        // Tự làm counter text nằm bên phải cho giống ảnh
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("${_groupNameController.text.length}/20", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. KHỐI THÊM TÙY CHỌN (Empty State hoặc List)
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        if (_options.isEmpty) ...[
                          // Trạng thái chưa có tùy chọn (Giống ảnh 1)
                          const Text(
                            "Thêm Tuỳ chọn đầu tiên cho nhóm ngay!\nVí dụ: Trân châu trắng",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _showAddOptionModal, // <--- Bấm nút này hiện Modal
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBlueButton,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            child: const Text("Thêm tuỳ chọn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ] else ...[
                          // Nếu đã có danh sách (Bonus thêm hiển thị danh sách)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _options.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final item = _options[index];
                              return ListTile(
                                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${item['price']} đ"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setState(() => _options.removeAt(index)),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _showAddOptionModal,
                            icon: const Icon(Icons.add),
                            label: const Text("Thêm tuỳ chọn khác"),
                          )
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. KHỐI CÀI ĐẶT (Checkbox)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Cài đặt nhóm bán kèm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 8),

                        _buildCheckboxRow("Bắt buộc phải chọn tuỳ chọn?", _isRequired, (v) => setState(() => _isRequired = v!)),
                        const Divider(height: 1),
                        _buildCheckboxRow("Có thể chọn nhiều tuỳ chọn cùng lúc?", _allowMultiple, (v) => setState(() => _allowMultiple = v!)),
                        const Divider(height: 1),
                        _buildCheckboxRow("Thêm số lượng nhiều cho 1 tuỳ chọn?", _allowQuantity, (v) => setState(() => _allowQuantity = v!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 4. FOOTER (Nút Tiếp tục)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: null, // Disabled (xám) như trong ảnh, khi nào validate xong thì enable
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Tiếp tục", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget checkbox custom cho giống layout
  Widget _buildCheckboxRow(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54))),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: kPrimaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// CLASS MODAL THÊM TÙY CHỌN (Giống ảnh 2)
// =======================================================
class _AddOptionModal extends StatefulWidget {
  final Function(String name, String price, String cost) onAdd;
  const _AddOptionModal({required this.onAdd});

  @override
  State<_AddOptionModal> createState() => _AddOptionModalState();
}

class _AddOptionModalState extends State<_AddOptionModal> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Cho modal full chiều cao hoặc tự co giãn
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView( // Để cuộn khi bàn phím hiện
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Modal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text("Thêm tuỳ chọn mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên tùy chọn
                  _buildLabel("Tên tùy chọn *"),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: "Ví dụ: Trân châu trắng",
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)), // Viền xanh khi focus
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Giá bán & Giá vốn
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Giá bán *"),
                            TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Giá vốn"),
                            TextFormField(
                              controller: _costCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Footer Buttons (Quay lại / Tạo)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.black26),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("Quay lại", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Logic đơn giản: Có tên và giá thì mới cho tạo
                            if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                              widget.onAdd(_nameCtrl.text, _priceCtrl.text, _costCtrl.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200], // Mặc định xám (chưa validate)
                            foregroundColor: Colors.black54, // Chữ xám
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("Tạo", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text.replaceAll("*", ""),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16), // Màu xanh lá như ảnh
        children: const [TextSpan(text: " *", style: TextStyle(color: Colors.red))],
      ),
    );
  }
}