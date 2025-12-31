import 'package:flutter/material.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart'; // Giữ nguyên import của bạn
import 'package:mobile/features/product/presentation/combo_create_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isGridView = false;
  String _selectedSort = 'Mới nhất';

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xff289ca7);
    const Color kGreyBg = Color(0xFFF5F5F5);
    const Color kGreyText = Colors.grey;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,

        // === APP BAR ===
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: Column(
              children: [
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
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.tune, color: Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onSelected: (String value) => setState(() => _selectedSort = value),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          _buildPopupItem("Mới nhất"),
                          _buildPopupItem("Sản phẩm bán chạy"),
                          _buildPopupItem("Còn hàng từ cao -> thấp"),
                          _buildPopupItem("Còn hàng từ thấp -> cao"),
                          _buildPopupItem("Từ A -> Z"),
                          _buildPopupItem("Từ Z -> A"),
                          _buildPopupItem("Giá từ cao đến thấp"),
                          _buildPopupItem("Giá từ thấp đến cao"),
                        ],
                      ),
                      IconButton(
                        onPressed: () => setState(() => _isGridView = !_isGridView),
                        icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.black87),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  labelColor: kPrimaryGreen,
                  unselectedLabelColor: Colors.black87,
                  indicatorColor: kPrimaryGreen,
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

        // === BODY CÁC TAB ===
        body: TabBarView(
          children: [
            // TAB 1: SẢN PHẨM
            _buildEmptyProductState(context, kPrimaryGreen, kGreyText, kGreyBg),

            // TAB 2: TỒN KHO [Cập nhật mới]
            _buildInventoryTab(context, kPrimaryGreen),

            // TAB 3: BÁN KÈM [Cập nhật mới]
            _buildComboTab(context, kPrimaryGreen),

            // TAB 4: DANH MỤC [Cập nhật mới]
            _buildCategoryTab(context, kPrimaryGreen),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TAB 2: TỒN KHO ---
  Widget _buildInventoryTab(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        // Thanh thống kê ở trên cùng
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Text("Số lượng 0", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("Giá trị tồn 0", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),
        // Nội dung rỗng
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                  child: Icon(Icons.analytics_outlined, size: 70, color: Colors.grey[300]),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Quản lý tồn kho giúp kiểm soát số lượng hàng tồn kho và đáp ứng nhu cầu của khách hàng.\nTạo sản phẩm đầu tiên ngay bạn nhé!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200, height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductCreateScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("Tạo sản phẩm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET TAB 3: BÁN KÈM ---
  Widget _buildComboTab(BuildContext context, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.copy_outlined, size: 70, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          const Text("Chưa có Nhóm bán kèm theo nào!", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            width: 220, height: 48,
            child: ElevatedButton(
              onPressed: () {
                // --- LIÊN KẾT MỚI TẠI ĐÂY ---
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComboCreateScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Tạo nhóm bán kèm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TAB 4: DANH MỤC ---
  Widget _buildCategoryTab(BuildContext context, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.category_outlined, size: 70, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          const Text("Danh mục rõ ràng - Khách dễ mua hàng", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            width: 200, height: 48,
            child: ElevatedButton(
              onPressed: () {}, // TODO: Logic tạo danh mục
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Tạo danh mục", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER ITEMS ---
  PopupMenuItem<String> _buildPopupItem(String text) {
    bool isSelected = _selectedSort == text;
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xff289ca7) : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: isSelected ? const Color(0xff289ca7) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // --- WIDGET TAB 1: SẢN PHẨM (GIỮ NGUYÊN) ---
  Widget _buildEmptyProductState(BuildContext context, Color primaryColor, Color greyText, Color greyBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text("Chế độ xem: ${_isGridView ? 'Lưới (Grid)' : 'Danh sách (List)'}", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 30),
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(color: greyBg, shape: BoxShape.circle),
            child: Icon(Icons.plagiarism_outlined, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text("Quản lý danh sách sản phẩm giúp theo dõi thông tin giá cả và tồn kho. Tạo sản phẩm đầu tiên ngay bạn nhé!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: greyText, height: 1.5)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductCreateScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
              child: const Text("Tạo sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: BorderSide(color: primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Tạo dịch vụ theo giờ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: BorderSide(color: primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Tạo sản phẩm hàng loạt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}