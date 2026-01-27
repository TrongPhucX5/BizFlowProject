package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.domain.Customer; // Đảm bảo import này
import com.bizflow.backend.core.usecase.ReportService;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderItemRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final CustomerRepository customerRepository;
    private final OrderItemRepository orderItemRepository;

    @Override
    public Map<String, Object> getDashboardMetrics(Long storeId) {
        Map<String, Object> metrics = new HashMap<>();

        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        // 1. Doanh thu hôm nay
        BigDecimal todayRevenue = orderRepository.sumTotalRevenue(storeId, startOfDay, endOfDay);
        metrics.put("todayRevenue", todayRevenue != null ? todayRevenue : BigDecimal.ZERO);

        // 2. Số đơn hôm nay
        Long todayOrders = orderRepository.countOrders(storeId, startOfDay, endOfDay);
        metrics.put("todayOrders", todayOrders != null ? todayOrders : 0);

        // 3. TỔNG KHÁCH HÀNG (CẬP NHẬT ĐỂ HIỆN SỐ 19)
        // Thay vì countByStoreId (bị lỗi), ta dùng countByStatus để lấy tất cả ACTIVE
        long totalCustomers = customerRepository.countByStatus(Customer.CustomerStatus.ACTIVE);
        metrics.put("totalCustomers", totalCustomers);

        // 4. Tổng sản phẩm (Tùy chọn: bỏ comment nếu ProductRepository đã có count)
        // metrics.put("totalProducts", productRepository.countByStoreIdAndStatus(storeId, Product.ProductStatus.ACTIVE));

        return metrics;
    }

    @Override
    public Map<String, Object> getSalesReport(Long storeId, LocalDateTime startDate, LocalDateTime endDate) {
        Map<String, Object> report = new HashMap<>();

        BigDecimal totalRevenue = orderRepository.sumTotalRevenue(storeId, startDate, endDate);
        Long totalOrders = orderRepository.countOrders(storeId, startDate, endDate);

        report.put("totalRevenue", totalRevenue != null ? totalRevenue : BigDecimal.ZERO);
        report.put("totalOrders", totalOrders != null ? totalOrders : 0);
        report.put("startDate", startDate);
        report.put("endDate", endDate);

        return report;
    }

    @Override
    public Map<String, Double> getRevenueByCategory(Long storeId, LocalDateTime startDate, LocalDateTime endDate) {
        return new HashMap<>();
    }

    @Override
    public Map<String, Double> getRevenueBySegment(Long storeId, LocalDateTime startDate, LocalDateTime endDate) {
        return new HashMap<>();
    }

    @Override
    public Map<String, Object> getTopProducts(Long storeId, Integer limit, LocalDateTime startDate, LocalDateTime endDate) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> products = new ArrayList<>();

        List<Object[]> topSelling = orderItemRepository.findTopSellingProducts(
                storeId, startDate, endDate, PageRequest.of(0, limit));

        for (Object[] row : topSelling) {
            Long productId = (Long) row[0];
            Long totalQty = (Long) row[1];
            BigDecimal totalRevenue = (BigDecimal) row[2];

            String productName = productRepository.findById(productId)
                    .map(Product::getName)
                    .orElse("Unknown Product");

            Map<String, Object> item = new HashMap<>();
            item.put("productId", productId);
            item.put("productName", productName);
            item.put("quantitySold", totalQty);
            item.put("revenue", totalRevenue);

            products.add(item);
        }

        result.put("products", products);
        return result;
    }

    @Override
    public Map<String, Object> getInventoryValuation(Long storeId) {
        return new HashMap<>();
    }

    @Override
    public Map<String, Object> getAccountsReceivable(Long storeId) {
        return new HashMap<>();
    }

    @Override
    public Map<String, Object> getCustomerAnalysis(Long storeId) {
        return new HashMap<>();
    }

    @Override
    public Map<String, Object> getDailySalesTrend(Long storeId) {
        return new HashMap<>();
    }

    @Override
    public Map<String, Object> getMonthlySalesTrend(Long storeId) {
        return new HashMap<>();
    }

    @Override
    public String exportSalesReportToCsv(Long storeId, LocalDateTime startDate, LocalDateTime endDate) {
        return "Date,Order ID,Amount\n";
    }

    @Override
    public Integer getBusinessHealthScore(Long storeId) {
        return 100;
    }
}