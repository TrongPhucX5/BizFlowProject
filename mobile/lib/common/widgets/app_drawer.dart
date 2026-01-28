import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/report/presentation/report_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthRepository _authRepository = AuthRepository();
  String _userName = 'Người dùng';
  String _userRole = '';

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
          _userName = userData['fullName'] ?? 'Người dùng';
          _userRole = _mapRole(userData['role'] ?? '');
        });
      }
    } catch (e) {
      print('Lỗi load user drawer: $e');
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
    
    return Drawer(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: primaryBlue,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_userRole.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _userRole,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== BODY =====
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Báo cáo - Mới thêm
                _drawerItem(
                  icon: Icons.bar_chart,
                  title: "Báo cáo",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    );
                  },
                ),
                
                const Divider(),
                
                _drawerItem(
                  icon: Icons.support_agent,
                  title: "Hỗ trợ",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _drawerItem(
                  icon: Icons.menu_book,
                  title: "Hướng dẫn",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _drawerItem(
                  icon: Icons.groups,
                  title: "Cộng đồng",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                _drawerItem(
                  icon: Icons.store_mall_directory,
                  title: "Cài đặt cửa hàng",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _drawerItem(
                  icon: Icons.card_membership,
                  title: "Gói đang sử dụng",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _drawerItem(
                  icon: Icons.person,
                  title: "Cài đặt cá nhân",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                // ===== LOGOUT =====
                _drawerItem(
                  icon: Icons.logout,
                  title: "Đăng xuất",
                  isDanger: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ITEM =================
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? Colors.red : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  // ================= CONFIRM LOGOUT =================
  void _confirmLogout(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi BizFlow không?',
        ),
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
