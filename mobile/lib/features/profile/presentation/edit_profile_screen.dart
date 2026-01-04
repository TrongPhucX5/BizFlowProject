import 'package:flutter/material.dart';
import 'personal_info_screen.dart';
import 'business_info_screen.dart';
import 'kyc_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(context, 'Thông tin cá nhân', Icons.person, const PersonalInfoScreen()),
          _item(context, 'Thông tin hộ kinh doanh', Icons.store, const BusinessInfoScreen()),
          _item(context, 'Xác thực KYC', Icons.verified_user, const KycScreen()),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }
}
