import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/order_repository.dart';

class ManualOrderScreen extends StatefulWidget {
  const ManualOrderScreen({super.key});

  @override
  State<ManualOrderScreen> createState() => _ManualOrderScreenState();
}

class _ManualOrderScreenState extends State<ManualOrderScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  // Customers & Products from backend
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _products = [];
  
  // Selected data
  Map<String, dynamic>? _selectedCustomer;
  List<OrderItemData> _orderItems = [];
  String? _notes;
  File? _orderImage;
  String _selectedPaymentType = 'CASH';
  
  final List<Map<String, dynamic>> _paymentTypes = [
    {'id': 'CASH', 'label': 'Tiền mặt', 'icon': Icons.money},
    {'id': 'CREDIT', 'label': 'Khách nợ', 'icon': Icons.hourglass_empty},
    {'id': 'TRANSFER', 'label': 'Chuyển khoản (Đang phát triển)', 'icon': Icons.swap_horiz},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _authRepository.getCustomers(),
        _authRepository.getProducts(),
      ]);
      
      if (mounted) {
        setState(() {
          _customers = results[0];
          _products = results[1];
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Lỗi load data: $e');
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _orderImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _orderImage = File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addOrderItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ProductSelector(
        products: _products,
        onSelect: (product, quantity, price) {
          setState(() {
            _orderItems.add(OrderItemData(
              productId: product['id'],
              productName: product['name'] ?? 'Sản phẩm',
              sku: product['sku'] ?? 'N/A',
              currentStock: product['stock'] ?? 0,
              quantity: quantity,
              unitPrice: price,
            ));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeOrderItem(int index) {
    setState(() => _orderItems.removeAt(index));
  }

  double get _totalAmount {
    return _orderItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(amount);
  }

  Future<void> _submitOrder() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khách hàng'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 sản phẩm'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final orderData = {
        'customerId': _selectedCustomer!['id'],
        'items': _orderItems.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        }).toList(),
        'notes': _notes ?? '',
        'paymentType': _selectedPaymentType,
        'discountAmount': 0,
      };
      
      await _orderRepository.createOrder(orderData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo đơn hàng thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Selector
                  _buildSectionCard(
                    title: 'Khách hàng',
                    icon: Icons.person,
                    child: _buildCustomerSelector(primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  
                  // Products
                  _buildSectionCard(
                    title: 'Sản phẩm',
                    icon: Icons.inventory_2,
                    trailing: TextButton.icon(
                      onPressed: _addOrderItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm'),
                    ),
                    child: _buildProductsList(primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Type
                  _buildSectionCard(
                    title: 'Hình thức thanh toán',
                    icon: Icons.payments_outlined,
                    child: _buildPaymentTypeSelector(primaryBlue),
                  ),
                  const SizedBox(height: 16),

                  // Image Upload
                  _buildSectionCard(
                    title: 'Hình ảnh đơn hàng',
                    icon: Icons.image,
                    child: _buildImageUpload(primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  _buildSectionCard(
                    title: 'Ghi chú',
                    icon: Icons.note,
                    child: TextField(
                      onChanged: (value) => _notes = value,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú cho đơn hàng...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Total & Submit
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _formatCurrency(_totalAmount),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Tạo đơn hàng',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCustomerSelector(Color primaryBlue) {
    return InkWell(
      onTap: () => _showCustomerPicker(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryBlue.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedCustomer == null
                  ? const Text(
                      'Chọn khách hàng...',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!['fullName'] ?? 'Khách hàng',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _selectedCustomer!['phone'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Chọn khách hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (customer['fullName'] ?? 'K')[0].toUpperCase(),
                      ),
                    ),
                    title: Text(customer['fullName'] ?? 'Khách hàng'),
                    subtitle: Text(customer['phone'] ?? ''),
                    onTap: () {
                      setState(() => _selectedCustomer = customer);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(Color primaryBlue) {
    if (_orderItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text(
            'Chưa có sản phẩm nào\nBấm "Thêm" để thêm sản phẩm',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _orderItems.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final item = _orderItems[index];
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SKU: ${item.sku}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tồn: ${item.currentStock}',
                        style: TextStyle(
                          fontSize: 10, 
                          color: item.currentStock > 0 ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} x ${_formatCurrency(item.unitPrice)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrency(item.quantity * item.unitPrice),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryBlue,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeOrderItem(index),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageUpload(Color primaryBlue) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: _orderImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_orderImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        onPressed: () => setState(() => _orderImage = null),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Chụp hoặc chọn hình ảnh',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector(Color primaryBlue) {
    return Column(
      children: _paymentTypes.map((type) {
        final bool isSelected = _selectedPaymentType == type['id'];
        return InkWell(
          onTap: () => setState(() => _selectedPaymentType = type['id']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? primaryBlue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? primaryBlue.withOpacity(0.05) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  type['icon'],
                  color: isSelected ? primaryBlue : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  type['label'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryBlue : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: primaryBlue, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Helper class for order items
class OrderItemData {
  final int productId;
  final String productName;
  final String sku;
  final int currentStock;
  final int quantity;
  final double unitPrice;

  OrderItemData({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.currentStock,
    required this.quantity,
    required this.unitPrice,
  });
}

// Product Selector Widget
class _ProductSelector extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic> product, int quantity, double price) onSelect;

  const _ProductSelector({
    required this.products,
    required this.onSelect,
  });

  @override
  State<_ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<_ProductSelector> {
  Map<String, dynamic>? _selectedProduct;
  late TextEditingController _qtyController;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '$_quantity');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }
  
  void _updateQuantity(int newQty) {
    if (newQty < 1) return;
    setState(() {
      _quantity = newQty;
      _qtyController.text = '$_quantity';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Product dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedProduct,
              hint: const Text('Chọn sản phẩm...'),
              isExpanded: true,
              underline: const SizedBox(),
              items: widget.products.map((product) {
                final int stock = product['stock'] ?? 0;
                final String sku = product['sku'] ?? 'N/A';
                return DropdownMenuItem(
                  value: product,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(product['name'] ?? 'Sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('SKU: $sku', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(
                        'Tồn: $stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: stock > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedProduct = value),
            ),
          ),
          const SizedBox(height: 16),
          
          // Quantity
          Row(
            children: [
              const Text('Số lượng:'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _quantity > 1 ? () => _updateQuantity(_quantity - 1) : null,
              ),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final newQty = int.tryParse(value);
                    if (newQty != null && newQty > 0) {
                      setState(() => _quantity = newQty);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _updateQuantity(_quantity + 1),
              ),
            ],
          ),
          
          if (_selectedProduct != null) ...[
            const SizedBox(height: 8),
            Text(
              'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_selectedProduct!['price'] ?? 0)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedProduct == null
                  ? null
                  : () {
                      final int stock = _selectedProduct!['stock'] ?? 0;
                      if (stock <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Sản phẩm này hiện đang hết hàng (Tồn: 0). Vui lòng nhập kho trước."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      widget.onSelect(
                        _selectedProduct!,
                        _quantity,
                        (_selectedProduct!['price'] ?? 0).toDouble(),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Thêm vào đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }
}
