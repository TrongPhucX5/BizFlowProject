import 'package:flutter/material.dart';
import 'dart:math'; // Để random mã khách hàng
import 'package:mobile/features/customer/presentation/group_create_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:intl/intl.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _currentTabIndex = 0;
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  // Dữ liệu từ API
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Gọi song song cả 2 API để tối ưu thời gian
      final results = await Future.wait([
        _authRepository.getCustomers(),
        _authRepository.getCustomerGroups(),
      ]);
      
      setState(() {
        customers = results[0];
        groups = results[1];
      });
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC HELPER ---

  // Hàm sinh mã khách hàng tự động (Ví dụ: KH + 5 số ngẫu nhiên)
  String _generateCustomerId() {
    var rng = Random();
    String code = (10000 + rng.nextInt(90000)).toString(); // Random từ 10000 -> 99999
    return "KH$code";
  }

  // --- LOGIC FORM KHÁCH HÀNG ---

  void _showCustomerForm({Map<String, dynamic>? existingCustomer, int? index}) {
    // Controller quản lý text
    final idController = TextEditingController(text: existingCustomer?['id'] ?? _generateCustomerId());
    final nameController = TextEditingController(text: existingCustomer?['fullName'] ?? '');
    final phoneController = TextEditingController(text: existingCustomer?['phone'] ?? '');
    final emailController = TextEditingController(text: existingCustomer?['email'] ?? '');
    final dobController = TextEditingController(text: existingCustomer?['dob'] ?? '');
    final addressController = TextEditingController(text: existingCustomer?['address'] ?? '');

    // Biến tạm cho Dropdown giới tính
    String? selectedGender = existingCustomer?['gender'] ?? 'Nam';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        // StatefulBuilder để cập nhật UI trong BottomSheet (cần thiết cho Dropdown)
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 16, right: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85), // Max cao 85% màn hình
                child: SingleChildScrollView( // Cho phép cuộn khi form dài
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(existingCustomer == null ? "Thêm khách hàng" : "Sửa thông tin",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 1. MÃ KHÁCH HÀNG (Read-only) & GIỚI TÍNH
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: idController,
                              enabled: false, // Không cho sửa mã
                              decoration: InputDecoration(
                                labelText: "Mã KH (Auto)",
                                filled: true, fillColor: Colors.grey[200],
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              decoration: const InputDecoration(labelText: "Giới tính", border: OutlineInputBorder()),
                              items: ['Nam', 'Nữ', 'Khác'].map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                              onChanged: (newValue) {
                                setModalState(() => selectedGender = newValue);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 2. TÊN & SĐT
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Tên khách hàng *", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "Số điện thoại *", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),

                      // 3. NGÀY SINH (Date Picker)
                      TextField(
                        controller: dobController,
                        readOnly: true, // Không cho gõ phím
                        decoration: const InputDecoration(
                          labelText: "Ngày sinh",
                          hintText: "dd/mm/yyyy",
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            // Format đơn giản dd/MM/yyyy
                            String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            dobController.text = formattedDate;
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // 4. EMAIL & ĐỊA CHỈ
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Địa chỉ", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),

                      // BUTTON LƯU
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate cơ bản
                            if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tên và SĐT là bắt buộc")));
                              return;
                            }

                            // Lấy StoreID hiện tại
                            final storeId = await _authRepository.getCurrentStoreId();

                            final data = {
                              "id": idController.text,
                              "fullName": nameController.text,
                              "phone": phoneController.text,
                              "gender": selectedGender,
                              "dob": dobController.text,
                              "email": emailController.text,
                              "address": addressController.text,
                              "storeId": storeId, // FIX: Gửi kèm StoreID
                            };

                            // Gọi API
                            try {
                              if (existingCustomer == null) {
                                await _authRepository.createCustomer(data);
                              } else {
                                await _authRepository.updateCustomer(existingCustomer['id'], data);
                              }
                              if (mounted) {
                                Navigator.pop(ctx);
                                _fetchData(); // Reload list
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B66FF)),
                          child: Text(existingCustomer == null ? "Lưu khách hàng" : "Cập nhật",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Hàm xóa (Giữ nguyên)
  void _deleteCustomer(int index) {
    // ... (Code xóa giữ nguyên như cũ)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xóa khách hàng này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              try {
                await _authRepository.deleteCustomer(customers[index]['id']);
                if (mounted) setState(() => customers.removeAt(index));
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi xóa: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- UI CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white, elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            children: [
              _buildTabItem("Khách hàng", 0),
              _buildTabItem("Nhóm khách hàng", 1),
            ],
          ),
        ),
      ),
      body: _currentTabIndex == 0 ? _buildCustomerList() : _buildGroupList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentTabIndex == 0) _showCustomerForm();
          else _navigateToCreateGroup();
        },
        backgroundColor: const Color(0xFF3B66FF),
        label: Text(_currentTabIndex == 0 ? 'Thêm khách' : 'Tạo nhóm', style: const TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _currentTabIndex == index;
    return Expanded(child: InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(title, style: TextStyle(color: isActive ? const Color(0xFF3B66FF) : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))),
        if (isActive) Container(height: 2, color: const Color(0xFF3B66FF)),
      ]),
    ));
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0đ";
    double val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(val);
  }

  Widget _buildCustomerList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (customers.isEmpty) return const Center(child: Text("Chưa có khách hàng nào"));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: customers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = customers[index];
        final type = item['type'] ?? 'RETAIL';
        final totalDebt = item['totalDebt'] ?? 0;
        final totalPurchased = item['totalPurchaseAmount'] ?? 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: item['gender'] == 'NỮ' ? Colors.pink[50] : Colors.blue[50], // Check case sensitivity if needed
                      child: Icon(Icons.person, color: item['gender'] == 'NỮ' ? Colors.pink : Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(item['fullName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 8),
                                Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: type == 'WHOLESALE' ? Colors.purple[50] 
                                       : type == 'CORPORATE' ? Colors.green[50] 
                                       : Colors.blue[50], // Default RETAIL
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: type == 'WHOLESALE' ? Colors.purple 
                                           : type == 'CORPORATE' ? Colors.green 
                                           : Colors.blue, 
                                      width: 0.5),
                                ),
                                child: Text(
                                  type == 'WHOLESALE' ? 'KH SỈ' : type == 'CORPORATE' ? 'DOANH NGHIỆP' : 'KH LẺ',
                                  style: TextStyle(
                                      fontSize: 10, 
                                      color: type == 'WHOLESALE' ? Colors.purple 
                                           : type == 'CORPORATE' ? Colors.green 
                                           : Colors.blue, 
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("ID: ${item['id']} • ${item['phone']}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () => _showCustomerForm(existingCustomer: item, index: index),
                      ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tổng mua", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(_formatCurrency(totalPurchased), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Công nợ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(_formatCurrency(totalDebt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildGroupList() và hàm _navigateToCreateGroup() giữ nguyên như bài trước
  // ...
  void _navigateToCreateGroup() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => GroupCreateScreen(existingCustomers: customers)));
    // Nếu tạo thành công (result == true), reload lại toàn bộ dữ liệu từ server
    if (result == true) {
      _fetchData();
    }
  }

  Widget _buildGroupList() {
    if (groups.isEmpty) return const Center(child: Text("Chưa có nhóm nào"));
    return ListView.builder(
      itemCount: groups.length,
      // Hiển thị số lượng thành viên an toàn (backend có thể trả về count hoặc customerCount)
      itemBuilder: (ctx, index) => ListTile(title: Text(groups[index]['name']), subtitle: Text("${groups[index]['customerCount'] ?? groups[index]['count'] ?? 0} thành viên")),
    );
  }
}