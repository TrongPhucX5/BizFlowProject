import 'package:flutter/material.dart';
// 1. Import Màn hình Bán hàng
import 'package:mobile/features/Sales/presentation/sales_screen.dart';
// 2. Import Màn hình Đơn hàng (Cực kỳ quan trọng, thiếu dòng này là lỗi)
import 'package:mobile/features/order/presentation/order_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- SỬA LẠI DANH SÁCH NÀY ---
  final List<Widget> _widgetOptions = <Widget>[
    // Vị trí 0: Bán hàng
    const SalesScreen(),

    // Vị trí 1: Đơn hàng (Anh kiểm tra kỹ dòng này nhé)
    const OrderScreen(),

    // Vị trí 2: Sản phẩm (Cái icon màu xanh lá cây hiện tại của anh đang nằm ở đây)
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.green),
          SizedBox(height: 10),
          Text('Quản lý Sản phẩm', style: TextStyle(fontSize: 18)),
        ],
      ),
    ),

    // Vị trí 3: Khách hàng
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt, size: 64, color: Colors.orange),
          SizedBox(height: 10),
          Text('Quản lý Khách hàng', style: TextStyle(fontSize: 18)),
        ],
      ),
    ),

    // Vị trí 4: Cá nhân
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.blue),
          SizedBox(height: 10),
          Text('Cá nhân & Cài đặt', style: TextStyle(fontSize: 18)),
        ],
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body sẽ lấy widget theo index tương ứng
      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Quan trọng vì có 5 tab
        items: const <BottomNavigationBarItem>[
          // 0
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Bán hàng'),
          // 1 (Phải khớp với vị trí OrderScreen ở trên)
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
          // 2
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Sản phẩm'),
          // 3
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
          // 4
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}