import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/home/presentation/main_screen.dart';
<<<<<<< HEAD
=======
<<<<<<< HEAD
// sales (POS)
=======
>>>>>>> ffc0dc1206b1cabcb15caeb053411f8b8d1c50ea
>>>>>>> 1f7ef7d (Update mobile and backend)
import 'package:mobile/features/Sales/presentation/sales_screen.dart';
import 'package:mobile/features/order/presentation/order_screen.dart'; // Đổi đường dẫn nếu bạn lưu chỗ khác
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
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/sales': (context) => const SalesScreen(),
        '/order': (context) => const OrderScreen(),
      },
    );
  }
}