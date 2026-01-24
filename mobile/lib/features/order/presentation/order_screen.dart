import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/Sales/presentation/sales_screen.dart';
import 'package:mobile/features/order/presentation/payment_screen.dart';
import 'package:mobile/features/order/presentation/ai_order_screen.dart';
import 'package:mobile/data/repositories/order_repository.dart';
import 'package:mobile/features/order/presentation/print_order_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await _orderRepository.getOrders();
      setState(() => _orders = data);
    } catch (e) {
      print("Lỗi tải đơn hàng: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToSales() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesScreen()));
    if (result == true) _fetchOrders();
  }

  void _navigateToAiOrder() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AiOrderScreen()));
    _fetchOrders(); // Reload sau khi tạo đơn AI
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Color(0xff289ca7);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body: Column(
        children: [
          // Action Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: _buildActionButton("Tạo đơn", Icons.add_shopping_cart, kPrimaryColor, _navigateToSales)),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton("AI Order", Icons.mic, Colors.purple, _navigateToAiOrder)),
                const SizedBox(width: 8),
                Expanded(child: _buildActionButton("Thu tiền", Icons.attach_money, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())))),
              ],
            ),
          ),
          const Divider(height: 1),

          // Order List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                ? const Center(child: Text("Chưa có đơn hàng nào"))
                : ListView.separated(
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final total = order['totalAmount'] ?? 0;
                      final status = order['status'] ?? 'PENDING';
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.receipt_long, color: Colors.blue),
                        ),
                        title: Text(order['orderCode'] ?? 'Đơn hàng #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${order['customerName'] ?? 'Khách lẻ'} • ${DateFormat('dd/MM HH:mm').format(DateTime.parse(order['createdAt'] ?? DateTime.now().toString()))}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${NumberFormat('#,###').format(total)} đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(status, style: TextStyle(fontSize: 10, color: status == 'COMPLETED' ? Colors.green : Colors.orange)),
                          ],
                        ),
                        onTap: () {
                          // Mở màn hình in hóa đơn khi bấm vào
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PrintOrderScreen(orderId: order['id'])));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}