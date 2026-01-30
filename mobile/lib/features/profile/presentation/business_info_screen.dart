import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/store_repository.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreRepository _repository = StoreRepository();

  final _businessNameCtrl = TextEditingController();
  final _taxCodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // Added email

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreInfo();
  }

  Future<void> _fetchStoreInfo() async {
    try {
      final data = await _repository.getMyStore();
      if (mounted) {
        setState(() {
          _businessNameCtrl.text = data['name'] ?? '';
          _taxCodeCtrl.text = data['taxCode'] ?? '';
          _addressCtrl.text = data['address'] ?? '';
          _phoneCtrl.text = data['phone'] ?? '';
          _emailCtrl.text = data['email'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải thông tin: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _repository.updateMyStore({
        'name': _businessNameCtrl.text,
        'taxCode': _taxCodeCtrl.text,
        'address': _addressCtrl.text,
        'phone': _phoneCtrl.text,
        'email': _emailCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi lưu: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin hộ kinh doanh'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _field('Tên hộ kinh doanh', _businessNameCtrl),
                  _field('Mã số thuế', _taxCodeCtrl),
                  _field('Số điện thoại liên hệ', _phoneCtrl, type: TextInputType.phone),
                  _field('Email', _emailCtrl, type: TextInputType.emailAddress),
                  _field('Địa chỉ kinh doanh', _addressCtrl, maxLines: 2),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (v) => v!.isEmpty ? "Vui lòng nhập thông tin" : null,
      ),
    );
  }
}
