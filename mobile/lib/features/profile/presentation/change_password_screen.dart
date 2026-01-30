import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu xác nhận không khớp")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepository.changePassword(_oldPassController.text, _newPassController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công")));
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu cũ", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Nhập mật khẩu cũ" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu mới", border: OutlineInputBorder()),
                validator: (v) => v!.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("XÁC NHẬN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
