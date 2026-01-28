import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ'),
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
              'Trung tâm hỗ trợ BizFlow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chào mừng bạn đến với hệ thống quản lý kinh doanh thông minh.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Hướng dẫn sử dụng'),
            _buildSupportItem(
              'Quản lý đơn hàng',
              'Cách tạo đơn hàng thủ công hoặc sử dụng AI để nhận diện đơn hàng từ hình ảnh/văn bản.',
            ),
            _buildSupportItem(
              'Quản lý kho',
              'Hướng dẫn nhập kho, kiểm kê và theo dõi biến động tồn kho.',
            ),
            _buildSupportItem(
              'Báo cáo',
              'Cách xem biểu đồ doanh thu, lợi nhuận và hiệu suất bán hàng theo thời gian.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Liên hệ hỗ trợ'),
            const Text(
              'Nếu gặp sự cố kỹ thuật, vui lòng gửi email về: admin@bizflow.com.',
              style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildSupportItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
