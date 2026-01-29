import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/order_repository.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final OrderRepository _orderRepository = OrderRepository();
  
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _selectedCustomer;
  List<Map<String, dynamic>> _cart = [];
  bool _isLoading = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCustomers();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await _authRepository.getProducts();
      setState(() => _products = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải SP: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      final data = await _authRepository.getCustomers();
      setState(() => _customers = data);
    } catch (e) {
      print("Lỗi tải khách hàng: $e");
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['id'] == product['id']);
      if (index != -1) {
        _cart[index]['quantity']++;
      } else {
        _cart.add({
          ...product,
          'quantity': 1,
          'productId': product['id'],
          'productName': product['name'],
        });
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index]['quantity'] > 1) {
        _cart[index]['quantity']--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  double get _totalAmount => _cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  Future<void> _createOrder() async {
    if (_cart.isEmpty) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn khách hàng"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderData = {
        "customerId": _selectedCustomer!['id'],
        "items": _cart.map((e) => {
          "productId": e['productId'],
          "quantity": e['quantity'],
          "price": e['price']
        }).toList(),
        "paymentMethod": "CASH",
        "totalAmount": _totalAmount,
        "status": "COMPLETED"
      };

      await _orderRepository.createOrder(orderData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanh toán thành công!"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((p) => 
      (p['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Bán hàng (POS)"),
        actions: [
          IconButton(onPressed: () => setState(() => _cart = []), icon: const Icon(Icons.refresh_rounded, size: 20)),
        ],
      ),
      body: Column(
        children: [
          _buildTopPanel(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildProductGrid(filteredProducts),
          ),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedCustomer,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: const InputDecoration(
              hintText: "Chọn khách hàng",
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
            items: _customers.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c['fullName'] ?? 'Khách hàng'),
            )).toList(),
            onChanged: (val) => setState(() => _selectedCustomer = val),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: "Tìm sản phẩm...",
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () => _addToCart(product),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: _buildProductImage(product['imageUrl'], size: 48),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'], maxLines: 2, overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text("${NumberFormat('#,###').format(product['price'])} đ", 
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(String? imageUrl, {double size = 40}) {
    if (imageUrl == null || imageUrl.isEmpty) return Icon(Icons.image_outlined, size: size, color: Colors.grey);
    try {
      if (imageUrl.startsWith('http')) return Image.network(imageUrl, width: size, height: size, fit: BoxFit.cover);
      return Image.memory(const Base64Decoder().convert(imageUrl.split(',').last), width: size, height: size, fit: BoxFit.cover);
    } catch (_) {
      return Icon(Icons.broken_image_outlined, size: size, color: Colors.grey);
    }
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cart.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Giỏ hàng (${_cart.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(onPressed: () => setState(() => _cart = []), child: const Text("Xóa hết")),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: ListView.separated(
                itemCount: _cart.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final item = _cart[idx];
                  return Row(
                    children: [
                      Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 13))),
                      Text("${item['quantity']} x ", style: const TextStyle(color: Colors.grey)),
                      Text(NumberFormat('#,###').format(item['price'])),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeFromCart(idx),
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 32),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tổng cộng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("${NumberFormat('#,###').format(_totalAmount)} đ", 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading || _cart.isEmpty ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Thanh toán"),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
