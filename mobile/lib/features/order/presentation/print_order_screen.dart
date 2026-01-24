import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/repositories/order_repository.dart';

class PrintOrderScreen extends StatefulWidget {
  final int orderId;
  const PrintOrderScreen({super.key, required this.orderId});

  @override
  State<PrintOrderScreen> createState() => _PrintOrderScreenState();
}

class _PrintOrderScreenState extends State<PrintOrderScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final OrderRepository _repository = OrderRepository();

  @override
  void initState() {
    super.initState();
    // Khởi tạo WebView Controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Tắt loading khi trang đã load xong nội dung
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );
    
    _fetchInvoiceData();
  }

  Future<void> _fetchInvoiceData() async {
    try {
      final htmlContent = await _repository.printOrder(widget.orderId);
      
      // Load HTML vào WebView
      await _controller.loadHtmlString(htmlContent);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString().replaceAll("Exception: ", "")}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("In hóa đơn"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: () {
            // TODO: Tích hợp lệnh in native nếu cần
          })
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}