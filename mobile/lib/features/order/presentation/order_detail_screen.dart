import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/repositories/order_repository.dart';
import 'print_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _repository = OrderRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    try {
      final data = await _repository.getOrderById(widget.orderId);
      setState(() {
        _order = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString().replaceAll("Exception: ", "")}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này? Hàng sẽ được hoàn lại vào kho."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("KHÔNG")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("HỦY ĐƠN")
          ),
        ],
      )
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _repository.cancelOrder(widget.orderId);
      await _fetchOrderDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã hủy đơn hàng thành công"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markAsPaid() async {
    setState(() => _isLoading = true);
    try {
      await _repository.updateOrderStatus(widget.orderId, 'PAID');
      await _fetchOrderDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã chuyển trạng thái sang Đã thanh toán"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _undoPayment() async {
    setState(() => _isLoading = true);
    try {
      await _repository.updateOrderStatus(widget.orderId, 'CONFIRMED');
      await _fetchOrderDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã hoàn tác trạng thái thanh toán"), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => PrintOrderScreen(orderId: widget.orderId)));
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text("Không tìm thấy đơn hàng"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 16),
                      _buildItemsSection(),
                      const SizedBox(height: 16),
                      _buildPaymentSection(),
                      const SizedBox(height: 16),
                       _buildNoteSection(),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionButtons() {
    final status = _order!['status'] ?? 'PENDING';
    final isCancelled = status == 'CANCELLED';
    final isPaid = status == 'PAID';

    return Column(
      children: [
        if (!isPaid && !isCancelled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _markAsPaid,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("XÁC NHẬN ĐÃ THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (isPaid) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _undoPayment,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.undo_rounded),
              label: const Text("HOÀN TÁC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (!isCancelled) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cancelOrder,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("HỦY ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PrintOrderScreen(orderId: widget.orderId)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.print),
            label: const Text("IN HÓA ĐƠN", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final status = _order!['status'] ?? 'PENDING';
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_order!['orderCode'] ?? '#${_order!['id']}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(_mapStatus(status), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.person_outline, "Khách hàng", _order!['customerName'] ?? 'Khách lẻ'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, "Số điện thoại", _order!['customerPhone'] ?? 'Không có'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, "Ngày tạo", DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(_order!['createdAt']))),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    final items = _order!['items'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['productName'] ?? item['product']?['name'] ?? 'Sản phẩm lỗi', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text("${NumberFormat('#,###', 'vi_VN').format(item['unitPrice'])} x${item['quantity']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  )
                ),
                Text("${NumberFormat('#,###', 'vi_VN').format(item['totalAmount'])} đ", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
          const Divider(),
          _buildSummaryRow("Tạm tính", _order!['subtotal']),
          if ((_order!['discountAmount'] ?? 0) > 0) 
             _buildSummaryRow("Giảm giá", -(_order!['discountAmount'] ?? 0), color: Colors.green),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TỔNG CỘNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${NumberFormat('#,###', 'vi_VN').format(_order!['totalAmount'])} đ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildPaymentSection() {
     return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.payment, "Hình thức", _order!['paymentType'] ?? 'Tiền mặt'),
          const SizedBox(height: 8),
          _buildSummaryRow("Đã thanh toán", _order!['paidAmount'] ?? 0),
          _buildSummaryRow("Còn nợ", _order!['remainingAmount'] ?? 0, color: Colors.red),
        ],
      ));
  }
  
  Widget _buildNoteSection() {
     if (_order!['notes'] == null || (_order!['notes'] as String).isEmpty) return const SizedBox.shrink();
     
     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text("Ghi chú", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
           const SizedBox(height: 4),
           Text(_order!['notes'], style: TextStyle(color: Colors.grey.shade700)),
        ],
      ));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: TextStyle(color: Colors.grey.shade600)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildSummaryRow(String label, dynamic amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text("${NumberFormat('#,###', 'vi_VN').format(amount)} đ", style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
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
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID': return Colors.green;
      case 'CONFIRMED': return Colors.blue;
      case 'CANCELLED': return Colors.red;
      case 'UNPAID': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
