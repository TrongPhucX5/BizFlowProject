import 'package:flutter/material.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  bool _darkMode = false;
  bool _autoPrint = true;
  bool _useAiAssistant = true;
  String _currency = 'VNĐ';

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Cài đặt cửa hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Giao diện'),
          _buildSettingCard(
            icon: Icons.dark_mode_outlined,
            title: 'Chế độ tối (Dark Mode)',
            subtitle: 'Chuyển đổi giao diện sáng/tối cho ứng dụng',
            trailing: Switch(
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
              activeColor: primaryBlue,
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Cấu hình bán hàng (POS)'),
          _buildSettingCard(
            icon: Icons.print_outlined,
            title: 'Tự động in hóa đơn',
            subtitle: 'In ngay sau khi hoàn tất đơn hàng',
            trailing: Switch(
              value: _autoPrint,
              onChanged: (val) => setState(() => _autoPrint = val),
              activeColor: primaryBlue,
            ),
          ),
          _buildSettingCard(
            icon: Icons.monetization_on_outlined,
            title: 'Đơn vị tiền tệ',
            subtitle: 'Hiện tại: $_currency',
            onTap: () {
               // Logic chọn tiền tệ
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Trợ lý AI'),
          _buildSettingCard(
            icon: Icons.psychology_outlined,
            title: 'Kích hoạt AI Assistant',
            subtitle: 'Cho phép hỗ trợ tạo đơn bằng giọng nói/hình ảnh',
            trailing: Switch(
              value: _useAiAssistant,
              onChanged: (val) => setState(() => _useAiAssistant = val),
              activeColor: primaryBlue,
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin cửa hàng'),
          _buildSettingCard(
            icon: Icons.storefront_outlined,
            title: 'Thông tin cơ bản',
            subtitle: 'Tên cửa hàng, địa chỉ, số điện thoại...',
            onTap: () {
               // Điều hướng đến sửa thông tin cửa hàng
            },
          ),
          _buildSettingCard(
            icon: Icons.image_outlined,
            title: 'Logo & Hình ảnh',
            subtitle: 'Thay đổi logo hiển thị trên hóa đơn',
            onTap: () {
               // Logic upload ảnh
            },
          ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'BizFlow Version 1.0.2',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey) : null),
        onTap: onTap,
      ),
    );
  }
}
