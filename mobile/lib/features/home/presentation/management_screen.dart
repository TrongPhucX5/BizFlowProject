import 'package:flutter/material.dart';
import 'main_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressCard(),
            // Truyền BuildContext vào đây để các nút bấm tìm được MainScreen
            _buildFeatureGrid(context),
            _buildSupportBanner(),
            const SizedBox(height: 20),
            const Text("Đang dùng bản mới nhất: 3.2.28", style: TextStyle(color: Colors.grey, fontSize: 12)),
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

  // --- HÀM GRID TÍNH NĂNG: Đã thêm index để nhảy Tab ---
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
              // Index 1 là Bán hàng trong danh sách _widgetOptions của bạn
              _buildFeatureIcon(context, Icons.storefront, "Bán hàng", Colors.redAccent, 1),
              _buildFeatureIcon(context, Icons.swap_horiz, "Thu chi", Colors.purple, 2), // Giả định nhảy sang Đơn hàng hoặc trang khác
              // Index 3 là Sản phẩm
              _buildFeatureIcon(context, Icons.inventory_2, "Sản phẩm", Colors.orange, 3),
              _buildFeatureIcon(context, Icons.warehouse, "Tồn kho", Colors.blue, 3),
              _buildFeatureIcon(context, Icons.add, "Thêm tính năng", Colors.grey, 4),
            ],
          ),
        ],
      ),
    );
  }

  // --- HÀM ICON: Thêm InkWell và logic nhảy Tab ---
  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label, Color color, int targetIndex) {
    return InkWell(
      onTap: () {
        // Tìm đến MainScreen và bảo nó đổi Tab
        MainScreen.of(context)?.setTabIndex(targetIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // --- GIỮ NGUYÊN CÁC PHẦN UI CÒN LẠI ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF289CA7), Color(0xFF289CA7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.store, color: Colors.green, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
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
              _buildIconWithBadge(Icons.qr_code_scanner, "N"),
              const SizedBox(width: 10),
              _buildIconWithBadge(Icons.chat_bubble_outline, "1"),
            ],
          ),
          const SizedBox(height: 15),
          const Row(children: [Text('Chào Bizflow', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), SizedBox(width: 5), Icon(Icons.edit, color: Colors.white, size: 14)]),
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
        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
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

  Widget _buildIconWithBadge(IconData icon, String label) {
    return Stack(children: [Icon(icon, color: Colors.white), Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), constraints: const BoxConstraints(minWidth: 12, minHeight: 12), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center)))]);
  }

  Widget _buildStepItem(String text, bool isActive) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? Colors.blue : Colors.grey, size: 20), const SizedBox(width: 10), Text(text, style: TextStyle(color: isActive ? Colors.black : Colors.grey))]));
  }

  Widget _buildSupportBanner() {
    return Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Column(children: [const Text("Bạn cần hỗ trợ? Nhắn tin cho Sổ tại đây nhé!", style: TextStyle(fontSize: 13)), const SizedBox(height: 10), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat), label: const Text("Chat ngay"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white))]));
  }
}