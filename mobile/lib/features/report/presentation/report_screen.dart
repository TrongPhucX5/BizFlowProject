import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/repositories/report_repository.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportRepository _reportRepository = ReportRepository();
  
  bool _isLoading = true;
  String _selectedPeriod = 'week';
  
  // Stats data
  double _revenueToday = 0;
  int _ordersToday = 0;
  double _totalDebt = 0;
  int _warningProducts = 0;
  
  // Revenue chart data
  List<Map<String, dynamic>> _revenueData = [];
  
  // Best selling products
  List<Map<String, dynamic>> _bestSelling = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _reportRepository.getDashboardStats(),
        _reportRepository.getRevenueData(period: _selectedPeriod),
        _reportRepository.getBestSellingProducts(),
      ]);
      
      final stats = results[0] as Map<String, dynamic>;
      final revenue = results[1] as List<Map<String, dynamic>>;
      final bestSelling = results[2] as List<Map<String, dynamic>>;
      
      if (mounted) {
        setState(() {
          _revenueToday = (stats['revenueToday'] ?? 0).toDouble();
          _ordersToday = (stats['ordersToday'] ?? 0).toInt();
          _totalDebt = (stats['totalDebt'] ?? 0).toDouble();
          _warningProducts = (stats['warningProducts'] ?? 0).toInt();
          
          _revenueData = revenue;
          _bestSelling = bestSelling;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi load report: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Báo cáo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    _buildStatsGrid(primaryBlue),
                    const SizedBox(height: 24),
                    
                    // Period Selector
                    _buildPeriodSelector(primaryBlue),
                    const SizedBox(height: 16),
                    
                    // Revenue Chart
                    _buildRevenueChart(primaryBlue),
                    const SizedBox(height: 24),
                    
                    // Best Selling Products
                    _buildBestSellingSection(primaryBlue),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid(Color primaryBlue) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Doanh thu hôm nay',
          _formatCurrency(_revenueToday),
          Icons.trending_up,
          Colors.green,
        ),
        _buildStatCard(
          'Đơn hàng hôm nay',
          _ordersToday.toString(),
          Icons.receipt_long,
          primaryBlue,
        ),
        _buildStatCard(
          'Tổng công nợ',
          _formatCurrency(_totalDebt),
          Icons.account_balance_wallet,
          Colors.orange,
        ),
        _buildStatCard(
          'Cảnh báo tồn kho',
          _warningProducts.toString(),
          Icons.warning_amber,
          _warningProducts > 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(Color primaryBlue) {
    return Row(
      children: [
        _buildPeriodChip('Tuần', 'week', primaryBlue),
        const SizedBox(width: 8),
        _buildPeriodChip('Tháng', 'month', primaryBlue),
        const SizedBox(width: 8),
        _buildPeriodChip('Năm', 'year', primaryBlue),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value, Color primaryBlue) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart(Color primaryBlue) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biểu đồ doanh thu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.bar_chart, color: primaryBlue),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_revenueData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Chưa có dữ liệu doanh thu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: _buildSimpleBarChart(primaryBlue),
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(Color primaryBlue) {
    // Simple bar chart without fl_chart dependency
    final maxRevenue = _revenueData.isNotEmpty
        ? _revenueData.map((e) => (e['totalAmount'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b)
        : 1.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _revenueData.take(7).map((item) {
        final revenue = (item['totalAmount'] ?? 0).toDouble();
        final height = maxRevenue > 0 ? (revenue / maxRevenue) * 150 : 0.0;
        final date = item['date']?.toString().substring(5, 10) ?? '';
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBestSellingSection(Color primaryBlue) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top sản phẩm bán chạy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.star, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_bestSelling.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Chưa có dữ liệu sản phẩm',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bestSelling.take(5).length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final product = _bestSelling[index];
                final rank = index + 1;
                
                return Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rank <= 3 
                            ? (rank == 1 ? Colors.amber : rank == 2 ? Colors.grey[400] : Colors.brown[300])
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        rank.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rank <= 3 ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'Sản phẩm',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Đã bán: ${product['sales'] ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Revenue
                    Text(
                      _formatCurrency((product['revenue'] ?? 0).toDouble()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
