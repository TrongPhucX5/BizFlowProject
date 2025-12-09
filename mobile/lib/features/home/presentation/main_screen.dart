import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Chỉ số tab đang chọn (Mặc định là 0 - Trang chủ/POS)
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với các tab
  // (Tạm thời dùng Placeholder để giữ chỗ, sau này sẽ thay bằng màn hình thật)
  static const List<Widget> _widgetOptions = <Widget>[
    PlaceholderTab(title: 'Bán hàng tại quầy (POS)', icon: Icons.point_of_sale, color: Colors.blue),
    PlaceholderTab(title: 'Quản lý Sản phẩm', icon: Icons.inventory_2, color: Colors.green),
    PlaceholderTab(title: 'Quản lý Khách hàng', icon: Icons.people_alt, color: Colors.orange),
    PlaceholderTab(title: 'Cá nhân & Cài đặt', icon: Icons.person, color: Colors.purple),
  ];

  // Hàm xử lý khi bấm vào tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar phía trên
      appBar: AppBar(
        title: const Text('BizFlow Mobile'),
        centerTitle: false, // Để tiêu đề lệch trái cho hiện đại
        automaticallyImplyLeading: false, // Ẩn nút back vì đây là màn hình chính
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Thêm nút thông báo demo (Firebase sau này)
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Chưa có thông báo mới!")),
              );
            },
          )
        ],
      ),

      // Nội dung chính giữa (Thay đổi theo tab)
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      // Thanh menu dưới đáy
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.point_of_sale),
            icon: Icon(Icons.point_of_sale_outlined),
            label: 'Bán hàng',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.inventory_2),
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.people_alt),
            icon: Icon(Icons.people_alt_outlined),
            label: 'Khách hàng',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

// --- Widget giữ chỗ tạm thời (Demo cho đẹp) ---
class PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const PlaceholderTab({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: color.withOpacity(0.5)),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Chức năng này đang được phát triển...",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}