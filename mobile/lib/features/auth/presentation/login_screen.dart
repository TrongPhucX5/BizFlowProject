import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/widgets/CustomTextField.dart'; // Import Component
import 'package:mobile/common/widgets/PrimaryButton.dart';   // Import Component
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/features/home/presentation/main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Thư viện Google
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Icon Google
import 'package:mobile/features/home/presentation/management_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Log để kiểm tra thông tin nhận về
        debugPrint("User: ${googleUser.displayName} - Email: ${googleUser.email}");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManagementScreen()),
          );
        }
      }
    } catch (error) {
      debugPrint("Lỗi Google Sign-In: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'admin';
    _passwordController.text = '123456';
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authRepository.login(
        _usernameController.text,
        _passwordController.text,
      );

      await _storage.write(key: 'jwt_token', value: result['jwt']);
      await _storage.write(key: 'user_role', value: result['role']);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo Section
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "BizFlow Workspace",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: primaryBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hệ thống quản trị nội bộ",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // 2. Sử dụng Component: CustomTextField cho Username
                CustomTextField(
                  label: "Tên đăng nhập",
                  hintText: "admin",
                  prefixIcon: Icons.person_outline,
                  controller: _usernameController,
                ),

                const SizedBox(height: 20),

                // 3. Sử dụng Component: CustomTextField cho Password
                CustomTextField(
                  label: "Mật khẩu",
                  hintText: "••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // 4. Sử dụng Component: PrimaryButton
                PrimaryButton(
                  text: "ĐĂNG NHẬP HỆ THỐNG",
                  isLoading: _isLoading,
                  onPressed: _login,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Hoặc", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Nút Đăng nhập Google
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 18),
                  label: Text(
                    "Đăng nhập bằng Google",
                    style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 32),

                // 5. Footer
                Center(
                  child: Column(
                    children: [
                      Text("Quên mật khẩu hoặc chưa có tài khoản?", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Liên hệ Quản Trị Viên",
                          style: GoogleFonts.poppins(color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}