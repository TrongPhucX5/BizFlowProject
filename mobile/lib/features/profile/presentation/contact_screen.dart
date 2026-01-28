import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Liên hệ & Đội ngũ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildContactHeader(primaryBlue),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle('Hỗ trợ kỹ thuật'),
                   _buildContactCard(
                     icon: Icons.phone_in_talk,
                     title: 'Hotline Dự án',
                     subtitle: '0892 050 212 (Trọng Phúc)',
                     color: Colors.green,
                     onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang kết nối tới Trưởng nhóm...")));
                     }
                   ),
                   _buildContactCard(
                     icon: Icons.email_outlined,
                     title: 'Email đội ngũ',
                     subtitle: 'admin@bizflow.com',
                     color: Colors.blue,
                     onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang mở ứng dụng Email...")));
                     }
                   ),
                   const SizedBox(height: 24),
                   _buildSectionTitle('Đội ngũ phát triển (Team BizFlow)'),
                   _buildTeamList(),
                   const SizedBox(height: 24),
                   _buildProjectInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        children: [
          Icon(Icons.diversity_3, size: 60, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Kết nối với chúng tôi',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Dự án BizFlow - Giải pháp quản lý thông minh cho Hộ kinh doanh vật liệu xây dựng.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamList() {
    final members = [
      'Lê Trọng Phúc (Leader)',
      'Lâm Khiêm',
      'Trần Ghi Đông',
      'Dư Nhật Anh',
      'Phạm Minh Dũng',
      'Võ Minh Quân',
      'Nguyễn Quốc Bảo',
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: members.map((name) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildProjectInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin dự án',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(
            'Hệ thống BizFlow được phát triển nhằm mục đích số hóa quy trình quản lý bán hàng, kho bãi và công nợ. Tích hợp công nghệ AI Assistant giúp tối ưu hóa hiệu suất làm việc.',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}
