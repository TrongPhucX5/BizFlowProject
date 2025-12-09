import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../home/presentation/main_screen.dart'; // Import màn hình chính để chuyển trang

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // Hàm xử lý đăng nhập (Hiện tại là test kết nối trước)
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // 1. Gọi API test kết nối (Sau này thay bằng API /login thật)
      // Gọi vào /users vì API này đang mở public
      await DioClient.instance.get('/users');

      if (mounted) {
        // 2. Nếu kết nối OK thì chuyển sang màn hình chính
        // pushReplacement: Xóa màn hình Login khỏi lịch sử để không back lại được
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Lỗi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi kết nối server: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BizFlow Login"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc Icon
              const Icon(Icons.store_mall_directory_rounded, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),

              const Text(
                  "BizFlow Mobile",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey)
              ),
              const Text(
                "Dành cho nhân viên bán hàng",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // Nút đăng nhập
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity, // Nút rộng full màn hình
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text(
                      "Đăng nhập vào hệ thống",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Phiên bản Demo v1.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}