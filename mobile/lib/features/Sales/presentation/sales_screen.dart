import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          'productId': product['id'], // Map ID cho API createOrder
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
        "status": "COMPLETED" // POS thường là bán xong luôn
      };

      await _orderRepository.createOrder(orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo đơn hàng thành công!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Trả về true để reload list ở màn hình cha
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
      appBar: AppBar(
        title: const Text("Bán hàng (POS)"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Customer Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: "Khách hàng",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: _customers.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c['fullName'] ?? 'Khách hàng'),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCustomer = val),
              hint: const Text("Chọn khách hàng"),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Tìm sản phẩm...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey[100],
                                child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text("${NumberFormat('#,###').format(product['price'])} đ", style: const TextStyle(color: Color(0xff289ca7), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),

          // Cart Summary (Bottom Sheet style)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_cart.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _cart.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          dense: true,
                          title: Text(item['name']),
                          subtitle: Text("${item['quantity']} x ${NumberFormat('#,###').format(item['price'])}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _removeFromCart(index)),
                              Text("${item['quantity']}"),
                              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _addToCart(item)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Tổng: ${NumberFormat('#,###').format(_totalAmount)} đ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading || _cart.isEmpty ? null : _createOrder,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff289ca7), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                        child: const Text("Thanh toán", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}