import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:mobile/common/widgets/app_drawer.dart';
import 'package:mobile/features/scanner/presentation/select_scanner_bottom_sheet.dart';
import 'package:mobile/features/inbox/presentation/inbox_screen.dart';
import 'package:mobile/data/repositories/report_repository.dart';
import '../data/models/dashboard_summary.dart';
import '../data/models/product_dto.dart';
import 'main_screen.dart';
import 'package:mobile/features/product/presentation/stock_in_screen.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/features/report/presentation/report_screen.dart';
import 'package:mobile/data/repositories/debt_screen.dart';
import 'package:mobile/features/order/presentation/manual_order_screen.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ReportRepository _repository = ReportRepository();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = true;
  DashboardSummary _summary = DashboardSummary.zero();

  List<ProductDTO> _lowStockProducts = [];
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _topProducts = [];

  String? _error;
  String _userName = 'Người dùng';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await _repository.getDashboardStats();
      print("DEBUG: Dashboard stats received: $stats");

      final revenue = await _repository.getRevenueData();
      final top = await _repository.getBestSellingProducts();
      final userData = await _authRepository.getCurrentUser();

      // Mock low stock for now since ReportRepository might not have it, or we use warningProducts count
      // Ideally we should have a getLowStockProducts in Inventory/Product Repository
      // For now let's leave _lowStockProducts empty or fetch if we had the repo
      
        if (mounted) {
          setState(() {
            // Lấy dữ liệu thô từ map
            final dynamic rawRevenueToday = stats['revenueToday'];
            final dynamic rawWarningProducts = stats['warningProducts'] ?? stats['lowStockCount'];
            final dynamic rawTotalDebt = stats['totalDebt'] ?? stats['pendingPayment'];
            final dynamic rawTotalProducts = stats['totalProducts'];
            final dynamic rawTotalStock = stats['totalStock'];

            // Ép kiểu an toàn tuyệt đối
            _summary = DashboardSummary(
              totalRevenue: double.tryParse((rawRevenueToday ?? 0).toString()) ?? 0.0,
              lowStockCount: int.tryParse((rawWarningProducts ?? 0).toString()) ?? 0,
              pendingPayment: double.tryParse((rawTotalDebt ?? 0).toString()) ?? 0.0,
              totalProducts: int.tryParse((rawTotalProducts ?? 0).toString()) ?? 0,
              totalStock: int.tryParse((rawTotalStock ?? 0).toString()) ?? 0,
            );


            _revenueData = revenue;
            _topProducts = top;

            if (userData != null) {
              _userName = userData['fullName'] ?? 'Người dùng';
              _userRole = _mapRole(userData['role'] ?? '');
            }
            _isLoading = false;
          });
        }

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _openScannerSelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectScannerBottomSheet(),
    );
  }

  void _openInbox() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen()));
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        displacement: 100,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildFlatHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(60.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _buildErrorState()
                    else ...[
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      _buildBentoStatsGrid(),
                      const SizedBox(height: 24),
                      _buildLowStockBento(), // Keeps UI but list might be empty if not fetched
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text("Tạo nhanh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildFlatHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.notes_rounded, size: 28),
        onPressed: _openDrawer,
      ),
      centerTitle: true,
      title: const Text("BizFlow", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      actions: [
        IconButton(onPressed: _openScannerSelector, icon: _buildIconWithBadge(Icons.qr_code_scanner_rounded, "")),
        IconButton(onPressed: _openInbox, icon: _buildIconWithBadge(Icons.notifications_none_rounded, "1")),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Xin chào, ", style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const Text("👋", style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "$_userName${_userRole.isNotEmpty ? ' ($_userRole)' : ''}", 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                "Hôm nay bạn có ${_summary?.lowStockCount ?? 0} sản phẩm cần nhập kho",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoStatsGrid() {


    return Column(
      children: [
        // Main Revenue Highlight
        _buildBentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TỔNG DOANH THU", style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const Icon(Icons.auto_graph_rounded, color: Color(0xFF2563EB), size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(_formatCurrency(_summary?.totalRevenue ?? 0.0), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF2563EB))),

              const SizedBox(height: 4),
              const Text("Dựa trên tất cả đơn hàng đã chốt", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
        ),
        const SizedBox(height: 16),
        
        const SizedBox(height: 16),
        // Sections removed to avoid redundancy with ReportScreen
        
        // Secondary Grid

        // Secondary Grid
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 24),
                    const SizedBox(height: 12),
                    Text("${_summary?.lowStockCount ?? 0}", style: Theme.of(context).textTheme.titleLarge),

                    const Text("Sắp hết hàng", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () => MainScreen.of(context)?.navigateToLowStock(), // Chuyển sang tab Kho và lọc hàng sắp hết
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warehouse_outlined, color: Colors.purple, size: 24),
                    const SizedBox(height: 12),
                    Text("${_summary?.totalStock ?? 0}", style: Theme.of(context).textTheme.titleLarge),

                    const Text("Tổng tồn kho", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () => MainScreen.of(context)?.navigateToInventory(), // Chuyển sang tab Kho và chọn Tab Tồn kho
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBentoCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.red, size: 24),
                  const SizedBox(height: 12),
                  Text(_formatCurrency(_summary?.pendingPayment ?? 0.0), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),

                  const Text("Tổng công nợ cần thu", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtScreen())),
        ),

        
        const SizedBox(height: 24),
        _buildSectionHeader("Phát triển kinh doanh"),
        const SizedBox(height: 12),
        _buildBentoCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFACC15).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFCA8A04), size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mẹo: Tăng doanh số", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                    SizedBox(height: 2),
                    Text("Sử dụng mã giảm giá cho khách hàng thân thiết để tăng 20% tỷ lệ quay lại.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSimpleBarChart() {
    if (_revenueData.isEmpty) return const Center(child: Text("Chưa có dữ liệu"));
    
    // Find max value
    double maxVal = 1;
    for (var item in _revenueData) {
      double val = double.tryParse(item['totalAmount']?.toString() ?? '0') ?? 0;
      if (val > maxVal) maxVal = val;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _revenueData.map((item) {
        double val = double.tryParse(item['totalAmount']?.toString() ?? '0') ?? 0;
        double h = (val / maxVal) * 120; // 120 is max height
        if (h < 4) h = 4; 

        String label = item['date'] ?? '';
        try {
           final dt = DateTime.parse(label); 
           label = "${dt.day}/${dt.month}";
        } catch (_) {}

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 24,
              height: h,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        );
      }).toList(),
    );
  }

  String _mapRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return 'Quản trị viên';
      case 'OWNER': return 'Chủ cửa hàng';
      case 'EMPLOYEE': return 'Nhân viên';
      default: return role;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.2),
    );
  }

  Widget _buildBentoCard({required Widget child, required VoidCallback onTap, EdgeInsets padding = const EdgeInsets.all(20)}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildLowStockBento() {
    if (_summary == null || _lowStockProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Hàng hóa thiếu hụt", style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        _buildBentoCard(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockInScreen())),
          child: Column(
            children: [
              ...List.generate(min(_lowStockProducts.length, 3), (index) {
                final p = _lowStockProducts[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                        child: _buildProductImage(p.imageUrl, size: 32),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text("Tồn kho: ${p.stock}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12)),
                      trailing: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: Color(0xFF2563EB)),
                    ),
                    if (index < min(_lowStockProducts.length, 3) - 1)
                      const Divider(height: 1, indent: 70, color: Color(0xFFF1F5F9)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String? imageUrl, {double size = 40}) {
    if (imageUrl == null || imageUrl.isEmpty) return Icon(Icons.image_outlined, size: size, color: Colors.grey);
    try {
      if (imageUrl.startsWith('http')) return Image.network(imageUrl, width: size, height: size, fit: BoxFit.cover);
      return Image.memory(const Base64Decoder().convert(imageUrl.split(',').last), width: size, height: size, fit: BoxFit.cover);
    } catch (_) {
      return Icon(Icons.broken_image_outlined, size: size, color: Colors.grey);
    }
  }

  Widget _buildIconWithBadge(IconData icon, String label) {
    return Stack(
      children: [
        Icon(icon, size: 24),
        if (label.isNotEmpty)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text("Không thể kết nối dữ liệu", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchData, child: const Text("Thử lại")),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thao tác nhanh", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
            const SizedBox(height: 20),
            _buildActionItem(Icons.receipt_long_rounded, "Tạo đơn hàng", "Thanh toán cho khách hàng", Colors.blue, 
              () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualOrderScreen())); }),
            const SizedBox(height: 12),
            _buildActionItem(Icons.add_box_rounded, "Thêm sản phẩm", "Cập nhật kho hàng của bạn", Colors.teal, 
              () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductCreateScreen())); }),
            const SizedBox(height: 12),
            _buildActionItem(Icons.person_add_alt_1_rounded, "Thêm khách hàng", "Lưu thông tin khách hàng mới", Colors.orange, 
              () { Navigator.pop(ctx); MainScreen.of(context)?.setTabIndex(3); }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
