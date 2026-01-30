import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['fullName']);
    _phoneController = TextEditingController(text: widget.user['phone']);
    _addressController = TextEditingController(text: widget.user['address']);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authRepository.updateProfile({
        'fullName': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'taxCode': widget.user['taxCode'], 
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa hồ sơ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Địa chỉ", border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LƯU THAY ĐỔI"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
