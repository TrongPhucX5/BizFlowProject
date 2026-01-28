import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chính sách bảo mật'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chính sách bảo mật BizFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chúng tôi cam kết bảo vệ dữ liệu kinh doanh của bạn.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Thu thập thông tin',
              'Chúng tôi thu thập các thông tin cơ bản như Họ tên, Email, Số điện thoại và dữ liệu liên quan đến hoạt động kinh doanh của bạn để vận hành hệ thống.',
            ),
            _buildSection(
              'Bảo mật dữ liệu',
              'Dữ liệu của bạn được mã hóa và bảo vệ bằng các công nghệ bảo mật tiên tiến, bao gồm cả xác thực đa yếu tố như Face ID.',
            ),
            _buildSection(
              'Sử dụng AI',
              'Thông tin từ hình ảnh đơn hàng bạn cung cấp cho tính năng AI sẽ chỉ được sử dụng để trích xuất dữ liệu đơn hàng và không chia sẻ cho bên thứ ba.',
            ),
            _buildSection(
              'Quyền của người dùng',
              'Bạn có quyền xem, chỉnh sửa thông tin cá nhân hoặc yêu cầu xóa dữ liệu tài khoản bất kỳ lúc nào thông qua phần cài đặt.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
