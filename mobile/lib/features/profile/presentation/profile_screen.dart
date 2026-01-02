import 'package:flutter/material.dart';
import 'widgets/profile_section.dart';
import 'widgets/profile_grid_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _textColor = Color(0xFF333333);
  static const Color _primaryBlue = Color(0xFF3B66FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Kho ứng dụng",
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TIỀN BẠC =====
            const ProfileSection(
              title: "Quản lý tiền",
              items: [
                ProfileGridItemData(Icons.account_balance_wallet, "Thu / Chi", Colors.orange),
                ProfileGridItemData(Icons.account_balance, "Ngân hàng", Colors.blue),
                ProfileGridItemData(Icons.bar_chart, "Báo cáo", Colors.green),
                ProfileGridItemData(Icons.receipt_long, "Hóa đơn", Colors.purple),
              ],
            ),

            // ===== BÁN HÀNG =====
            const ProfileSection(
              title: "Quản lý bán hàng",
              items: [
                ProfileGridItemData(Icons.storefront, "Bán hàng", Colors.red),
                ProfileGridItemData(Icons.people, "Khách hàng", Colors.blue),
                ProfileGridItemData(Icons.person_outline, "Nhân viên", Colors.green),
                ProfileGridItemData(Icons.campaign, "Marketing", Colors.orange),
              ],
            ),

            // ===== KHO =====
            const ProfileSection(
              title: "Kho & Sản phẩm",
              items: [
                ProfileGridItemData(Icons.inventory_2, "Sản phẩm", Colors.orange),
                ProfileGridItemData(Icons.warehouse, "Kho hàng", Colors.blue),
                ProfileGridItemData(Icons.qr_code, "Barcode", Colors.green),
                ProfileGridItemData(Icons.category, "Danh mục", Colors.purple),
              ],
            ),

            // ===== ONLINE =====
            const ProfileSection(
              title: "Kênh online",
              items: [
                ProfileGridItemData(Icons.public, "Website", Colors.blue),
                ProfileGridItemData(Icons.shopping_cart, "Sàn TMĐT", Colors.green),
                ProfileGridItemData(Icons.chat, "Chat bán hàng", Colors.orange),
                ProfileGridItemData(Icons.share, "Mạng xã hội", Colors.purple),
              ],
            ),

            const SizedBox(height: 24),

            // ===== NÚT SỬA THANH ĐIỀU HƯỚNG =====
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  side: const BorderSide(color: _primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Sửa thanh điều hướng",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
