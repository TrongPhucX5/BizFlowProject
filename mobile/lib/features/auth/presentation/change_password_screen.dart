import 'package:flutter/material.dart';
import 'package:mobile/common/widgets/CustomTextField.dart';
import 'package:mobile/common/widgets/PrimaryButton.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthRepository _authRepository = AuthRepository();
  
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _handleChangePassword() async {
    FocusScope.of(context).unfocus();

    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin", Colors.orange);
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar("Mật khẩu mới phải có ít nhất 6 ký tự", Colors.orange);
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar("Mật khẩu xác nhận không khớp", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.changePassword(oldPass, newPass);
      if (mounted) {
        _showSnackBar("Đổi mật khẩu thành công!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi mật khẩu"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CustomTextField(
                label: "Mật khẩu hiện tại",
                hintText: "••••••",
                prefixIcon: Icons.lock_outline,
                controller: _oldPasswordController,
                isPassword: true,
                isPasswordVisible: _isOldPasswordVisible,
                onVisibilityToggle: () {
                  setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Mật khẩu mới",
                hintText: "•••••• (Tối thiểu 6 ký tự)",
                prefixIcon: Icons.vpn_key_outlined,
                controller: _newPasswordController,
                isPassword: true,
                isPasswordVisible: _isNewPasswordVisible,
                onVisibilityToggle: () {
                  setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Xác nhận mật khẩu mới",
                hintText: "••••••",
                prefixIcon: Icons.check_circle_outline,
                controller: _confirmPasswordController,
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                onVisibilityToggle: () {
                  setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "Lưu thay đổi",
                isLoading: _isLoading,
                onPressed: _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}