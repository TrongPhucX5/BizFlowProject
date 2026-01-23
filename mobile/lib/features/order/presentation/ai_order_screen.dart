import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/ai_repository.dart';
import 'package:mobile/data/repositories/order_repository.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class AiOrderScreen extends StatefulWidget {
  const AiOrderScreen({super.key});

  @override
  State<AiOrderScreen> createState() => _AiOrderScreenState();
}

class _AiOrderScreenState extends State<AiOrderScreen> {
  final AiRepository _aiRepository = AiRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final AuthRepository _authRepository = AuthRepository();
  
  final TextEditingController _inputController = TextEditingController();
  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _selectedCustomer;
  
  bool _isAnalyzing = false;
  bool _isCreatingOrder = false;
  List<Map<String, dynamic>> _draftItems = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final data = await _authRepository.getCustomers();
    setState(() => _customers = data);
  }

  // 1. Gửi Text lên AI
  Future<void> _analyzeText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _draftItems = [];
    });

    try {
      final items = await _aiRepository.generateDraftOrder(text);
      
      // Tính tổng tiền tạm tính
      double total = 0;
      for (var item in items) {
        total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
      }

      setState(() {
        _draftItems = items;
        _totalAmount = total;
      });
      
      if (items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("AI không tìm thấy sản phẩm nào trong câu nói.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi AI: ${e.toString().replaceAll("Exception: ", "")}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // 2. Xác nhận tạo đơn (Gọi OrderRepository đã có)
  Future<void> _confirmOrder() async {
    if (_draftItems.isEmpty) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn khách hàng")));
      return;
    }

    setState(() => _isCreatingOrder = true);
    try {
      final orderData = {
        "customerId": _selectedCustomer!['id'],
        "items": _draftItems,
        "paymentMethod": "CASH",
        "totalAmount": _totalAmount,
        "status": "PENDING"
      };

      await _orderRepository.createOrder(orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo đơn hàng thành công!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Quay về màn hình trước
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tạo đơn: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo đơn bằng AI"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Customer Select
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedCustomer,
              decoration: const InputDecoration(labelText: "Khách hàng", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: _customers.map((c) => DropdownMenuItem(value: c, child: Text(c['fullName']))).toList(),
              onChanged: (val) => setState(() => _selectedCustomer = val),
              hint: const Text("Chọn khách hàng"),
            ),
          ),

          // Khu vực nhập liệu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: "VD: Bán 5 bao xi măng, 2 khối cát...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (_) => _analyzeText(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isAnalyzing ? null : _analyzeText,
                  icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send),
                )
              ],
            ),
          ),

          const Divider(height: 1),

          // Danh sách đơn nháp
          Expanded(
            child: _draftItems.isEmpty
                ? Center(
                    child: Text(
                      _isAnalyzing ? "Đang phân tích..." : "Nhập nội dung để AI soạn đơn",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _draftItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _draftItems[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                        title: Text(item['productName'] ?? 'Sản phẩm'),
                        subtitle: Text("${item['quantity']} x ${item['price']} đ"),
                        trailing: Text(
                          "${((item['quantity'] ?? 0) * (item['price'] ?? 0)).toStringAsFixed(0)} đ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),

          // Footer xác nhận
          if (_draftItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: ElevatedButton(
                onPressed: _isCreatingOrder ? null : _confirmOrder,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff289ca7), minimumSize: const Size(double.infinity, 50)),
                child: Text(_isCreatingOrder ? "Đang xử lý..." : "Xác nhận tạo đơn (${_totalAmount.toStringAsFixed(0)} đ)", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }
}