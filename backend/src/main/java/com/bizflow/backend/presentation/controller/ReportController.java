package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderItemRepository;
import com.bizflow.backend.infrastructure.persistence.repository.DebtRepository;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.presentation.dto.response.RevenueChartDto;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import com.bizflow.backend.core.common.UserContext;

@RestController
@RequestMapping("/v1/reports") // Khớp với axiosClient
@CrossOrigin(origins = "*")
public class ReportController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final DebtRepository debtRepository;
    private final ProductRepository productRepository;

    public ReportController(OrderRepository orderRepository, 
                           OrderItemRepository orderItemRepository,
                           DebtRepository debtRepository,
                           ProductRepository productRepository) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.debtRepository = debtRepository;
        this.productRepository = productRepository;
    }

    // 1. API DOANH THU (BIỂU ĐỒ)
    @GetMapping("/revenue")
    public ResponseEntity<?> getRevenueReport(@RequestParam(defaultValue = "week") String period) {
        Long storeId = UserContext.getCurrentStoreId(); // Lấy từ UserContext để đảm bảo bảo mật đa chi nhánh
        LocalDateTime endDate = LocalDateTime.now();
        LocalDateTime startDate = calculateStartDate(period, endDate);

        List<RevenueChartDto> data = orderRepository.getRevenueChartData(storeId, startDate, endDate);

        // Map DTO sang JSON: { date: "2023-01-01", totalAmount: 100000, orderCount: 5 }
        List<Map<String, Object>> result = new ArrayList<>();
        for (RevenueChartDto row : data) {
            Map<String, Object> item = new HashMap<>();
            item.put("date", row.getDate().toString());
            item.put("totalAmount", row.getRevenue());
            item.put("orderCount", row.getOrderCount());
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    // 2. API THỐNG KÊ TỔNG QUAN (4 ô vuông đầu trang)
    @GetMapping("/dashboard-stats")
    public ResponseEntity<?> getDashboardStats() {
        Long storeId = UserContext.getCurrentStoreId();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startToday = LocalDate.now().atStartOfDay();

        BigDecimal revenueToday = orderRepository.sumTotalRevenue(storeId, startToday, now);
        Long ordersToday = orderRepository.countOrders(storeId, startToday, now);
        
        // Lấy tổng công nợ thật từ DebtRepository (UNPAID + PAID_PARTIAL)
        BigDecimal totalDebt = debtRepository.sumByStoreIdAndStatusIn(storeId, 
                Arrays.asList(com.bizflow.backend.core.domain.Debt.DebtStatus.UNPAID, 
                              com.bizflow.backend.core.domain.Debt.DebtStatus.PAID_PARTIAL));
        
        // Đếm số sản phẩm có số lượng tồn kho <= mức tối thiểu (reorderLevel)
        // Giả sử reorderLevel trung bình là 10
        long warningProducts = productRepository.countByStoreIdAndStockQuantityLessThanEqual(storeId, 10);

        Map<String, Object> stats = new HashMap<>();
        stats.put("revenueToday", revenueToday.doubleValue());
        stats.put("ordersToday", ordersToday);
        stats.put("totalDebt", totalDebt.doubleValue());
        stats.put("warningProducts", warningProducts);

        return ResponseEntity.ok(stats);
    }

    // 3. API TOP SẢN PHẨM BÁN CHẠY
    @GetMapping("/best-selling")
    public ResponseEntity<?> getBestSelling() {
        Long storeId = UserContext.getCurrentStoreId();
        // Lấy 30 ngày gần nhất
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(30);

        // Gọi Repo lấy Top 10
        List<Object[]> topData = orderItemRepository.findTopSellingProducts(storeId, start, end, PageRequest.of(0, 10));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Object[] row : topData) {
            Map<String, Object> item = new HashMap<>();
            // row[0]=productId, row[1]=productName, row[2]=qty, row[3]=revenue
            item.put("productId", row[0]);
            item.put("name", row[1] != null ? row[1] : "Sản phẩm #" + row[0]); // Fallback nếu không có tên
            item.put("sales", row[2]);
            item.put("revenue", row[3]);
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    // Hàm phụ tính ngày bắt đầu
    private LocalDateTime calculateStartDate(String period, LocalDateTime endDate) {
        switch (period) {
            case "today":
                return LocalDate.now().atStartOfDay();
            case "week":
                return endDate.minusDays(7);
            case "month":
                return endDate.minusDays(30);
            case "year":
                return endDate.minusDays(365);
            default:
                return endDate.minusDays(7);
        }
    }
}