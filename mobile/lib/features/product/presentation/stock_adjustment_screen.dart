import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/inventory_repository.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _selectedProduct;

  final TextEditingController _actualQuantityCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();

  int _currentStock = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _authRepository.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onProductSelected(Map<String, dynamic>? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _currentStock = product['stock'] ?? 0;
        _actualQuantityCtrl.text = _currentStock.toString();
      } else {
        _currentStock = 0;
        _actualQuantityCtrl.clear();
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedProduct == null) return;
    final newQty = int.tryParse(_actualQuantityCtrl.text);
    if (newQty == null || newQty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Số lượng không hợp lệ")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _inventoryRepository.adjustStock(
        productId: _selectedProduct!['id'],
        newQuantity: newQty,
        reason: _reasonCtrl.text.isEmpty ? "Kiểm kê kho" : _reasonCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cân bằng kho thành công"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kiểm kê / Cân bằng kho")),
      body: _isLoading && _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chọn sản phẩm", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedProduct,
                    isExpanded: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Chọn sản phẩm"),
                    items: _products.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text("${p['name']} (Tồn: ${p['stock']})"),
                    )).toList(),
                    onChanged: _onProductSelected,
                  ),
                  const SizedBox(height: 24),

                  if (_selectedProduct != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tồn kho hệ thống:"),
                          Text("$_currentStock", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text("Số lượng thực tế (Kiểm đếm)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _actualQuantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Nhập số lượng thực tế"),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text("Lý do chênh lệch", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonCtrl,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "VD: Hư hỏng, thất thoát, tìm thấy..."),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("XÁC NHẬN CÂN BẰNG KHO"),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
