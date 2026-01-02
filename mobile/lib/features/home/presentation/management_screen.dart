import 'package:flutter/material.dart';
import 'package:mobile/common/widgets/app_drawer.dart';
import 'package:mobile/features/scanner/presentation/select_scanner_bottom_sheet.dart';
import 'package:mobile/features/inbox/presentation/inbox_screen.dart';
import 'main_screen.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ===== MỞ DRAWER =====
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // ===== CHỌN MÁY QUÉT =====
  Future<void> _openScannerSelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SelectScannerBottomSheet(),
    );
  }

  // ===== MỞ INBOX =====
  void _openInbox() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InboxScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressCard(),
            _buildFeatureGrid(context),
            _buildSupportBanner(),
            const SizedBox(height: 20),
            const Text(
              "Đang dùng bản mới nhất: 3.2.28",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3B66FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // =====================================================
  // ================ UI GỐC CỦA BẠN =====================
  // =====================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF289CA7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ICON NHÀ → DRAWER
              InkWell(
                onTap: _openDrawer,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, color: Colors.green, size: 20),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.white, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // QR
              InkWell(
                onTap: _openScannerSelector,
                child: _buildIconWithBadge(Icons.qr_code_scanner, "N"),
              ),
              const SizedBox(width: 10),

              // CHAT
              InkWell(
                onTap: _openInbox,
                child: _buildIconWithBadge(Icons.chat_bubble_outline, "1"),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              Text(
                'Chào Bizflow',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5),
              Icon(Icons.edit, color: Colors.white, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thực hiện 3 bước để bắt đầu', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const LinearProgressIndicator(value: 0.1, backgroundColor: Colors.white, color: Colors.green),
            const SizedBox(height: 15),
            _buildStepItem("Bước 1: Tạo sản phẩm", true),
            _buildStepItem("Bước 2: Tạo đơn hàng", false),
            _buildStepItem("Bước 3: Xem lãi lỗ", false),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tính năng cho bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildFeatureIcon(context, Icons.storefront, "Bán hàng", Colors.redAccent, 1),
              _buildFeatureIcon(context, Icons.swap_horiz, "Thu chi", Colors.purple, 2),
              _buildFeatureIcon(context, Icons.inventory_2, "Sản phẩm", Colors.orange, 3),
              _buildFeatureIcon(context, Icons.warehouse, "Tồn kho", Colors.blue, 3),
              _buildFeatureIcon(context, Icons.add, "Thêm tính năng", Colors.grey, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label, Color color, int index) {
    return InkWell(
      onTap: () => MainScreen.of(context)?.setTabIndex(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(IconData icon, String label) {
    return Stack(
      children: [
        Icon(icon, color: Colors.white),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
            constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? Colors.blue : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: active ? Colors.black : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSupportBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Text("Bạn cần hỗ trợ? Nhắn tin cho Sổ tại đây nhé!", style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat),
            label: const Text("Chat ngay"),
          ),
        ],
      ),
    );
  }
}
