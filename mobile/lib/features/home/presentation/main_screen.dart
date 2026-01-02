import 'package:flutter/material.dart';
import 'package:mobile/features/Sales/presentation/sales_screen.dart';
import 'package:mobile/features/order/presentation/order_screen.dart';
import 'package:mobile/features/product/presentation/product_screen.dart';
import 'package:mobile/features/home/presentation/management_screen.dart';
import 'package:mobile/features/customer/presentation/customer_screen.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static _MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainScreenState>();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void setTabIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    const ManagementScreen(), // Index 0
    const SalesScreen(),      // Index 1
    const OrderScreen(),      // Index 2
    const ProductScreen(),    // Index 3
    const CustomerScreen(),   // Index 4
    const ProfileScreen(),    // ✅ Cá nhân (UI mới)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
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
