import 'package:flutter/material.dart';
import 'package:mobile/features/Sales/presentation/sales_screen.dart';
import 'package:mobile/features/order/presentation/order_screen.dart';
import 'package:mobile/features/product/presentation/product_screen.dart';
import 'package:mobile/features/home/presentation/management_screen.dart';
import 'package:mobile/features/customer/presentation/customer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Hàm static này cực kỳ quan trọng để các trang con có thể gọi
  static _MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainScreenState>();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Hàm đổi Tab từ bên ngoài
  void setTabIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Danh sách Widget phải khớp số lượng với BottomNavigationBar (6 items)
  final List<Widget> _widgetOptions = <Widget>[
    const ManagementScreen(), // Index 0
    const SalesScreen(),      // Index 1
    const OrderScreen(),      // Index 2
    const ProductScreen(),    // Index 3
    const CustomerScreen(),   // Index 4:
    const Center(child: Text('Trang Cá nhân')),   // Index 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để khi chuyển tab không bị load lại trang từ đầu
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700], // Chỉnh màu xanh cho giống mẫu của bạn
        unselectedItemColor: Colors.grey,
        onTap: (index) => setTabIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Quản lý'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Bán hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Sản phẩm'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
    );
  }
}