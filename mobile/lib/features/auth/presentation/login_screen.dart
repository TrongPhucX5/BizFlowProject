import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/widgets/CustomTextField.dart';
import 'package:mobile/common/widgets/PrimaryButton.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/features/home/presentation/main_screen.dart';
import 'package:mobile/features/auth/presentation/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập tên đăng nhập và mật khẩu"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Sử dụng pushAndRemoveUntil để xóa hết các màn hình trước đó (như Logout)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false, // Xóa hết stack
        );
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo Section
                const Icon(Icons.store, size: 80, color: primaryBlue),
                const SizedBox(height: 16),
                const Text(
                  "BizFlow",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "BizFlow Workspace",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.w700, color: primaryBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hệ thống quản trị nội bộ",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // 2. Username
                CustomTextField(
                  label: "Tên đăng nhập / Email",
                  hintText: "Nhập email hoặc tên đăng nhập",
                  prefixIcon: Icons.person_outline,
                  controller: _usernameController,
                ),
                const SizedBox(height: 20),

                // 3. Password
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Mật khẩu",
                  hintText: "••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
                
                const SizedBox(height: 32),

                // 4. Login Button
                PrimaryButton(
                  text: "Đăng nhập",
                  isLoading: _isLoading,
                  onPressed: _login,
                ),

                const SizedBox(height: 24),

                // 5. Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Chưa có tài khoản? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const RegisterScreen())
                      ),
                      child: Text(
                        "Đăng ký ngay",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
