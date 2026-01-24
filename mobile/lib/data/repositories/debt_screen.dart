import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/debt_repository.dart';
import '../../features/order/presentation/payment_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final DebtRepository _repository = DebtRepository();
  bool _isLoading = false;
  List<Map<String, dynamic>> _debts = [];

  @override
  void initState() {
    super.initState();
    _fetchDebts();
  }

  Future<void> _fetchDebts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getDebts();
      setState(() => _debts = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString().replaceAll("Exception: ", "")}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0 đ";
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(amount)} đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý công nợ"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debts.isEmpty
              ? const Center(child: Text("Không có khoản nợ nào"))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _debts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _debts[index];
                    // Mapping field tùy theo response backend (unpaidAmount hoặc debtAmount)
                    final debtAmount = item['unpaidAmount'] ?? item['debtAmount'] ?? 0;
                    // Lấy customerId từ item (hoặc từ object customer lồng nhau)
                    final customerId = item['customerId'] ?? (item['customer'] != null ? item['customer']['id'] : null);
                    final customerName = item['customerName'] ?? (item['customer'] != null ? item['customer']['fullName'] : 'Khách hàng');
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade50,
                        child: const Icon(Icons.monetization_on_outlined, color: Colors.red),
                      ),
                      title: Text(
                        customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['customerPhone'] ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(debtAmount),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            "Chưa thanh toán",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (customerId != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                customerId: customerId,
                                customerName: customerName,
                                initialAmount: (debtAmount is int) ? debtAmount.toDouble() : debtAmount,
                              ),
                            ),
                          );
                          // Nếu thanh toán thành công (result == true) -> Reload danh sách nợ
                          if (result == true) {
                            _fetchDebts();
                          }
                        }
                      },
                    );
                  },
                ),
    );
  }
}