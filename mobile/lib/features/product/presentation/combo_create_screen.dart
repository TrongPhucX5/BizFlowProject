import 'package:flutter/material.dart';

class ComboCreateScreen extends StatefulWidget {
  // Nhận danh sách sản phẩm từ màn hình trước
  final List<Map<String, dynamic>> availableProducts;

  const ComboCreateScreen({super.key, required this.availableProducts});

  @override
  State<ComboCreateScreen> createState() => _ComboCreateScreenState();
}

class _ComboCreateScreenState extends State<ComboCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Danh sách sản phẩm đã được chọn vào Combo
  List<Map<String, dynamic>> _selectedProducts = [];

  void _openProductSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.9,
            builder: (_, scrollController) {
              return Column(
                children: [
                  AppBar(
                    title: const Text("Chọn sản phẩm"),
                    leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: widget.availableProducts.length,
                      separatorBuilder: (_,__) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = widget.availableProducts[index];
                        // Kiểm tra xem sản phẩm này đã được chọn chưa
                        final isSelected = _selectedProducts.any((p) => p == product);

                        return CheckboxListTile(
                          title: Text(product['name'] ?? ''),
                          subtitle: Text("${product['price']} đ"),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedProducts.add(product);
                              } else {
                                _selectedProducts.remove(product);
                              }
                            });
                            Navigator.pop(context); // Đóng modal để refresh UI cha (hoặc dùng StatefulBuilder trong modal)
                            _openProductSelector(); // Mở lại để chọn tiếp (cách đơn giản)
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _saveCombo() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên Combo")));
      return;
    }
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ít nhất 1 sản phẩm")));
      return;
    }

    // Đóng gói dữ liệu combo trả về
    final comboData = {
      'name': _nameController.text,
      'price': _priceController.text, // Giá bán combo
      'products': _selectedProducts,
      'isCombo': true,
    };

    Navigator.pop(context, comboData);
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xff289ca7);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo nhóm bán kèm (Combo)"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tên Combo *", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Ví dụ: Combo Mùa Hè")),
                  const SizedBox(height: 20),

                  const Text("Giá bán Combo", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Nhập giá trọn gói")),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sản phẩm trong combo", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _openProductSelector,
                        icon: const Icon(Icons.add),
                        label: const Text("Thêm sản phẩm"),
                      )
                    ],
                  ),

                  // List sản phẩm đã chọn
                  if (_selectedProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: const Text("Chưa chọn sản phẩm nào", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ..._selectedProducts.map((p) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p['name']),
                      subtitle: Text("${p['price']} đ"),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _selectedProducts.remove(p)),
                      ),
                    )).toList(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveCombo,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
                child: const Text("Lưu Combo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}