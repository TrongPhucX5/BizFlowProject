import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/home/presentation/main_screen.dart';
import 'package:mobile/features/Sales/presentation/sales_screen.dart';
import 'package:mobile/features/order/presentation/order_screen.dart';
import 'package:mobile/features/product/presentation/product_screen.dart';
import 'package:mobile/features/home/presentation/management_screen.dart';

void main() {
  runApp(const BizFlowApp());
}

class BizFlowApp extends StatelessWidget {
  const BizFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BizFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Màn hình đầu tiên khi mở app
      home: const LoginScreen(),

      // Định nghĩa các tuyến đường (Routes) để tiện gọi tên
      routes: {
        '/management': (context) => const ManagementScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/sales': (context) => const SalesScreen(),
        '/order': (context) => const OrderScreen(),
        '/product': (context) => const ProductScreen(),
      },
    );
  }
}