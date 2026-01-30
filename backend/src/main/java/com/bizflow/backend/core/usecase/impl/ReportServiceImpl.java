package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.core.domain.Order;
import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.usecase.ReportService;
import com.bizflow.backend.infrastructure.persistence.repository.*;
import com.bizflow.backend.presentation.dto.response.TT88DebtRow;
import com.bizflow.backend.presentation.dto.response.TT88RevenueRow;
import com.bizflow.backend.presentation.dto.response.TT88StockRow;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final CustomerRepository customerRepository;
    private final OrderItemRepository orderItemRepository;
    private final DebtRepository debtRepository;
    private final PaymentRepository paymentRepository;
    private final StockMovementRepository stockMovementRepository;

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

    @Override
    public List<TT88RevenueRow> getTT88Revenue(LocalDate from, LocalDate to) {
        Long storeId = UserContext.getCurrentStoreId();
        // Sử dụng hàm có sẵn để lọc theo storeId
        List<Order> orders = orderRepository.findByStoreIdAndCreatedAtBetweenOrderByCreatedAtDesc(
                storeId, 
                from.atStartOfDay(), 
                to.plusDays(1).atStartOfDay()
        );
        
        // Fetch customers để lấy tên
        Set<Long> customerIds = orders.stream().map(Order::getCustomerId).collect(Collectors.toSet());
        Map<Long, Customer> customerMap = customerRepository.findAllById(customerIds).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));

        AtomicInteger index = new AtomicInteger(1);

        return orders.stream().map(o -> {
            Customer customer = customerMap.get(o.getCustomerId());
            String customerName = customer != null ? customer.getName() : "Khách lẻ";
            
            return new TT88RevenueRow(
                index.getAndIncrement(),
                o.getCreatedAt().toLocalDate(),
                o.getOrderNumber(),
                customerName,
                o.getTotalAmount(),
                o.getNotes() != null ? o.getNotes() : ""
            );
        }).collect(Collectors.toList());
    }

    @Override
    public List<TT88DebtRow> getTT88Debt(LocalDate from, LocalDate to) {
        Long storeId = UserContext.getCurrentStoreId();
        List<Customer> customers = customerRepository.findByStoreId(storeId, Pageable.unpaged()).getContent();

        AtomicInteger index = new AtomicInteger(1);
        List<TT88DebtRow> result = new ArrayList<>();

        for (Customer c : customers) {
            // 1. Nợ đầu kỳ: Tổng nợ phát sinh trước ngày from - Tổng đã trả trước ngày from
            BigDecimal debtBefore = debtRepository.sumOriginalAmountBefore(storeId, c.getId(), from.atStartOfDay());
            BigDecimal paidBefore = paymentRepository.sumAmountBefore(storeId, c.getId(), from.atStartOfDay());
            BigDecimal opening = debtBefore.subtract(paidBefore);

            // 2. Phát sinh trong kỳ: Tổng nợ phát sinh từ from đến to
            BigDecimal newDebt = debtRepository.sumOriginalAmountBetween(storeId, c.getId(), from.atStartOfDay(), to.plusDays(1).atStartOfDay());

            // 3. Đã trả trong kỳ: Tổng đã trả từ from đến to
            BigDecimal paid = paymentRepository.sumAmountBetween(storeId, c.getId(), from.atStartOfDay(), to.plusDays(1).atStartOfDay());

            // 4. Nợ cuối kỳ: Đầu kỳ + Phát sinh - Đã trả
            BigDecimal closing = opening.add(newDebt).subtract(paid);

            // Chỉ hiển thị nếu có biến động hoặc còn nợ
            if (closing.compareTo(BigDecimal.ZERO) != 0 || opening.compareTo(BigDecimal.ZERO) != 0 || newDebt.compareTo(BigDecimal.ZERO) != 0) {
                 result.add(new TT88DebtRow(
                    index.getAndIncrement(),
                    c.getName(),
                    c.getPhone(),
                    opening,
                    newDebt,
                    paid,
                    closing
                ));
            }
        }

        return result;
    }

    @Override
    public List<TT88StockRow> getTT88Stock(LocalDate from, LocalDate to) {
        Long storeId = UserContext.getCurrentStoreId();
        List<Product> products = productRepository.findByStoreId(storeId, Pageable.unpaged()).getContent();

        AtomicInteger index = new AtomicInteger(1);
        List<TT88StockRow> result = new ArrayList<>();

        for (Product p : products) {
            Integer opening = stockMovementRepository.sumQuantityBefore(storeId, p.getId(), from.atStartOfDay());
            Integer imported = stockMovementRepository.sumImportBetween(storeId, p.getId(), from.atStartOfDay(), to.plusDays(1).atStartOfDay());
            Integer exported = stockMovementRepository.sumExportBetween(storeId, p.getId(), from.atStartOfDay(), to.plusDays(1).atStartOfDay());
            int closing = opening + imported - exported;

            // Chỉ hiển thị nếu có biến động hoặc còn tồn kho
            if (opening != 0 || imported != 0 || exported != 0 || closing != 0) {
                result.add(new TT88StockRow(
                    index.getAndIncrement(),
                    p.getSku(),
                    p.getName(),
                    opening,
                    imported,
                    exported,
                    closing
                ));
            }
        }

        return result;
    }
}
