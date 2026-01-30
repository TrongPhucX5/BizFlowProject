import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/repositories/order_repository.dart';
import 'package:mobile/data/repositories/debt_repository.dart';
import 'package:mobile/features/order/presentation/order_detail_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderRepository _orderRepository = OrderRepository();
  final DebtRepository _debtRepository = DebtRepository();

  bool _isLoadingHistory = false;
  bool _isLoadingDebts = false;
  List<Map<String, dynamic>> _orderHistory = [];
  List<Map<String, dynamic>> _debtHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchHistory();
    _fetchDebts();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final customerId = int.parse(widget.customer['id'].toString());
      final orders = await _orderRepository.getOrders(customerId: customerId, size: 50);
      if (mounted) setState(() => _orderHistory = orders);
    } catch (e) {
      print("Lỗi tải lịch sử đơn hàng: $e");
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _fetchDebts() async {
    setState(() => _isLoadingDebts = true);
    try {
      final customerId = int.parse(widget.customer['id'].toString());
      final debts = await _debtRepository.getDebts(customerId: customerId);
      if (mounted) setState(() => _debtHistory = debts);
    } catch (e) {
      print("Lỗi tải lịch sử công nợ: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDebts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.customer['name'] ?? 'Chi tiết khách hàng'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Thông tin"),
            Tab(text: "Lịch sử mua"),
            Tab(text: "Công nợ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildHistoryTab(),
          _buildDebtTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final c = widget.customer;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard("Thông tin cơ bản", [
            _buildInfoRow(Icons.person, "Họ tên", c['name']),
            _buildInfoRow(Icons.phone, "Số điện thoại", c['phone'] ?? "Chưa có"),
            _buildInfoRow(Icons.email, "Email", c['email'] ?? "Chưa có"),
            _buildInfoRow(Icons.location_on, "Địa chỉ", c['address'] ?? "Chưa có"),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard("Thống kê", [
            _buildInfoRow(Icons.shopping_bag, "Tổng đơn hàng", "${c['totalOrders'] ?? 0}"),
            _buildInfoRow(Icons.monetization_on, "Tổng tiền mua", _formatCurrency(c['totalPurchaseAmount'])),
            _buildInfoRow(Icons.account_balance_wallet, "Nợ hiện tại", _formatCurrency(c['totalDebt']), 
                valueColor: (c['totalDebt'] ?? 0) > 0 ? Colors.red : Colors.green),
          ]),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) return const Center(child: CircularProgressIndicator());
    if (_orderHistory.isEmpty) return _buildEmptyState("Chưa có đơn hàng nào");

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orderHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _orderHistory[index];
        final status = order['status'] ?? 'PENDING';
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order['id']))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("#${order['orderCode'] ?? order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Ngày: ${_formatDate(order['createdAt'])}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatCurrency(order['totalAmount']), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildStatusBadge(status),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebtTab() {
    if (_isLoadingDebts) return const Center(child: CircularProgressIndicator());
    if (_debtHistory.isEmpty) return _buildEmptyState("Không có ghi nhận công nợ");

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _debtHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final debt = _debtHistory[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mã nợ: #${debt['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Ngày tạo: ${_formatDate(debt['createdAt'])}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (debt['note'] != null) ...[
                     const SizedBox(height: 4),
                     Text("${debt['note']}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                  ]
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatCurrency(debt['amount']), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Còn thiếu: ${_formatCurrency((debt['amount'] ?? 0) - (debt['paidAmount'] ?? 0))}", style: const TextStyle(fontSize: 12, color: Colors.orange)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text((value ?? "Chưa có").toString(), style: TextStyle(fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String text = status;
    switch (status) {
      case 'COMPLETED': color = Colors.green; text = "Hoàn thành"; break;
      case 'PENDING': color = Colors.orange; text = "Chờ xử lý"; break;
      case 'CANCELLED': color = Colors.red; text = "Đã hủy"; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(color: Colors.grey)),
    ]));
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0 đ";
    final val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(val);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
