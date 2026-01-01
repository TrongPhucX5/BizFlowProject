import 'package:flutter/material.dart';

class AttributeModalContent extends StatefulWidget {
  // Thêm tham số nhận dữ liệu cũ (nếu là sửa)
  final Map<String, dynamic>? initialData;

  const AttributeModalContent({super.key, this.initialData});

  @override
  State<AttributeModalContent> createState() => _AttributeModalContentState();
}

class _AttributeModalContentState extends State<AttributeModalContent> {
  late TextEditingController _nameController;
  late List<TextEditingController> _valueControllers;

  @override
  void initState() {
    super.initState();

    // LOGIC KHỞI TẠO DỮ LIỆU
    if (widget.initialData != null) {
      // TRƯỜNG HỢP SỬA: Điền dữ liệu cũ vào
      _nameController = TextEditingController(text: widget.initialData!['name']);

      List<String> values = List<String>.from(widget.initialData!['values']);
      _valueControllers = values.map((v) => TextEditingController(text: v)).toList();

      // Luôn đảm bảo có ít nhất 1 dòng (dù dữ liệu cũ rỗng - phòng hờ)
      if (_valueControllers.isEmpty) {
        _valueControllers.add(TextEditingController());
      }
    } else {
      // TRƯỜNG HỢP THÊM MỚI: Khởi tạo rỗng
      _nameController = TextEditingController();
      _valueControllers = [TextEditingController()];
    }
  }

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
    // Tiêu đề thay đổi tùy theo là Thêm hay Sửa
    final String title = widget.initialData != null ? "Cập nhật thuộc tính" : "Thêm thuộc tính";

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

          // Body
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

          // Footer
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
                  List<String> validValues = _valueControllers
                      .map((c) => c.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();

                  if (_nameController.text.isNotEmpty && validValues.isNotEmpty) {
                    Navigator.pop(context, {
                      'name': _nameController.text.trim(),
                      'values': validValues
                    });
                  } else {
                    Navigator.pop(context);
                  }
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