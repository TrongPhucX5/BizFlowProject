import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF27AE60),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.store,
                    size: 30,
                    color: Color(0xFF27AE60),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "MinhDung",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Chip(
                        label: Text(
                          "Gói chuyên nghiệp",
                          style: TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
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
