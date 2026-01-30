import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mobile/features/customer/presentation/group_create_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/customer/presentation/customer_detail_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

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

  String _generateCustomerId() {
    var rng = Random();
    String code = (10000 + rng.nextInt(90000)).toString();
    return "KH$code";
  }

  void _showCustomerForm({Map<String, dynamic>? existingCustomer}) {
    final idController = TextEditingController(text: (existingCustomer?['id'] ?? _generateCustomerId()).toString());
    final nameController = TextEditingController(text: (existingCustomer?['fullName'] ?? '').toString());
    final phoneController = TextEditingController(text: (existingCustomer?['phone'] ?? '').toString());
    final emailController = TextEditingController(text: (existingCustomer?['email'] ?? '').toString());
    final dobController = TextEditingController(text: (existingCustomer?['dob'] ?? '').toString());
    final addressController = TextEditingController(text: (existingCustomer?['address'] ?? '').toString());

    String rawGender = (existingCustomer?['gender'] ?? 'Nam').toString().toUpperCase();
    String? selectedGender = rawGender.contains('NAM') ? 'Nam' : (rawGender.contains('NỮ') || rawGender.contains('NU') ? 'Nữ' : 'Khác');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, top: 12, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(existingCustomer == null ? "Thêm khách hàng" : "Sửa thông tin",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idController,
                      enabled: false,
                      decoration: const InputDecoration(labelText: "Mã KH (Tự động)"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(labelText: "Giới tính"),
                      items: ['Nam', 'Nữ', 'Khác'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setModalState(() => selectedGender = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên khách hàng", hintText: "Nhập họ và tên"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Số điện thoại", hintText: "Nhập số điện thoại liên hệ"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Địa chỉ", hintText: "Số nhà, tên đường, phường/xã"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tên và SĐT không được để trống")));
                      return;
                    }
                    try {
                      final storeId = await _authRepository.getCurrentStoreId();
                      final data = {
                        "id": idController.text,
                        "fullName": nameController.text,
                        "phone": phoneController.text,
                        "gender": selectedGender,
                        "address": addressController.text,
                        "storeId": storeId,
                      };
                      if (existingCustomer == null) {
                        await _authRepository.createCustomer(data);
                      } else {
                        await _authRepository.updateCustomer(existingCustomer['id'], data);
                      }
                      Navigator.pop(ctx);
                      _fetchData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã lưu thông tin"), backgroundColor: Colors.green));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text("Lưu khách hàng"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Khách hàng'),
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [Tab(text: "Danh sách"), Tab(text: "Nhóm khách")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCustomerList(),
            _buildGroupList(),
          ],
        ),
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              final index = DefaultTabController.of(context).index;
              if (index == 0) {
                _showCustomerForm();
              } else {
                _navigateToCreateGroup();
              }
            },
            child: const Icon(Icons.add_rounded, size: 28),
          );
        }),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (customers.isEmpty) return _buildEmptyState(Icons.people_outline_rounded, "Chưa có khách hàng", "Thêm khách hàng để bắt đầu quản lý thông tin và công nợ");

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = customers[index];
          final type = item['type'] ?? 'RETAIL';
          final gender = (item['gender'] ?? '').toString().toUpperCase();
          final isFemale = gender.contains('NỮ') || gender.contains('NU');

          return InkWell(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: item))
            ).then((_) => _fetchData()),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isFemale ? const Color(0xFFFFF1F2) : const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, color: isFemale ? const Color(0xFFF43F5E) : const Color(0xFF3B82F6)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(item['fullName'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                                const SizedBox(width: 8),
                                _buildTypeBadge(type),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("${item['phone']} • ID: ${item['id']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  Row(
                    children: [
                      Expanded(child: _buildStatColumn("Tổng mua", _formatCurrency(item['totalPurchaseAmount']))),
                      Expanded(child: _buildStatColumn("Công nợ", _formatCurrency(item['totalDebt']), color: const Color(0xFFEF4444))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = type == 'WHOLESALE' ? const Color(0xFF8B5CF6) : (type == 'CORPORATE' ? const Color(0xFF10B981) : const Color(0xFF3B82F6));
    String label = type == 'WHOLESALE' ? 'KH SỈ' : (type == 'CORPORATE' ? 'CTY' : 'KH LẺ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color ?? const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildGroupList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (groups.isEmpty) return _buildEmptyState(Icons.group_work_outlined, "Chưa có nhóm", "Phân loại khách hàng vào các nhóm để dễ quản lý ưu đãi");

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final group = groups[index];
        return ListTile(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupCreateScreen(
                  existingCustomers: customers,
                  existingGroup: group,
                ),
              ),
            );
            if (result == true) _fetchData();
          },
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.groups_rounded, color: Color(0xFF64748B)),
          ),
          title: Text(group['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text("${group['customerCount'] ?? group['count'] ?? 0} thành viên", style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    double val = double.tryParse((amount ?? 0).toString()) ?? 0;
    return NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(val);
  }

  void _navigateToCreateGroup() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => GroupCreateScreen(existingCustomers: customers)));
    if (result == true) _fetchData();
  }
}
