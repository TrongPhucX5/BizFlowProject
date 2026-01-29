import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/order/presentation/payment_screen.dart';
import 'package:mobile/features/order/presentation/ai_order_screen.dart';
import 'package:mobile/features/order/presentation/manual_order_screen.dart';
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

  void _navigateToAiOrder() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AiOrderScreen()));
    _fetchOrders();
  }

  void _navigateToManualOrder() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ManualOrderScreen())
    );
    if (result == true) {
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, size: 22), onPressed: _fetchOrders),
        ],
      ),
      body: Column(
        children: [
          _buildActionPanel(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                ? _buildEmptyState()
                : _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              "Tạo đơn", 
              Icons.add_rounded, 
              Theme.of(context).colorScheme.primary, 
              _navigateToManualOrder
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              "AI Order", 
              Icons.auto_awesome_rounded, 
              const Color(0xFF6366F1), // Indigo instead of bright purple
              _navigateToAiOrder
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              "Thu tiền", 
              Icons.account_balance_wallet_rounded, 
              const Color(0xFF64748B), // Slate/Grey for secondary financial action
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()))
            )
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = _orders[index];
          final total = order['totalAmount'] ?? 0;
          final status = order['status'] ?? 'PENDING';
          final color = _getStatusColor(status);
          
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrintOrderScreen(orderId: order['id']))),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order['orderCode'] ?? 'Đơn #${order['id']}', 
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${NumberFormat('#,###', 'vi_VN').format(total)} đ", 
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B))
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order['customerName'] ?? 'Khách lẻ',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('dd/MM/yyyy • HH:mm').format(DateTime.parse(order['createdAt'] ?? DateTime.now().toString())),
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _mapStatus(status), 
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800, letterSpacing: 0.2)
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, size: 48, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 20),
          const Text("Chưa có đơn hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          const Text("Các đơn hàng bạn tạo sẽ xuất hiện tại đây", style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToManualOrder,
            icon: const Icon(Icons.add_rounded),
            label: const Text("Tạo đơn ngay"),
          ),
        ],
      ),
    );
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'CONFIRMED': return 'ĐÃ XÁC NHẬN';
      case 'PAID': return 'ĐÃ THANH TOÁN';
      case 'PAID_PARTIAL': return 'THANH TOÁN 1 PHẦN';
      case 'UNPAID': return 'CHƯA THANH TOÁN';
      case 'CANCELLED': return 'ĐÃ HỦY';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID': return const Color(0xFF10B981); // Emerald
      case 'CONFIRMED': return const Color(0xFF3B82F6); // Blue
      case 'CANCELLED': return const Color(0xFFEF4444); // Red
      case 'UNPAID': return const Color(0xFFF59E0B); // Amber
      default: return const Color(0xFF64748B); // Slate
    }
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}
