import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⚠️ ĐÃ SỬA: Đổi 'mobile' thành 'bizflow_project' cho đúng tên project của ông
import 'package:mobile/features/home/presentation/main_screen.dart';
import 'package:mobile/data/repositories/debt_repository.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class PaymentScreen extends StatefulWidget {
  final int? customerId;
  final String? customerName;
  final double? initialAmount;

  const PaymentScreen({
    super.key,
    this.customerId,
    this.customerName,
    this.initialAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color kPrimaryColor = const Color(0xff289ca7);
  final Color kBorderColor = Colors.grey.shade300;
  final DebtRepository _debtRepository = DebtRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _selectedCustomer;

  String _amountString = "0";
  bool _isLoading = false; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountString = widget.initialAmount!.toInt().toString();
    }
    if (widget.customerId == null) {
      _fetchCustomers();
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

  void _handleKeyPress(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (_amountString == '0') {
        if (value != '000' && value != '0') {
          _amountString = value;
        }
      } else {
        if (_amountString.length < 12) {
          _amountString += value;
        }
      }
    });
  }

  String get _formattedAmount {
    if (_amountString == '0') return '0';
    try {
      final formatter = NumberFormat('#,###', 'vi_VN');
      return formatter.format(int.parse(_amountString));
    } catch (e) {
      return _amountString;
    }
  }

  // Hàm này chuẩn rồi: Xóa hết lịch sử và set MainScreen làm màn hình gốc
  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
    );
  }

  // --- LOGIC GỌI API ---
  Future<void> _processPayment() async {
    final int amount = int.parse(_amountString);
    if (amount <= 0) return;
    
    final customerId = widget.customerId ?? _selectedCustomer?['id'];
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn khách hàng"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Payload gửi lên API POST /payments
      final paymentData = {
        "customerId": customerId,
        "amount": amount,
        "paymentMethod": "CASH",
        "note": "Thu tiền nhanh tại quầy"
      };

      // Gọi API
      await _debtRepository.createPayment(paymentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thu tiền thành công!"), backgroundColor: Colors.green),
        );
        // Trả về true để màn hình trước reload dữ liệu
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasAmount = _amountString != '0';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.customerName != null ? 'Thu từ: ${widget.customerName}' : 'Thu tiền', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          // Nút Trang chủ
          InkWell(
            onTap: () => _navigateToHome(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.store_outlined, color: Colors.black, size: 24),
                  Text("Trang chủ", style: TextStyle(color: Colors.black, fontSize: 10)),
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.customerId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    child: DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: "Chọn khách hàng nộp tiền",
                        border: OutlineInputBorder(),
                      ),
                      items: _customers.map((c) => DropdownMenuItem(value: c, child: Text(c['fullName']))).toList(),
                      onChanged: (val) => setState(() => _selectedCustomer = val),
                    ),
                  ),
                const Text("Số tiền", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 10),
                Text(
                  _formattedAmount,
                  style: TextStyle(color: kPrimaryColor, fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(width: 60, height: 2, color: kPrimaryColor),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                _buildKeypadRow(['4', '5', '6']),
                _buildKeypadRow(['7', '8', '9']),
                _buildKeypadRow(['000', '0', 'backspace']),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAmount ? kPrimaryColor : Colors.grey.shade300,
                  elevation: 0,
                ),
                // Chặn bấm khi đang loading hoặc chưa có tiền
                onPressed: (hasAmount && !_isLoading)
                    ? _processPayment
                    : null,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                  "Xác nhận",
                  style: TextStyle(
                    color: hasAmount ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) => _buildKeypadButton(key)).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(String key) {
    return Expanded(
      child: InkWell(
        onTap: () => _handleKeyPress(key),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: kBorderColor, width: 0.5),
          ),
          alignment: Alignment.center,
          child: key == 'backspace'
              ? const Icon(Icons.backspace_outlined, color: Colors.black54)
              : Text(
            key,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}