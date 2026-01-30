import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/profile/presentation/change_password_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'personal_info_screen.dart';
import 'business_info_screen.dart';
import 'kyc_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_service_screen.dart';
import 'contact_screen.dart';
import 'subscription_plan_screen.dart';

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
  String servicePlan = 'Gói miễn phí';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Cá nhân'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildPlanCard(),
                const SizedBox(height: 24),
                _buildMenuSection(
                  title: 'Tài khoản',
                  items: [
                    _MenuItem(Icons.person_outline_rounded, 'Thông tin cá nhân', 'Quản lý thông tin cơ bản', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen()))),
                    _MenuItem(Icons.lock_outline, 'Đổi mật khẩu', 'Cập nhật mật khẩu tài khoản', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                    _MenuItem(Icons.storefront_rounded, 'Hộ kinh doanh', 'Cài đặt thông tin cửa hàng', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessInfoScreen()))),
                    _MenuItem(Icons.verified_user_outlined, 'Xác thực KYC', 'Tăng hạn mức giao dịch', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen()))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMenuSection(
                  title: 'Hỗ trợ & Pháp lý',
                  items: [
                    _MenuItem(Icons.help_outline_rounded, 'Trung tâm trợ giúp', 'Hướng dẫn sử dụng BizFlow', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                    _MenuItem(Icons.description_outlined, 'Điều khoản dịch vụ', 'Quyền lợi & Trách nhiệm', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()))),
                    _MenuItem(Icons.privacy_tip_outlined, 'Chính sách bảo mật', 'Cam kết bảo mật dữ liệu', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
                    _MenuItem(Icons.headset_mic_outlined, 'Liên hệ hỗ trợ', 'Yêu cầu hỗ trợ kỹ thuật', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()))),
                  ],
                ),
                const SizedBox(height: 32),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              userFullName.isNotEmpty ? userFullName[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userFullName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                child: Text(userRole, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFACC15), size: 20),
                    const SizedBox(width: 8),
                    Text(servicePlan, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Sử dụng từ: $memberSince', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPlanScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Nâng cấp', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<_MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Icon(item.icon, color: const Color(0xFF475569), size: 22),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                  ),
                  if (idx < items.length - 1)
                    const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          backgroundColor: const Color(0xFFFEF2F2),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Đăng xuất tài khoản'),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi phiên làm việc này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await _authRepository.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  _MenuItem(this.icon, this.title, this.subtitle, this.onTap);
}
