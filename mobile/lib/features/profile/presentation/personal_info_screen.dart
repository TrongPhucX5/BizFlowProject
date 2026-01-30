import 'package:flutter/material.dart';

import 'package:mobile/features/profile/presentation/edit_profile_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = true;
  
  // Thông tin user
  String _fullName = '';
  String _username = '';
  String _email = '';
  String _phone = '';
  String _role = '';
  String _status = '';
  String _createdAt = '';

  Map<String, dynamic>? _userDataMap; // Store full data

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authRepository.getCurrentUser();
      if (userData != null && mounted) {
        setState(() {
          _userDataMap = userData;
          _fullName = userData['fullName'] ?? '';
          _username = userData['username'] ?? '';
          _email = userData['email'] ?? '';
          _phone = userData['phone'] ?? '';
          _role = _mapRole(userData['role'] ?? '');
          _status = _mapStatus(userData['status'] ?? '');
          
          if (userData['createdAt'] != null) {
            try {
              final created = DateTime.parse(userData['createdAt']);
              _createdAt = '${created.day}/${created.month}/${created.year}';
            } catch (_) {
              _createdAt = 'N/A';
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Lỗi load user: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return 'Quản trị viên';
      case 'OWNER': return 'Chủ cửa hàng';
      case 'EMPLOYEE': return 'Nhân viên';
      default: return role;
    }
  }

  String _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return 'Đang hoạt động';
      case 'INACTIVE': return 'Không hoạt động';
      case 'LOCKED': return 'Đã khóa';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryBlue.withOpacity(0.1),
                          child: Text(
                            _fullName.isNotEmpty ? _fullName[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _role,
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit button
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_userDataMap != null) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditProfileScreen(user: _userDataMap!)),
                            );
                            if (result == true) _loadUserInfo();
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("CHỈNH SỬA THÔNG TIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info cards
                  _buildInfoCard([
                    _buildInfoRow(Icons.person_outline, 'Tên đăng nhập', _username),
                    _buildInfoRow(Icons.badge_outlined, 'Họ và tên', _fullName),
                  ]),
                  const SizedBox(height: 16),

                  _buildInfoCard([
                    _buildInfoRow(Icons.email_outlined, 'Email', _email.isNotEmpty ? _email : 'Chưa cập nhật'),
                    _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', _phone.isNotEmpty ? _phone : 'Chưa cập nhật'),
                  ]),
                  const SizedBox(height: 16),

                  _buildInfoCard([
                    _buildInfoRow(Icons.admin_panel_settings_outlined, 'Vai trò', _role),
                    _buildInfoRow(
                      Icons.circle, 
                      'Trạng thái', 
                      _status,
                      valueColor: _status == 'Đang hoạt động' ? Colors.green : Colors.grey,
                    ),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Ngày tạo', _createdAt),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
