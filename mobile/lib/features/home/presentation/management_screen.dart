import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/widgets/app_drawer.dart';
import 'package:mobile/features/scanner/presentation/select_scanner_bottom_sheet.dart';
import 'package:mobile/features/inbox/presentation/inbox_screen.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/models/dashboard_summary.dart';
import '../data/models/product_dto.dart';
import 'main_screen.dart';
import 'package:mobile/features/product/presentation/stock_in_screen.dart';
import 'package:mobile/features/product/presentation/product_create_screen.dart';
import 'package:mobile/features/report/presentation/report_screen.dart';
import 'package:mobile/data/repositories/debt_screen.dart';
import 'dart:convert';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardRepository _repository = DashboardRepository();
  bool _isLoading = true;
  DashboardSummary? _summary;
  List<ProductDTO> _lowStockProducts = [];
  String? _error;

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
      final summary = await _repository.getDashboardSummary();
      final lowStock = await _repository.getLowStockProducts();
      if (mounted) {
        setState(() {
          _summary = summary;
          _lowStockProducts = lowStock;
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

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.grey[50], // Light grey background
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(
                         "Không thể tải dữ liệu",
                         style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 4),
                       Text(
                         _error?.contains("401") == true 
                           ? "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại." 
                           : "Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.",
                         textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 12, color: Colors.red[800]),
                       ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchData,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text("Thử lại"),
                      )
                    ],
                  ),
                )
              else ...[
                _buildStatsGrid(),
                _buildLowStockSection(),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions, // Connected Action
        backgroundColor: const Color(0xFF3B66FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF289CA7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: _openDrawer,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, color: Color(0xFF289CA7), size: 20),
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
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      // Navigate to Product Screen for search
                      MainScreen.of(context)?.setTabIndex(2);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.white, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _openScannerSelector,
                child: _buildIconWithBadge(Icons.qr_code_scanner, "N"),
              ),
              const SizedBox(width: 10),
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
                'Tổng quan BizFlow',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(Icons.mic, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_summary == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
                  },
                  child: _buildStatCard(
                    "DOANH THU",
                    _formatCurrency(_summary!.totalRevenue),
                    "Tổng các đơn thành công",
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const StockInScreen()));
                  },
                  child: _buildStatCard(
                    "HÀNG SẮP HẾT",
                    "${_summary!.lowStockCount}",
                    "Cần nhập hàng ngay",
                    Icons.warning_amber_rounded,
                    Colors.orange,
                    isAlert: _summary!.lowStockCount > 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                 child: InkWell(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtScreen()));
                  },
                  child: _buildStatCard(
                    "CÔNG NỢ KHÁCH",
                    _formatCurrency(_summary!.pendingPayment),
                    "Số tiền chưa thu hồi",
                    Icons.people_alt_outlined,
                    Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                 child: InkWell(
                  onTap: () {
                     // Navigate to Product Tab
                     MainScreen.of(context)?.setTabIndex(2);
                  },
                  child: _buildStatCard(
                    "MÃ HÀNG",
                    "${_summary!.totalProducts}",
                    "Trong danh mục kho",
                    Icons.inventory_2_outlined,
                    Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtext, IconData icon, Color color, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
        ],
        border: isAlert ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(subtext, style: TextStyle(fontSize: 11, color: isAlert ? Colors.orange : Colors.grey)),
        ],
      ),
    );
  }

  // --- HELPER: BUILD IMAGE ---
  Widget _buildProductImage(String? imageUrl, {double size = 40}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(Icons.image, size: size, color: Colors.grey);
    }
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(imageUrl, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: size, color: Colors.grey));
      } else {
        final cleanBase64 = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
        return Image.memory(const Base64Decoder().convert(cleanBase64), width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: size, color: Colors.grey));
      }
    } catch (e) {
      return Icon(Icons.broken_image, size: size, color: Colors.grey);
    }
  }

  Widget _buildLowStockSection() {
    if (_lowStockProducts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text("Cảnh báo tồn kho thấp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text("${_lowStockProducts.length} sản phẩm", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lowStockProducts.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final product = _lowStockProducts[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Image with Helper
                      Container(
                        width: 40, height: 40,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: _buildProductImage(product.imageUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text("Tồn kho: ${product.stock} ${product.unitName ?? ''}", 
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                           // Navigate to Stock In Screen
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (_) => StockInScreen(initialProductId: product.id)),
                           ).then((_) => _fetchData()); // Refresh if returned
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text("Nhập hàng", style: TextStyle(fontSize: 12, color: Colors.blue)),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text("Thao tác nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.assignment_add, color: Colors.white)),
            title: const Text("Tạo đơn hàng mới"),
            subtitle: const Text("Chuyển đến tab Đơn hàng"),
            onTap: () {
               Navigator.pop(context);
               MainScreen.of(context)?.setTabIndex(1); 
            },
          ),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.add_box, color: Colors.white)),
            title: const Text("Thêm sản phẩm"),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (_) => const ProductCreateScreen())
               ).then((_) => _fetchData());
            },
          ),
          ListTile(
            title: const Text("Thêm khách hàng"),
            subtitle: const Text("Chuyển đến tab Khách hàng"),
            onTap: () {
               Navigator.pop(context);
               MainScreen.of(context)?.setTabIndex(3);
            },
          ),
          const SizedBox(height: 24),
        ],
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
}

