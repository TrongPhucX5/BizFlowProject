import 'package:flutter/material.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameCtrl = TextEditingController();
  final _taxCodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _businessType = 'Cửa hàng bán lẻ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin hộ kinh doanh'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('Tên hộ kinh doanh', _businessNameCtrl),
            _field('Mã số thuế', _taxCodeCtrl),
            _dropdown(),
            _field('Địa chỉ kinh doanh', _addressCtrl, maxLines: 2),

            const SizedBox(height: 24),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _businessType,
        decoration: InputDecoration(
          labelText: 'Loại hình kinh doanh',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: const [
          DropdownMenuItem(value: 'Cửa hàng bán lẻ', child: Text('Cửa hàng bán lẻ')),
          DropdownMenuItem(value: 'Dịch vụ', child: Text('Dịch vụ')),
          DropdownMenuItem(value: 'Online', child: Text('Kinh doanh online')),
        ],
        onChanged: (value) => setState(() => _businessType = value!),
      ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thông tin hộ kinh doanh')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text('Lưu thay đổi'),
    );
  }
}
