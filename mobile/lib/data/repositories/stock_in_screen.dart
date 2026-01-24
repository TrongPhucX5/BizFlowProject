import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/inventory_repository.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  // State
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _selectedProduct;

  // Controllers
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      // Tái sử dụng hàm lấy danh sách sản phẩm có sẵn
      final products = await _authRepository.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      _showSnackBar("Lỗi tải sản phẩm: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStockIn() async {
    if (_selectedProduct == null) {
      _showSnackBar("Vui lòng chọn sản phẩm", Colors.orange);
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showSnackBar("Số lượng nhập phải lớn hơn 0", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _inventoryRepository.stockIn(
        productId: _selectedProduct!['id'],
        quantity: quantity,
        note: _noteController.text.trim(),
      );

      if (mounted) {
        _showSnackBar("Nhập hàng thành công!", Colors.green);
        Navigator.pop(context, true); // Trả về true để reload nếu cần
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập hàng vào kho"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading && _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Chọn sản phẩm
                  const Text("Sản phẩm *", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedProduct,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Chọn sản phẩm cần nhập",
                    ),
                    items: _products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(
                          "${product['name']} (Tồn: ${product['stock'] ?? 0})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedProduct = value);
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),

                  // 2. Số lượng nhập
                  const Text("Số lượng nhập *", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nhập số lượng",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Ghi chú
                  const Text("Ghi chú", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "VD: Nhập hàng từ nhà cung cấp A...",
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleStockIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff289ca7),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Xác nhận nhập kho", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}