import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/widgets/CustomTextField.dart';
import 'package:mobile/common/widgets/PrimaryButton.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập email"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.forgotPassword(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Link reset mật khẩu đã được gửi đến email"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quên mật khẩu"),
        backgroundColor: primaryBlue,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  label: "Email",
                  hintText: "example@email.com",
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: "Gửi link reset mật khẩu",
                  isLoading: _isLoading,
                  onPressed: _sendResetLink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
