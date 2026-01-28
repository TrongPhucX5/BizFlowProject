import 'package:flutter/material.dart';

class SubscriptionPlanScreen extends StatelessWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Gói dịch vụ'),
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
              'Chọn gói dịch vụ phù hợp',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nâng cấp để trải nghiệm các tính năng thông minh hơn.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Gói Free
            _buildPlanCard(
              context,
              title: 'Gói Miễn Phí (Free)',
              price: '0đ',
              description: 'Dành cho hộ kinh doanh nhỏ mới bắt đầu.',
              features: [
                'Quản lý tối đa 50 sản phẩm',
                'Tạo đơn hàng thủ công',
                'Báo cáo doanh thu cơ bản',
                'Hỗ trợ qua Email',
              ],
              isCurrent: true,
              color: Colors.grey[700]!,
            ),
            
            const SizedBox(height: 16),
            
            // Gói Pro
            _buildPlanCard(
              context,
              title: 'Gói BizFlow Pro',
              price: '199.000đ / tháng',
              description: 'Giải pháp toàn diện cho tăng trưởng.',
              features: [
                'Không giới hạn sản phẩm',
                'Sử dụng AI tạo đơn từ hình ảnh',
                'Báo cáo phân tích chuyên sâu',
                'Hỗ trợ ưu tiên 24/7',
                'Quản lý đa nền tảng',
              ],
              isCurrent: false,
              isComingSoon: true,
              color: primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required bool isCurrent,
    bool isComingSoon = false,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: const Text('GÓI ĐANG DÙNG', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Divider(height: 32),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: color),
                const SizedBox(width: 10),
                Text(f, style: const TextStyle(fontSize: 14)),
              ],
            ),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isComingSoon ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey[200] : color,
                foregroundColor: isCurrent ? Colors.grey[700] : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isComingSoon ? 'ĐANG PHÁT TRIỂN' : (isCurrent ? 'ĐÃ KÍCH HOẠT' : 'NÂNG CẤP NGAY'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
