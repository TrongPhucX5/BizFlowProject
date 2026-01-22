import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/widgets/CustomTextField.dart';
import 'package:mobile/common/widgets/PrimaryButton.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/features/home/presentation/main_screen.dart';
import 'package:mobile/features/home/presentation/management_screen.dart';
import 'package:mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:mobile/features/auth/presentation/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
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
        const SnackBar(
          content: Text("Vui lòng nhập tên đăng nhập và mật khẩu"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authRepository.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Lưu token vào Secure Storage
      if (result['token'] != null) {
        await _storage.write(key: 'accessToken', value: result['token']);
      }
      if (result['refreshToken'] != null) {
        await _storage.write(key: 'refreshToken', value: result['refreshToken']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
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

                // 5. Or Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(child: Divider()),
                    const SizedBox(width: 16),
                    const Text("Chưa có tài khoản? "),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text("Đăng ký ngay", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Google Sign-In
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 18),
                  label: Text(
                    "Đăng nhập bằng Google",
                    style: GoogleFonts.poppins(
                        color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),

                // 7. Footer: Forgot Password & Register
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: GoogleFonts.poppins(
                              color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Chưa có tài khoản? Đăng ký",
                          style: GoogleFonts.poppins(
                              color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
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
