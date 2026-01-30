import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/repositories/payment_repository.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final PaymentRepository _repository = PaymentRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch payments
      final payments = await _repository.getPayments(size: 100);
      
      // Calculate total (simple sum of fetched items for now)
      double total = 0;
      for (var p in payments) {
        total += (p['amount'] ?? 0).toDouble();
      }

      setState(() {
        _payments = payments;
        _totalRevenue = total;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(amount);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sổ quỹ (Lịch sử thu)"),
        actions: [IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          // Revenue Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                const Text("Tổng thu (Danh sách hiển thị)", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(_formatCurrency(_totalRevenue), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _payments.isEmpty 
                ? const Center(child: Text("Chưa có giao dịch nào"))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _payments.length,
                    separatorBuilder: (_,__) => const Divider(),
                    itemBuilder: (ctx, index) {
                      final p = _payments[index];
                      final amount = (p['amount'] ?? 0).toDouble();
                      final method = p['paymentMethod'] ?? 'CASH';
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                        ),
                        title: Text(p['customerName'] ?? 'Khách lẻ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${_formatDate(p['createdAt'])}\n${p['notes'] ?? ''}", style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                              child: Text(method, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
