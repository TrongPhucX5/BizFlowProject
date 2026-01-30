import 'package:flutter/material.dart';
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
  final GlobalKey<ProductScreenState> _productScreenKey = GlobalKey<ProductScreenState>();

  void setTabIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToInventory() {
    setState(() {
      _selectedIndex = 2; // Chọn tab Sản phẩm
    });
    // Đợi UI render xong rồi mới gọi chuyển Tab con
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productScreenKey.currentState?.switchToInventoryTab();
    });
  }

  void navigateToLowStock() {
    setState(() {
      _selectedIndex = 2; // Chọn tab Sản phẩm
    });
    // Đợi UI render xong rồi mới gọi chuyển sang chế độ lọc hàng sắp hết
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productScreenKey.currentState?.switchToLowStock();
    });
  }



  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const ManagementScreen(), // Index 0
      const OrderScreen(),      // Index 1
      ProductScreen(key: _productScreenKey), // Index 2
      const CustomerScreen(),   // Index 3
      const ProfileScreen(),    // Index 4
    ];
  }


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
        selectedItemColor: const Color(0xFF2563EB), // Unified Primary Blue
        unselectedItemColor: Colors.grey,
        onTap: (index) => setTabIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Quản lý'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Sản phẩm'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
    );
  }
}


