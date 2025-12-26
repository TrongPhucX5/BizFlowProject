import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Màu xanh lá chủ đạo theo thiết kế
    const Color kPrimaryGreen = Color(0xff2871a7);
    const Color kGreyBg = Color(0xFFF5F5F5);
    const Color kGreyText = Colors.grey;

    // Sử dụng DefaultTabController để quản lý 4 tab
    return DefaultTabController(
      length: 4, // Số lượng tab: Sản phẩm, Tồn kho, Bán kèm, Danh mục
      child: Scaffold(
        backgroundColor: Colors.white,
        // === 1. APP BAR TÙY CHỈNH ===
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5, // Bóng mờ nhẹ
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Phần bottom chứa thanh tìm kiếm và TabBar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0), // Chiều cao tổng cho phần bottom
            child: Column(
              children: [
                // --- Hàng chứa ô tìm kiếm và icon ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: kGreyBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Tìm tên, mã SKU, ...",
                              prefixIcon: Icon(Icons.search, color: kGreyText),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {}, // TODO: Icon sắp xếp/lọc
                        icon: const Icon(Icons.tune, color: Colors.black87),
                        constraints: const BoxConstraints(), // Thu gọn padding
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        onPressed: () {}, // TODO: Icon đổi kiểu xem
                        icon: const Icon(Icons.list, color: Colors.black87),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
],
                  ),
                ),
                // --- Thanh TabBar ---
                TabBar(
                  labelColor: kPrimaryGreen, // Màu chữ tab được chọn
                  unselectedLabelColor: Colors.black87, // Màu chữ tab chưa chọn
                  indicatorColor: kPrimaryGreen, // Màu thanh gạch chân
                  indicatorWeight: 3.0,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "Sản phẩm"),
                    Tab(text: "Tồn kho"),
                    Tab(text: "Bán kèm"),
                    Tab(text: "Danh mục"),
                  ],
                ),
              ],
            ),
          ),
        ),

        // === 2. NỘI DUNG CÁC TAB (TabBarView) ===
        body: TabBarView(
          children: [
            // --- Tab 1: Sản phẩm (Giao diện trạng thái rỗng) ---
            _buildEmptyProductState(context, kPrimaryGreen, kGreyText, kGreyBg),

            // --- Các tab khác (Placeholder tạm) ---
            const Center(child: Text("Màn hình Tồn kho")),
            const Center(child: Text("Màn hình Bán kèm")),
            const Center(child: Text("Màn hình Danh mục")),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng giao diện "Trạng thái rỗng" cho tab Sản phẩm
  Widget _buildEmptyProductState(BuildContext context, Color primaryColor, Color greyText, Color greyBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // 1. Ảnh minh họa (Dùng Icon thay thế cho ảnh thật)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: greyBg,
              shape: BoxShape.circle,
            ),
            // Sử dụng một icon tương tự cái kính lúp trên tài liệu
            child: Icon(Icons.plagiarism_outlined, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),

          // 2. Text mô tả
          Text(
            "Quản lý danh sách sản phẩm giúp theo dõi thông tin giá cả và tồn kho. Tạo sản phẩm đầu tiên ngay bạn nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: greyText, height: 1.5),
          ),
          const SizedBox(height: 32),

          // 3. Các nút chức năng
          // Nút 1: Tạo sản phẩm (Full màu xanh)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Mở màn hình tạo sản phẩm
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Tạo sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),

          // Nút 2: Tạo dịch vụ (Viền xanh)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Chức năng khác
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tạo dịch vụ theo giờ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),

          // Nút 3: Tạo hàng loạt (Viền xanh)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Chức năng khác
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tạo sản phẩm hàng loạt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}