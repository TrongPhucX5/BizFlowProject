import 'package:flutter/material.dart';

class GroupCreateScreen extends StatefulWidget {
  final List<Map<String, dynamic>> existingCustomers; // Nhận danh sách khách hàng từ màn hình cha

  const GroupCreateScreen({super.key, required this.existingCustomers});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  late List<Map<String, dynamic>> _customers; // List cục bộ để xử lý check/uncheck

  @override
  void initState() {
    super.initState();
    // Tạo bản sao của list khách hàng và thêm thuộc tính 'isSelected'
    _customers = widget.existingCustomers.map((e) => {
      ...e,
      'isSelected': false,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tạo nhóm khách hàng", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              // Lọc ra những khách hàng đã chọn
              final selectedCustomers = _customers.where((e) => e['isSelected']).toList();
              final groupName = _nameController.text;

              if (groupName.isNotEmpty && selectedCustomers.isNotEmpty) {
                // Trả dữ liệu về màn hình trước
                Navigator.pop(context, {
                  "name": groupName,
                  "count": selectedCustomers.length, // Lưu số lượng cho đơn giản
                  "members": selectedCustomers,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng nhập tên và chọn ít nhất 1 khách hàng")),
                );
              }
            },
            child: const Text("LƯU", style: TextStyle(color: Color(0xFF3B66FF), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên nhóm khách hàng",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Chọn thành viên:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          ),
          Expanded(
            child: widget.existingCustomers.isEmpty
                ? const Center(child: Text("Chưa có khách hàng nào để chọn"))
                : ListView.separated(
              itemCount: _customers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: _customers[index]['isSelected'],
                  activeColor: const Color(0xFF3B66FF),
                  title: Text(_customers[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_customers[index]['phone']),
                  onChanged: (val) {
                    setState(() {
                      _customers[index]['isSelected'] = val;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}