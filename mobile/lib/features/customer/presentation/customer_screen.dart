import 'package:flutter/material.dart';
import 'dart:math'; // Để random mã khách hàng
import 'package:mobile/features/customer/presentation/group_create_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _currentTabIndex = 0;

  // Dữ liệu mẫu mở rộng
  List<Map<String, dynamic>> customers = [
    {
      "id": "KH10239",
      "name": "Khách lẻ",
      "phone": "0999988888",
      "gender": "Nam",
      "dob": "01/01/1990",
      "email": "khachle@gmail.com",
      "address": "TP. Hồ Chí Minh"
    },
  ];

  List<Map<String, dynamic>> groups = [];

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
    final nameController = TextEditingController(text: existingCustomer?['name'] ?? '');
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
                          onPressed: () {
                            // Validate cơ bản
                            if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tên và SĐT là bắt buộc")));
                              return;
                            }

                            final data = {
                              "id": idController.text,
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "gender": selectedGender,
                              "dob": dobController.text,
                              "email": emailController.text,
                              "address": addressController.text,
                            };

                            setState(() {
                              if (existingCustomer == null) {
                                customers.add(data);
                              } else {
                                customers[index!] = data;
                              }
                            });
                            Navigator.pop(ctx);
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
            onPressed: () {
              setState(() => customers.removeAt(index));
              Navigator.pop(ctx);
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

  Widget _buildCustomerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: customers.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = customers[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: item['gender'] == 'Nữ' ? Colors.pink[50] : Colors.blue[50],
            child: Icon(Icons.person, color: item['gender'] == 'Nữ' ? Colors.pink : Colors.blue),
          ),
          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${item['id']} - ${item['phone']}"),
              if(item['address'] != null && item['address'].isNotEmpty)
                Text(item['address'], style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.grey),
            onPressed: () => _showCustomerForm(existingCustomer: item, index: index),
          ),
          onLongPress: () => _deleteCustomer(index), // Nhấn giữ để xóa cho nhanh
        );
      },
    );
  }

  // Widget _buildGroupList() và hàm _navigateToCreateGroup() giữ nguyên như bài trước
  // ...
  void _navigateToCreateGroup() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => GroupCreateScreen(existingCustomers: customers)));
    if (result != null) setState(() => groups.add(result));
  }

  Widget _buildGroupList() {
    if (groups.isEmpty) return const Center(child: Text("Chưa có nhóm nào"));
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (ctx, index) => ListTile(title: Text(groups[index]['name']), subtitle: Text("${groups[index]['count']} thành viên")),
    );
  }
}