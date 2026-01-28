import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Điều khoản sử dụng'),
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
              'Điều khoản dịch vụ BizFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cập nhật lần cuối: Tháng 01/2026',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Chấp thuận điều khoản',
              'Bằng việc đăng ký tài khoản BizFlow, bạn đồng ý tuân thủ các quy định về quản lý hộ kinh doanh và quyền hạn người dùng (Admin, Owner, Employee).',
            ),
            _buildSection(
              'Trách nhiệm tài khoản',
              'Người dùng có trách nhiệm bảo mật mật khẩu và quyền truy cập vào dữ liệu cửa hàng của mình.',
            ),
            _buildSection(
              'Gói dịch vụ',
              'BizFlow cung cấp các gói dịch vụ (như BizFlow Pro) với các giới hạn về tính năng và lưu trữ khác nhau.',
            ),
            _buildSection(
              'Chấm dứt dịch vụ',
              'Chúng tôi có quyền tạm ngừng tài khoản nếu phát hiện vi phạm quy định sử dụng hoặc có hành vi gian lận dữ liệu.',
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
