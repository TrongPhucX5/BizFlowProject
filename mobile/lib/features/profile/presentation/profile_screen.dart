import 'package:flutter/material.dart';
import 'widgets/profile_section.dart';
import 'widgets/profile_grid_item.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'personal_info_screen.dart';
import 'business_info_screen.dart';
import 'kyc_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_service_screen.dart';
import 'contact_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  
  String userFullName = 'Đang tải...';
  String userRole = '';
  String userEmail = '';
  String memberSince = '';
  String servicePlan = 'BizFlow Pro';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authRepository.getCurrentUser();
      if (userData != null && mounted) {
        setState(() {
          userFullName = userData['fullName'] ?? 'Người dùng';
          userRole = _mapRole(userData['role'] ?? 'EMPLOYEE');
          userEmail = userData['email'] ?? '';
          // Format createdAt thành tháng/năm
          if (userData['createdAt'] != null) {
            try {
              final created = DateTime.parse(userData['createdAt']);
              memberSince = '${created.month.toString().padLeft(2, '0')}/${created.year}';
            } catch (_) {
              memberSince = 'N/A';
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Lỗi load user: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return 'Quản trị viên';
      case 'OWNER': return 'Chủ cửa hàng';
      case 'EMPLOYEE': return 'Nhân viên';
      default: return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Cá nhân'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(context, primaryBlue),
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
                  onItemTap: (index) {
                    switch (index) {
                      case 0: // Thông tin cá nhân
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen()));
                        break;
                      case 1: // Hộ kinh doanh
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessInfoScreen()));
                        break;
                      case 2: // KYC
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen()));
                        break;
                      case 3: // Email - show current email
                        _showEmailInfo(context);
                        break;
                    }
                  },
                ),

                ProfileSection(
                  title: 'Cài đặt',
                  items: [
                    ProfileGridItemData(Icons.notifications_outlined, 'Thông báo', Colors.blue),
                    ProfileGridItemData(Icons.lock_outline, 'Đổi mật khẩu', Colors.redAccent),
                    ProfileGridItemData(Icons.face_retouching_natural, 'Face ID', Colors.teal),
                    ProfileGridItemData(Icons.settings_outlined, 'Tuỳ chỉnh', Colors.grey),
                  ],
                  onItemTap: (index) {
                    if (index == 1) { // Đổi mật khẩu
                      _showChangePasswordDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
                    }
                  },
                ),

                ProfileSection(
                  title: 'Hỗ trợ',
                  items: [
                    ProfileGridItemData(Icons.help_outline, 'Trợ giúp', Colors.blue),
                    ProfileGridItemData(Icons.description_outlined, 'Điều khoản', Colors.purple),
                    ProfileGridItemData(Icons.privacy_tip_outlined, 'Chính sách', Colors.green),
                    ProfileGridItemData(Icons.headset_mic_outlined, 'Liên hệ', Colors.orange),
                  ],
                  onItemTap: (index) {
                    switch (index) {
                      case 0: // Trợ giúp
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                        break;
                      case 1: // Điều khoản
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
                        break;
                      case 2: // Chính sách
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                        break;
                      case 3: // Liên hệ
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                        break;
                    }
                  },
                ),

                const SizedBox(height: 20),
                _buildLogoutButton(context, primaryBlue),
              ],
            ),
          ),
    );
  }

  void _showEmailInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Email liên kết'),
        content: Text(userEmail.isNotEmpty ? userEmail : 'Chưa liên kết email'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu cũ")),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu mới")),
            TextField(controller: confirmPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (newPassCtrl.text != confirmPassCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu xác nhận không khớp"), backgroundColor: Colors.red));
                return;
              }
              try {
                // Gọi API đổi pass
                await _authRepository.changePassword(oldPassCtrl.text, newPassCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công"), backgroundColor: Colors.green));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Đổi"),
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context, Color primaryBlue) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: primaryBlue.withOpacity(0.1),
          child: Text(
            userFullName.isNotEmpty ? userFullName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          userFullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(userRole, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        // Đã xóa nút "Chỉnh sửa hồ sơ" vì thông tin tài khoản cố định
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
          _statItem('Thành viên từ', memberSince.isNotEmpty ? memberSince : 'N/A'),
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
                child: Icon(Icons.verified, size: 16, color: Color(0xFF1565C0)),
              ),
          ],
        ),
      ],
    );
  }

  // ================= LOGOUT =================
  Widget _buildLogoutButton(BuildContext context, Color primaryBlue) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirmLogout(context, primaryBlue),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue),
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
  void _confirmLogout(BuildContext context, Color primaryBlue) {
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
            child: Text('Huỷ', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await _authRepository.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
