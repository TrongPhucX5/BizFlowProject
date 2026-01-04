import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'widgets/profile_section.dart';
import 'widgets/profile_grid_item.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final String userFullName = 'Pham Minh Dung';
  final String userRole = 'Business Owner';
  final String memberSince = '04/2023';
  final String servicePlan = 'BizFlow Pro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Cá nhân'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildAccountStats(),
            const SizedBox(height: 24),

            ProfileSection(
              title: 'Tài khoản',
              items: [
                ProfileGridItemData(Icons.person_outline, 'Thông tin cá nhân', Colors.blue),
                ProfileGridItemData(Icons.storefront_outlined, 'Hộ kinh doanh', Colors.deepPurple),
                ProfileGridItemData(Icons.verified_user_outlined, 'Xác thực KYC', Colors.green),
                ProfileGridItemData(Icons.email_outlined, 'Email', Colors.orange),
              ],
            ),

            ProfileSection(
              title: 'Cài đặt',
              items: [
                ProfileGridItemData(Icons.notifications_outlined, 'Thông báo', Colors.blue),
                ProfileGridItemData(Icons.lock_outline, 'Bảo mật', Colors.redAccent),
                ProfileGridItemData(Icons.face_retouching_natural, 'Face ID', Colors.teal),
                ProfileGridItemData(Icons.settings_outlined, 'Tuỳ chỉnh', Colors.grey),
              ],
            ),

            ProfileSection(
              title: 'Hỗ trợ',
              items: [
                ProfileGridItemData(Icons.help_outline, 'Trợ giúp', Colors.blue),
                ProfileGridItemData(Icons.description_outlined, 'Điều khoản', Colors.purple),
                ProfileGridItemData(Icons.privacy_tip_outlined, 'Chính sách', Colors.green),
                ProfileGridItemData(Icons.headset_mic_outlined, 'Liên hệ', Colors.orange),
              ],
            ),

            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 48, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Text(
          userFullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(userRole, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ================= ACCOUNT STATS =================
  Widget _buildAccountStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem('Gói dịch vụ', servicePlan, verified: true),
          _statItem('Thành viên từ', memberSince),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value, {bool verified = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Row(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (verified)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified, size: 16, color: Colors.blue),
              ),
          ],
        ),
      ],
    );
  }

  // ================= LOGOUT =================
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Đăng xuất'),
      ),
    );
  }

  // ================= CONFIRM DIALOG =================
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi BizFlow không?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
