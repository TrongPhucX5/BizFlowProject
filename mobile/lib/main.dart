import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';
import 'package:flutter/widgets.dart';

// Phải thêm 'async' và gọi 'ensureInitialized'
void main() async {
  // 1. Dòng này bắt buộc phải gọi khi sử dụng các plugin (như shared_preferences)
  WidgetsFlutterBinding.ensureInitialized();

  print("App bắt đầu chạy...");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BizFlow Mobile',
      debugShowCheckedModeBanner: false, // Tắt cái chữ DEBUG ở góc
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}