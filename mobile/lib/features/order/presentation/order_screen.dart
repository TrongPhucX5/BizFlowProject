import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/order/presentation/payment_screen.dart';
import 'package:mobile/features/order/presentation/ai_order_screen.dart';
import 'package:mobile/features/order/presentation/manual_order_screen.dart';
import 'package:mobile/data/repositories/order_repository.dart';
import 'package:mobile/features/order/presentation/print_order_screen.dart';
import 'package:mobile/features/order/presentation/order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  bool _isLoading = false;
  
  // Filtering
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Hôm nay', 'Tuần này', 'Tháng này', 'Tùy chọn'];
  DateTime? _startDate;
  DateTime? _endDate;

  // Data
  List<Map<String, dynamic>> _orders = [];
  Map<String, List<Map<String, dynamic>>> _groupedOrders = {};

  // Search
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      _calculateDateRange();
      final data = await _orderRepository.getOrders(startDate: _startDate, endDate: _endDate);
      
      // Sort: Newest -> Oldest
      data.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      setState(() {
        _orders = data;
        _groupOrdersByDate();
      });
    } catch (e) {
      print("Lỗi tải đơn hàng: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateDateRange() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Hôm nay':
        _startDate = now;
        _endDate = now;
        break;
      case 'Tuần này':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'Tháng này':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Tùy chọn':
        // Keep existing _startDate/_endDate or if null default to month
        if (_startDate == null) {
             _startDate = DateTime(now.year, now.month, 1);
             _endDate = DateTime(now.year, now.month + 1, 0);
        }
        break;
      default: // Tất cả
        _startDate = null;
        _endDate = null;
    }
  }

  void _groupOrdersByDate() {
    _groupedOrders = {};
    final query = _searchController.text.toLowerCase();

    for (var order in _orders) {
      if (_isSearching && query.isNotEmpty) {
        final code = (order['orderCode'] ?? '').toLowerCase();
        final name = (order['customerName'] ?? '').toLowerCase();
        if (!code.contains(query) && !name.contains(query)) continue;
      }

      final dateStr = order['createdAt'] ?? DateTime.now().toString();
      final date = DateTime.parse(dateStr);
      final key = DateFormat('dd/MM/yyyy').format(date);
      
      if (!_groupedOrders.containsKey(key)) {
        _groupedOrders[key] = [];
      }
      _groupedOrders[key]!.add(order);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null 
          ? DateTimeRange(start: _startDate!, end: _endDate!) 
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedFilter = 'Tùy chọn';
      });
      _fetchOrders();
    }
  }

  void _onFilterChanged(String filter) {
    if (filter == 'Tùy chọn') {
      _selectDateRange();
    } else {
      setState(() {
        _selectedFilter = filter;
        _startDate = null; 
        _endDate = null;
      });
      _fetchOrders();
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
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tìm theo mã hoặc tên khách...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38),
              ),
              onChanged: (_) => setState(() => _groupOrdersByDate()),
            )
          : const Text('Quản lý đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black54), 
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _groupOrdersByDate();
                } else {
                  _isSearching = true;
                }
              });
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildActionPanel(),
                _buildFilterBar(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                ? _buildEmptyState()
                : _buildGroupedOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter, style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )),
            selected: isSelected,
            onSelected: (_) => _onFilterChanged(filter),
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.transparent)),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildActionPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              "Tạo đơn", 
              "Bán hàng",
              Icons.post_add_rounded, 
              Colors.blue, 
              _navigateToManualOrder,
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureCard(
              "AI Scan", 
              "Tự động",
              Icons.qr_code_scanner_rounded, 
              Colors.indigo, 
              _navigateToAiOrder,
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureCard(
              "Thu nợ", 
              "Thanh toán",
              Icons.attach_money_rounded, 
              Colors.teal, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedOrderList() {
    final keys = _groupedOrders.keys.toList();
    
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final dateKey = keys[index];
          final orders = _groupedOrders[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateKey),
              ...orders.map((order) => _buildOrderItem(order)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    // Check if Today/Yesterday
    String displayDate = date;
    final now = DateTime.now();
    final today = DateFormat('dd/MM/yyyy').format(now);
    final yesterday = DateFormat('dd/MM/yyyy').format(now.subtract(const Duration(days: 1)));
    
    if (date == today) displayDate = "Hôm nay, $date";
    else if (date == yesterday) displayDate = "Hôm qua, $date";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        displayDate,
        style: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade600,
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final total = order['totalAmount'] ?? 0;
    final status = order['status'] ?? 'PENDING';
    final color = _getStatusColor(status);
    final time = DateFormat('HH:mm').format(DateTime.parse(order['createdAt']));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order['id']))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                 child: Icon(Icons.receipt_long_rounded, color: color, size: 24),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Text(
                             order['customerName'] ?? 'Khách lẻ', 
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                         const SizedBox(width: 8),
                         Text("${NumberFormat('#,###', 'vi_VN').format(total)} đ", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                       ],
                     ),
                     const SizedBox(height: 4),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                          Expanded(
                            child: Text(
                              "$time • ${order['orderCode'] ?? '#' + order['id'].toString()}", 
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status),
                       ],
                     )
                   ],
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(_mapStatus(status), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }



  // ... Helpers match cũ ...
  Widget _buildEmptyState() {
     return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
       Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
       const SizedBox(height: 16),
       const Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
     ]));
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
